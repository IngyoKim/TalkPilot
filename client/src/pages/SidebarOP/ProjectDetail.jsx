import { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import Sidebar from '../../components/SideBar';
import ProfileDropdown from '../Profile/ProfileDropdown';
import * as projectAPI from '../../utils/api/project'; // 추가

export default function ProjectDetail() {
    const [isSidebarOpen, setIsSidebarOpen] = useState(true);
    const { id } = useParams();
    const navigate = useNavigate();

    const [title, setTitle] = useState('');
    const [description, setDescription] = useState('');
    const [content, setContent] = useState('');
    const [presentationDate, setPresentationDate] = useState('');
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const fetchProject = async () => {
            try {
                const project = await projectAPI.fetchProjectById(id);
                if (!project) {
                    alert('프로젝트를 찾을 수 없습니다.');
                    return navigate(-1);
                }
                setTitle(project.title || '');
                setDescription(project.description || '');
                setContent(project.script || '');
                setPresentationDate(project.scheduledDate?.split('T')[0] || '');
            } catch (e) {
                console.error('프로젝트 로드 실패:', e);
            } finally {
                setLoading(false);
            }
        };
        fetchProject();
    }, [id, navigate]);

    const handleSave = async () => {
        try {
            await projectAPI.updateProject(id, {
                title,
                description,
                script: content,
                scheduledDate: presentationDate || null,
            });
            alert('프로젝트가 저장되었습니다.');
        } catch (e) {
            console.error('저장 실패:', e);
            alert('저장 중 오류가 발생했습니다.');
        }
    };

    if (loading) return <div style={{ padding: 20 }}>로딩 중...</div>;

    return (
        <div style={styles.container}>
            <Sidebar isOpen={isSidebarOpen} />
            <div
                style={{
                    ...styles.content,
                    marginLeft: isSidebarOpen ? 240 : 0,
                }}
            >
                <ProfileDropdown
                    isSidebarOpen={isSidebarOpen}
                    onToggleSidebar={() => setIsSidebarOpen(prev => !prev)}
                />

                <div style={styles.formWrapper}>
                    <h2>프로젝트 수정</h2>
                    <p>프로젝트 ID: <strong>{id}</strong></p>

                    <div style={styles.inputGroup}>
                        <label>제목</label>
                        <input type="text" value={title} onChange={e => setTitle(e.target.value)}
                            style={styles.input} />
                    </div>

                    <div style={styles.inputGroup}>
                        <label>설명</label>
                        <textarea value={description} onChange={e => setDescription(e.target.value)}
                            style={{ ...styles.input, height: '60px' }} />
                    </div>

                    <div style={styles.inputGroup}>
                        <label>내용</label>
                        <textarea value={content} onChange={e => setContent(e.target.value)}
                            style={{ ...styles.input, height: '100px' }} placeholder="대본을 입력하세요" />
                    </div>

                    <div style={styles.inputGroup}>
                        <label>발표일</label>
                        <input type="date" value={presentationDate} onChange={e => setPresentationDate(e.target.value)}
                            style={styles.input} />
                    </div>

                    <div style={styles.buttonGroup}>
                        <button onClick={() => navigate(-1)} style={styles.backButton}>← 뒤로가기</button>
                        <button onClick={handleSave} style={styles.saveButton}>저장</button>
                    </div>
                </div>
            </div>
        </div>
    );
}

const styles = {
    container: { display: 'flex' },
    content: { flex: 1, transition: 'margin-left 0.3s ease' },
    formWrapper: { padding: '20px', maxWidth: '640px' },
    inputGroup: { marginTop: '20px', display: 'flex', flexDirection: 'column' },
    input: {
        padding: '10px', fontSize: '14px', borderRadius: '6px', border: '1px solid #ccc',
        marginTop: '8px'
    },

    buttonGroup: { marginTop: '24px', display: 'flex', justifyContent: 'space-between' },
    backButton: {
        background: 'transparent', border: 'none', color: '#673AB7', fontWeight: 'bold',
        cursor: 'pointer', fontSize: '14px'
    },

    saveButton: {
        backgroundColor: '#673AB7', color: '#fff', border: 'none', borderRadius: '8px',
        padding: '10px 20px', fontWeight: 'bold', cursor: 'pointer'
    },
};
