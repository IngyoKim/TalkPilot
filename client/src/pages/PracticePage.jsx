import { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import * as projectAPI from '@/utils/api/project';
import { useUser } from '@/contexts/UserContext';
import useSttSocket from '@/utils/SttSocket';
import { AudioRecorder } from '@/utils/AudioRecorder';
import LiveCpm from '@/utils/LiveCpm';
import {
    calculateAccuracy,
    calculateProgress,
    splitText,
    getMatchedFlags,
} from '@/utils/scriptUtils';

export default function PracticePage() {
    const { id: projectId } = useParams();
    const navigate = useNavigate();
    const { user } = useUser();

    const [project, setProject] = useState(null);
    const [recognizedText, setRecognizedText] = useState('');
    const [wpm, setWpm] = useState(0);

    const {
        socket,
        connect,
        disconnect,
        transcriptText,
        speakingDuration,
        transcripts,
        isConnected,
        clearTranscript,
        endAudio,
        sendAudioChunk,
    } = useSttSocket();

    /// sendAudioChunk를 넘기도록 수정
    /// 아 진짜 죽을거 같아요...왤케 해결이 안됨???
    const { startRecording, stopRecording } = AudioRecorder(sendAudioChunk);

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
        setRecognizedText(transcriptText);
        updateCpm(transcriptText);

        const startTime = transcripts[0]?.timestamp;
        const elapsedMin = startTime ? (Date.now() - new Date(startTime)) / 60000 : 0;

        if (elapsedMin > 0.1) {
            const wordCount = transcriptText.trim().split(/\s+/).length;
            setWpm(Math.round(wordCount / elapsedMin));
        }
    }, [transcriptText, transcripts]);

    const handleStart = async () => {
        try {
            if (!isConnected) {
                await connect();
            }

            if (!socket.current || !socket.current.connected) {
                alert('STT 서버와 연결되지 않았습니다. 잠시 후 다시 시도하세요.');
                return;
            }

            clearTranscript();
            setRecognizedText('');
            startRecording();
            startCpm();
        } catch (e) {
            alert('STT 서버 연결에 실패했습니다.');
            console.error(e);
        }
    };

    const handleStop = async () => {
        await stopRecording();
        stopCpm();
        await endAudio();

        const accuracy = calculateAccuracy(project.script, transcriptText);
        const progress = calculateProgress(project.script, transcriptText);

        navigate(`/result/${projectId}`, {
            state: {
                wpm,
                cpm,
                recognizedText: transcriptText,
                accuracy,
                progress,
                status,
                speakingDuration,
            },
        });
    };

    if (!project) return <div>프로젝트 정보 로딩 중...</div>;

    const scriptWords = splitText(project.script ?? '');
    const matchedFlags = getMatchedFlags(project.script ?? '', transcriptText);
    const currentIndex = matchedFlags.findIndex(flag => !flag);

    return (
        <div style={styles.container}>
            <h2>발표 연습 - {project.title}</h2>
            <p>대본 길이: {project.script?.length ?? 0}자</p>

            <div
                style={{
                    marginBottom: 20,
                    padding: 12,
                    backgroundColor: '#e3f2fd',
                    borderRadius: 6,
                    minHeight: 50,
                    whiteSpace: 'pre-wrap',
                }}
            >
                <strong>현재 STT 텍스트:</strong>
                <p>{transcriptText || '아직 입력이 없습니다.'}</p>
            </div>

            <div style={styles.controlRow}>
                <button onClick={handleStart} style={styles.button}>시작</button>
                <button onClick={handleStop} style={styles.button}>종료</button>
            </div>

            <div style={styles.scriptBox}>
                {scriptWords.map((word, idx) => {
                    const isMatched = matchedFlags[idx];
                    const isCurrent = idx === currentIndex;
                    return (
                        <span
                            key={idx}
                            style={{
                                ...styles.word,
                                backgroundColor: isCurrent ? '#FFD54F' : isMatched ? '#D1C4E9' : 'transparent',
                            }}
                        >
                            {word}{' '}
                        </span>
                    );
                })}
            </div>

            <div style={styles.resultBox}>
                <p><strong>STT 결과:</strong> {transcriptText}</p>
                <p>WPM: {wpm} / CPM: {cpm} ({status})</p>
                <p>발표 시간: {(speakingDuration / 1000).toFixed(1)}초</p>
            </div>
        </div>
    );
}

const styles = {
    container: { padding: 40, fontFamily: 'sans-serif' },
    controlRow: { marginTop: 20, marginBottom: 20, display: 'flex', gap: 12 },
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
        borderRadius: 4,
    },
    resultBox: {
        marginTop: 20,
        padding: 20,
        backgroundColor: '#f3f3f3',
        borderRadius: 8,
    },
};
