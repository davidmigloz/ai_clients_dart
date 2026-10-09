// Copyright 2026 OpenAI.
// SPDX-License-Identifier: Apache-2.0
// Adapted from OpenAI's Live transcript helpers for Dart by ai_clients_dart
// contributors. See THIRD_PARTY_NOTICES.md and licenses/openai-sdk-apache-2.0.txt.

import 'dart:math' as math;

import 'live_transcript_values.dart';

/// Pure port of the official SDK public-transcript grouping policy.
///
/// Call [process] with delivery-ordered fragments sharing a source interval, and
/// [advance] with elapsed source time. This class has no clock, timer, transport,
/// audio, server turn IDs or callbacks. Brief acknowledgments can be suppressed;
/// original raw events remain the caller's source of truth.
final class LiveTranscriptGrouping {
  /// Creates a policy with a unique local [idPrefix], never a server identifier.
  LiveTranscriptGrouping({
    LiveTranscriptOptions? options,
    String idPrefix = 'segment',
  }) : options = options ?? LiveTranscriptOptions(),
       _idPrefix = idPrefix {
    if (idPrefix.isEmpty) throw ArgumentError('idPrefix must not be empty.');
    _acknowledgments = [
      ..._builtInAcknowledgments,
      ...this.options.additionalAcknowledgments
          .map(_normalizeAcknowledgment)
          .where((phrase) => phrase.isNotEmpty),
    ];
    _maxAcknowledgmentLength = _acknowledgments.fold(
      0,
      (length, phrase) => math.max(length, phrase.length),
    );
  }

  /// Copied, immutable timing and acknowledgment configuration.
  final LiveTranscriptOptions options;
  final String _idPrefix;
  late final List<String> _acknowledgments;
  late final int _maxAcknowledgmentLength;
  _Turn? _current;
  _Turn? _buffered;
  String? _lastId;
  var _nextId = 0;
  int? _lastAssistantEnd;

  /// Current projected speaker, or null without an open segment.
  LiveTranscriptSpeaker? get speaker => _current?.speaker;

  /// Processes one delivery batch, preferring the current speaker on overlap.
  List<LiveTranscriptUpdate> process(List<LiveTranscriptFragment> fragments) {
    final preferred = _current?.speaker ?? LiveTranscriptSpeaker.user;
    final ordered = [
      ...fragments.where((fragment) => fragment.speaker == preferred),
      ...fragments.where((fragment) => fragment.speaker != preferred),
    ];
    final updates = <LiveTranscriptUpdate>[];
    if (ordered.isEmpty) return const [];
    final first = ordered.first;
    var nextDeadline = deadline;
    while (nextDeadline != null && nextDeadline < first.startMs) {
      updates.addAll(advance(nextDeadline));
      nextDeadline = deadline;
    }
    if (_current != null &&
        !ordered.any((fragment) => fragment.speaker == _current!.speaker)) {
      updates.addAll(
        advance(
          first.startMs.toDouble(),
          hasIncomingUser: ordered.any(
            (fragment) => fragment.speaker == LiveTranscriptSpeaker.user,
          ),
        ),
      );
    }
    for (final fragment in ordered) {
      updates.addAll(_ingest(fragment));
    }
    return List.unmodifiable(updates);
  }

  /// Resolves separation, backchannel isolation and assistant inactivity.
  List<LiveTranscriptUpdate> advance(
    double sourceMs, {
    bool hasIncomingUser = false,
  }) {
    _validSourceTime(sourceMs);
    if (_current != null &&
        _buffered != null &&
        sourceMs >= _current!.endMs + options.minTurnSeparationMs &&
        !_keepBackchannel(sourceMs)) {
      _buffered = _maybeDropBackchannel(sourceMs);
      if (_buffered != null) return List.unmodifiable(_promote());
    }
    if (_current?.speaker == LiveTranscriptSpeaker.assistant &&
        !hasIncomingUser &&
        sourceMs >= _current!.endMs + options.assistantSilenceMs) {
      return List.unmodifiable(
        _finishCurrent(LiveTranscriptCloseReason.inactivity),
      );
    }
    return const [];
  }

