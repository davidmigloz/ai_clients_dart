import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

Map<String, dynamic> _details() => {
  'detailed_explanation': 'private explanation',
  'error_type': 'future-classification',
  'review_target': 'opaque:review',
  'steer': {'message': 'private instruction', 'future_steer': true},
  'future_detail': true,
};

Map<String, dynamic> _error() => {
  'type': 'invalid_request_error',
  'code': 'misalignment_policy_violation',
  'param': null,
  'message': 'private failure',
  'misalignment': _details(),
  'future_error': true,
};

Map<String, dynamic> _envelope() => {
  'type': 'error',
  'status': 403,
  'stream_id': 'private-lane',
  'error': _error(),
  'future_envelope': true,
};

Map<String, dynamic> _failed() => {
  'type': 'response.failed',
  'sequence_number': 5,
  'stream_id': 'private-lane',
  'response': {
    'id': 'private-response',
    'object': 'response',
    'created_at': 1,
    'status': 'failed',
    'output': <dynamic>[],
    'error': {
      'code': 'misalignment_policy_violation',
      'message': 'private failure',
      'misalignment': _details(),
      'future_error': true,
    },
    'future_response': true,
  },
  'future_envelope': true,
};

void _wireValue(ResponsesServerEvent value) {
  final parsed = ResponsesServerEvent.fromJson(value.toJson());
  expect(parsed, value);
  expect(parsed.hashCode, value.hashCode);
}

