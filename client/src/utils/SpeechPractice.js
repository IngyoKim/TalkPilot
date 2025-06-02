import { useEffect, useRef, useState } from 'react';
import io from 'socket.io-client';

export default function SpeechPractice(firebaseToken) {
    const socketRef = useRef(null);
    const mediaStreamRef = useRef(null);
    const mediaRecorderRef = useRef(null);
    const [transcripts, setTranscripts] = useState([]);

    useEffect(() => {
        const socket = io(import.meta.env.VITE_STT_SERVER_URL, {
            transports: ['websocket'],
            auth: { token: `Bearer ${firebaseToken}` },
        });

        socket.on('connect', () => console.log('Connected to STT server'));
        socket.on('disconnect', () => console.log('Disconnected'));
        socket.on('stt-result', (data) => {
            const { transcript, timestamp } = data;
            setTranscripts((prev) => [...prev, { transcript, timestamp }]);
        });

        socketRef.current = socket;

        return () => {
            socket.disconnect();
        };
    }, [firebaseToken]);

    const startSpeech = async () => {
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
        mediaRecorder.start(250); // 250ms마다 chunk 전송
    };

    const stopSpeech = () => {
        mediaRecorderRef.current?.stop();
        mediaStreamRef.current?.getTracks().forEach((track) => track.stop());
        socketRef.current.emit('end-audio');
    };

    return {
        transcripts,
        startSpeech,
        stopSpeech,
    };
}
