export function splitText(text) {
    return text
        .trim()
        .replace(/[^가-힣a-zA-Z0-9\s]/g, '')
        .split(/\s+/)
        .filter(Boolean);
}

export function calculateProgressByLastMatch(scriptChunks, recognizedText) {
    const recognizedWords = splitText(recognizedText);
    if (!scriptChunks.length || !recognizedWords.length) return 0;

    const matchedFlags = new Array(scriptChunks.length).fill(false);
    let lastMatchedIndex = -1;

    for (let i = 0; i < recognizedWords.length; i++) {
        // Flutter 동일 → matching window = ±8
        const start = Math.max(0, lastMatchedIndex - 8);
        const end = Math.min(scriptChunks.length, lastMatchedIndex + 8);

        for (let j = start; j < end; j++) {
            if (matchedFlags[j]) continue;
            if (recognizedWords[i] === scriptChunks[j]) {
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
        // Flutter 동일 → matching window = ±8
        const start = Math.max(0, lastMatchedIndex - 8);
        const end = Math.min(scriptChunks.length, lastMatchedIndex + 8);

        for (let j = start; j < end; j++) {
            if (matchedFlags[j]) continue;
            if (recognizedWords[i] === scriptChunks[j]) {
                matchedFlags[j] = true;
                lastMatchedIndex = j;
                matchedCount++;
                break;
            }
        }
    }

    // Flutter는 (matchedCount / lastMatchedIndex), JS에서는 안전하게 +1
    return recognizedWords.length === 0
        ? 1
        : Math.min(matchedCount / (lastMatchedIndex + 1), 1);
}

export function getMatchedFlags(scriptChunks, recognizedText) {
    const recognizedWords = splitText(recognizedText);
    const matchedFlags = new Array(scriptChunks.length).fill(false);
    let lastMatchedIndex = -1;

    for (let i = 0; i < recognizedWords.length; i++) {
        // Flutter 동일 → matching window = ±8
        const start = Math.max(0, lastMatchedIndex - 8);
        const end = Math.min(scriptChunks.length, lastMatchedIndex + 8);

        for (let j = start; j < end; j++) {
            if (matchedFlags[j]) continue;
            if (recognizedWords[i] === scriptChunks[j]) {
                matchedFlags[j] = true;
                lastMatchedIndex = j;
                break;
            }
        }
    }

    return matchedFlags;
}
