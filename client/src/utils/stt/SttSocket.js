import { useRef, useState } from 'react';
import io from 'socket.io-client';
import { useAuth } from '@/contexts/AuthContext';

export default function useSttSocket() {
    const { authUser } = useAuth();
    const firebaseToken = authUser?.token;

    const socketRef = useRef(null);
    const [isConnected, setIsConnected] = useState(false);
    const [transcripts, setTranscripts] = useState([]);
    const [transcriptText, setTranscriptText] = useState('');
    const [speakingDuration, setSpeakingDuration] = useState(0);

    const sentWordsRef = useRef(new Set());
    const sessionStartRef = useRef(null);
    const lastTranscriptRef = useRef(null);
    const onTranscriptCallbackRef = useRef(null);

    const setOnTranscript = (cb) => {
        onTranscriptCallbackRef.current = cb;
    };
    const connect = () => {
        return new Promise((resolve, reject) => {
            if (!firebaseToken) {
                console.warn('[STT] 토큰 없음');
                reject(new Error('No token'));
                return;
            }

            if (socketRef.current) {
                socketRef.current.disconnect();
                socketRef.current = null;
            }

            /// url을 https 프로토콜에서 wss 프로토콜로 변경
            /// web socket은 secure websocket으로 통신함.
            /// 일단 작동이 되니깐 건들지 말기!!
            /// 제발...이거 만드는데 너무 힘들었어요...
            const rawUrl = import.meta.env.VITE_SERVER_URL;
            const wsUrl = rawUrl.startsWith('https')
                ? rawUrl.replace(/^https/, 'wss')
                : rawUrl.replace(/^http/, 'ws');

            const socket = io(wsUrl, {
                transports: ['websocket'],
                auth: { token: `Bearer ${firebaseToken}` },
            });

            socket.on('connect', () => {
                setIsConnected(true);
                socket.emit('start-audio');
                resolve();
            });

            socket.on('disconnect', () => {
                setIsConnected(false);
            });

            socket.on('connect_error', (e) => {
                console.error('[STT] 연결 실패:', e);
                setIsConnected(false);
                reject(e);
            });

            socket.on('stt-result', (data) => {
                console.log('[STT] 받은 데이터:', data);

                const transcript = data?.transcript?.trim();
                const timestamp = data?.timestamp;

                if (!transcript) {
                    console.warn('[STT] transcript가 비어있음. 무시함.');
                    return;
                }

                const currentTime = new Date(timestamp);

                if (!sessionStartRef.current) {
                    sessionStartRef.current = currentTime;
                }
                lastTranscriptRef.current = currentTime;

                const words = transcript.split(/\s+/);
                let newText = '';

                for (const word of words) {
                    if (!sentWordsRef.current.has(word)) {
                        sentWordsRef.current.add(word);
                        newText += word + ' ';
                    }
                }

                setTranscriptText((prev) => (prev + newText).trim());
                setTranscripts((prev) => [...prev, { transcript, timestamp }]);

                /// 필요 시 외부 콜백 실행(실제로는 안 쓸 듯?)
                if (onTranscriptCallbackRef.current) {
                    onTranscriptCallbackRef.current(transcript);
                }
            });


            socketRef.current = socket;
        });
    };

    const disconnect = () => {
        socketRef.current?.disconnect();
        socketRef.current = null;
        setIsConnected(false);
    };

    const sendAudioChunk = (chunk) => {
        if (socketRef.current?.connected) {
            socketRef.current.emit('audio-chunk', chunk);
        } else {
            console.warn('[Socket] 연결 안됨. 전송 실패');
        }
    };

    const endAudio = () => {
        if (socketRef.current?.connected) {
            socketRef.current.emit('end-audio');
        }

        const now = new Date();
        const sessionStart = sessionStartRef.current;
        const lastTranscript = lastTranscriptRef.current;

        if (sessionStart && lastTranscript) {
            const total = now - sessionStart;
            const silentGap = now - lastTranscript;
            const effective = silentGap > 3000 ? total - silentGap : total;
            setSpeakingDuration(Math.max(0, effective));
        }
    };

    const clearTranscript = () => {
        setTranscripts([]);
        setTranscriptText('');
        setSpeakingDuration(0);
        sentWordsRef.current.clear();
        sessionStartRef.current = null;
        lastTranscriptRef.current = null;
    };

    return {
        socket: socketRef,
        isConnected,
        connect,
        disconnect,
        transcripts,
        transcriptText,
        speakingDuration,
        sendAudioChunk,
        endAudio,
        clearTranscript,
        setOnTranscript,
    };
}
