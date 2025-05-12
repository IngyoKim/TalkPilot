import React, { useState } from 'react';
import { User, ChevronLeft, ChevronRight } from 'lucide-react';
import { motion } from 'framer-motion';
import { useNavigate } from 'react-router-dom';
import Sidebar from './SideBar';

const mainColor = '#673AB7';

export default function MainPage() {
    const [isSidebarOpen, setIsSidebarOpen] = useState(true);
    const [isHovered, setIsHovered] = useState(false);
    const navigate = useNavigate();

    const handleProfileClick = () => {
        navigate('/profile');
    };

    const handleToggleSidebar = () => {
        setIsSidebarOpen(prev => !prev);
    };

    return (
        <div style={styles.container}>
            {/* Top Navbar */}
            <div style={{ ...styles.navbar, marginLeft: isSidebarOpen ? '240px' : '0' }}>
                <div
                    style={styles.arrowToggle}
                    onClick={handleToggleSidebar}
                    onMouseEnter={() => setIsHovered(true)}
                    onMouseLeave={() => setIsHovered(false)}
                >
                    {isSidebarOpen
                        ? (isHovered ? <ChevronRight size={20} /> : <ChevronLeft size={20} />)
                        : (isHovered ? <ChevronLeft size={20} /> : <ChevronRight size={20} />)
                    }
                </div>

                <div style={styles.profileIcon} onClick={handleProfileClick}>
                    <User size={20} color={mainColor} strokeWidth={2} />
                </div>
            </div>

            {/* Sidebar */}
            <Sidebar isOpen={isSidebarOpen} />

            {/* Main Content */}
            <motion.div
                style={{
                    ...styles.mainContent,
                    marginLeft: isSidebarOpen ? '240px' : '0',
                }}
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                transition={{ duration: 0.3 }}
            >
                <div style={styles.headerSection}>
                    <h2 style={styles.welcomeText}>Welcome to TalkPilot!</h2>
                    <button style={styles.startButton}>Start a New Presentation</button>
                    <p style={styles.emptyMessage}>현재 생성된 프로젝트가 없습니다.</p>
                </div>
            </motion.div>

            <footer style={{ ...styles.footer, marginLeft: isSidebarOpen ? '240px' : '0' }}>
                © 2025 TalkPilot. All rights reserved.
            </footer>
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
    title: {
        fontSize: '24px',
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
    menuButton: {
        background: 'none',
        border: 'none',
        cursor: 'pointer',
        marginRight: '12px',
    },
    arrowToggle: {
        backgroundColor: '#ffffff',
        border: `1px solid ${mainColor}`,
        borderRadius: '50%',
        width: '36px',
        height: '36px',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        cursor: 'pointer',
        transition: 'background-color 0.2s ease',
    },
    mainContent: {
        padding: '80px 32px 32px',
        flex: 1,
        transition: 'margin-left 0.3s ease',
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
        padding: '8px 0',
        fontSize: '12px',
        color: '#000000',
        backgroundColor: '#FFFFFF',
        position: 'fixed',
        bottom: 0,
        width: '100%',
    },
};
