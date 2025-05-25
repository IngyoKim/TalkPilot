import { useState } from 'react';
import { Link } from 'react-router-dom';
import { v4 as uuidv4 } from 'uuid';

import Sidebar from '../../components/SideBar';
import ToastMessage from '../../components/ToastMessage';
import ProfileDropdown from '../Profile/ProfileDropdown';

const mainColor = '#673AB7';
const STATUS_COLORS = {
    진행중: '#4CAF50',
    보류: '#FFC107',
    완료: '#F44336',
};

const formatRelativeTime = (date) => {// 수정 일
    const seconds = Math.floor((new Date() - new Date(date)) / 1000);
    if (seconds < 60) return `${seconds}초 전`;
    const minutes = Math.floor(seconds / 60);
    if (minutes < 60) return `${minutes}분 전`;
    const hours = Math.floor(minutes / 60);
    if (hours < 24) return `${hours}시간 전`;
    const days = Math.floor(hours / 24);
    return `${days}일 전`;
};

export default function MyPresentation() {
    const [isSidebarOpen, setIsSidebarOpen] = useState(true);
    const [projects, setProjects] = useState([]);
    const [showModal, setShowModal] = useState(false);
    const [mode, setMode] = useState('생성');
    const [title, setTitle] = useState('');
    const [description, setDescription] = useState('');
    const [selectedId, setSelectedId] = useState(null);
    const [menuOpenId, setMenuOpenId] = useState(null);
    const [editId, setEditId] = useState(null);
    const [joinProjectId, setJoinProjectId] = useState('');
    const [messages, setMessages] = useState([]);// 토스트 메시지

    const handleCreateOrUpdate = () => {
        if (mode === '참여') {
            if (!joinProjectId.trim()) return;
            console.log('입력된 ID:', joinProjectId); // 여기에 ID 확인 로직 등 연결 가능
            setJoinProjectId('');
            setShowModal(false);
            return;
        }
        if (!title.trim()) return;
        const now = new Date();
        if (editId) {// 프로젝트 수정
            setProjects(ps =>
                ps.map(p =>
                    p.id === editId
                        ? { ...p, title, description, updatedAt: now }
                        : p
                )
            );
            setMessages(prev => [
                ...prev,
                {
                    id: uuidv4(),
                    text: '프로젝트가 수정되었습니다.',
                    duration: 3000,
                    type: 'yellow',
                },
            ]);
        }
        else {
            setProjects(ps => [// 프로젝트 생성
                ...ps,
                {
                    id: uuidv4(), title, description, status: '진행중',
                    createdAt: now, updatedAt: now
                },
            ]);
            setMessages(prev => [
                ...prev,
                {
                    id: uuidv4(),
                    text: '프로젝트가 생성되었습니다.',
                    duration: 3000,
                    type: 'green',
                },
            ]);
        }

        // 초기화
        setTitle('');
        setDescription('');
        setEditId(null);
        setShowModal(false);
    };

    const handleStatusChange = (id, newStatus) => {// 상태창 변경
        setProjects(ps =>
            ps.map(p =>
                p.id === id
                    ? { ...p, status: newStatus, updatedAt: new Date() }
                    : p
            )
        );
        setSelectedId(null);

        const typeMap = {
            진행중: 'green',
            보류: 'yellow',
            완료: 'red',
        };

        setMessages(prev => [
            ...prev,
            {
                id: uuidv4(),
                text: `상태가 '${newStatus}'로 변경되었습니다.`,
                duration: 3000,
                type: typeMap[newStatus] || 'info', // fallback to 'info'
            },
        ]);
    };


    const handleDelete = (id) => {// 프로젝트 삭제
        setProjects(ps => ps.filter(p => p.id !== id));
        setMenuOpenId(prev => (prev === id ? null : prev));
        setMessages(prev => [
            ...prev,
            {
                id: uuidv4(),
                text: '프로젝트가 삭제되었습니다.',
                duration: 3000,
                type: 'red',
            },
        ]);
    };

    const handleEdit = (p) => {// 프로젝트 수정모드 진입
        setTitle(p.title);
        setDescription(p.description);
        setEditId(p.id);
        setMode('생성');
        setShowModal(true);
    };

    // 렌더링
    return (
        <div style={styles.container}>
            <Sidebar isOpen={isSidebarOpen} />
            <div style={{ ...styles.content, marginLeft: isSidebarOpen ? 240 : 0 }}>
                <ProfileDropdown
                    isSidebarOpen={isSidebarOpen}
                    onToggleSidebar={() => setIsSidebarOpen(o => !o)}
                />

                {/* 헤더 */}
                <div style={styles.header}>

                    <button style={styles.addButton} onClick={() => setShowModal(true)}>
                        프로젝트 추가
                    </button>
                </div>

                {/* 프로젝트 그리드 */}
                <div style={styles.projectGrid}>
                    {projects.map(p => (
                        <div key={p.id} style={styles.cardWrapper}>
                            <Link to={`/project/${p.id}`} style={styles.link}>
                                <div style={styles.card}>
                                    <h3>{p.title}</h3>
                                    <p>{p.description}</p>
                                    <small>생성일: {new Date(p.createdAt).toLocaleDateString()}</small><br />
                                    <small>수정일: {formatRelativeTime(p.updatedAt)}</small>
                                </div>
                            </Link>

                            {/* 메뉴 버튼 */}
                            <div
                                style={styles.menuButton}
                                onClick={() => setMenuOpenId(m => (m === p.id ? null : p.id))}
                            >
                                ⋮
                            </div>

                            {/* 상태 도트 */}
                            <div
                                style={{ ...styles.statusDot, backgroundColor: STATUS_COLORS[p.status] }}
                                onClick={() => setSelectedId(id => (id === p.id ? null : p.id))}
                            />

                            {/* 상태 드롭다운 */}
                            {selectedId === p.id && (
                                <div style={styles.dropdown}>
                                    {Object.entries(STATUS_COLORS).map(([status, color]) => (
                                        <div
                                            key={status}
                                            style={styles.dropdownItem}
                                            onClick={() => handleStatusChange(p.id, status)}
                                        >
                                            <div style={{ ...styles.dropdownDot, backgroundColor: color }} />
                                            <span>{status}</span>
                                        </div>
                                    ))}
                                </div>
                            )}

                            {/* 메뉴 드롭다운 */}
                            {menuOpenId === p.id && (
                                <div style={styles.dropdown}>
                                    <div style={styles.dropdownItem} onClick={() => handleEdit(p)}>
                                        수정
                                    </div>
                                    <div style={styles.dropdownItem} onClick={() => handleDelete(p.id)}>
                                        삭제
                                    </div>
                                </div>
                            )}
                        </div>
                    ))}
                </div>
            </div>

            {/* 모달 */}
            {showModal && (
                <div style={styles.modalOverlay}>
                    <div style={styles.modal}>
                        <div style={styles.tabWrapper}>
                            {['생성', '참여'].map(tab => (
                                <button
                                    key={tab}
                                    onClick={() => setMode(tab)}
                                    style={{
                                        ...styles.tabButton,
                                        backgroundColor: mode === tab ? '#fff' : '#eee',
                                        fontWeight: mode === tab ? 'bold' : 'normal',
                                    }}
                                >
                                    {tab}
                                </button>
                            ))}
                        </div>
                        {mode === '생성' ? (
                            <>
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
                            </>
                        ) : (
                            <div style={styles.inputGroup}>
                                <label>프로젝트 ID 입력</label>
                                <input
                                    type="text"
                                    value={joinProjectId}
                                    onChange={e => setJoinProjectId(e.target.value)}
                                    style={styles.input}
                                />
                            </div>
                        )}


                        <div style={styles.modalActions}>
                            <button style={styles.cancelBtn} onClick={() => setShowModal(false)}>
                                취소
                            </button>
                            <button style={styles.confirmBtn} onClick={handleCreateOrUpdate}>
                                {editId ? '수정' : '생성'}
                            </button>
                        </div>
                    </div>
                </div>
            )}
            <ToastMessage messages={messages} setMessages={setMessages} />
        </div>
    );
}

