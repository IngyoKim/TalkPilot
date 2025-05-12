import React from 'react';
import { User } from 'lucide-react';
import { motion } from 'framer-motion';
import { useNavigate } from 'react-router-dom';

import Sidebar from './SideBar';

export default function MainPage() {
    const navigate = useNavigate();

    const handleProfileClick = () => {
        navigate('/profile');
    };

    return (
        <div style={styles.container}>
            {/* Top Navbar */}
            <div style={styles.navbar}>
                <h1 style={styles.title}>TalkPilot</h1>
                <div style={styles.profileIcon} onClick={handleProfileClick}>
                    <User size={20} color="#673AB7" strokeWidth={2} />
                </div>
            </div>

            {/* Divider */}
            <div style={styles.wrapper}>
                <Sidebar />
                <main style={styles.mainContent}>
                    <h1>Welcome to TalkPilot!</h1>
                    <p>현재 생성된 프로젝트가 없습니다.</p>
                </main>
            </div>
            {/* Main Content */}
            <motion.div
                style={styles.mainContent}
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
            >
                <div style={styles.headerSection}>
                    <h2 style={styles.welcomeText}>Welcome to TalkPilot!</h2>
                    <button style={styles.startButton}>Start a New Presentation</button>
                    <p style={styles.emptyMessage}>현재 생성된 프로젝트가 없습니다.</p>
                </div>
            </motion.div>

            <footer style={styles.footer}>
                © 2025 TalkPilot. All rights reserved.
            </footer>
        </div>
    );
}

const mainColor = '#673AB7';

const styles = {
    container: {
        minHeight: '100vh',
        display: 'flex',
        flexDirection: 'column',
        backgroundColor: '#FFFFFF',
    },
    navbar: {
        display: 'flex',
        justifyContent: 'space-between',
        alignItems: 'center',
        padding: '16px 32px',
        backgroundColor: '#FFFFFF',
    },
    title: {
        fontSize: '28px',
        fontWeight: 'bold',
        color: mainColor,
    },
    profileIcon: {
        width: '40px',
        height: '40px',
        borderRadius: '50%',
        backgroundColor: '#FFFFFF',
        border: `2px solid ${mainColor}`,
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
        cursor: 'pointer',
    },
    divider: {
        height: '1px',
        backgroundColor: '#E0E0E0',
        width: '100%',
    },
    wrapper: {
        display: 'flex',
        minHeight: '100vh',
    },
    mainContent: {
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        padding: '48px 16px',
        flex: 1,
    },
    verticalMenu: {
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'flex-start',
        padding: '16px 32px',
        gap: '8px',
        backgroundColor: '#FFFFFF',
    },

    menuItem: {
        fontSize: '16px',
        fontWeight: '500',
        color: '#333333',
        cursor: 'pointer',
    },
    headerSection: {
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        gap: '16px',
        marginBottom: '48px',
    },
    welcomeText: {
        fontSize: '24px',
        fontWeight: '600',
        color: '#555555',
    },
    startButton: {
        padding: '12px 24px',
        backgroundColor: mainColor,
        color: '#fff',
        border: 'none',
        borderRadius: '8px',
        cursor: 'pointer',
        fontSize: '16px',
    },
    emptyMessage: {
        marginTop: '12px',
        fontSize: '14px',
        color: '#888888',
    },
    footer: {
        textAlign: 'center',
        padding: '16px',
        fontSize: '12px',
        color: '#000000',
        backgroundColor: '#FFFFFF',
    },
};
