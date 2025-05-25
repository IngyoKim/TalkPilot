import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';

import Sidebar from '../../components/SideBar';
import ProfileDropdown from '../Profile/ProfileDropdown';

import { useUser } from '../../contexts/UserContext';
import * as projectAPI from '../../utils/api/project';

const mainColor = '#673AB7';
const STATUS_COLORS = {
    진행중: '#4CAF50',
    보류: '#FFC107',
    완료: '#F44336',
};

const formatRelativeTime = (date) => {
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
    const { user } = useUser();
    const [projects, setProjects] = useState([]);
    const [isSidebarOpen, setIsSidebarOpen] = useState(true);
    const [showModal, setShowModal] = useState(false);
    const [mode, setMode] = useState('생성');
    const [title, setTitle] = useState('');
    const [description, setDescription] = useState('');
    const [selectedId, setSelectedId] = useState(null);
    const [menuOpenId, setMenuOpenId] = useState(null);
    const [editId, setEditId] = useState(null);
    const [joinProjectId, setJoinProjectId] = useState('');

    useEffect(() => {
        if (!user || !user.projectIds) return;

        const loadProjects = async () => {
            try {
                const entries = Object.entries(user.projectIds);
                const fetchedProjects = await Promise.all(
                    entries.map(async ([id, status]) => {
                        const project = await projectAPI.fetchProjectById(id);
                        if (!project) return null;
                        return { ...project, status };
                    })
                );
                setProjects(fetchedProjects.filter(Boolean));
            } catch (error) {
                console.error('[MyPresentation] 프로젝트 불러오기 실패:', error);
            }
        };

        loadProjects();
    }, [user]);

    const handleCreateOrUpdate = async () => {
        if (mode === '참여') {
            if (!joinProjectId.trim()) return;

            try {
                const project = await projectAPI.fetchProjectById(joinProjectId);
                if (!project) {
                    alert('해당 프로젝트가 존재하지 않습니다.');
                    return;
                }

                /// 이미 참여 중인지 확인
                if (project.participants[user.uid]) {
                    alert('이미 참여 중인 프로젝트입니다.');
                    return;
                }

                /// participants 업데이트
                await projectAPI.updateProject(joinProjectId, {
                    participants: {
                        ...project.participants,
                        [user.uid]: 'member',
                    },
                });

                /// 유저 정보 업데이트
                await projectAPI.updateUser({
                    projectIds: {
                        ...(user.projectIds || {}),
                        [joinProjectId]: project.status,
                    },
                });

                /// 프로젝트 리스트 반영
                setProjects(ps => [
                    {
                        ...project,
                        participants: {
                            ...project.participants,
                            [user.uid]: 'member',
                        },
                        status: project.status,
                    },
                    ...ps,
                ]);
            } catch (e) {
                console.error('참여 실패:', e);
                alert('프로젝트 참여 중 오류가 발생했습니다.');
            }

            setJoinProjectId('');
            setShowModal(false);
            return;
        }

        if (!title.trim()) return;

        if (editId) {
            await projectAPI.updateProject(editId, {
                title,
                description,
                updatedAt: new Date().toISOString(),
            });
            setProjects(ps =>
                ps.map(p =>
                    p.id === editId ? { ...p, title, description, updatedAt: new Date().toISOString() } : p
                )
            );
        } else {
            const res = await projectAPI.createProject({ title, description });

            const newProject = {
                id: res.id,
                title,
                description,
                status: '진행중',
                createdAt: new Date().toISOString(),
                updatedAt: new Date().toISOString(),
            };
            setProjects(ps => [newProject, ...ps]);
        }

        setTitle('');
        setDescription('');
        setEditId(null);
        setShowModal(false);
    };

    const handleStatusChange = async (id, newStatus) => {
        await projectAPI.updateProject(id, {
            status: newStatus,
            updatedAt: new Date().toISOString(),
        });
        setProjects(ps =>
            ps.map(p =>
                p.id === id ? { ...p, status: newStatus, updatedAt: new Date().toISOString() } : p
            )
        );
        setSelectedId(null);
    };

    const handleDelete = async (id) => {
        await projectAPI.deleteProject(id);
        setProjects(ps => ps.filter(p => p.id !== id));
        setMenuOpenId(null);
    };

    const handleEdit = (p) => {
        setTitle(p.title);
        setDescription(p.description);
        setEditId(p.id);
        setMode('생성');
        setShowModal(true);
    };

    return (
        <div style={styles.container}>
            <Sidebar isOpen={isSidebarOpen} />
            <div style={{ ...styles.content, marginLeft: isSidebarOpen ? 240 : 0 }}>
                <ProfileDropdown
                    isSidebarOpen={isSidebarOpen}
                    onToggleSidebar={() => setIsSidebarOpen(o => !o)}
                />

                <div style={styles.header}>
                    <button style={styles.addButton} onClick={() => setShowModal(true)}>
                        프로젝트 추가
                    </button>
                </div>

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

                            <div
                                style={styles.menuButton}
                                onClick={() => setMenuOpenId(m => (m === p.id ? null : p.id))}
                            >
                                ⋮
                            </div>

                            <div
                                style={{ ...styles.statusDot, backgroundColor: STATUS_COLORS[p.status] }}
                                onClick={() => setSelectedId(id => (id === p.id ? null : p.id))}
                            />

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

                            {menuOpenId === p.id && (
                                <div style={styles.dropdown}>
                                    <div style={styles.dropdownItem} onClick={() => handleEdit(p)}>수정</div>
                                    <div style={styles.dropdownItem} onClick={() => handleDelete(p.id)}>삭제</div>
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
                            <button style={styles.cancelBtn} onClick={() => setShowModal(false)}>취소</button>
                            <button style={styles.confirmBtn} onClick={handleCreateOrUpdate}>
                                {editId ? '수정' : '생성'}
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
