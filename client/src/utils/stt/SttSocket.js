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

                /// Flutter처럼 recognizedText는 원문 그대로 저장
                setRecognizedText(transcript);

                // console.log('🟢 recognizedText updated to:', transcript);

                /// Flutter처럼 savedText는 _silenceTimer에서 prefix 비교 후 업데이트
                if (silenceTimerRef.current) {
                    clearTimeout(silenceTimerRef.current);
                }

                silenceTimerRef.current = setTimeout(() => {
                    setSavedText((savedText) => {
                        const compareLength = 2;

                        const currentText = transcript.trim();
                        const lastSaved = savedText.trim();

                        const currentPrefix = currentText.length >= compareLength
                            ? currentText.substring(0, compareLength)
                            : currentText;

                        const savedPrefix = lastSaved.length >= compareLength
                            ? lastSaved.substring(0, compareLength)
                            : lastSaved;

                        let newSavedText = savedText;

                        if (currentText.length === 0) {
                            newSavedText = savedText;
                        } else if (lastSaved.length === 0) {
                            newSavedText = currentText + ' ';
                        }
                        if (currentPrefix === savedPrefix) {
                            const newPart = currentText.length > lastSaved.length
                                ? currentText.substring(lastSaved.length).trim()
                                : '';
                            if (newPart.length > 0) {
                                newSavedText = savedText + newPart + ' ';
                            } else {
                                newSavedText = savedText;
                            }
                        } else {
                            /// 동일 문장이 계속 반복되는 경우 방지
                            if (savedText.endsWith(currentText + ' ') || savedText.endsWith(currentText)) {
                                return savedText;
                            } else {
                                return savedText + currentText + ' ';
                            }
                        }

                        console.log('🟠 savedText updated to:', newSavedText);

                        return newSavedText;
                    });
                }, 1000);

                /// transcripts는 로그용으로 유지
                setTranscripts((prev) => [...prev, { transcript, timestamp }]);

                /// 필요 시 외부 콜백 실행
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
