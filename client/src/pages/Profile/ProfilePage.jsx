// pages/ProfilePage.jsx
import { useState } from 'react';
import { FaUserCircle, FaEdit, FaCheckCircle, FaChartLine, FaBullseye, FaPoll, FaAngellist, FaTachometerAlt } from 'react-icons/fa';
import Sidebar from '../../components/SideBar';
import ProfileDropdown from './ProfileDropdown';
import { useUser } from '../../contexts/UserContext';
import { updateUser } from '../../utils/api/user';

const mainColor = '#673AB7';

export default function ProfilePage() {
    const [isSidebarOpen, setIsSidebarOpen] = useState(true);
    const [profileImage] = useState(null);
    const { user, setUser } = useUser();

    const [isEditingNickname, setIsEditingNickname] = useState(false);
    const [nickname, setNickname] = useState(user?.name ?? '');

    const handleToggleSidebar = () => setIsSidebarOpen(prev => !prev);

    // 닉네임 수정 시작
    const startEditNickname = () => {
        setNickname(user?.nickname ?? '');
        setIsEditingNickname(true);
    };

    // 닉네임 저장
    const saveNickname = async () => {
        try {
            await updateUser({ nickname: nickname });
            setUser(prev => ({ ...prev, nickname: nickname }));
            setIsEditingNickname(false);
            alert('닉네임이 수정되었습니다.');
        } catch (err) {
            alert('닉네임 수정에 실패했습니다.');
            console.error(err);
        }
    };

    // 닉네임 편집 취소
    const cancelEdit = () => {
        setIsEditingNickname(false);
        setNickname(user?.nickname ?? '');
    };

    if (!user) {
        return <div style={{ padding: 40 }}>사용자 정보를 불러오는 중입니다...</div>;
    }

    return (
        <div style={styles.container}>
            <div style={{ ...styles.navbar, marginLeft: isSidebarOpen ? 240 : 0, transition: 'all 0.3s ease' }}>
                <ProfileDropdown
                    isSidebarOpen={isSidebarOpen}
                    onToggleSidebar={handleToggleSidebar}
                />
            </div>

            <Sidebar isOpen={isSidebarOpen} />

            <div style={{ ...styles.mainContent, marginLeft: isSidebarOpen ? 240 : 0 }}>
                <div style={styles.topSection}>
                    <div style={styles.profileCard}>
                        <div style={styles.header}>
                            <span role="img" aria-label="user" style={styles.avatar}>👤</span>
                            <h2 style={styles.title}>Account Detail</h2>
                        </div>
                        <div style={styles.infoSection}>
                            <div style={styles.photoBox}>
                                {profileImage ? (
                                    <img
                                        src={profileImage}
                                        alt="프로필"
                                        style={styles.image}
                                    />
                                ) : (
                                    <FaUserCircle size={100} color="#bbb" />
                                )}
                            </div>
                            <div style={styles.infoText}>
                                <div style={styles.infoRow}>
                                    <strong>이름:</strong>{' '}
                                    {isEditingNickname ? (
                                        <>
                                            <input
                                                type="text"
                                                value={nickname}
                                                onChange={e => setNickname(e.target.value)}
                                                style={{ fontSize: 16, padding: 4, width: 180 }}
                                            />
                                            <button onClick={saveNickname} style={{ marginLeft: 8 }}>저장</button>
                                            <button onClick={cancelEdit} style={{ marginLeft: 4 }}>취소</button>
                                        </>
                                    ) : (
                                        <>
                                            {user.nickname}
                                            <FaEdit style={styles.editIcon} onClick={startEditNickname} />
                                        </>
                                    )}
                                </div>
                                <div style={styles.infoRow}><strong>이메일:</strong> {user.email}</div>
                                <div style={styles.infoRow}><strong>친구 코드:</strong> {user.friendCode ?? '없음'}</div>
                                <div style={styles.infoRow}><strong>가입일:</strong> {user.createdAt?.slice(0, 10)}</div>
                            </div>
                        </div>
                    </div>

                    <div style={styles.profileSideBox}>
                        <div style={styles.header}>
                            <FaAngellist style={styles.avatar} />
                            <span style={styles.accountTitle}>Statistics</span>
                        </div>
                        <div style={styles.metricsItem}>
                            <FaCheckCircle style={styles.icon} />
                            <span><strong>완료한 발표:</strong> {user.completedPresentation ?? 0}회</span>
                        </div>
                        <div style={styles.metricsItem}>
                            <FaChartLine style={styles.icon} />
                            <span><strong>평균 발표 점수:</strong> {user.averageScore ?? 0}점</span>
                        </div>
                        <div style={styles.metricsItem}>
                            <FaBullseye style={styles.icon} />
                            <span>
                                <strong>목표 점수:</strong> {user.targetScore ?? 0}점
                                <FaEdit style={styles.editIcon} onClick={() => alert('목표 점수 수정 구현 예정')} />
                            </span>
                        </div>
                        <div style={styles.metricsItem}>
                            <FaPoll style={styles.icon} />
                            <span><strong>평균 CPM:</strong> {user.averageCPM ?? 0}</span>
                        </div>
                    </div>
                </div>

                <div style={styles.bottomSection}>
                    <div style={styles.gridBox}>
                        <div style={styles.boxTitle}>
                            <FaCheckCircle style={styles.icon} />
                            발표 기록 보기
                        </div>
                        <div style={styles.placeholder}>당신의 발표 기록 데이터를 확인할 수 있습니다.</div>
                        <button style={styles.actionButton}>확인하기</button>
                    </div>

                    <div style={styles.gridBox}>
                        <div style={styles.boxTitle}>
                            <FaPoll style={styles.icon} />
                            임시 STT 테스트
                        </div>
                        <div style={styles.placeholder}>STT 기능을 확인할 수 있습니다.</div>
                        <button style={styles.actionButton}>테스트</button>
                    </div>

                    <div style={styles.gridBox}>
                        <div style={styles.boxTitle}>
                            <FaTachometerAlt style={styles.icon} />
                            CPM 계산 페이지
                        </div>
                        <div style={styles.placeholder}>당신의 CPM이 몇인지 측정하세요.</div>
                        <button style={styles.actionButton}>테스트</button>
                    </div>
                </div>
            </div>
        </div>
    );
}

