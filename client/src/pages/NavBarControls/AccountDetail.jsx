import React, { useState } from 'react';
import Sidebar from '../Navigations/SideBar';
import NavbarControls from '../Navigations/NavbarControl';

const mainColor = '#673AB7';

export default function AccountDetailPage() {
    const [isSidebarOpen, setIsSidebarOpen] = useState(true);

    const user = {
        name: '홍길동',
        email: 'hong@example.com',
        friendCode: '123213213121',
        joinedAt: '2024-01-15',
    };

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
            <div style={{ ...styles.navbar, marginLeft: isSidebarOpen ? 240 : 0 }}>
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
                                <>
                                    <input
                                        type="file"
                                        accept="image/*"
                                        onChange={handleImageUpload}
                                    />
                                </>
                                <label htmlFor="upload" style={styles.uploadLabel}>사진 업로드</label>
                                <input
                                    id="upload"
                                    type="file"
                                    accept="image/*"
                                    onChange={handleImageUpload}
                                    style={{ display: 'none' }}
                                />
                            </div>

                            {/* 텍스트 정보 */}
                            <div style={styles.infoText}>
                                <div style={styles.infoRow}><strong>이름:</strong> {user.name}</div>
                                <div style={styles.infoRow}><strong>이메일:</strong> {user.email}</div>
                                <div style={styles.infoRow}><strong>친구 코드:</strong> {user.friendCode}</div>
                                <div style={styles.infoRow}><strong>가입일:</strong> {user.joinedAt}</div>
                            </div>
                        </div>
                    </div>
                    <div style={styles.profilePhotoBox}>{/*CPM 영역*/}
                        <div style={styles.boxTitle}>CPM</div>
                        <div style={styles.placeholder}>목표, 평균 등</div>
                    </div>
                </div>
                <div style={styles.bottomSection}>{/*기록, 테스트 영역*/}
                    <div style={styles.noteBox}>
                        <div style={styles.boxTitle}>메모</div>
                        <div style={styles.placeholder}>메모 내용</div>
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
        padding: '96px 48px 32px',
        transition: 'margin-left 0.3s ease',
    },
    topSection: {
        display: 'flex',
        gap: '24px',
        marginBottom: '32px',
    },
    bottomSection: {
        display: 'flex',
        gap: '24px',
    },
    profileCard: {
        backgroundColor: '#fff',
        borderRadius: '12px',
        padding: '24px 32px',
        boxShadow: '0 4px 12px rgba(0,0,0,0.06)',
        flex: 1,
        minWidth: '300px',
    },
    header: {
        display: 'flex',
        alignItems: 'center',
        marginBottom: '16px',
        gap: '12px',
    },
    avatar: {
        fontSize: '28px',
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
};
