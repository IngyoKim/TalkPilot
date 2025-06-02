import { useEffect, useRef, useState } from 'react';
import io from 'socket.io-client';

export default function SttSocket(firebaseToken) {
    const socketRef = useRef(null);
    const [transcripts, setTranscripts] = useState([]);

    useEffect(() => {
        const socket = io(import.meta.env.VITE_SERVER_URL, {
            transports: ['websocket'],
            auth: { token: `Bearer ${firebaseToken}` },
        });

        socket.on('connect', () => console.log('[STT] 연결됨'));
        socket.on('disconnect', () => console.log('[STT] 연결 끊김'));
        socket.on('stt-result', (data) => {
            const { transcript, timestamp } = data;
            setTranscripts((prev) => [...prev, { transcript, timestamp }]);
        });

        socketRef.current = socket;

        return () => {
            socket.disconnect();
        };
    }, [firebaseToken]);

    return {
        socket: socketRef,
        transcripts,
    };
}