  /// Next source-time decision, or null when no inactivity timer is needed.
  double? get deadline {
    if (_current == null) return null;
    if (_buffered != null) {
      final separation = _current!.endMs + options.minTurnSeparationMs;
      if (_mightBeBackchannel &&
          _buffered!.canDropAsBackchannel &&
          !_userContinued &&
          !_recentAssistant) {
        return math.max(
          separation,
          _buffered!.endMs + options.backchannelIsolationMs,
        );
      }
      return separation;
    }
    return _current!.speaker == LiveTranscriptSpeaker.assistant
        ? _current!.endMs + options.assistantSilenceMs
        : null;
  }

  /// Finalizes open/buffered display text according to the grouping policy.
  ///
  /// Finishing does not make this pure policy unusable. IDs and predecessor links
  /// continue when further fragments arrive; timestamp reset clears old assistant
  /// isolation state. The clock-driven grouper separately owns its closed guard.
  List<LiveTranscriptUpdate> finish(
    double sourceMs, {
    LiveTranscriptCloseReason reason = LiveTranscriptCloseReason.manual,
  }) {
    _validSourceTime(sourceMs);
    final buffered = _maybeDropBackchannel(sourceMs);
    final updates = _finishCurrent(reason);
    _buffered = null;
    if (buffered != null && buffered.text.isNotEmpty) {
      updates
        ..addAll(_emit(buffered))
        ..addAll(_finish(buffered, reason));
    }
    if (reason == LiveTranscriptCloseReason.timestampReset) {
      _lastAssistantEnd = null;
    }
    return List.unmodifiable(updates);
  }

  List<LiveTranscriptUpdate> _ingest(LiveTranscriptFragment fragment) {
    if (_current == null) {
      _current = _newTurn(fragment);
      return _emit(_current!);
    }
    if (fragment.speaker == _current!.speaker) {
      _append(_current!, fragment, separate: _buffered != null);
      return _emit(_current!);
    }
    if (_current!.speaker == LiveTranscriptSpeaker.user && _userContinued) {
      _buffered = null;
    }
    final separation = fragment.startMs - _current!.endMs;
    if (_current!.speaker == LiveTranscriptSpeaker.assistant) {
      _buffer(fragment);
      return _promote();
    }
    final withinDuration =
        fragment.endMs - (_buffered?.startMs ?? fragment.startMs) <
        options.backchannelMaxDurationMs;
    final acknowledgment = _acknowledgment(fragment, withinDuration);
    final normalized = withinDuration ? acknowledgment.text : null;
    if (separation < options.minTurnSeparationMs) {
      _buffer(
        fragment,
        canDrop:
            normalized != null &&
            normalized.isNotEmpty &&
            _acknowledgments.any((phrase) => phrase.startsWith(normalized)),
        acknowledgment: acknowledgment,
      );
      return [];
    }
    if (normalized != null && _acknowledgments.contains(normalized)) {
      _buffer(
        fragment,
        canDrop: _buffered != null,
        acknowledgment: acknowledgment,
      );
      return [];
    }
    _buffered = _maybeDropBackchannel(null, fragment);
    final updates = _finishCurrent(LiveTranscriptCloseReason.speakerChange);
    if (_buffered != null) {
      _current = _buffered;
      _buffered = null;
      _append(_current!, fragment);
    } else {
      _current = _newTurn(fragment);
    }
    updates.addAll(_emit(_current!));
    return updates;
  }

  _Turn _newTurn(LiveTranscriptFragment fragment) =>
      _Turn(fragment, '${_idPrefix}_${_nextId++}');

  static void _append(
    _Turn turn,
    LiveTranscriptFragment fragment, {
    bool separate = false,
  }) {
    final separator =
        separate &&
            _wordBoundary(turn.text, atEnd: true) &&
            _wordBoundary(fragment.text, atEnd: false)
        ? ' '
        : '';
    turn
      ..text += separator + fragment.text
      ..endMs = math.max(turn.endMs, fragment.endMs);
  }

  void _buffer(
    LiveTranscriptFragment fragment, {
    bool? canDrop,
    _Acknowledgment? acknowledgment,
  }) {
    if (_buffered != null) {
      _append(_buffered!, fragment);
    } else {
      _buffered = _newTurn(fragment);
    }
    if (canDrop != null) _buffered!.canDropAsBackchannel = canDrop;
    _buffered!.acknowledgment = acknowledgment;
  }

  List<LiveTranscriptUpdate> _promote() {
    if (_buffered == null) return [];
    final updates = _finishCurrent(LiveTranscriptCloseReason.speakerChange);
    _current = _buffered;
    _buffered = null;
    updates.addAll(_emit(_current!));
    return updates;
  }

