var Validation, words_testcases;

Validation = require("../validation");

words_testcases = [
  {
    description: 'One unsupported custom emoji and one unicode emoji',
    words: ['<:carl:762777713949540402>', 'Carl,', '🧨', 'Jake'],
    pairs: [
      {name: 'Carl', emoji: '<:carl:762777713949540402>'},
      {name: 'Jake', emoji: '🧨'}
    ]
  },
  {
    // tb! roles 🍣 Sushi, ⚾ Baseball
    description: 'Two unicode emojis and some whitespace.',
    words: [' 🍣   ', ' Sushi,  ', '  ⚾   ', ' Baseball '],
    pairs: [
      {name: 'Sushi', emoji: '🍣'},
      {name: 'Baseball', emoji: '⚾'}
    ]
  }
];

// The 'test' function doesn't seem to work in an inner loop.  Oh well.
test('All word testcases.', () => {
  var i, j, p, pairs, ref, ref1, t, testcase;

  words_testcases.forEach(testcase => {
    // Check that the same number of pairs are returned
    pairs = Validation.validate_pairs(testcase.words);
    expect(pairs.length).toBe(testcase.pairs.length);

    // Check individual pairs
    pairs.forEach((pair, p) => {
      expect(pair.name).toBe(testcase.pairs[p].name);
      expect(pair.emoji).toBe(testcase.pairs[p].emoji);
    });
  });

});
