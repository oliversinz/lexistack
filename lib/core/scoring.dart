int starsForMistakes(int mistakes) {
  if (mistakes < 0) throw RangeError.value(mistakes, 'mistakes');
  return mistakes == 0 ? 3 : (mistakes <= 2 ? 2 : 1);
}
