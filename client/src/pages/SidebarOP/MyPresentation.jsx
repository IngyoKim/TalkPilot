import { useState } from 'react';
import { Link } from 'react-router-dom';
import { v4 as uuidv4 } from 'uuid';

import Sidebar from '../../components/SideBar';
import ProfileDropdown from '../Profile/ProfileDropdown';

export default function MyPresentation() {
    const [isSidebarOpen, setIsSidebarOpen] = useState(true);
    const [projects, setProjects] = useState([]);
    const [showModal, setShowModal] = useState(false);
    const [mode, setMode] = useState('생성');
    const [title, setTitle] = useState('');
    const [description, setDescription] = useState('');

    const handleCreate = () => {
        if (title.trim() === '') return;
        setProjects(prev => [
            ...prev,
            {
                id: uuidv4(),
                title,
                description,
            },
        ]);
        setTitle('');
        setDescription('');
        setShowModal(false);
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

                <div style={styles.header}>
                    <h2>프로젝트</h2>
                    <button onClick={() => setShowModal(true)} style={styles.addButton}>
                        + 새 프로젝트 추가
                    </button>
                </div>

                <div style={styles.projectGrid}>
                    {projects.map(p => (
                        <Link to={`/project/${p.id}`} key={p.id} style={{ textDecoration: 'none', color: 'inherit' }}>
                            <div style={styles.card}>
                                <h3>{p.title}</h3>
                                <p>{p.description}</p>
                            </div>
                        </Link>
                    ))}
                </div>
            </div>

            {showModal && (
                <div style={styles.modalOverlay}>
                    <div style={styles.modal}>
                        <div style={styles.tabWrapper}>
                            <button
                                onClick={() => setMode('생성')}
                                style={{
                                    ...styles.tabButton,
                                    backgroundColor: mode === '생성' ? '#fff' : '#eee',
                                    fontWeight: mode === '생성' ? 'bold' : 'normal',
                                }}
                            >
                                생성
                            </button>
                            <button
                                onClick={() => setMode('참여')}
                                style={{
                                    ...styles.tabButton,
                                    backgroundColor: mode === '참여' ? '#fff' : '#eee',
                                    fontWeight: mode === '참여' ? 'bold' : 'normal',
                                }}
                            >
                                참여
                            </button>
                        </div>

                        <div style={styles.inputGroup}>
                            <label>제목 입력</label>
                            <input
                                type="text"
                                maxLength={100}
                                value={title}
                                onChange={e => setTitle(e.target.value)}
                                style={styles.input}
                            />
                        </div>

                        <div style={styles.inputGroup}>
                            <label>설명 입력 (최대 100자)</label>
                            <textarea
                                maxLength={100}
                                value={description}
                                onChange={e => setDescription(e.target.value)}
                                style={{ ...styles.input, height: '60px' }}
                            />
                        </div>

                        <div style={styles.modalActions}>
                            <button onClick={() => setShowModal(false)} style={styles.cancelBtn}>
                                취소
                            </button>
                            <button onClick={handleCreate} style={styles.confirmBtn}>
                                생성
                            </button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
}

const styles = {
    container: { display: 'flex' },
    content: {
        flex: 1,
        transition: 'margin-left 0.3s ease',
        padding: '20px',
    },
    header: {
        display: 'flex',
        justifyContent: 'space-between',
        alignItems: 'center',
        marginBottom: '20px',
    },
    addButton: {
        backgroundColor: '#673AB7',
        color: '#fff',
        border: 'none',
        borderRadius: '8px',
        padding: '10px 16px',
        cursor: 'pointer',
        fontSize: '14px',
    },
    projectGrid: {
        display: 'grid',
        gridTemplateColumns: 'repeat(auto-fill, minmax(220px, 1fr))',
        gap: '20px',
    },
    card: {
        backgroundColor: '#f4f4f4',
        padding: '16px',
        borderRadius: '10px',
        boxShadow: '0 2px 6px rgba(0,0,0,0.1)',
    },
    modalOverlay: {
        position: 'fixed',
        top: 0,
        left: 0,
        width: '100vw',
        height: '100vh',
        backgroundColor: 'rgba(0, 0, 0, 0.5)',
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
        zIndex: 999,
    },
    modal: {
        backgroundColor: '#f2e8ff',
        padding: '24px',
        borderRadius: '20px',
        width: '90%',
        maxWidth: '360px',
        boxShadow: '0 4px 12px rgba(0,0,0,0.2)',
    },
    tabWrapper: {
        display: 'flex',
        borderRadius: '10px',
        overflow: 'hidden',
        marginBottom: '16px',
    },
    tabButton: {
        flex: 1,
        padding: '8px',
        border: 'none',
        cursor: 'pointer',
    },
    inputGroup: {
        marginBottom: '12px',
        display: 'flex',
        flexDirection: 'column',
        fontSize: '14px',
    },
    input: {
        padding: '8px',
        border: '1px solid #ccc',
        borderRadius: '6px',
        fontSize: '14px',
    },
    modalActions: {
        display: 'flex',
        justifyContent: 'space-between',
        marginTop: '20px',
    },
    cancelBtn: {
        backgroundColor: 'transparent',
        color: '#673AB7',
        border: 'none',
        fontWeight: 'bold',
        cursor: 'pointer',
    },
    confirmBtn: {
        backgroundColor: '#673AB7',
        color: '#fff',
        border: 'none',
        padding: '8px 16px',
        borderRadius: '8px',
        fontWeight: 'bold',
        cursor: 'pointer',
    },
};
