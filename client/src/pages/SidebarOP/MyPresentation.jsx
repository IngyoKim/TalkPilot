// MyPresentation.jsx (최종 수정 반영)

import { Link } from 'react-router-dom';
import { useEffect, useState, useRef } from 'react';
import Sidebar from '../../components/SideBar';
import ProfileDropdown from '../Profile/ProfileDropdown';
import { useUser } from '../../contexts/UserContext';
import * as projectAPI from '../../utils/api/project';

const mainColor = '#673AB7';
const STATUS_COLORS = {
    preparing: '#4CAF50',
    보류: '#FFC107',
    completed: '#F44336',
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
    const { user, setUser } = useUser();
    const [projects, setProjects] = useState([]);
    const [isSidebarOpen, setIsSidebarOpen] = useState(true);
    const [showModal, setShowModal] = useState(false);
    const [editMode, setEditMode] = useState(false);
    const [editId, setEditId] = useState(null);
    const [title, setTitle] = useState('');
    const [description, setDescription] = useState('');
    const [joinProjectId, setJoinProjectId] = useState('');
    const [activeDropdown, setActiveDropdown] = useState(null);
    const [tab, setTab] = useState('create');
    const [isSaving, setIsSaving] = useState(false);

    const containerRef = useRef();

    useEffect(() => {
        const handleClickOutside = (e) => {
            if (containerRef.current && !containerRef.current.contains(e.target)) {
                setActiveDropdown(null);
            }
        };
        document.addEventListener('mousedown', handleClickOutside);
        return () => document.removeEventListener('mousedown', handleClickOutside);
    }, []);

    useEffect(() => {
        if (!user?.projectIds) return;
        const entries = Object.entries(user.projectIds).filter(([id]) => id && id !== 'undefined');
        if (entries.length === 0) return;
        (async () => {
            try {
                const fetched = await Promise.all(
                    entries.map(async ([id, status]) => {
                        const project = await projectAPI.fetchProjectById(id);
                        return project ? { ...project, status } : null;
                    })
                );
                setProjects(fetched.filter(Boolean).sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt)));
            } catch (e) {
                console.error('[MyPresentation] 프로젝트 불러오기 실패:', e);
            }
        })();
    }, [user]);

    const resetModal = () => {
        setTitle('');
        setDescription('');
        setJoinProjectId('');
        setEditId(null);
        setEditMode(false);
        setTab('create');
        setShowModal(false);
    };

    const handleSave = async () => {
        if (isSaving) return;
        setIsSaving(true);
        try {
            if (editMode && editId) {
                await projectAPI.updateProject(editId, { title, description });
                setProjects((ps) => ps.map((p) => (p.id === editId ? { ...p, title, description } : p)));
            } else if (tab === 'join') {
                if (!joinProjectId.trim()) return alert('유효한 프로젝트 ID를 입력하세요.');
                const project = await projectAPI.fetchProjectById(joinProjectId);
                if (!project) return alert('존재하지 않는 프로젝트입니다.');
                if (project.participants[user.uid]) return alert('이미 참여 중입니다.');

                await projectAPI.updateProject(joinProjectId, {
                    participants: { ...project.participants, [user.uid]: 'member' },
                });
                const updatedProjectIds = { ...(user.projectIds || {}), [joinProjectId]: project.status };
                await projectAPI.updateUser({ projectIds: updatedProjectIds });
                setUser({ ...user, projectIds: updatedProjectIds });
                setProjects((prev) => [
                    { ...project, participants: { ...project.participants, [user.uid]: 'member' } },
                    ...prev,
                ]);
            } else {
                const res = await projectAPI.createProject({ title, description });
                setProjects((prev) => [{ ...res, title, description }, ...prev]);
            }
        } catch {
            alert('프로젝트 저장 중 오류 발생');
        } finally {
            setIsSaving(false);
            resetModal();
        }
    };

    const handleDelete = async (id) => {
        if (!window.confirm('정말로 삭제하시겠습니까?')) return;
        await projectAPI.deleteProject(id);
        const updatedProjectIds = { ...user.projectIds };
        delete updatedProjectIds[id];
        await projectAPI.updateUser({ projectIds: updatedProjectIds });
        setUser({ ...user, projectIds: updatedProjectIds });
        setProjects((ps) => ps.filter((p) => p.id !== id));
        setActiveDropdown(null);
    };

    const handleStatusChange = async (id, newStatus) => {
        await projectAPI.updateProject(id, { status: newStatus });
        setProjects((ps) => ps.map((p) => (p.id === id ? { ...p, status: newStatus } : p)));
        setActiveDropdown(null);
    };

    const openEditModal = (project) => {
        setTitle(project.title);
        setDescription(project.description);
        setEditId(project.id);
        setEditMode(true);
        setShowModal(true);
    };

    return (
        <div ref={containerRef} style={{ display: 'flex' }}>
            <Sidebar isOpen={isSidebarOpen} />
            <div style={{ flex: 1, padding: 20, marginLeft: isSidebarOpen ? 240 : 0 }}>
                <ProfileDropdown
                    isSidebarOpen={isSidebarOpen}
                    onToggleSidebar={() => setIsSidebarOpen((o) => !o)}
                />
                <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 20 }}>
                    <button
                        style={{
                            backgroundColor: mainColor,
                            color: '#fff',
                            padding: '10px 16px',
                            borderRadius: 8,
                            border: 'none',
                            cursor: 'pointer',
                        }}
                        onClick={() => setShowModal(true)}
                    >
                        프로젝트 추가
                    </button>
                </div>
                <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(220px, 1fr))', gap: 20 }}>
                    {projects.map((p) => (
                        <div key={p.id} style={{ position: 'relative' }}>
                            <Link to={`/project/${p.id}`} style={{ textDecoration: 'none', color: 'inherit' }}>
                                <div style={{ padding: 16, backgroundColor: '#fff', borderRadius: 10, boxShadow: '0 6px 16px rgba(0,0,0,0.3)' }}>
                                    <h3>{p.title}</h3>
                                    <p>{p.description}</p>
                                    <small>생성일: {new Date(p.createdAt).toLocaleDateString()}</small><br />
                                    <small>수정일: {formatRelativeTime(p.updatedAt)}</small>
                                </div>
                            </Link>
                            <div
                                style={{ position: 'absolute', top: 8, right: 32, cursor: 'pointer' }}
                                onClick={() =>
                                    setActiveDropdown((prev) =>
                                        prev?.id === p.id && prev?.type === 'menu' ? null : { id: p.id, type: 'menu' }
                                    )
                                }
                            >
                                ⋮
                            </div>
                            <div
                                style={{
                                    position: 'absolute',
                                    top: 8,
                                    right: 8,
                                    width: 14,
                                    height: 14,
                                    borderRadius: '50%',
                                    border: '1px solid #ccc',
                                    backgroundColor: STATUS_COLORS[p.status],
                                    cursor: 'pointer',
                                }}
                                onClick={() =>
                                    setActiveDropdown((prev) =>
                                        prev?.id === p.id && prev?.type === 'status' ? null : { id: p.id, type: 'status' }
                                    )
                                }
                            />
                            {activeDropdown?.id === p.id && activeDropdown?.type === 'menu' && (
                                <div style={styles.dropdown}>
                                    <div style={styles.dropdownItem} onClick={() => openEditModal(p)}>수정</div>
                                    <div style={styles.dropdownItem} onClick={() => handleDelete(p.id)}>삭제</div>
                                </div>
                            )}
                            {activeDropdown?.id === p.id && activeDropdown?.type === 'status' && (
                                <div style={styles.dropdown}>
                                    {Object.entries(STATUS_COLORS).map(([status, color]) => (
                                        <div key={status} style={styles.dropdownItem} onClick={() => handleStatusChange(p.id, status)}>
                                            <div style={{ ...styles.dropdownDot, backgroundColor: color }} />
                                            <span>{status}</span>
                                        </div>
                                    ))}
                                </div>
                            )}
                        </div>
                    ))}
                </div>

                {/* ✅ 프로젝트 생성/수정 모달 추가 */}
                {showModal && (
                    <div style={styles.modalOverlay}>
                        <div style={styles.modal}>
                            <div style={styles.tabWrapper}>
                                {!editMode && (
                                    <>
                                        <button
                                            style={{
                                                ...styles.tabButton,
                                                backgroundColor: tab === 'create' ? mainColor : '#e0d4f7',
                                                color: tab === 'create' ? '#fff' : '#000',
                                            }}
                                            onClick={() => setTab('create')}
                                        >
                                            생성
                                        </button>
                                        <button
                                            style={{
                                                ...styles.tabButton,
                                                backgroundColor: tab === 'join' ? mainColor : '#e0d4f7',
                                                color: tab === 'join' ? '#fff' : '#000',
                                            }}
                                            onClick={() => setTab('join')}
                                        >
                                            참여
                                        </button>
                                    </>
                                )}
                                {editMode && (
                                    <button
                                        style={{ ...styles.tabButton, backgroundColor: mainColor, color: '#fff' }}
                                        disabled
                                    >
                                        수정
                                    </button>
                                )}
                            </div>

                            {editMode || tab === 'create' ? (
                                <>
                                    <div style={styles.inputGroup}>
                                        <label>제목</label>
                                        <input style={styles.input} value={title} onChange={(e) => setTitle(e.target.value)} />
                                    </div>
                                    <div style={styles.inputGroup}>
                                        <label>설명</label>
                                        <textarea
                                            style={{ ...styles.input, resize: 'none', minHeight: 80 }}
                                            value={description}
                                            onChange={(e) => setDescription(e.target.value)}
                                        />
                                    </div>
                                </>
                            ) : (
                                <div style={styles.inputGroup}>
                                    <label>참여할 프로젝트 ID</label>
                                    <input
                                        style={styles.input}
                                        value={joinProjectId}
                                        onChange={(e) => setJoinProjectId(e.target.value)}
                                    />
                                </div>
                            )}

                            <div style={styles.modalActions}>
                                <button style={styles.cancelBtn} onClick={resetModal}>취소</button>
                                <button style={styles.confirmBtn} onClick={handleSave}>
                                    {isSaving ? '저장 중...' : editMode ? '수정' : tab === 'join' ? '참여' : '생성'}
                                </button>
                            </div>
                        </div>
                    </div>
                )}
            </div>
        </div>
    );

}

