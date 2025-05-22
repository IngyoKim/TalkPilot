import { useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';

import Sidebar from '../../components/SideBar';
import ProfileDropdown from '../Profile/ProfileDropdown';

export default function ProjectDetail() {
    const [isSidebarOpen, setIsSidebarOpen] = useState(true);
    const { id } = useParams();
    const navigate = useNavigate();

    // 프로젝트 정보 상태
    const [title, setTitle] = useState('예시 프로젝트 제목');
    const [description, setDescription] = useState('예시 설명');
    const [content, setContent] = useState('');
    const [presentationDate, setPresentationDate] = useState('');

    // 저장 버튼 클릭 시 동작
    const handleSave = () => {
        console.log('저장된 프로젝트:', {
            id,
            title,
            description,
            content,
            presentationDate,
        });

        // 저장 완료 메시지, 추후 제거 예정
        alert('프로젝트가 저장되었습니다.');
    };

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
                    <p>
                        프로젝트 ID: <strong>{id}</strong>
                    </p>

                    {/* 제목 입력 */}
                    <div style={styles.inputGroup}>
                        <label>제목</label>
                        <input
                            type="text"
                            value={title}
                            onChange={e => setTitle(e.target.value)}
                            style={styles.input}
                        />
                    </div>

                    {/* 설명 입력 */}
                    <div style={styles.inputGroup}>
                        <label>설명</label>
                        <textarea
                            value={description}
                            onChange={e => setDescription(e.target.value)}
                            style={{ ...styles.input, height: '60px' }}
                        />
                    </div>

                    {/* 대본 입력 */}
                    <div style={styles.inputGroup}>
                        <label>내용</label>
                        <textarea
                            value={content}
                            onChange={e => setContent(e.target.value)}
                            style={{ ...styles.input, height: '100px' }}
                            placeholder="대본을 입력하세요"
                        />
                    </div>

                    {/* 발표일 입력 */}
                    <div style={styles.inputGroup}>
                        <label>발표일</label>
                        <input
                            type="date"
                            value={presentationDate}
                            onChange={e => setPresentationDate(e.target.value)}
                            style={styles.input}
                        />
                    </div>

                    {/* 버튼 영역 */}
                    <div style={styles.buttonGroup}>
                        <button onClick={() => navigate(-1)} style={styles.backButton}>
                            ← 뒤로가기
                        </button>
                        <button onClick={handleSave} style={styles.saveButton}>
                            저장
                        </button>
                    </div>
                </div>
            </div>
        </div>
    );
}

const styles = {
    container: {
        display: 'flex',
    },
    content: {
        flex: 1,
        transition: 'margin-left 0.3s ease',
    },
    formWrapper: {
        padding: '20px',
        maxWidth: '640px',
    },
    inputGroup: {
        marginTop: '20px',
        display: 'flex',
        flexDirection: 'column',
    },
    input: {
        padding: '10px',
        fontSize: '14px',
        borderRadius: '6px',
        border: '1px solid #ccc',
        marginTop: '8px',
    },
    buttonGroup: {
        marginTop: '24px',
        display: 'flex',
        justifyContent: 'space-between',
    },
    backButton: {
        background: 'transparent',
        border: 'none',
        color: '#673AB7',
        fontWeight: 'bold',
        cursor: 'pointer',
        fontSize: '14px',
    },
    saveButton: {
        backgroundColor: '#673AB7',
        color: '#fff',
        border: 'none',
        borderRadius: '8px',
        padding: '10px 20px',
        fontWeight: 'bold',
        cursor: 'pointer',
    },
};
