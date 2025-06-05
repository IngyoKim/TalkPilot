export function AudioRecorder(sendAudioChunk) {
    let audioContext;
    let processorNode;
    let input;
    let stream;

    const startRecording = async () => {
        try {
            stream = await navigator.mediaDevices.getUserMedia({ audio: true });
            audioContext = new AudioContext({ sampleRate: 16000 });
            input = audioContext.createMediaStreamSource(stream);

            await audioContext.audioWorklet.addModule('/audio-worklet-processor.js');
            processorNode = new AudioWorkletNode(audioContext, 'audio-worklet-processor');

            processorNode.port.onmessage = (event) => {
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
        try {
            if (processorNode?.port) {
                processorNode.port.onmessage = null;
            }

            if (processorNode) processorNode.disconnect();
            if (input) input.disconnect();

            if (stream) {
                stream.getTracks().forEach(track => {
                    track.stop();
                });
            }

            if (audioContext && audioContext.state !== 'closed') {
                await audioContext.close();
                console.log('[Recorder] AudioContext 종료');
            }
        } catch (e) {
            console.error('[Recorder] stopRecording 실패:', e);
        }
    };

    return { startRecording, stopRecording };
}
