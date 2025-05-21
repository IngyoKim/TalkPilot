import { useParams } from 'react-router-dom';

export default function ProjectDetail() {
    const { id } = useParams();

    return (
        <div style={{ padding: '20px' }}>
            <h2>프로젝트 상세 페이지</h2>
            <p>선택한 프로젝트 ID: <strong>{id}</strong></p>
            {/* 여기에 수정 폼이나 DB 연결 가능 */}
        </div>
    );
}