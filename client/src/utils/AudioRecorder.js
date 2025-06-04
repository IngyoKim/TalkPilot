export function AudioRecorder(socket) {
    let audioContext;
    let processorNode;
    let input;
    let stream;

    const startRecording = async () => {
        try {
            console.log('[Recorder] 마이크 스트림 요청 중...');
            stream = await navigator.mediaDevices.getUserMedia({ audio: true });
            console.log('[Recorder] 마이크 스트림 획득 성공');

            audioContext = new AudioContext();
            input = audioContext.createMediaStreamSource(stream);

            // AudioWorkletProcessor를 AudioContext에 추가
            await audioContext.audioWorklet.addModule('./AudioWorkletProcessor.js'); // 경로 수정 필요

            processorNode = new AudioWorkletNode(audioContext, 'audio-worklet-processor');

            // WebSocket으로 PCM 데이터를 전송하는 처리
            processorNode.port.onmessage = (event) => {
                const pcm = event.data;
                if (socket?.connected) {
                    socket.emit('audio-chunk', pcm); // WebSocket을 통해 서버로 전송
                }
            };

            input.connect(processorNode);
            processorNode.connect(audioContext.destination);

            if (socket?.connected) {
                socket.emit('start-audio'); // 오디오 시작
            }
        } catch (err) {
            console.error('[Recorder] startRecording 실패:', err);
        }
    };

    const stopRecording = () => {
        console.log('[Recorder] 녹음 중지 요청');

        // 위에서 생성한 processorNode 및 기타 자원 해제
        if (processorNode) {
            processorNode.disconnect();
        }
        if (input) {
            input.disconnect();
        }
        if (stream) {
            stream.getTracks().forEach(track => track.stop());
        }
        if (audioContext) {
            audioContext.close();
        }

        if (socket?.connected) {
            socket.emit('end-audio'); // 오디오 종료
        }
    };

    return { startRecording, stopRecording };
}