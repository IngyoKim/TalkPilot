import { useLocation, useNavigate, useParams } from 'react-router-dom';
import { useEffect, useState } from 'react';
import * as projectAPI from '@/utils/api/project';
import { useUser } from '@/contexts/UserContext';

export default function PresentationResultPage() {
    const { id: projectId } = useParams();
    const { state } = useLocation();
    const navigate = useNavigate();
    const { user } = useUser();
    const [project, setProject] = useState(null);

    useEffect(() => {
        const fetchProject = async () => {
            const result = await projectAPI.fetchProjectById(projectId);
            setProject(result);
        };
        fetchProject();
    }, [projectId]);

    if (!project) return <div>로딩 중...</div>;

    return (
        <div style={styles.container}>
            <h2>결과 요약 - {project.title}</h2>

            <div style={styles.statsBox}>
                <p>WPM: {state.wpm}</p>
                <p>CPM: {state.cpm} ({state.status})</p>
                <p>정확도: {(state.accuracy * 100).toFixed(1)}%</p>
                <p>진행률: {(state.progress * 100).toFixed(1)}%</p>
            </div>

            <div style={styles.scriptBox}>
                <h4>STT 결과</h4>
                <p>{state.recognizedText}</p>
            </div>

            <div style={styles.scriptBox}>
                <h4>대본</h4>
                <p>{project.script}</p>
            </div>

            <div style={styles.buttonRow}>
                <button onClick={() => navigate(`/project/${projectId}`)} style={styles.button}>
                    프로젝트로 돌아가기
                </button>
            </div>
        </div>
    );
}

const styles = {
    container: { padding: 40, fontFamily: 'sans-serif' },
    statsBox: {
        padding: 20,
        backgroundColor: '#EDE7F6',
        borderRadius: 8,
        marginBottom: 20,
        lineHeight: 1.6
    },
    scriptBox: {
        padding: 20,
        backgroundColor: '#f4f4f4',
        borderRadius: 8,
        marginTop: 16
    },
    buttonRow: {
        marginTop: 30
    },
    button: {
        padding: '10px 20px',
        fontWeight: 'bold',
        borderRadius: 8,
        backgroundColor: '#673AB7',
        color: '#fff',
        border: 'none'
    }
};
