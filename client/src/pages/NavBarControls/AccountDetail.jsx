// src/pages/NavBarControls/AccountDetail.jsx
import React, { useState } from 'react';
import Sidebar from '../Navigations/SideBar';
import NavbarControls from '../Navigations/NavbarControl';

const mainColor = '#673AB7';

export default function AccountDetailPage() {
    const [isSidebarOpen, setIsSidebarOpen] = useState(true);

    const dummyUser = {//임시
        name: '홍길동',
        email: 'hong@example.com',
        role: 'User',
        joinedAt: '2024-01-15',
    };

    const handleToggleSidebar = () => setIsSidebarOpen(prev => !prev);

    return (
        <div style={styles.container}>
            {/* Navbar */}
            <div style={{ ...styles.navbar, marginLeft: isSidebarOpen ? 240 : 0 }}>
                <NavbarControls
                    isSidebarOpen={isSidebarOpen}
                    onToggleSidebar={handleToggleSidebar}
                    user={dummyUser}
                />
            </div>

            {/* Sidebar */}
            <Sidebar isOpen={isSidebarOpen} />

            {/* Main content */}
            <div style={{ ...styles.mainContent, marginLeft: isSidebarOpen ? 240 : 0 }}>
                <h2 style={styles.title}>Account Detail</h2>
                <div style={styles.infoBox}>
                    <div><strong>이름:</strong> {dummyUser.name}</div>
                    <div><strong>이메일:</strong> {dummyUser.email}</div>
                    <div><strong>역할:</strong> {dummyUser.role}</div>
                    <div><strong>가입일:</strong> {dummyUser.joinedAt}</div>
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
        backgroundColor: '#FFFFFF',
        overflow: 'hidden',
    },
    navbar: {
        display: 'flex',
        justifyContent: 'space-between',
        alignItems: 'center',
        padding: '16px 32px',
        backgroundColor: '#FFFFFF',
        position: 'fixed',
        top: 0,
        left: 0,
        right: 0,
        zIndex: 1000,
        height: '64px',
        boxShadow: '0 1px 4px rgba(0,0,0,0.05)',
    },
    mainContent: {
        padding: '80px 32px 32px',
        flex: 1,
        transition: 'margin-left 0.3s ease',
    },
    title: {
        fontSize: '24px',
        fontWeight: 'bold',
        marginBottom: '24px',
        color: '#333',
    },
    infoBox: {
        backgroundColor: '#fff',
        padding: '24px',
        borderRadius: '8px',
        boxShadow: '0 2px 8px rgba(0,0,0,0.05)',
        lineHeight: '2',
    },
};