void main() {
  group('WebSocket monitoring nested replacement contracts', () {
    for (final kind in ['payload', 'error', 'ordinary']) {
      test(
        'const-compatible $kind constructor rejects nonfinite and cyclic raw JSON on output',
        () {
          Map<String, dynamic> output(Map<String, dynamic> raw) =>
              switch (kind) {
                'payload' => ResponsesErrorPayload(
                  type: 'error',
                  message: 'failure',
                  rawJson: raw,
                ).toJson(),
                'error' => ResponsesErrorEvent(
                  error: const ResponsesErrorPayload(
                    type: 'error',
                    message: 'failure',
                  ),
                  rawJson: raw,
                ).toJson(),
                _ => ResponsesStreamEvent(
                  event: const ResponseAudioDoneEvent(),
                  rawJson: raw,
                ).toJson(),
              };
          for (final bad in [double.infinity, double.nan, Object()]) {
            expect(
              () => output({'private key': bad}),
              throwsA(
                isA<FormatException>()
                    .having(
                      (error) => error.toString(),
                      'safe',
                      isNot(contains('private')),
                    )
                    .having((error) => error.source, 'source', isNull),
              ),
            );
          }
          final raw = <String, dynamic>{};
          raw['private key'] = raw;
          expect(
            () => output(raw),
            throwsA(
              isA<FormatException>().having(
                (error) => error.message,
                'context',
                contains('acyclic'),
              ),
            ),
          );
        },
      );
    }

    for (final name in ['same', 'changed']) {
      test('fresh $name agent drops old future metadata', () {
        final value = ResponsesErrorEvent.fromJson(
          _envelope()
            ..['agent'] = {'agent_name': 'same', 'private_token': 'old'},
        );
        final changed = value.copyWith(agent: AgentTag(agentName: name));
        expect(changed.toJson()['agent'], {'agent_name': name});
        expect(changed.rawJson.clear, throwsUnsupportedError);
        _wireValue(changed);
      });
    }

    test('explicit agent parent raw override wins while typed agent wins', () {
      final value = ResponsesErrorEvent.fromJson(
        _envelope()..['agent'] = {'agent_name': 'old', 'private_token': 'old'},
      );
      final raw = <String, dynamic>{
        'agent': {'parent_agent': true},
        'replacement_envelope': true,
      };
      final changed = value.copyWith(
        agent: const AgentTag(agentName: 'new'),
        rawJson: raw,
      );
      expect(identical(changed.rawJson, raw), isTrue);
      expect(changed.toJson()['agent'], {
        'agent_name': 'new',
        'parent_agent': true,
      });
      _wireValue(changed);
    });

    test(
      'explicit failed-response raw override preserves future metadata without restoring cleared detail fields',
      () {
        final value = ResponsesStreamEvent.fromJson(_failed());
        final failed = value.event as ResponseFailedEvent;
        final child = failed.response.error!.copyWith(
          type: 'legacy',
          param: 'legacy',
          misalignment: null,
        );
        final event = failed.copyWith(
          response: failed.response.copyWith(error: child),
        );
        final raw = <String, dynamic>{
          'response': {
            'parent_response': true,
            'error': {
              'parent_error': true,
              'misalignment': {'stale_detail': true},
            },
          },
        };
        final changed = value.copyWith(event: event, rawJson: raw);
        final response = changed.toJson()['response'] as Map<String, dynamic>;
        final error = response['error'] as Map<String, dynamic>;
        expect(identical(changed.rawJson, raw), isTrue);
        expect(response['parent_response'], isTrue);
        expect(error['parent_error'], isTrue);
        expect(error.containsKey('misalignment'), isFalse);
        _wireValue(changed);
      },
    );

    for (final fresh in [false, true]) {
      test(
        'payload details ${fresh ? 'fresh replacement' : 'raw clear'} cannot resurrect old future metadata',
        () {
          final value = ResponsesErrorPayload.fromJson(_error());
          final child = fresh
              ? const ResponsesMisalignmentDetails(errorType: 'future-new')
              : value.misalignment!.copyWith(rawJson: {}, steer: null);
          final changed = value.copyWith(misalignment: child);
          expect(changed.toJson()['misalignment'], child.toJson());
          expect(changed.toJson()['future_error'], isTrue);
          expect(changed.rawJson.clear, throwsUnsupportedError);
          final parsed = ResponsesErrorPayload.fromJson(changed.toJson());
          expect(parsed, changed);
          expect(parsed.hashCode, changed.hashCode);
        },
      );

      test(
        'error envelope ${fresh ? 'fresh child' : 'raw clear'} cannot resurrect old error metadata',
        () {
          final value = ResponsesErrorEvent.fromJson(_envelope());
          final child = fresh
              ? const ResponsesErrorPayload(
                  type: 'invalid_request_error',
                  code: 'misalignment_policy_violation',
                  message: 'new failure',
                )
              : value.error.copyWith(rawJson: {}, misalignment: null);
          final changed = value.copyWith(error: child);
          expect(changed.toJson()['error'], child.toJson());
          expect(changed.toJson()['future_envelope'], isTrue);
          expect(changed.rawJson.clear, throwsUnsupportedError);
          _wireValue(changed);
        },
      );

      test(
        'ordinary failed-response envelope ${fresh ? 'fresh error' : 'raw clear'} preserves response metadata only',
        () {
          final value = ResponsesStreamEvent.fromJson(_failed());
          final failed = value.event as ResponseFailedEvent;
          final child = fresh
              ? const ResponseError(
                  code: 'misalignment_policy_violation',
                  message: 'new failure',
                )
              : failed.response.error!.copyWith(
                  rawJson: {},
                  misalignment: null,
                );
          final changed = value.copyWith(
            event: failed.copyWith(
              response: failed.response.copyWith(error: child),
            ),
          );
          final response = changed.toJson()['response'] as Map<String, dynamic>;
          expect(response['error'], child.toJson());
          expect(response['future_response'], isTrue);
          expect(changed.toJson()['future_envelope'], isTrue);
          expect(changed.rawJson.clear, throwsUnsupportedError);
          _wireValue(changed);
        },
      );
    }

    test(
      'clear steer, explanation, classification, and token all the way through error envelope',
      () {
        final value = ResponsesErrorEvent.fromJson(_envelope());
        final details = value.error.misalignment!.copyWith(
          detailedExplanation: null,
          errorType: null,
          reviewTarget: null,
          hasReviewTarget: false,
          steer: null,
        );
        final changed = value.copyWith(
          error: value.error.copyWith(misalignment: details),
        );
        final error = changed.toJson()['error'] as Map<String, dynamic>;
        expect(error['misalignment'], {'future_detail': true});
        expect(error['future_error'], isTrue);
        _wireValue(changed);
      },
    );

    test('clear misalignment all the way through failed response envelope', () {
      final value = ResponsesStreamEvent.fromJson(_failed());
      final failed = value.event as ResponseFailedEvent;
      final changed = value.copyWith(
        event: failed.copyWith(
          response: failed.response.copyWith(
            error: failed.response.error!.copyWith(misalignment: null),
          ),
        ),
      );
      final response = changed.toJson()['response'] as Map<String, dynamic>;
      final error = response['error'] as Map<String, dynamic>;
      expect(error.containsKey('misalignment'), isFalse);
      expect(error['future_error'], isTrue);
      _wireValue(changed);
    });

    test('clear entire failed response error cannot restore raw error', () {
      final value = ResponsesStreamEvent.fromJson(_failed());
      final failed = value.event as ResponseFailedEvent;
      final changed = value.copyWith(
        event: failed.copyWith(response: failed.response.copyWith(error: null)),
      );
      expect(
        (changed.toJson()['response'] as Map<String, dynamic>).containsKey(
          'error',
        ),
        isFalse,
      );
      _wireValue(changed);
    });

    test(
      'explicit parent raw override wins at payload and details child levels',
      () {
        final value = ResponsesErrorPayload.fromJson(_error());
        final raw = <String, dynamic>{
          'misalignment': {
            'parent_detail': true,
            'steer': {'parent_steer': true},
          },
          'replacement_parent': true,
        };
        final changed = value.copyWith(
          misalignment: const ResponsesMisalignmentDetails(
            steer: ResponsesMisalignmentSteer(message: 'new'),
          ),
          rawJson: raw,
        );
        expect(identical(changed.rawJson, raw), isTrue);
        expect(changed.toJson()['misalignment'], {
          'parent_detail': true,
          'steer': {'parent_steer': true, 'message': 'new'},
        });
        expect(changed.toJson().containsKey('future_error'), isFalse);
        final parsed = ResponsesErrorPayload.fromJson(changed.toJson());
        expect(parsed, changed);
        expect(parsed.hashCode, changed.hashCode);
      },
    );

    test(
      'explicit envelope raw override wins while typed known fields clear',
      () {
        final value = ResponsesErrorEvent.fromJson(_envelope());
        final raw = <String, dynamic>{
          'error': {
            'parent_error': true,
            'misalignment': {
              'parent_detail': true,
              'steer': {'parent_steer': true},
            },
          },
          'replacement_envelope': true,
        };
        final child = value.error.copyWith(
          rawJson: {},
          misalignment: const ResponsesMisalignmentDetails(
            steer: ResponsesMisalignmentSteer(message: 'new'),
          ),
        );
        final changed = value.copyWith(error: child, rawJson: raw);
        expect(identical(changed.rawJson, raw), isTrue);
        expect(changed.toJson()['error'], {
          'parent_error': true,
          'type': child.type,
          'message': child.message,
          'code': child.code,
          'param': null,
          'misalignment': {
            'parent_detail': true,
            'steer': {'parent_steer': true, 'message': 'new'},
          },
        });
        expect(changed.toJson().containsKey('future_envelope'), isFalse);
        _wireValue(changed);
      },
    );

    test(
      'misalignment data is passive and envelope diagnostics remain redacted',
      () {
        final value = ResponsesErrorEvent.fromJson(_envelope());
        expect(value.error.misalignment!.reviewTarget, 'opaque:review');
        expect(value.error.misalignment!.steer!.message, 'private instruction');
        expect(value.toString(), isNot(contains('private')));
        expect(value.error.toString(), isNot(contains('private')));
        expect(value.error.misalignment.toString(), isNot(contains('private')));
        _wireValue(value);
      },
    );

    test('cyclic WS envelopes fail contextually without sensitive keys', () {
      final json = _envelope();
      json['private key'] = json;
      expect(
        () => ResponsesServerEvent.fromJson(json),
        throwsA(
          isA<FormatException>()
              .having(
                (error) => error.message,
                'safe',
                allOf(contains('acyclic'), isNot(contains('private'))),
              )
              .having((error) => error.source, 'source', isNull),
        ),
      );
    });
  });
}
