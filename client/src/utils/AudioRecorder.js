import { useRef } from 'react';

export function AudioRecorder(socketRef) {
    const mediaStreamRef = useRef(null);
    const mediaRecorderRef = useRef(null);

    const startRecording = async () => {
        const stream = await navigator.mediaDevices.getUserMedia({
            audio: { channelCount: 1, sampleRate: 16000 },
            video: false,
        });
        mediaStreamRef.current = stream;

        const mediaRecorder = new MediaRecorder(stream, {
            mimeType: 'audio/webm',
        });

        mediaRecorder.ondataavailable = async (e) => {
            if (e.data.size > 0 && socketRef.current?.connected) {
                const arrayBuffer = await e.data.arrayBuffer();
                socketRef.current.emit('audio-chunk', arrayBuffer);
            }
        };

        mediaRecorderRef.current = mediaRecorder;

        socketRef.current.emit('start-audio');
        mediaRecorder.start(250);
    };

    const stopRecording = () => {
        mediaRecorderRef.current?.stop();
        mediaStreamRef.current?.getTracks().forEach((track) => track.stop());
        socketRef.current.emit('end-audio');
    };

    return { startRecording, stopRecording };
}