const styles = {
    container: { display: 'flex' },

    content: { flex: 1, transition: 'margin-left 0.3s ease', padding: '20px' },

    header: {
        display: 'flex', justifyContent: 'space-between', alignItems: 'center',
        marginBottom: '20px'
    },
    addButton: {
        backgroundColor: mainColor, color: '#fff', border: 'none', borderRadius: '8px',
        padding: '10px 16px', cursor: 'pointer', fontSize: '14px', marginLeft: '16px'
    },
    projectGrid: {
        display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(220px, 1fr))',
        gap: '20px'
    },
    cardWrapper: { position: 'relative' },

    link: { textDecoration: 'none', color: 'inherit' },

    card: {
        backgroundColor: '#fff', padding: '16px', borderRadius: '10px',
        boxShadow: '0 6px 16px rgba(0,0,0,0.3)'
    },
    menuButton: {
        position: 'absolute', top: 8, right: 32, width: 16, height: 16, cursor: 'pointer',
        fontSize: '16px', textAlign: 'center', lineHeight: '16px'
    },
    statusDot: {
        position: 'absolute', top: 8, right: 8, width: 14, height: 14, borderRadius: '50%',
        border: '1px solid #ccc', cursor: 'pointer'
    },
    dropdown: {
        position: 'absolute', top: 30, right: 8, backgroundColor: '#fff', border: '1px solid #ccc',
        borderRadius: '6px', boxShadow: '0 2px 6px rgba(0,0,0,0.2)', zIndex: 10
    },
    dropdownItem: {
        display: 'flex', alignItems: 'center', gap: '8px', padding: '6px 12px',
        cursor: 'pointer', fontSize: '13px'
    },
    dropdownDot: { width: '10px', height: '10px', borderRadius: '50%' },

    modalOverlay: {
        position: 'fixed', top: 0, left: 0, width: '100vw', height: '100vh',
        backgroundColor: 'rgba(0,0,0,0.5)', display: 'flex', justifyContent: 'center',
        alignItems: 'center', zIndex: 999
    },
    modal: {
        backgroundColor: '#f2e8ff', padding: '24px', borderRadius: '20px', width: '90%',
        maxWidth: '360px', boxShadow: '0 4px 12px rgba(0,0,0,0.2)'
    },
    tabWrapper: { display: 'flex', borderRadius: '10px', overflow: 'hidden', marginBottom: '16px' },

    tabButton: { flex: 1, padding: '8px', border: 'none', cursor: 'pointer' },

    inputGroup: { marginBottom: '12px', display: 'flex', flexDirection: 'column', fontSize: '14px' },

    input: { padding: '8px', border: '1px solid #ccc', borderRadius: '6px', fontSize: '14px' },

    modalActions: { display: 'flex', justifyContent: 'space-between', marginTop: '20px' },

    cancelBtn: {
        backgroundColor: 'transparent', color: mainColor, border: 'none', fontWeight: 'bold',
        cursor: 'pointer'
    },
    confirmBtn: {
        backgroundColor: mainColor, color: '#fff', border: 'none', padding: '8px 16px',
        borderRadius: '8px', fontWeight: 'bold', cursor: 'pointer'
    },
};
