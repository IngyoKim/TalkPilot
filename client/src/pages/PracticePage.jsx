import { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import * as projectAPI from '@/utils/api/project';
import { useUser } from '@/contexts/UserContext';
import SttSocket from '@/utils/SttSocket';
import { AudioRecorder } from '@/utils/AudioRecorder';
import LiveCpm from '@/utils/LiveCpm';
import {
    calculateAccuracy,
    calculateProgress,
    splitText,
    getMatchedFlags
} from '@/utils/scriptUtils';

export default function PracticePage() {
    const { id: projectId } = useParams();
    const navigate = useNavigate();
    const { user } = useUser();

    const [project, setProject] = useState(null);
    const [recognizedText, setRecognizedText] = useState('');
    const [wpm, setWpm] = useState(0);

    const { socket, transcripts } = SttSocket(user.token);
    const { startRecording, stopRecording } = AudioRecorder(socket);
    const { cpm, status, start: startCpm, update: updateCpm, stop: stopCpm } = LiveCpm(user.cpm ?? 200);

    useEffect(() => {
        const load = async () => {
            const result = await projectAPI.fetchProjectById(projectId);
            setProject(result);
        };
        load();
    }, [projectId]);

    useEffect(() => {
        const allText = transcripts.map(t => t.transcript).join(' ');
        setRecognizedText(allText);
        updateCpm(allText);

        const startTime = transcripts[0]?.timestamp;
        const elapsedMin = startTime
            ? (Date.now() - new Date(startTime)) / 60000
            : 0;

        if (elapsedMin > 0.1) {
            const wordCount = allText.trim().split(/\s+/).length;
            setWpm(Math.round(wordCount / elapsedMin));
        }
    }, [transcripts]);

    const handleStart = () => {
        setRecognizedText('');
        startRecording();
        startCpm();
    };

    const handleStop = () => {
        stopRecording();
        stopCpm();

        const accuracy = calculateAccuracy(project.script, recognizedText);
        const progress = calculateProgress(project.script, recognizedText);

        navigate(`/result/${projectId}`, {
            state: { wpm, cpm, recognizedText, accuracy, progress, status },
        });
    };

    if (!project) return <div>로딩 중...</div>;

    const scriptWords = splitText(project.script ?? '');
    const matchedFlags = getMatchedFlags(project.script ?? '', recognizedText);
    const currentIndex = matchedFlags.findIndex(flag => !flag);

    return (
        <div style={styles.container}>
            <h2>발표 연습 - {project.title}</h2>
            <p>대본 길이: {project.script?.length ?? 0}자</p>

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
                                backgroundColor: isCurrent
                                    ? '#FFD54F'
                                    : isMatched
                                        ? '#D1C4E9'
                                        : 'transparent'
                            }}
                        >
                            {word}{' '}
                        </span>
                    );
                })}
            </div>

            <div style={styles.resultBox}>
                <p><strong>STT 결과:</strong> {recognizedText}</p>
                <p>WPM: {wpm} / CPM: {cpm} ({status})</p>
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
        border: 'none'
    },
    scriptBox: {
        marginTop: 20,
        padding: 20,
        backgroundColor: '#f9f9f9',
        borderRadius: 8,
        lineHeight: 1.8
    },
    word: {
        padding: '2px 4px',
        borderRadius: 4
    },
    resultBox: {
        marginTop: 20,
        padding: 20,
        backgroundColor: '#f3f3f3',
        borderRadius: 8
    }
};