  List<LiveTranscriptUpdate> _finishCurrent(LiveTranscriptCloseReason reason) {
    final current = _current;
    _current = null;
    return current == null ? [] : _finish(current, reason);
  }

  List<LiveTranscriptUpdate> _finish(
    _Turn turn,
    LiveTranscriptCloseReason reason,
  ) {
    if (turn.speaker == LiveTranscriptSpeaker.assistant) {
      _lastAssistantEnd = turn.endMs;
    }
    return turn.emitted
        ? [LiveTranscriptUpdate(segment: turn.snapshot, reason: reason)]
        : [];
  }

  List<LiveTranscriptUpdate> _emit(_Turn turn) {
    if (turn.text.isEmpty) return [];
    if (!turn.emitted) {
      turn.previousId = _lastId;
      _lastId = turn.id;
      turn.emitted = true;
    }
    return [LiveTranscriptUpdate(segment: turn.snapshot)];
  }

  bool get _mightBeBackchannel =>
      _current?.speaker == LiveTranscriptSpeaker.user &&
      _buffered?.speaker == LiveTranscriptSpeaker.assistant &&
      _buffered!.endMs - _buffered!.startMs < options.backchannelMaxDurationMs;

  bool get _userContinued =>
      _mightBeBackchannel &&
      _buffered!.canDropAsBackchannel &&
      _current!.endMs > _buffered!.endMs;

  bool get _recentAssistant =>
      _current != null &&
      _buffered != null &&
      _lastAssistantEnd != null &&
      _buffered!.startMs - _lastAssistantEnd! <
          options.backchannelIsolationMs &&
      _buffered!.startMs <= _current!.startMs;

  bool _keepBackchannel(double timeMs) =>
      _mightBeBackchannel &&
      _buffered!.canDropAsBackchannel &&
      !_userContinued &&
      !_recentAssistant &&
      timeMs < _buffered!.endMs + options.backchannelIsolationMs;

  _Turn? _maybeDropBackchannel([double? timeMs, LiveTranscriptFragment? next]) {
    if (!_mightBeBackchannel || _buffered == null) return _buffered;
    if (_userContinued) return null;
    if (_recentAssistant) return _buffered;
    if (next != null &&
        next.startMs < _buffered!.endMs + options.backchannelIsolationMs) {
      return _buffered;
    }
    if (next == null &&
        (timeMs == null ||
            timeMs < _buffered!.endMs + options.backchannelIsolationMs)) {
      return _buffered;
    }
    return _buffered!.canDropAsBackchannel ? null : _buffered;
  }

  _Acknowledgment _acknowledgment(
    LiveTranscriptFragment fragment,
    bool withinDuration,
  ) {
    final previous = _buffered?.acknowledgment;
    final previousCharacters = previous?.characters ?? 0;
    var characters = previousCharacters;
    for (
      var index = 0;
      index < fragment.text.length && characters <= _maxAcknowledgmentLength;
      index++
    ) {
      if (!_ackSeparator.hasMatch(fragment.text[index])) characters++;
    }
    String? text;
    if (characters == previousCharacters && previous?.text != null) {
      text = previous!.text;
    } else if (withinDuration && characters <= _maxAcknowledgmentLength) {
      text = _normalizeAcknowledgment((_buffered?.text ?? '') + fragment.text);
    }
    return _Acknowledgment(characters, text);
  }
}

final class _Turn {
  _Turn(LiveTranscriptFragment fragment, this.id)
    : speaker = fragment.speaker,
      text = fragment.text,
      startMs = fragment.startMs,
      endMs = fragment.endMs;

  final LiveTranscriptSpeaker speaker;
  String text;
  final int startMs;
  int endMs;
  final String id;
  String? previousId;
  bool emitted = false;
  bool canDropAsBackchannel = true;
  _Acknowledgment? acknowledgment;

  LiveTranscriptSegment get snapshot => LiveTranscriptSegment(
    id: id,
    previousId: previousId,
    speaker: speaker,
    text: text,
    startMs: startMs,
    endMs: endMs,
  );
}

final class _Acknowledgment {
  const _Acknowledgment(this.characters, this.text);
  final int characters;
  final String? text;
}

const _builtInAcknowledgments = [
  'aha',
  'alright',
  'gotcha',
  'hm',
  'hmm',
  'mhm',
  'mm',
  'mm hmm',
  'okay',
  'ok',
  'right',
  'sure',
  'uh huh',
  'yeah',
  'yep',
  'yes',
];

