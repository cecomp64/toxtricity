Validation = require("../lib/validation")

words_testcases = [
  {
    description: 'One unsupported custom emoji and one unicode emoji',
    words: [ '<:carl:762777713949540402>', 'Carl,', '🧨', 'Jake' ],
    pairs: [{name: 'Carl', emoji: '<:carl:762777713949540402>'}, {name: 'Jake', emoji: '🧨'}],
  },

  # tb! roles 🍣 Sushi, ⚾ Baseball
  {
    description: 'Two unicode emojis and some whitespace.',
    words: [ ' 🍣   ', ' Sushi,  ', '  ⚾   ', ' Baseball ' ],
    pairs: [{name: 'Sushi', emoji: '🍣'}, {name: 'Baseball', emoji: '⚾'}],
  },
]

# The 'test' function doesn't seem to work in an inner loop.  Oh well.
test('All word testcases.', () =>
  for t in [0..words_testcases.length-1]
    testcase = words_testcases[t]
    pairs = Validation.validate_pairs(testcase.words)
    expect(pairs.length).toBe(testcase.pairs.length)
    for p in [0..pairs.length-1]
      expect(pairs[p].name).toBe(testcase.pairs[p].name)
      expect(pairs[p].emoji).toBe(testcase.pairs[p].emoji)
    
  return
)