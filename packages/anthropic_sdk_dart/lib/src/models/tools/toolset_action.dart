import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';

part 'browser_tool_actions.dart';
part 'computer_tool_actions.dart';

/// The input to a browser or computer toolset member.
///
/// Read the typed action after the tool input is complete. Streaming start
/// events can carry an empty input map before their JSON deltas arrive.
@immutable
sealed class ToolsetAction {
  ToolsetAction._(this.toolsetName, this.name, Map<String, dynamic> input)
    : input = deepUnmodifiableMap(input);

  /// Decodes the toolset family, member name and input from a tool-use block.
  factory ToolsetAction.fromJson(Map<String, dynamic> json) =>
      ToolsetAction.decode(
        json['toolset_name'] as String,
        json['name'] as String,
        json['input'] as Map<String, dynamic>,
      );

  /// Decodes a completed member input. Unknown members keep their raw input.
  factory ToolsetAction.decode(
    String toolsetName,
    String name,
    Map<String, dynamic> input,
  ) {
    return switch ((toolsetName, name)) {
      ('browser', 'navigate') => BrowserNavigateAction._(input),
      ('browser', 'list_tabs') => BrowserListTabsAction._(input),
      ('browser', 'new_tab') => BrowserNewTabAction._(input),
      ('browser', 'switch_tab') => BrowserSwitchTabAction._(input),
      ('browser', 'close_tab') => BrowserCloseTabAction._(input),
      ('browser', 'read_page') => BrowserReadPageAction._(input),
      ('browser', 'get_page_text') => BrowserGetPageTextAction._(input),
      ('browser', 'read_console') => BrowserReadConsoleAction._(input),
      ('browser', 'read_network') => BrowserReadNetworkAction._(input),
      ('browser', 'find') => BrowserFindAction._(input),
      ('browser', 'form_input') => BrowserFormInputAction._(input),
      ('browser', 'file_upload') => BrowserFileUploadAction._(input),
      ('browser', 'scroll_to') => BrowserScrollToAction._(input),
      ('browser', 'screenshot') => BrowserScreenshotAction._(input),
      ('browser', 'zoom') => BrowserZoomAction._(input),
      ('browser', 'left_click') => BrowserLeftClickAction._(input),
      ('browser', 'right_click') => BrowserRightClickAction._(input),
      ('browser', 'middle_click') => BrowserMiddleClickAction._(input),
      ('browser', 'double_click') => BrowserDoubleClickAction._(input),
      ('browser', 'triple_click') => BrowserTripleClickAction._(input),
      ('browser', 'hover') => BrowserHoverAction._(input),
      ('browser', 'left_click_drag') => BrowserLeftClickDragAction._(input),
      ('browser', 'left_mouse_down') => BrowserLeftMouseDownAction._(input),
      ('browser', 'left_mouse_up') => BrowserLeftMouseUpAction._(input),
      ('browser', 'mouse_move') => BrowserMouseMoveAction._(input),
      ('browser', 'scroll') => BrowserScrollAction._(input),
      ('browser', 'type') => BrowserTypeAction._(input),
      ('browser', 'key') => BrowserKeyAction._(input),
      ('browser', 'hold_key') => BrowserHoldKeyAction._(input),
      ('browser', 'wait') => BrowserWaitAction._(input),
      ('browser', 'javascript_exec') => BrowserJavascriptExecAction._(input),
      ('computer', 'key') => ComputerKeyAction._(input),
      ('computer', 'hold_key') => ComputerHoldKeyAction._(input),
      ('computer', 'type') => ComputerTypeAction._(input),
      ('computer', 'cursor_position') => ComputerCursorPositionAction._(input),
      ('computer', 'mouse_move') => ComputerMouseMoveAction._(input),
      ('computer', 'left_mouse_down') => ComputerLeftMouseDownAction._(input),
      ('computer', 'left_mouse_up') => ComputerLeftMouseUpAction._(input),
      ('computer', 'left_click') => ComputerLeftClickAction._(input),
      ('computer', 'left_click_drag') => ComputerLeftClickDragAction._(input),
      ('computer', 'right_click') => ComputerRightClickAction._(input),
      ('computer', 'middle_click') => ComputerMiddleClickAction._(input),
      ('computer', 'double_click') => ComputerDoubleClickAction._(input),
      ('computer', 'triple_click') => ComputerTripleClickAction._(input),
      ('computer', 'scroll') => ComputerScrollAction._(input),
      ('computer', 'wait') => ComputerWaitAction._(input),
      ('computer', 'screenshot') => ComputerScreenshotAction._(input),
      ('computer', 'zoom') => ComputerZoomAction._(input),
      _ => UnknownToolsetAction._(toolsetName, name, input),
    };
  }

  /// The family of the toolset member, such as `browser` or `computer`.
  final String toolsetName;

