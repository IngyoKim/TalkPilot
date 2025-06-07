import { useEffect, useMemo, useRef, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import * as projectAPI from '@/utils/api/project';
import { useUser } from '@/contexts/UserContext';
import useSttSocket from '@/utils/stt/SttSocket';
import { AudioRecorder } from '@/utils/stt/AudioRecorder';
import LiveCpm from '@/utils/stt/LiveCpm';
import {
    calculateAccuracy,
    splitText,
    getMatchedFlags,
} from '@/utils/stt/ScriptUtils';

// ... import 그대로 유지

export default function PracticePage() {
    const { id: projectId } = useParams();
    const navigate = useNavigate();
    const { user } = useUser();

    const [project, setProject] = useState(null);
    const [recognizedText, setRecognizedText] = useState('');
    const [savedText, setSavedText] = useState('');
    const [wpm, setWpm] = useState(0);
    const [elapsedTime, setElapsedTime] = useState(0);
    const [isRecording, setIsRecording] = useState(false);

    const {
        socket,
        connect,
        disconnect,
        recognizedText: socketRecognizedText,
        savedText: socketSavedText,
        speakingDuration,
        transcripts,
        isConnected,
        clearTranscript,
        endAudio,
        sendAudioChunk,
    } = useSttSocket();

    const recorderRef = useRef(null);
    const timerRef = useRef(null);

    const { cpm, status, start: startCpm, update: updateCpm, stop: stopCpm } = LiveCpm(user?.cpm ?? 200);

    useEffect(() => {
        const load = async () => {
            if (!projectId) return;
            const result = await projectAPI.fetchProjectById(projectId);
            setProject(result);
        };
        load();
    }, [projectId]);

    useEffect(() => {
        setRecognizedText(socketRecognizedText);
        setSavedText(socketSavedText);
        updateCpm(socketRecognizedText);

        const startTime = transcripts[0]?.timestamp;
        const elapsedMin = startTime ? (Date.now() - new Date(startTime)) / 60000 : 0;

        if (elapsedMin > 0.1) {
            const wordCount = socketRecognizedText.trim().split(/\s+/).length;
            setWpm(Math.round(wordCount / elapsedMin));
        }
    }, [socketRecognizedText, socketSavedText, transcripts]);

    useEffect(() => {
        return () => {
            console.log('[PracticePage] Cleaning up...');
            recorderRef.current?.stopRecording();
            recorderRef.current = null;
            stopCpm();
            endAudio();
            disconnect();
            if (timerRef.current) {
                clearInterval(timerRef.current);
                timerRef.current = null;
            }
        };
    }, []);

    const scriptChunks = useMemo(() => splitText(project?.script ?? ''), [project?.script]);
    const matchedFlags = useMemo(
        () => getMatchedFlags(scriptChunks, socketSavedText),
        [scriptChunks, socketSavedText, socketRecognizedText]
    );

    const progress = useMemo(() => {
        const recognizedWords = splitText(socketSavedText);
        let matchCount = 0;

        for (let i = 0; i < recognizedWords.length && i < scriptChunks.length; i++) {
            if (scriptChunks[i] === recognizedWords[i]) {
                matchCount = i + 1;
            } else {
                matchCount = i + 1;
            }
        }

        return matchCount / scriptChunks.length;
    }, [socketSavedText, socketRecognizedText, scriptChunks]);

    // ✅ CPM 계산 추가
    const cpmProgressBased = useMemo(() => {
        if (!project?.script?.length || elapsedTime === 0) return 0;
        const cps = (progress * project.script.length) / elapsedTime;
        return cps * 60;
    }, [progress, project?.script?.length, elapsedTime]);

    const expectedDurationSec = project?.estimatedTime ?? 120;

    const handleStart = async () => {
        try {
            if (isRecording) return;
            if (!isConnected) await connect();
            if (!socket.current || !socket.current.connected) {
                alert('STT 서버와 연결되지 않았습니다.');
                return;
            }

            clearTranscript();
            setRecognizedText('');
            setSavedText('');
            setElapsedTime(0);

            recorderRef.current = AudioRecorder(sendAudioChunk);
            await recorderRef.current.startRecording();
            startCpm();
            setIsRecording(true);

            timerRef.current = setInterval(() => {
                setElapsedTime((prev) => prev + 1);
            }, 1000);
        } catch (e) {
            console.error(e);
            alert('STT 서버 연결 실패');
        }
    };

    const handleStop = async () => {
        try {
            if (!isRecording) return;
            await recorderRef.current?.stopRecording();
            recorderRef.current = null;
            stopCpm();
            endAudio();
            disconnect();
            setIsRecording(false);

            if (timerRef.current) {
                clearInterval(timerRef.current);
                timerRef.current = null;
            }

            const accuracy = calculateAccuracy(scriptChunks, socketSavedText);

            if (progress >= 0.9) {
                navigate(`/result/${projectId}`, {
                    state: {
                        wpm,
                        cpm,
                        recognizedText: socketSavedText,
                        accuracy,
                        progress,
                        status,
                        speakingDuration,
                        elapsedTime,
                    },
                });
            } else {
                navigate(`/project/${projectId}`);
            }
        } catch (e) {
            console.error(e);
        }
    };

    const handleGoToResult = () => {
        const accuracy = calculateAccuracy(scriptChunks, socketSavedText);

        navigate(`/result/${projectId}`, {
            state: {
                wpm,
                cpm,
                recognizedText: socketSavedText,
                accuracy,
                progress,
                status,
                speakingDuration,
                elapsedTime,
            },
        });
    };

    if (!project) return <div>프로젝트 정보 로딩 중...</div>;

    return (
        <div style={styles.container}>

            <h2>발표 연습 - {project.title}</h2>
            <p>대본 길이: {project.script?.length ?? 0}자</p>

            <div style={styles.controlRow}>
                {isRecording && progress >= 0.9 ? (
                    <button onClick={handleGoToResult} style={styles.button}>결과 보러 가기</button>
                ) : isRecording ? (
                    <button onClick={handleStop} style={styles.button}>중지</button>
                ) : progress >= 0.9 ? (
                    <button onClick={handleGoToResult} style={styles.button}>결과 보러 가기</button>
                ) : (
                    <button onClick={handleStart} style={styles.button}>시작</button>
                )}
            </div>

            <div style={styles.resultBox}>
                <h3 style={styles.resultTitle}>발표 결과</h3>
                <div style={styles.resultItem}>
                    <span style={styles.resultLabel}>진행률:</span>
                    <span style={styles.resultValue}>{(progress * 100).toFixed(1)}%</span>
                </div>
                <div style={styles.resultItem}>
                    <span style={styles.resultLabel}>정확도:</span>
                    <span style={styles.resultValue}>
                        {(calculateAccuracy(scriptChunks, socketSavedText) * 100).toFixed(1)}%
                    </span>
                </div>
                <div style={styles.resultItem}>
                    <span style={styles.resultLabel}>CPM (진행률 기준):</span>
                    <span style={styles.resultValue}>{Math.round(cpmProgressBased)} CPM</span>
                </div>
                <div style={styles.resultItem}>
                    <span style={styles.resultLabel}>발표 시간:</span>
                    <span style={styles.resultValue}>{elapsedTime}초 / 예상 {Math.round(expectedDurationSec)}초</span>
                </div>
            </div>

            <div style={styles.scriptBox}>
                {scriptChunks.map((word, idx) => {
                    const isMatched = matchedFlags[idx];

                    return (
                        <span
                            key={idx}
                            style={{
                                ...styles.word,
                                backgroundColor: isMatched ? '#D1C4E9' : 'transparent',
                            }}
                        >
                            {word}{' '}
                        </span>
                    );
                })}
            </div>
        </div>
    );
}


const styles = {
    container: {
        padding: 40,
        fontFamily: 'sans-serif'
    },
    controlRow: {
        marginTop: 20,
        marginBottom: 20,
        display: 'flex',
        gap: 12
    },
    button: {
        padding: '10px 20px',
        fontWeight: 'bold',
        borderRadius: 8,
        backgroundColor: '#673AB7',
        color: '#fff',
        border: 'none',
    },
    scriptBox: {
        marginTop: 20,
        padding: 20,
        backgroundColor: '#f9f9f9',
        borderRadius: 8,
        lineHeight: 1.8,
    },
    word: {
        padding: '2px 4px',
        borderRadius: 4
    },
    resultBox: {
        marginTop: 20,
        padding: 20,
        backgroundColor: '#ffffff',
        borderRadius: 12,
        boxShadow: '0 2px 8px rgba(0, 0, 0, 0.1)',
        lineHeight: 1.6,
        display: 'flex',
        flexDirection: 'column',
        gap: '10px',
    },
    resultTitle: {
        fontSize: '18px',
        fontWeight: 'bold',
        marginBottom: '10px',
        color: '#333',
    },
    resultItem: {
        display: 'flex',
        flexWrap: 'wrap',
        alignItems: 'center',
        fontSize: '15px',
    },
    resultLabel: {
        fontWeight: 'bold',
        color: '#555',
        marginRight: '8px',
    },
    resultValue: {
        color: '#222',
    },
};
