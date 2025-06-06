export function splitText(text) {
    return text
        .trim()
        .replace(/[^가-힣a-zA-Z0-9\s]/g, '')
        .split(/\s+/)
        .filter(Boolean);
}

function isSimilar(a, b) {
    const normA = a.trim().toLowerCase();
    const normB = b.trim().toLowerCase();

    if (Math.abs(normA.length - normB.length) > 2) return false;

    return levenshteinSimilarity(normA, normB) >= 0.7;
}

function levenshteinSimilarity(a, b) {
    const lenA = a.length, lenB = b.length;
    const dp = Array.from({ length: lenA + 1 }, () => Array(lenB + 1).fill(0));

    for (let i = 0; i <= lenA; i++) dp[i][0] = i;
    for (let j = 0; j <= lenB; j++) dp[0][j] = j;

    for (let i = 1; i <= lenA; i++) {
        for (let j = 1; j <= lenB; j++) {
            if (a[i - 1] === b[j - 1]) dp[i][j] = dp[i - 1][j - 1];
            else dp[i][j] = 1 + Math.min(dp[i - 1][j], dp[i][j - 1], dp[i - 1][j - 1]);
        }
    }

    const distance = dp[lenA][lenB];
    const maxLen = Math.max(lenA, lenB);
    return maxLen === 0 ? 1 : 1 - distance / maxLen;
}

export function calculateProgressByLastMatch(scriptChunks, recognizedText) {
    const recognizedWords = splitText(recognizedText);
    if (!scriptChunks.length || !recognizedWords.length) return 0;

    const matchedFlags = new Array(scriptChunks.length).fill(false);
    let lastMatchedIndex = -1;

    for (let i = 0; i < recognizedWords.length; i++) {
        const start = Math.max(0, lastMatchedIndex - 8);
        const end = Math.min(scriptChunks.length, lastMatchedIndex + 8);

        for (let j = start; j < end; j++) {
            if (matchedFlags[j]) continue;
            if (isSimilar(recognizedWords[i], scriptChunks[j])) {
                matchedFlags[j] = true;
                lastMatchedIndex = j;
                break;
            }
        }
    }

    if (lastMatchedIndex === -1) return 0;
    return (lastMatchedIndex + 1) / scriptChunks.length;
}

export function calculateAccuracy(scriptChunks, recognizedText) {
    const recognizedWords = splitText(recognizedText);
    if (!scriptChunks.length || !recognizedWords.length) return 1;

    const matchedFlags = new Array(scriptChunks.length).fill(false);
    let lastMatchedIndex = -1;
    let matchedCount = 0;

    for (let i = 0; i < recognizedWords.length; i++) {
        const start = Math.max(0, lastMatchedIndex - 8);
        const end = Math.min(scriptChunks.length, lastMatchedIndex + 8);

        for (let j = start; j < end; j++) {
            if (matchedFlags[j]) continue;
            if (isSimilar(recognizedWords[i], scriptChunks[j])) {
                matchedFlags[j] = true;
                lastMatchedIndex = j;
                matchedCount++;
                break;
            }
        }
    }

    return recognizedWords.length === 0
        ? 1
        : Math.min(matchedCount / recognizedWords.length, 1);
}

export function getMatchedFlags(scriptChunks, recognizedText) {
    const recognizedWords = splitText(recognizedText);
    const matchedFlags = new Array(scriptChunks.length).fill(false);
    const usedIndexes = new Set();
    let lastMatchedIndex = -1;

    for (let i = 0; i < scriptChunks.length; i++) {
        const start = Math.max(0, lastMatchedIndex - 8);
        const end = Math.min(recognizedWords.length, lastMatchedIndex + 8);

        for (let j = start; j < end; j++) {
            if (usedIndexes.has(j)) continue;
            if (isSimilar(scriptChunks[i], recognizedWords[j])) {
                matchedFlags[i] = true;
                usedIndexes.add(j);
                lastMatchedIndex = j;
                break;
            }
        }
    }

    return matchedFlags;
}