// ECMAScript whitespace deliberately includes BOM and excludes U+0085/U+001C.
const _spaceAscii = '\u0009\u000a\u000b\u000c\u000d\u0020\u00a0\u1680';
const _spaceUnicode = '\u2000\u2001\u2002\u2003\u2004\u2005\u2006\u2007\u2008';
const _spaceOther = '\u2009\u200a\u2028\u2029\u202f\u205f\u3000\ufeff';
const _whitespace = '$_spaceAscii$_spaceUnicode$_spaceOther';
final _trimAcknowledgment = RegExp(
  '[${RegExp.escape('$_whitespace.,!?;:"\'()[]{}')}]+',
  unicode: true,
);
final _ackSeparator = RegExp(
  '[${RegExp.escape('$_whitespace.,!?;:"\'()[]{}-')}]',
  unicode: true,
);
final _collapseWhitespace = RegExp('[${RegExp.escape(_whitespace)}]+');
final _wordCharacter = RegExp(r'[\p{L}\p{N}]', unicode: true);

// Match only the boundary code point, avoiding a V8 end-anchor bug for astral
// letters. This preserves the SDK's Unicode letter/number separator policy on
// Dart VM, JavaScript and Wasm without scanning an entire accumulated transcript.
bool _wordBoundary(String text, {required bool atEnd}) {
  if (text.isEmpty) return false;
  var start = atEnd ? text.length - 1 : 0;
  var end = start + 1;
  final unit = text.codeUnitAt(start);
  if (atEnd && unit >= 0xdc00 && unit <= 0xdfff && start > 0) {
    final previous = text.codeUnitAt(start - 1);
    if (previous >= 0xd800 && previous <= 0xdbff) start--;
  } else if (!atEnd && unit >= 0xd800 && unit <= 0xdbff && end < text.length) {
    final next = text.codeUnitAt(end);
    if (next >= 0xdc00 && next <= 0xdfff) end++;
  }
  return _wordCharacter.hasMatch(text.substring(start, end));
}

String _normalizeAcknowledgment(String text) {
  var normalized = _ecmaLowerCase(text).replaceAll('-', ' ');
  final leading = _trimAcknowledgment.matchAsPrefix(normalized);
  if (leading != null) normalized = normalized.substring(leading.end);
  final trailing = _trimAcknowledgment
      .allMatches(normalized)
      .where((match) => match.end == normalized.length);
  if (trailing.isNotEmpty) {
    normalized = normalized.substring(0, trailing.last.start);
  }
  return normalized.replaceAll(_collapseWhitespace, ' ');
}

// Dart uses simple Unicode lowercase mappings. ECMAScript also applies the
// unconditional dotted-I expansion and context-sensitive final sigma mapping.
// Inspect complete joined text so split surrogate pairs and sigma fragments
// preserve the official SDK acknowledgment decisions.
final _cased = RegExp(r'\p{Cased}', unicode: true);
final _caseIgnorable = RegExp(r'\p{Case_Ignorable}', unicode: true);

String _ecmaLowerCase(String text) {
  if (!text.contains('Σ') && !text.contains('İ')) return text.toLowerCase();
  final runes = text.runes.toList();
  final result = StringBuffer();
  for (var index = 0; index < runes.length; index++) {
    final rune = runes[index];
    if (rune == 0x130) {
      result.write('i\u0307');
    } else if (rune == 0x3a3) {
      var before = index - 1;
      while (before >= 0 &&
          _caseIgnorable.hasMatch(String.fromCharCode(runes[before]))) {
        before--;
      }
      var after = index + 1;
      while (after < runes.length &&
          _caseIgnorable.hasMatch(String.fromCharCode(runes[after]))) {
        after++;
      }
      final finalSigma =
          before >= 0 &&
          _cased.hasMatch(String.fromCharCode(runes[before])) &&
          (after == runes.length ||
              !_cased.hasMatch(String.fromCharCode(runes[after])));
      result.write(finalSigma ? 'ς' : 'σ');
    } else {
      result.write(String.fromCharCode(rune).toLowerCase());
    }
  }
  return result.toString();
}

void _validSourceTime(double value) {
  if (!value.isFinite || value < 0) {
    throw ArgumentError('Source time must be finite and nonnegative.');
  }
}