const styles = {
    dropdown: {
        position: 'absolute', top: 30, right: 8, backgroundColor: '#fff', border: '1px solid #ccc', borderRadius: 6,
        boxShadow: '0 2px 6px rgba(0,0,0,0.2)', zIndex: 10,
    },
    dropdownItem: {
        display: 'flex', alignItems: 'center', gap: 8, padding: '6px 12px', cursor: 'pointer', fontSize: 13,
    },
    dropdownDot: { width: 10, height: 10, borderRadius: '50%' },
    modalOverlay: {
        position: 'fixed', top: 0, left: 0, width: '100vw', height: '100vh', backgroundColor: 'rgba(0,0,0,0.5)',
        display: 'flex', justifyContent: 'center', alignItems: 'center', zIndex: 999,
    },
    modal: {
        backgroundColor: '#f2e8ff', padding: 24, borderRadius: 20, width: '90%', maxWidth: 360,
        boxShadow: '0 4px 12px rgba(0,0,0,0.2)',
    },
    tabWrapper: { display: 'flex', borderRadius: 10, overflow: 'hidden', marginBottom: 16 },
    tabButton: { flex: 1, padding: 8, border: 'none', cursor: 'pointer' },
    inputGroup: { marginBottom: 12, display: 'flex', flexDirection: 'column', fontSize: 14 },
    input: { padding: 8, border: '1px solid #ccc', borderRadius: 6, fontSize: 14 },
    modalActions: { display: 'flex', justifyContent: 'space-between', marginTop: 20 },
    cancelBtn: { backgroundColor: 'transparent', color: mainColor, border: 'none', fontWeight: 'bold', cursor: 'pointer' },
    confirmBtn: { backgroundColor: mainColor, color: '#fff', border: 'none', padding: '8px 16px', borderRadius: 8, fontWeight: 'bold', cursor: 'pointer' },
};
