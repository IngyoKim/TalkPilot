import { useLocation, useNavigate, useParams } from 'react-router-dom';
import { useEffect, useState } from 'react';
import * as projectAPI from '@/utils/api/project';

export default function PresentationResultPage() {
    const { id: projectId } = useParams();
    const navigate = useNavigate();
    const { state } = useLocation();
    const [project, setProject] = useState(null);

    useEffect(() => {
        const fetchProject = async () => {
            const result = await projectAPI.fetchProjectById(projectId);
            setProject(result);
        };
        fetchProject();
    }, [projectId]);

    if (!project) return <div>로딩 중...</div>;

    const averageCpm = project.cpm ?? 300;
    const speedDiff = ((state.cpm - averageCpm) / averageCpm) * 100;
    const interpretation =
        speedDiff < -30 ? '느림' : speedDiff > 30 ? '빠름' : '적당함';

    const score = Math.round(
        (state.accuracy * 100 * 0.5) + (Math.max(0, 100 - Math.abs(speedDiff)) * 0.5)
    );

    const targetScore = 90;
    const timeSec = Math.round(state.recognizedText.length / state.cpm * 60);
    const expectedSec = Math.round(project.script.length / averageCpm * 60);

    return (
        <div style={styles.container}>
            <h2 style={styles.header}>최종 결과</h2>

            <div style={styles.score}>
                <span style={styles.scoreValue}>{score.toFixed(1)}점</span>
                <p style={{
                    color: score >= targetScore ? '#4CAF50' : '#D32F2F',
                    fontWeight: 'bold',
                    marginTop: 4
                }}>
                    {score >= targetScore
                        ? '목표 점수를 넘었습니다!'
                        : '목표 점수를 넘지 못했습니다.'}
                </p>
                <p style={styles.sub}>목표 점수: {targetScore.toFixed(1)}점</p>
            </div>

            <div style={styles.resultBox}>
                <ResultRow label="대본 정확도" value={`${(state.accuracy * 100).toFixed(1)}%`} />
                <ResultRow label="평균 CPM" value={`${averageCpm.toFixed(1)} CPM`} />
                <ResultRow label="나의 CPM" value={`${state.cpm.toFixed(1)} CPM`} />
                <ResultRow label="속도 차이" value={`${speedDiff.toFixed(1)}%`} />
                <ResultRow label="속도 해석" value={interpretation} />
                <ResultRow label="발표 시간" value={`${timeSec}초`} />
                <ResultRow label="예상 시간" value={`${expectedSec}초`} />
            </div>

            <button style={styles.button} onClick={() => navigate('/')}>
                메인 화면으로 이동
            </button>
        </div>
    );
}

function ResultRow({ label, value }) {
    return (
        <div style={styles.row}>
            <span>{label}</span>
            <span><strong>{value}</strong></span>
        </div>
    );
}

const styles = {
    container: {
        padding: 32,
        fontFamily: 'sans-serif',
        textAlign: 'center'
    },
    header: {
        fontSize: 24,
        marginBottom: 20,
        color: '#673AB7'
    },
    score: {
        marginBottom: 20,
    },
    scoreValue: {
        fontSize: 48,
        fontWeight: 'bold',
        color: '#673AB7'
    },
    sub: { fontSize: 14, color: '#888' },
    resultBox: {
        backgroundColor: '#FAF7FF',
        padding: 20,
        borderRadius: 12,
        boxShadow: '0 0 8px rgba(0,0,0,0.05)',
        marginBottom: 30
    },
    row: {
        display: 'flex',
        justifyContent: 'space-between',
        padding: '10px 0',
        borderBottom: '1px solid #eee'
    },
    button: {
        padding: '12px 24px',
        fontSize: 16,
        backgroundColor: '#673AB7',
        color: '#fff',
        border: 'none',
        borderRadius: 8,
        fontWeight: 'bold',
        cursor: 'pointer'
    }
};
