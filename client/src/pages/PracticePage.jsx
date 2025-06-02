import { useEffect, useRef, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import * as projectAPI from '@/utils/api/project';
import { useUser } from '@/contexts/UserContext';
import SttSocket from '@/utils/SttSocket';
import { AudioRecorder } from '@/utils/AudioRecorder';

export default function PracticePage() {
    const { id: projectId } = useParams();
    const navigate = useNavigate();
    const { user } = useUser();

    const [project, setProject] = useState(null);
    const [recognizedText, setRecognizedText] = useState('');
    const [startTime, setStartTime] = useState(null);
    const [wpm, setWpm] = useState(0);
    const [cpm, setCpm] = useState(0);

    const { socket, transcripts } = SttSocket(user.token);
    const { startRecording, stopRecording } = AudioRecorder(socket);

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

        if (!startTime || allText.trim() === '') return;
        const elapsedMin = (Date.now() - startTime) / 60000;
        const wordCount = allText.trim().split(/\s+/).length;
        const charCount = allText.replace(/\s/g, '').length;
        setWpm(Math.round(wordCount / elapsedMin));
        setCpm(Math.round(charCount / elapsedMin));
    }, [transcripts, startTime]);

    const handleStart = () => {
        setRecognizedText('');
        setStartTime(Date.now());
        startRecording();
    };

    const handleStop = () => {
        stopRecording();
        navigate(`/presentation/${projectId}/result`, {
            state: { wpm, cpm, recognizedText },
        });
    };

    if (!project) return <div>로딩 중...</div>;

    const scriptWords = project.script?.split(/\s+/) ?? [];
    const recognizedWords = recognizedText.trim().split(/\s+/);

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
                    const isSpoken = idx < recognizedWords.length;
                    const isCurrent = idx === recognizedWords.length;
                    return (
                        <span
                            key={idx}
                            style={{
                                ...styles.word,
                                backgroundColor: isCurrent
                                    ? '#FFD54F'
                                    : isSpoken
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
                <p>WPM: {wpm} / CPM: {cpm}</p>
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
