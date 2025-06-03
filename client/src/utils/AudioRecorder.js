export function AudioRecorder(socket) {
    let audioContext;
    let processor;
    let input;
    let stream;

    const startRecording = async () => {
        try {
            console.log('[Recorder] 마이크 스트림 요청 중...');
            stream = await navigator.mediaDevices.getUserMedia({ audio: true, video: false });
            console.log('[Recorder] 마이크 스트림 획득 성공');

            audioContext = new AudioContext();
            input = audioContext.createMediaStreamSource(stream);

            processor = audioContext.createScriptProcessor(4096, 1, 1);
            processor.onaudioprocess = (e) => {
                const inputData = e.inputBuffer.getChannelData(0);
                const pcm = float32ToInt16(inputData);

                if (socket?.connected) {  // 여기서 socket은 소켓 인스턴스
                    socket.emit('audio-chunk', pcm);
                }
            };

            input.connect(processor);
            processor.connect(audioContext.destination);

            if (socket?.connected) {
                socket.emit('start-audio');
            }
        } catch (err) {
            console.error('[Recorder] startRecording 실패:', err);
        }
    };

    const stopRecording = () => {
        console.log('[Recorder] 녹음 중지 요청');

        processor?.disconnect();
        input?.disconnect();
        stream?.getTracks().forEach(track => track.stop());
        audioContext?.close();

        if (socket?.connected) {
            socket.emit('end-audio');
        }
    };

    return { startRecording, stopRecording };
}

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
