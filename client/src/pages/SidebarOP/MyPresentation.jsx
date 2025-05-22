import { useState } from 'react';
import { Link } from 'react-router-dom';
import { v4 as uuidv4 } from 'uuid';

import Sidebar from '../../components/SideBar';
import ProfileDropdown from '../Profile/ProfileDropdown';

const mainColor = '#673AB7';

export default function MyPresentation() {
    const [isSidebarOpen, setIsSidebarOpen] = useState(true);
    const [projects, setProjects] = useState([]);
    const [showModal, setShowModal] = useState(false);
    const [mode, setMode] = useState('생성');
    const [title, setTitle] = useState('');
    const [description, setDescription] = useState('');
    const [selectedProjectId, setSelectedProjectId] = useState(null);
    const [menuOpenId, setMenuOpenId] = useState(null);
    const [editProjectId, setEditProjectId] = useState(null);

    const formatRelativeTime = (date) => {//수정일
        const seconds = Math.floor((new Date() - new Date(date)) / 1000);
        if (seconds < 60) return `${seconds}초 전`;
        const minutes = Math.floor(seconds / 60);
        if (minutes < 60) return `${minutes}분 전`;
        const hours = Math.floor(minutes / 60);
        if (hours < 24) return `${hours}시간 전`;
        const days = Math.floor(hours / 24);
        return `${days}일 전`;
    };

    const statusColors = {//상태창 색
        '진행중': '#4CAF50',
        '보류': '#FFC107',
        '완료': '#F44336',
    };

    const handleCreate = () => {//프로젝트 카드
        if (title.trim() === '') return;
        const now = new Date();

        if (editProjectId) {
            setProjects(prev => prev.map(p =>
                p.id === editProjectId ? {
                    ...p,
                    title,
                    description,
                    updatedAt: now
                } : p
            ));
        } else {
            setProjects(prev => [
                ...prev,
                {
                    id: uuidv4(),
                    title,
                    description,
                    createdAt: now,
                    updatedAt: now,
                    status: '진행중',
                },
            ]);
        }

        setTitle('');
        setDescription('');
        setEditProjectId(null);
        setShowModal(false);
    };

    const handleStatusChange = (id, newStatus) => {//상태창 변경
        setProjects(prev =>
            prev.map(p =>
                p.id === id ? { ...p, status: newStatus, updatedAt: new Date() } : p
            )
        );
        setSelectedProjectId(null);
    };

    const handleDelete = (id) => {//삭제
        setProjects(prev => prev.filter(p => p.id !== id));
        if (menuOpenId === id) setMenuOpenId(null);
    };

    const handleEdit = (project) => {//수정
        setTitle(project.title);
        setDescription(project.description);
        setEditProjectId(project.id);
        setShowModal(true);
    };

    return (
        <div style={styles.container}>
            <Sidebar isOpen={isSidebarOpen} />
            <div style={{ ...styles.content, marginLeft: isSidebarOpen ? 240 : 0 }}>
                <ProfileDropdown
                    isSidebarOpen={isSidebarOpen}
                    onToggleSidebar={() => setIsSidebarOpen(prev => !prev)}
                />

                <div style={styles.header}>
                    <h2>프로젝트</h2>
                    <button onClick={() => setShowModal(true)} style={styles.addButton}>
                        프로젝트 추가
                    </button>
                </div>

                <div style={styles.projectGrid}>
                    {projects.map(p => (
                        <div key={p.id} style={{ position: 'relative' }}>
                            <Link to={`/project/${p.id}`} style={{ textDecoration: 'none', color: 'inherit' }}>
                                <div style={styles.card}>
                                    <h3>{p.title}</h3>
                                    <p>{p.description}</p>
                                    <small>생성일: {new Date(p.createdAt).toLocaleDateString()}</small><br />
                                    <small>수정일: {formatRelativeTime(p.updatedAt)}</small>
                                </div>
                            </Link>

                            <div style={styles.menuButton} onClick={() => setMenuOpenId(menuOpenId === p.id ? null : p.id)}>⋮</div>
                            <div
                                style={{ ...styles.statusDot, backgroundColor: statusColors[p.status] }}
                                onClick={() => setSelectedProjectId(p.id)}
                            />

                            {selectedProjectId === p.id && (
                                <div style={styles.statusDropdown}>
                                    {Object.keys(statusColors).map(status => (
                                        <div
                                            key={status}
                                            onClick={() => handleStatusChange(p.id, status)}
                                            style={{
                                                display: 'flex',
                                                alignItems: 'center',
                                                gap: '8px',
                                                padding: '6px 12px',
                                                cursor: 'pointer',
                                                fontSize: '13px',
                                            }}
                                        >
                                            <div style={{
                                                width: '10px',
                                                height: '10px',
                                                borderRadius: '50%',
                                                backgroundColor: statusColors[status],
                                            }} />
                                            <span>{status}</span>
                                        </div>
                                    ))}
                                </div>
                            )}

                            {menuOpenId === p.id && (
                                <div style={styles.menuDropdown}>
                                    <div style={styles.menuItem} onClick={() => handleEdit(p)}>수정</div>
                                    <div style={styles.menuItem} onClick={() => handleDelete(p.id)}>삭제</div>
                                </div>
                            )}
                        </div>
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
                            <button onClick={() => setShowModal(false)} style={styles.cancelBtn}>취소</button>
                            <button onClick={handleCreate} style={styles.confirmBtn}>{editProjectId ? '수정' : '생성'}</button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
}

const styles = {
    container: { display: 'flex' },
    content: { flex: 1, transition: 'margin-left 0.3s ease', padding: '20px' },
    header: {
        display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px'
    },
    addButton: {
        backgroundColor: mainColor, color: '#fff', border: 'none', borderRadius: '8px',
        padding: '10px 16px', cursor: 'pointer', fontSize: '14px'
    },
    projectGrid: {
        display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(220px, 1fr))', gap: '20px'
    },
    card: {
        backgroundColor: '#ffffff', padding: '16px', borderRadius: '10px',
        boxShadow: '0 6px 16px rgba(0, 0, 0, 0.3)', position: 'relative'
    },
    statusDot: {
        position: 'absolute', top: 8, right: 8, width: 14, height: 14, borderRadius: '50%',
        border: '1px solid #ccc', cursor: 'pointer'
    },
    menuButton: {
        position: 'absolute', top: 8, right: 32, width: 16, height: 16, cursor: 'pointer',
        fontSize: '16px', textAlign: 'center', lineHeight: '16px'
    },
    statusDropdown: {
        position: 'absolute', top: 30, right: 8, backgroundColor: '#fff', border: '1px solid #ccc',
        borderRadius: '6px', boxShadow: '0 2px 6px rgba(0,0,0,0.2)', zIndex: 10
    },
    menuDropdown: {
        position: 'absolute', top: 30, right: 32, backgroundColor: '#fff', border: '1px solid #ccc',
        borderRadius: '6px', boxShadow: '0 2px 6px rgba(0,0,0,0.2)', zIndex: 10
    },
    menuItem: {
        padding: '6px 12px', fontSize: '13px', cursor: 'pointer', whiteSpace: 'nowrap',
        borderBottom: '1px solid #eee'
    },
    modalOverlay: {
        position: 'fixed', top: 0, left: 0, width: '100vw', height: '100vh',
        backgroundColor: 'rgba(0, 0, 0, 0.5)', display: 'flex', justifyContent: 'center',
        alignItems: 'center', zIndex: 999
    },
    modal: {
        backgroundColor: '#f2e8ff', padding: '24px', borderRadius: '20px', width: '90%',
        maxWidth: '360px', boxShadow: '0 4px 12px rgba(0,0,0,0.2)'
    },
    tabWrapper: {
        display: 'flex', borderRadius: '10px', overflow: 'hidden', marginBottom: '16px'
    },
    tabButton: {
        flex: 1, padding: '8px', border: 'none', cursor: 'pointer'
    },
    inputGroup: {
        marginBottom: '12px', display: 'flex', flexDirection: 'column', fontSize: '14px'
    },
    input: {
        padding: '8px', border: '1px solid #ccc', borderRadius: '6px', fontSize: '14px'
    },
    modalActions: {
        display: 'flex', justifyContent: 'space-between', marginTop: '20px'
    },
    cancelBtn: {
        backgroundColor: 'transparent', color: '#673AB7', border: 'none', fontWeight: 'bold',
        cursor: 'pointer'
    },
    confirmBtn: {
        backgroundColor: '#673AB7', color: '#fff', border: 'none', padding: '8px 16px',
        borderRadius: '8px', fontWeight: 'bold', cursor: 'pointer'
    }
};
