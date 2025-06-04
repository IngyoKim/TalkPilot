class AudioWorkletProcessor extends AudioWorkletProcessor {
    constructor() {
        super();
    }

    process(inputs, outputs, parameters) {
        const input = inputs[0];
        if (input) {
            const inputData = input[0]; // 첫 번째 채널 데이터
            const pcm = float32ToInt16(inputData); // PCM으로 변환

            // WebSocket을 통해 PCM 데이터를 보내는 부분
            if (this.port) {
                this.port.postMessage(pcm);
            }
        }
        return true;
    }
}

registerProcessor('audio-worklet-processor', AudioWorkletProcessor);

// 32-bit floating point to 16-bit PCM conversion
function float32ToInt16(buffer) {
    const l = buffer.length;
    const result = new Int16Array(l);
    for (let i = 0; i < l; i++) {
        const s = Math.max(-1, Math.min(1, buffer[i]));
        result[i] = s < 0 ? s * 0x8000 : s * 0x7FFF;
    }
    // Uint8Array로 변환해서 전송하는 게 일반적임
    return new Uint8Array(result.buffer);
}