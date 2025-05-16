import React, { useState } from 'react';
import Sidebar from '../Navigations/SideBar';
import NavbarControls from '../Navigations/NavbarControl';

import { FaEdit, FaCheckCircle, FaChartLine, FaBullseye, FaPoll, FaAngellist, FaTachometerAlt } from 'react-icons/fa';

const mainColor = '#673AB7';

export default function AccountDetailPage() {
    const [isSidebarOpen, setIsSidebarOpen] = useState(true);

    const user = {
        name: '홍길동',
        email: 'hong@example.com',
        friendCode: '123213213121',
        joinedAt: '2024-01-15',
    };
    const handleEdit = () => {
        alert('구현할까 고민중.');
    };
    const metricsData = [
        { icon: <FaCheckCircle style={styles.icon} />, label: '완료한 발표', value: '12회' },
        { icon: <FaChartLine style={styles.icon} />, label: '평균 발표 점수', value: '87점' },
        { icon: <FaBullseye style={styles.icon} />, label: '목표 점수', value: '90점' },
        { icon: <FaPoll style={styles.icon} />, label: '평균 CPM', value: '152' },
    ];

    const handleToggleSidebar = () => setIsSidebarOpen(prev => !prev);
    const [profileImage, setProfileImage] = useState(null);

    const handleImageUpload = (e) => {
        const file = e.target.files[0];
        if (file) {
            const reader = new FileReader();
            reader.onloadend = () => {
                setProfileImage(reader.result);  // profileImage state에 저장
            };
            reader.readAsDataURL(file);
        }
    };

    return (

        <div style={styles.container}>
            {/* Navbar */}
            <div style={{ ...styles.navbar, marginLeft: isSidebarOpen ? 240 : 0, transition: 'all 0.3s ease', }}>
                <NavbarControls
                    isSidebarOpen={isSidebarOpen}
                    onToggleSidebar={handleToggleSidebar}
                    user={user}
                />
            </div>

            {/* Sidebar */}
            <Sidebar isOpen={isSidebarOpen} />

            {/* Main Content */}
            <div style={{ ...styles.mainContent, marginLeft: isSidebarOpen ? 240 : 0 }}>

                <div style={styles.topSection}>
                    <div style={styles.profileCard}>
                        <div style={styles.header}>
                            <span role="img" aria-label="user" style={styles.avatar}>👤</span>
                            <h2 style={styles.title}>Account Detail</h2>
                        </div>

                        <div style={styles.infoSection}>
                            {/* 프로필 사진 */}
                            <div style={styles.photoBox}>
                                {profileImage ? (
                                    <img src={profileImage} alt="프로필" style={styles.image} />
                                ) : (
                                    <div style={styles.imagePlaceholder}>이미지 없음</div>
                                )}

                            </div>

                            {/* 텍스트 정보 */}
                            <div style={styles.infoText}>
                                <div style={styles.infoRow}><strong>이름:</strong> {user.name}<FaEdit style={styles.editIcon} onClick={handleEdit} />
                                </div>
                                <div style={styles.infoRow}><strong>이메일:</strong> {user.email}</div>
                                <div style={styles.infoRow}><strong>친구 코드:</strong> {user.friendCode}</div>
                                <div style={styles.infoRow}><strong>가입일:</strong> {user.joinedAt}</div>
                            </div>
                        </div>
                    </div>
                    <div style={styles.profileSideBox}>{/*CPM 영역*/}
                        <div style={styles.header}>
                            <FaAngellist style={styles.avatar} />
                            <span style={styles.accountTitle}>Statistics</span>
                        </div>

                        <div style={styles.metricsItem}>
                            <FaCheckCircle style={styles.icon} />
                            <span><strong>완료한 발표:</strong> 12회</span>
                        </div>
                        <div style={styles.metricsItem}>
                            <FaChartLine style={styles.icon} />
                            <span><strong>평균 발표 점수:</strong> 87점</span>
                        </div>
                        <div style={styles.metricsItem}>
                            <FaBullseye style={styles.icon} />
                            <span><strong>목표 점수:</strong> 90점<FaEdit style={styles.editIcon} onClick={handleEdit} /></span>
                        </div>
                        <div style={styles.metricsItem}>
                            <FaPoll style={styles.icon} />
                            <span><strong>평균 CPM:</strong> 152</span>
                        </div>
                    </div>
                </div>
                <div style={styles.bottomSection}>{/*기록, 테스트 영역*/}
                    <div style={styles.gridBox}>
                        <div style={styles.boxTitle}>
                            <FaCheckCircle style={styles.icon} />
                            발표 기록 보기
                        </div>
                        <div style={styles.placeholder}>기록 데이터</div>
                    </div>
                    <div style={styles.gridBox}>
                        <div style={styles.boxTitle}>
                            <FaPoll style={styles.icon} />
                            임시 STT 테스트 페이지
                        </div>
                        <div style={styles.placeholder}>STT 기능 미리보기</div>
                    </div>
                    <div style={styles.gridBox}>
                        <div style={styles.boxTitle}>
                            <FaTachometerAlt style={styles.icon} />
                            CPM 계산 페이지
                        </div>
                        <div style={styles.placeholder}>계산 결과</div>
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
        overflowX: 'auto', // 잘릴 경우 대비 스크롤 허용
    },
    topSection: {
        display: 'flex',
        gap: '24px',
        marginBottom: '32px',
    },
    bottomSection: {
        display: 'grid',
        gridTemplateColumns: 'repeat(3, 1fr)', // 고정 3개
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
        color: '#673AB7',
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
    uploadLabel: {
        backgroundColor: '#673AB7',
        color: '#fff',
        padding: '6px 12px',
        borderRadius: '6px',
        cursor: 'pointer',
        fontSize: '12px',
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
    },
    noteBox: {
        flex: 1,
        backgroundColor: '#fff',
        borderRadius: '12px',
        padding: '24px',
        boxShadow: '0 4px 12px rgba(0,0,0,0.06)',
        minHeight: '200px',
    },
    recordBox: {
        flex: 1,
        backgroundColor: '#fff',
        borderRadius: '12px',
        padding: '24px',
        boxShadow: '0 4px 12px rgba(0,0,0,0.06)',
        minHeight: '200px',
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
    bottomGrid: {
        display: 'grid',
        gridTemplateColumns: 'repeat(3, minmax(220px, 1fr))', // 최소 220px 확보
        gap: '24px',
        marginTop: '24px',
    },
    gridBox: {
        backgroundColor: '#fff',
        borderRadius: '12px',
        padding: '24px',
        boxShadow: '0 4px 12px rgba(0,0,0,0.06)',
        minHeight: '180px',
        boxSizing: 'border-box',
    }
};