  /// The toolset member name.
  final String name;

  /// The complete input, including fields introduced by the service later.
  final Map<String, dynamic> input;

  /// Converts to the fields carried by a tool-use block.
  Map<String, dynamic> toJson() => {
    'toolset_name': toolsetName,
    'name': name,
    'input': input,
  };

  @override
  bool operator ==(Object other) =>
      other is ToolsetAction &&
      toolsetName == other.toolsetName &&
      name == other.name &&
      mapsDeepEqual(input, other.input);

  @override
  int get hashCode => Object.hash(toolsetName, name, mapDeepHashCode(input));

  @override
  String toString() => 'ToolsetAction(toolsetName: $toolsetName, name: $name)';
}

/// A member or toolset family not yet modeled by this client.
final class UnknownToolsetAction extends ToolsetAction {
  UnknownToolsetAction._(super.toolsetName, super.name, super.input)
    : super._();
}

/// A viewport coordinate or element reference for a browser action.
@immutable
sealed class BrowserClickTarget {
  BrowserClickTarget._(Map<String, dynamic> raw)
    : _raw = deepUnmodifiableMap(raw);

  /// Decodes the browser target, preserving future target kinds.
  factory BrowserClickTarget.fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        'coordinate' => BrowserCoordinateTarget.fromJson(json),
        'ref' => BrowserRefTarget.fromJson(json),
        _ => UnknownBrowserClickTarget._(json),
      };

  final Map<String, dynamic> _raw;

  /// The target discriminator returned by the server.
  String? get type => _raw['type'] as String?;

  /// Converts to the original browser target fields.
  Map<String, dynamic> toJson() => _raw;

  @override
  bool operator ==(Object other) =>
      other is BrowserClickTarget && mapsDeepEqual(_raw, other._raw);

  @override
  int get hashCode => mapDeepHashCode(_raw);
}

/// A point measured in viewport pixels.
final class BrowserCoordinateTarget extends BrowserClickTarget {
  BrowserCoordinateTarget._(super.raw) : super._();

  /// Decodes a coordinate target.
  factory BrowserCoordinateTarget.fromJson(Map<String, dynamic> json) {
    if (json case {'type': 'coordinate', 'x': int _, 'y': int _}) {
      return BrowserCoordinateTarget._(json);
    }
    throw const FormatException('Expected a browser coordinate target');
  }

  /// The horizontal pixel coordinate.
  int get x => _raw['x'] as int;

  /// The vertical pixel coordinate.
  int get y => _raw['y'] as int;
}

/// An element reference scoped to a tab.
final class BrowserRefTarget extends BrowserClickTarget {
  BrowserRefTarget._(super.raw) : super._();

  /// Decodes an element reference target.
  factory BrowserRefTarget.fromJson(Map<String, dynamic> json) {
    if (json case {'type': 'ref', 'ref': String _}) {
      return BrowserRefTarget._(json);
    }
    throw const FormatException('Expected a browser element reference target');
  }

  /// The element reference from a previous browser result.
  String get ref => _raw['ref'] as String;
}

/// A future browser target with its original fields preserved.
final class UnknownBrowserClickTarget extends BrowserClickTarget {
  UnknownBrowserClickTarget._(super.raw) : super._();
}

/// A string, number or boolean accepted by a browser form control.
@immutable
sealed class BrowserFormValue {
  const BrowserFormValue._();

  /// Decodes a form value.
  factory BrowserFormValue.fromJson(Object? value) => switch (value) {
    final String text => BrowserTextFormValue(text),
    final num number => BrowserNumberFormValue(number),
    final bool checked => BrowserBooleanFormValue(value: checked),
    _ => throw const FormatException('Expected a browser form value'),
  };

  /// Converts to the scalar form value.
  Object toJson();

  @override
  bool operator ==(Object other) =>
      other is BrowserFormValue &&
      runtimeType == other.runtimeType &&
      toJson() == other.toJson();

  @override
  int get hashCode => Object.hash(runtimeType, toJson());
}

/// A textual browser form value.
final class BrowserTextFormValue extends BrowserFormValue {
  /// Creates a textual form value.
  const BrowserTextFormValue(this.value) : super._();

  /// The text to enter.
  final String value;

  @override
  String toJson() => value;
}

/// A numeric browser form value.
final class BrowserNumberFormValue extends BrowserFormValue {
  /// Creates a numeric form value.
  const BrowserNumberFormValue(this.value) : super._();

  /// The number to enter.
  final num value;

  @override
  num toJson() => value;
}

/// A boolean browser form value.
final class BrowserBooleanFormValue extends BrowserFormValue {
  /// Creates a boolean form value.
  const BrowserBooleanFormValue({required this.value}) : super._();

  /// The checked state.
  final bool value;

  @override
  bool toJson() => value;
}
