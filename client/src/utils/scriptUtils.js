/// flutter쪽과 마찬가지로 levenshtein Distance 기반의 Similarity 적용
export function splitText(text) {
    return text
        .trim()
        .replace(/[^가-힣a-zA-Z0-9\s]/g, '')
        .split(/\s+/)
        .filter(word => word);
}

export function isSimilar(a, b) {
    const normA = a.replace(/\s/g, '').toLowerCase();
    const normB = b.replace(/\s/g, '').toLowerCase();
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

export function calculateProgress(script, recognized) {
    const scriptWords = splitText(script);
    const recognizedWords = splitText(recognized);
    const matched = scriptWords.map((word, idx) =>
        recognizedWords.some((rw, j) => j >= idx - 8 && j <= idx + 8 && isSimilar(word, rw))
    );
    const lastIdx = matched.lastIndexOf(true);
    return lastIdx === -1 ? 0 : (lastIdx + 1) / scriptWords.length;
}

export function calculateAccuracy(script, recognized) {
    const scriptWords = splitText(script);
    const recognizedWords = splitText(recognized);
    const matched = recognizedWords.filter((rw, i) =>
        scriptWords.some((sw, j) => j >= i - 8 && j <= i + 8 && isSimilar(sw, rw))
    );
    return recognizedWords.length === 0 ? 1 : matched.length / recognizedWords.length;
}

/// 매칭이 되는 단어 반환(대본 하이라이트 처리를 위해서 추가함;;)
export function getMatchedFlags(script, recognized) {
    const scriptWords = splitText(script);
    const recognizedWords = splitText(recognized);

    const matchedFlags = new Array(scriptWords.length).fill(false);
    const usedIndexes = new Set();

    for (let i = 0; i < scriptWords.length; i++) {
        for (let j = Math.max(0, i - 8); j <= Math.min(recognizedWords.length - 1, i + 8); j++) {
            if (usedIndexes.has(j)) continue;
            if (isSimilar(scriptWords[i], recognizedWords[j])) {
                matchedFlags[i] = true;
                usedIndexes.add(j);
                break;
            }
        }
    }

    return matchedFlags;
}
