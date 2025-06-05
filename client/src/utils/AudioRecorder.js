export function AudioRecorder(sendAudioChunk) {
    let audioContext;
    let processorNode;
    let input;
    let stream;

    const startRecording = async () => {
        try {
            console.log('[Recorder] 마이크 스트림 요청 중...');
            stream = await navigator.mediaDevices.getUserMedia({ audio: true });
            console.log('[Recorder] 마이크 스트림 획득 성공');

            audioContext = new AudioContext({ sampleRate: 16000 });
            input = audioContext.createMediaStreamSource(stream);

            await audioContext.audioWorklet.addModule('/audio-worklet-processor.js');

            processorNode = new AudioWorkletNode(audioContext, 'audio-worklet-processor');

            processorNode.port.onmessage = (event) => {
                console.log('[Recorder] PCM 수신됨:', event.data);
                const pcm = event.data;
                sendAudioChunk?.(pcm);
            };

            input.connect(processorNode);
            processorNode.connect(audioContext.destination);
        } catch (e) {
            console.error('[Recorder] startRecording 실패:', e);
        }
    };

    const stopRecording = async () => {
        if (processorNode) processorNode.disconnect();
        if (input) input.disconnect();
        if (stream) stream.getTracks().forEach((track) => track.stop());
        if (audioContext) await audioContext.close();

        if (socket?.connected) {
            socket.emit('end-audio');
        }
    };

    return { startRecording, stopRecording };
}
