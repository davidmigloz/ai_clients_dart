import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  const top = TopLogprob(token: 'hello', logprob: -1, bytes: [104, 105]);
  const token = TokenLogprob(
    token: 'hello',
    logprob: -1,
    bytes: [104, 105],
    topLogprobs: [top],
  );
  const logprobs = Logprobs(content: [token], refusal: [token]);
  test('all token/alternative fields reach nested equality and hash', () {
    final parsed = Logprobs.fromJson(logprobs.toJson());
    expect(parsed, logprobs);
    expect(parsed.hashCode, logprobs.hashCode);
    expect({parsed, logprobs}, hasLength(1));
    for (final changed in [
      token.copyWith(token: 'other'),
      token.copyWith(logprob: -2),
      token.copyWith(bytes: [105, 104]),
      token.copyWith(bytes: null),
      token.copyWith(topLogprobs: []),
      token.copyWith(topLogprobs: null),
      token.copyWith(
        topLogprobs: [
          top.copyWith(bytes: [1]),
        ],
      ),
    ]) {
      expect(changed, isNot(token));
      const choiceA = ChatStreamChoice(delta: ChatDelta(), logprobs: logprobs);
      final choiceB = ChatStreamChoice(
        delta: const ChatDelta(),
        logprobs: Logprobs(content: [changed], refusal: const [token]),
      );
      expect(choiceA, isNot(choiceB));
    }
    expect(top.copyWith(token: 'other'), isNot(top));
    expect(top.copyWith(logprob: -2), isNot(top));
    expect(top.copyWith(bytes: [105, 104]), isNot(top));
    expect(top.copyWith(bytes: null), isNot(top));
  });
  test(
    'copies preserve required values and clear or replace nullable lists',
    () {
      expect(logprobs.copyWith(), logprobs);
      expect(token.copyWith(), token);
      expect(top.copyWith(), top);
      expect(logprobs.copyWith(content: null, refusal: null).toJson(), isEmpty);
      expect(logprobs.copyWith(content: <dynamic>[], refusal: []).toJson(), {
        'content': <dynamic>[],
        'refusal': <dynamic>[],
      });
      expect(token.copyWith(bytes: null, topLogprobs: null).toJson(), {
        'token': 'hello',
        'logprob': -1.0,
      });
      expect(token.copyWith(bytes: <dynamic>[], topLogprobs: []).toJson(), {
        'token': 'hello',
        'logprob': -1.0,
        'bytes': <dynamic>[],
        'top_logprobs': <dynamic>[],
      });
      expect(top.copyWith(bytes: []).toJson()['bytes'], isEmpty);
      expect(logprobs.toString(), contains('content: 1 items'));
      expect(const Logprobs().toString(), isNot(contains('null items')));
      expect(token.toString(), contains('topLogprobs: 1 items'));
      expect(top.toString(), contains('bytes: 2 items'));
    },
  );
}
