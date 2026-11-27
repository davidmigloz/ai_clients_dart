/// A phoneme accepted by the Voxtral pronunciation API.
enum IpaPhoneme {
  /// IPA symbol `a`.
  a('a'),

  /// IPA symbol `aɪ`.
  aSmallCapitalI('aɪ'),

  /// IPA symbol `aʊ`.
  aUpsilon('aʊ'),

  /// IPA symbol `b`.
  b('b'),

  /// IPA symbol `d`.
  d('d'),

  /// IPA symbol `dʒ`.
  dEzh('dʒ'),

  /// IPA symbol `e`.
  e('e'),

  /// IPA symbol `eɪ`.
  eSmallCapitalI('eɪ'),

  /// IPA symbol `f`.
  f('f'),

  /// IPA symbol `g`.
  g('g'),

  /// IPA symbol `h`.
  h('h'),

  /// IPA symbol `i`.
  i('i'),

  /// IPA symbol `j`.
  j('j'),

  /// IPA symbol `k`.
  k('k'),

  /// IPA symbol `l`.
  l('l'),

  /// IPA symbol `m`.
  m('m'),

  /// IPA symbol `n`.
  n('n'),

  /// IPA symbol `o`.
  o('o'),

  /// IPA symbol `oʊ`.
  oUpsilon('oʊ'),

  /// IPA symbol `p`.
  p('p'),

  /// IPA symbol `s`.
  s('s'),

  /// IPA symbol `t`.
  t('t'),

  /// IPA symbol `tʃ`.
  tEsh('tʃ'),

  /// IPA symbol `u`.
  u('u'),

  /// IPA symbol `v`.
  v('v'),

  /// IPA symbol `w`.
  w('w'),

  /// IPA symbol `z`.
  z('z'),

  /// IPA symbol `æ`.
  ae('æ'),

  /// IPA symbol `ð`.
  eth('ð'),

  /// IPA symbol `ŋ`.
  eng('ŋ'),

  /// IPA symbol `ɑ`.
  alpha('ɑ'),

  /// IPA symbol `ɔ`.
  openO('ɔ'),

  /// IPA symbol `ɔɪ`.
  openOSmallCapitalI('ɔɪ'),

  /// IPA symbol `ɖ`.
  dWithTail('ɖ'),

  /// IPA symbol `ə`.
  schwa('ə'),

  /// IPA symbol `ɚ`.
  schwaWithHook('ɚ'),

  /// IPA symbol `ɛ`.
  openE('ɛ'),

  /// IPA symbol `ɜ`.
  reversedOpenE('ɜ'),

  /// IPA symbol `ɪ`.
  smallCapitalI('ɪ'),

  /// IPA symbol `ɱ`.
  mWithHook('ɱ'),

  /// IPA symbol `ɹ`.
  turnedR('ɹ'),

  /// IPA symbol `ɾ`.
  rWithFishhook('ɾ'),

  /// IPA symbol `ʃ`.
  esh('ʃ'),

  /// IPA symbol `ʈ`.
  tWithRetroflexHook('ʈ'),

  /// IPA symbol `ʊ`.
  upsilon('ʊ'),

  /// IPA symbol `ʋ`.
  vWithHook('ʋ'),

  /// IPA symbol `ʌ`.
  turnedV('ʌ'),

  /// IPA symbol `ʒ`.
  ezh('ʒ'),

  /// IPA symbol `ʔ`.
  glottalStop('ʔ'),

  /// IPA symbol `θ`.
  theta('θ'),

  /// IPA symbol `ʁ`.
  smallCapitalInvertedR('ʁ'),

  /// IPA symbol `r`.
  r('r'),

  /// IPA symbol `ɑ̃`.
  alphaCombiningTilde('ɑ̃'),

  /// IPA symbol `ʀ`.
  smallCapitalR('ʀ'),

  /// IPA symbol `x`.
  x('x'),

  /// IPA symbol `y`.
  y('y'),

  /// IPA symbol `ɔ̃`.
  openOCombiningTilde('ɔ̃'),

  /// IPA symbol `ɐ`.
  turnedA('ɐ'),

  /// IPA symbol `œ`.
  latinSmallLigatureOe('œ'),

  /// IPA symbol `ɛ̃`.
  openECombiningTilde('ɛ̃'),

  /// IPA symbol `ʝ`.
  jWithCrossedTail('ʝ'),

  /// IPA symbol `ɲ`.
  nWithLeftHook('ɲ'),

  /// IPA symbol `ts`.
  tS('ts'),

  /// IPA symbol `ɥ`.
  turnedH('ɥ'),

  /// IPA symbol `ʏ`.
  smallCapitalY('ʏ'),

  /// IPA symbol `ø`.
  oWithStroke('ø'),

  /// IPA symbol `β`.
  beta('β'),

  /// IPA symbol `ɦ`.
  hWithHook('ɦ'),

  /// IPA symbol `pf`.
  pF('pf'),

  /// IPA symbol `ʎ`.
  turnedY('ʎ'),

  /// IPA symbol `ɣ`.
  gamma('ɣ'),

  /// IPA symbol `ɳ`.
  nWithRetroflexHook('ɳ'),

  /// IPA symbol `ɔʏ`.
  openOSmallCapitalY('ɔʏ'),

  /// IPA symbol `œ̃`.
  latinSmallLigatureOeCombiningTilde('œ̃'),

  /// IPA symbol `ɟʝ`.
  dotlessJWithStrokeJWithCrossedTail('ɟʝ'),

  /// IPA symbol `ɬ`.
  lWithBelt('ɬ'),

  /// IPA symbol `q`.
  q('q'),

  /// A newer symbol that this version of the client does not recognize.
  unknown('unknown');

  const IpaPhoneme(this.value);

  /// The IPA symbol sent in a pronunciation hint.
  final String value;

  /// Looks up a phoneme by its IPA symbol.
  static IpaPhoneme fromJson(String value) => values.firstWhere(
    (phoneme) => phoneme.value == value,
    orElse: () => unknown,
  );
}
