/// 솔직히 이걸 왜 이렇게 해야하는지는 잘 모르겠는데..
/// 다른 똑똑하신 분이 이렇게 해둔걸 봤으니 이렇게 합시다.
class AudioProcessor extends AudioWorkletProcessor {
    constructor() {
        super();
    }

    process(inputs, outputs, parameters) {
        const input = inputs[0];
        if (input && input[0]) {
            const inputData = input[0];
            const pcm = float32ToInt16(inputData);
            this.port.postMessage(pcm);
        }
        return true;
    }
}

registerProcessor('audio-worklet-processor', AudioProcessor);

function float32ToInt16(buffer) {
    const result = new Int16Array(buffer.length);
    for (let i = 0; i < buffer.length; i++) {
        const s = Math.max(-1, Math.min(1, buffer[i]));
        result[i] = s < 0 ? s * 0x8000 : s * 0x7FFF;
        result[i] = Math.floor(result[i]);
    }
    return new Uint8Array(result.buffer);
}