const styles = {
    container: {
        height: '100vh',
        display: 'flex',
        flexDirection: 'column',
        backgroundColor: '#f9f9f9',
        overflow: 'hidden',
    },
    navbar: {
        position: 'fixed',
        top: 0,
        left: 0,
        right: 0,
        height: '64px',
        backgroundColor: '#fff',
        zIndex: 1000,
        boxShadow: '0 1px 4px rgba(0,0,0,0.05)',
        display: 'flex',
        alignItems: 'center',
        padding: '0 32px',
    },
    mainContent: {
        display: 'flex',
        flexDirection: 'column',
        padding: '96px 48px 32px',
        boxSizing: 'border-box',
        transition: 'all 0.3s ease',
        overflowX: 'auto',
    },
    topSection: {
        display: 'flex',
        gap: '24px',
        marginBottom: '32px',
    },
    bottomSection: {
        display: 'grid',
        gridTemplateColumns: 'repeat(3, 1fr)',
        gap: '24px',
        marginTop: '24px',
        width: '100%',
    },
    profileCard: {
        backgroundColor: '#fff',
        borderRadius: '12px',
        padding: '24px 32px',
        boxShadow: '0 4px 12px rgba(0,0,0,0.06)',
        flex: 2,
        minWidth: '300px',
    },
    profileSideBox: {
        flex: 1,
        backgroundColor: '#fff',
        borderRadius: '12px',
        padding: '24px',
        boxShadow: '0 4px 12px rgba(0,0,0,0.06)',
        minWidth: '200px',
    },
    accountTitle: {
        fontSize: '20px',
        fontWeight: '600',
        color: '#333',
        letterSpacing: '0.5px',
    },
    header: {
        display: 'flex',
        alignItems: 'center',
        marginBottom: '16px',
        gap: '12px',
    },
    avatar: {
        fontSize: '26px',
        color: mainColor,
    },
    title: {
        fontSize: '22px',
        fontWeight: 'bold',
        color: '#333',
    },
    infoSection: {
        display: 'flex',
        alignItems: 'center',
        gap: '24px',
        marginTop: '12px',
    },
    photoBox: {
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        gap: '8px',
    },
    image: {
        width: '100px',
        height: '100px',
        borderRadius: '50%',
        objectFit: 'cover',
        border: '2px solid #ccc',
    },
    imagePlaceholder: {
        width: '100px',
        height: '100px',
        borderRadius: '50%',
        backgroundColor: '#eee',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        color: '#999',
    },
    infoText: {
        display: 'flex',
        flexDirection: 'column',
        gap: '8px',
        fontSize: '16px',
        color: '#444',
    },
    infoRow: {
        fontSize: '16px',
        color: '#444',
    },
    boxTitle: {
        fontWeight: '600',
        fontSize: '16px',
        marginBottom: '12px',
        color: '#555',
        display: 'flex',
        alignItems: 'center',
        gap: '8px',
    },
    icon: {
        fontSize: '16px',
        marginRight: '8px',
        color: mainColor,
        flexShrink: 0,
    },
    metricsItem: {
        display: 'flex',
        alignItems: 'center',
        gap: '8px',
        fontSize: '14px',
        color: '#444',
        marginBottom: '12px',
        paddingBottom: '8px',
        borderBottom: '1px solid #ddd',
    },
    gridBox: {
        backgroundColor: '#fff',
        borderRadius: '12px',
        padding: '24px',
        boxShadow: '0 4px 12px rgba(0,0,0,0.06)',
        minHeight: '180px',
        boxSizing: 'border-box',
    },
    placeholder: {
        color: '#999',
        fontSize: '14px',
    },
    editIcon: {
        marginLeft: '6px',
        cursor: 'pointer',
        color: mainColor,
    },
    actionButton: {
        marginTop: '16px',
        padding: '8px 16px',
        backgroundColor: mainColor,
        color: '#fff',
        border: 'none',
        borderRadius: '6px',
        cursor: 'pointer',
        fontSize: '14px',
        alignSelf: 'flex-start',
    },
};
