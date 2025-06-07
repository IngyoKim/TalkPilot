import { useRef, useState } from 'react';
import io from 'socket.io-client';
import { useAuth } from '@/contexts/AuthContext';

export default function useSttSocket() {
    const { authUser } = useAuth();
    const firebaseToken = authUser?.token;

    const socketRef = useRef(null);
    const silenceTimerRef = useRef(null);
    const sessionStartRef = useRef(null);
    const lastTranscriptRef = useRef(null);
    const onTranscriptCallbackRef = useRef(null);
    const prevRecognizedTextRef = useRef('');

    const [isConnected, setIsConnected] = useState(false);
    const [transcripts, setTranscripts] = useState([]);
    const [recognizedText, setRecognizedText] = useState('');
    const [savedText, setSavedText] = useState('');
    const [speakingDuration, setSpeakingDuration] = useState(0);

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

                // recognizedText는 원문 그대로 저장
                setRecognizedText(transcript);

                // 🔥 prevRecognizedText 확인
                const prevRecognizedText = prevRecognizedTextRef.current.trim();
                const currentText = transcript.trim();

                // silenceTimer에서 savedText 업데이트
                if (silenceTimerRef.current) {
                    clearTimeout(silenceTimerRef.current);
                }

                silenceTimerRef.current = setTimeout(() => {
                    setSavedText((savedText) => {
                        const compareLength = 2;

                        const currentPrefix = currentText.length >= compareLength
                            ? currentText.substring(0, compareLength)
                            : currentText;

                        const prevPrefix = prevRecognizedText.length >= compareLength
                            ? prevRecognizedText.substring(0, compareLength)
                            : prevRecognizedText;

                        let newSavedText = savedText;

                        if (currentText.length === 0) {
                            newSavedText = savedText;
                        } else if (savedText.length === 0) {
                            newSavedText = currentText + ' ';
                        } else if (currentPrefix === prevPrefix) {
                            const newPart = currentText.length > prevRecognizedText.length
                                ? currentText.substring(prevRecognizedText.length).trim()
                                : '';
                            if (newPart.length > 0) {
                                newSavedText = savedText + newPart + ' ';
                            }
                        } else {
                            let commonLength = 0;
                            while (
                                commonLength < currentText.length &&
                                commonLength < prevRecognizedText.length &&
                                currentText.charAt(commonLength) === prevRecognizedText.charAt(commonLength)
                            ) {
                                commonLength++;
                            }

                            const newPart = currentText.substring(commonLength).trim();

                            if (newPart.length > 0) {
                                newSavedText = savedText + newPart + ' ';
                            } else {
                                newSavedText = savedText + currentText + ' ';
                            }
                        }

                        // ✅ prevRecognizedText 갱신 조건 추가
                        if (currentText.length >= prevRecognizedText.length) {
                            prevRecognizedTextRef.current = currentText;
                            console.log('✅ prevRecognizedText 갱신됨');
                        } else {
                            console.log('⚠️ prevRecognizedText 유지 (current shorter)');
                        }

                        return newSavedText;
                    });
                }, 100);

                // transcripts는 로그용으로 유지
                setTranscripts((prev) => [...prev, { transcript, timestamp }]);

                // 필요 시 외부 콜백 실행
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
        setRecognizedText('');
        setSavedText('');
        setSpeakingDuration(0);
        sessionStartRef.current = null;
        lastTranscriptRef.current = null;
        prevRecognizedTextRef.current = ''; // prevRecognizedText도 초기화!
    };

    return {
        socket: socketRef,
        isConnected,
        connect,
        disconnect,
        transcripts,
        recognizedText,
        savedText,
        speakingDuration,
        sendAudioChunk,
        endAudio,
        clearTranscript,
        setOnTranscript,
    };
}
