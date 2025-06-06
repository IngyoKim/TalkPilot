import { useEffect, useRef, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import mammoth from 'mammoth';

import * as userAPI from '@/utils/api/user';
import * as projectAPI from '@/utils/api/project';
import ProfileDropdown from '@/pages/Profile/ProfileDropdown';

import Sidebar from '@/components/SideBar';
import { useUser } from '@/contexts/UserContext';
import ToastMessage from '@/components/ToastMessage';

export default function ProjectPage() {
    const [isSidebarOpen, setIsSidebarOpen] = useState(true);
    const { id } = useParams();
    const navigate = useNavigate();

    const { user } = useUser();
    const [project, setProject] = useState(null);
    const [isScriptEditable, setIsScriptEditable] = useState(false);
    const [loading, setLoading] = useState(true);
    const [ownerName, setOwnerName] = useState(null);
    const [messages, setMessages] = useState([]);

    const fileInputRef = useRef(null);

    const showMessage = (text, type = 'green', duration = 3000) => {
        setMessages((prev) => [...prev, { id: Date.now(), text, type, duration }]);
    };

    const getUserRole = (project, uid) => {
        const role = project.participants?.[uid] || 'member';
        console.log(`[ProjectPage] 역할 판별 - uid: ${uid}, role: ${role}`);
        return role;
    };

    useEffect(() => {
        if (!user?.uid) return;
        let isMounted = true;

        const fetchProject = async () => {
            console.log('[ProjectPage] fetchProject called');
            try {
                const result = await projectAPI.fetchProjectById(id);
                if (!isMounted) return;

                if (!result) {
                    showMessage('프로젝트를 찾을 수 없습니다.', 'red');
                    return navigate(-1);
                }
                setProject(result);

                const ownerUid = result.ownerUid;
                if (ownerUid) {
                    const ownerUser = await userAPI.fetchUserByUid(ownerUid);
                    if (isMounted) setOwnerName(ownerUser?.nickname || ownerUid);
                } else {
                    if (isMounted) setOwnerName('(소유자 없음)');
                }
            } catch (e) {
                showMessage('프로젝트 로드 실패', 'red');
                console.error('[ProjectPage] 프로젝트 로드 실패:', e);
            } finally {
                if (isMounted) setLoading(false);
            }
        };

        fetchProject();
        return () => {
            isMounted = false;
        };
    }, [id, user?.uid]);

    const handleSave = async () => {
        console.log('[ProjectPage] 저장 시도:', project);
        try {
            await projectAPI.updateProject(id, project);
            showMessage('프로젝트가 저장되었습니다.', 'green');
        } catch (e) {
            console.error('저장 실패:', e);
            showMessage('저장 실패', 'red');
        }
    };

    const handleChange = (field, value) => {
        console.log(`[ProjectPage] 필드 변경 - ${field}:`, value);
        setProject(prev => ({ ...prev, [field]: value }));
    };

    const handleUploadScriptClick = () => {
        fileInputRef.current?.click();
    };

    const handleScriptFileChange = async (e) => {
        const file = e.target.files?.[0];
        if (!file) return;

        // 덮어쓸지 확인
        if (project.script && project.script.trim() !== '') {
            const confirmOverwrite = window.confirm('기존 대본이 존재합니다. 덮어쓸까요?');
            if (!confirmOverwrite) {
                e.target.value = ''; // input 초기화
                return;
            }
        }

        try {
            if (file.type === 'text/plain') {
                const reader = new FileReader();
                reader.onload = () => {
                    const text = reader.result
                        .replace(/\r\n/g, '\n')
                        .replace(/\n{2,}/g, '\n\n')
                        .trim();

                    setProject(prev => ({
                        ...prev,
                        script: text,
                    }));
                    showMessage('텍스트 파일에서 대본이 추가되었습니다.', 'green');
                };
                reader.readAsText(file);
            } else if (file.type === 'application/vnd.openxmlformats-officedocument.wordprocessingml.document') {
                const arrayBuffer = await file.arrayBuffer();
                const result = await mammoth.extractRawText({ arrayBuffer });
                const cleanedText = result.value
                    .replace(/\r\n/g, '\n')
                    .replace(/\n{2,}/g, '\n\n')
                    .trim();

                setProject(prev => ({
                    ...prev,
                    script: cleanedText,
                }));
                showMessage('DOCX 파일에서 대본이 추가되었습니다.', 'green');
            } else {
                showMessage('지원하지 않는 파일 형식입니다. (txt, docx만 지원)', 'red');
            }
        } catch (e) {
            console.error('파일 읽기 오류:', e);
            showMessage('파일 읽기 오류', 'red');
        } finally {
            e.target.value = ''; // input 초기화
        }
    };

    if (!user?.uid) return <div style={styles.centered}>사용자 정보를 불러오는 중입니다...</div>;
    if (loading || !project) return <div style={styles.centered}>로딩 중...</div>;

    const role = getUserRole(project, user.uid);
    const isEditable = ['owner', 'editor'].includes(role);

    return (
        <div style={styles.container}>
            <Sidebar isOpen={isSidebarOpen} />
            <div style={{ ...styles.content, marginLeft: isSidebarOpen ? 240 : 0 }}>
                <ProfileDropdown
                    isSidebarOpen={isSidebarOpen}
                    onToggleSidebar={() => setIsSidebarOpen(prev => !prev)}
                />

                <div style={styles.section}>
                    <div style={styles.sectionHeader}>
                        <h2 style={styles.title}>프로젝트 정보</h2>
                        {isEditable && (
                            <>
                                <button onClick={handleUploadScriptClick} style={styles.uploadScriptButton}>+ 대본 추가</button>
                                <input
                                    type="file"
                                    accept=".txt,.docx"
                                    ref={fileInputRef}
                                    onChange={handleScriptFileChange}
                                    style={{ display: 'none' }}
                                />
                            </>
                        )}
                    </div>

                    <p style={styles.subtitle}>프로젝트 ID: <strong>{id}</strong></p>
                    <p style={styles.metaInfo}>참여자 수: {Object.keys(project.participants || {}).length}</p>
                    <p style={styles.metaInfo}>소유자: {ownerName || '없음'}</p>
                    <p style={styles.metaInfo}>생성일: {new Date(project.createdAt).toLocaleString()}</p>
                    {project.updatedAt && <p style={styles.metaInfo}>마지막 수정일: {new Date(project.updatedAt).toLocaleString()}</p>}

                    <div style={styles.inputGroup}>
                        <label style={styles.label}>제목</label>
                        <input
                            type="text"
                            value={project.title || ''}
                            onChange={e => handleChange('title', e.target.value)}
                            style={styles.input}
                            disabled={!isEditable}
                        />
                    </div>

                    <div style={styles.inputGroup}>
                        <label style={styles.label}>설명</label>
                        <textarea
                            value={project.description || ''}
                            onChange={e => handleChange('description', e.target.value)}
                            style={{ ...styles.input, height: '60px' }}
                            disabled={!isEditable}
                        />
                    </div>

                    <div style={styles.inputGroup}>
                        <label style={styles.label}>대본</label>
                        <textarea
                            value={project.script || ''}
                            onChange={e => handleChange('script', e.target.value)}
                            style={{ ...styles.input, height: '120px' }}
                            placeholder="대본을 입력하세요"
                            disabled={!isEditable || !isScriptEditable}
                        />
                        {isEditable && (
                            <button onClick={() => setIsScriptEditable(prev => !prev)} style={styles.editToggleButton}>
                                {isScriptEditable ? '편집 종료' : '편집 시작'}
                            </button>
                        )}
                    </div>

                    <div style={styles.inputGroup}>
                        <label style={styles.label}>발표일</label>
                        <input
                            type="date"
                            value={
                                project.scheduledDate
                                    ? new Date(project.scheduledDate).toISOString().split('T')[0]
                                    : ''
                            }
                            onChange={e => handleChange('scheduledDate', e.target.value)}
                            style={styles.input}
                            disabled={!isEditable}
                        />
                    </div>

                    <div style={styles.buttonRow}>
                        <button onClick={() => navigate(-1)} style={styles.backButton}>← 뒤로가기</button>
                        {isEditable && (
                            <button onClick={handleSave} style={styles.saveButton}>저장</button>
                        )}
                    </div>

                    <button onClick={() => navigate(`/practice/${project.id}`)} style={styles.secondaryButton}>
                        연습 시작하기
                    </button>
                </div>
            </div>

            <ToastMessage messages={messages} setMessages={setMessages} />
        </div>
    );
}

const styles = {
    container: {
        display: 'flex', fontFamily: 'sans-serif', backgroundColor: '#f9f7fc',
        minHeight: '100vh', paddingBottom: '40px'
    },
    content: {
        flex: 1, transition: 'margin-left 0.3s ease', padding: '40px', backgroundColor: '#f9f7fc'
    },
    centered: { padding: 40, fontSize: '16px', textAlign: 'center' },
    section: {
        backgroundColor: 'transparent', padding: '0 8px', maxWidth: '1200px', margin: '0 auto'
    },
    sectionHeader: {
        display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '12px'
    },
    uploadScriptButton: {
        backgroundColor: '#673AB7', color: '#fff', border: 'none', borderRadius: '6px',
        padding: '8px 12px', cursor: 'pointer', fontSize: '14px', fontWeight: 'bold'
    },
    title: { fontSize: '28px', fontWeight: 'bold', marginBottom: '8px' },
    subtitle: { fontSize: '14px', color: '#888', marginBottom: '12px' },
    metaInfo: { fontSize: '13px', color: '#777', marginBottom: '4px' },
    inputGroup: { marginTop: '24px', display: 'flex', flexDirection: 'column' },
    label: { fontSize: '14px', fontWeight: '500', marginBottom: '6px' },
    input: {
        padding: '12px', fontSize: '14px', borderRadius: '8px', border: '1px solid #ccc',
        backgroundColor: '#fff', transition: 'border-color 0.2s'
    },
    buttonRow: { marginTop: '28px', display: 'flex', justifyContent: 'space-between' },
    backButton: {
        background: 'transparent', border: 'none', color: '#673AB7', fontWeight: 'bold',
        cursor: 'pointer', fontSize: '14px'
    },
    saveButton: {
        backgroundColor: '#673AB7', color: '#fff', border: 'none', borderRadius: '8px',
        padding: '10px 20px', fontWeight: 'bold', cursor: 'pointer'
    },
    editToggleButton: {
        marginTop: '10px', alignSelf: 'flex-end', backgroundColor: '#eee', border: 'none',
        borderRadius: '6px', padding: '6px 12px', cursor: 'pointer', fontSize: '13px'
    },
    secondaryButton: {
        marginTop: '16px', width: '100%', backgroundColor: '#EDE7F6', color: '#673AB7',
        border: 'none', borderRadius: '8px', padding: '12px', fontWeight: 'bold', cursor: 'pointer'
    },
};
