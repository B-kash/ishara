export function levenshteinDistance(left: string, right: string): number {
  if (left === right) {
    return 0;
  }

  if (left.length === 0) {
    return right.length;
  }

  if (right.length === 0) {
    return left.length;
  }

  const previousRow = Array.from({ length: right.length + 1 }, (_, index) => index);

  for (let leftIndex = 0; leftIndex < left.length; leftIndex += 1) {
    let previousDiagonal = previousRow[0]!;
    previousRow[0] = leftIndex + 1;

    for (let rightIndex = 0; rightIndex < right.length; rightIndex += 1) {
      const temporaryValue = previousRow[rightIndex + 1]!;
      const substitutionCost = left[leftIndex] === right[rightIndex] ? 0 : 1;

      previousRow[rightIndex + 1] = Math.min(
        previousRow[rightIndex]! + 1,
        previousRow[rightIndex + 1]! + 1,
        previousDiagonal + substitutionCost,
      );

      previousDiagonal = temporaryValue;
    }
  }

  return previousRow[right.length]!;
}

export function fuzzyMatchScore(word: string, searchTerm: string): number {
  if (!word || !searchTerm) {
    return 0;
  }

  if (word === searchTerm) {
    return 100;
  }

  if (word.startsWith(searchTerm)) {
    return 80;
  }

  if (word.includes(searchTerm)) {
    return 60;
  }

  if (searchTerm.includes(word) && word.length >= 3) {
    return 40;
  }

  const maxEditDistance =
    searchTerm.length <= 3 ? 1 : searchTerm.length <= 6 ? 2 : 3;
  const editDistance = levenshteinDistance(word, searchTerm);

  if (editDistance > maxEditDistance) {
    return 0;
  }

  return Math.max(10, 30 - editDistance * 10);
}

export function fuzzyTermMatches(word: string, searchTerm: string): boolean {
  return fuzzyMatchScore(word, searchTerm) > 0;
}
