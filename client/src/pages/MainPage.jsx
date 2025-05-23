import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { motion } from 'framer-motion';

import Sidebar from '../components/SideBar';
import ProfileDropdown from './Profile/ProfileDropdown';
import MyPresentation from './SidebarOP/MyPresentation';


const mainColor = '#673AB7';

export default function MainPage() {
    const [isSidebarOpen, setIsSidebarOpen] = useState(true);
    const handleProfileClick = () => {
        console.log('프로필 클릭!');
    };
    const handleToggleSidebar = () => setIsSidebarOpen(prev => !prev);
    const navigate = useNavigate();

    return (
        <div style={styles.container}>
            {/* Top Navbar */}
            <div style={{ ...styles.navbar, marginLeft: isSidebarOpen ? '240px' : '0' }}>
                <ProfileDropdown
                    isSidebarOpen={isSidebarOpen}
                    onToggleSidebar={handleToggleSidebar}
                    onProfileClick={handleProfileClick}
                />
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
                    <button style={styles.startButton} onClick={() => navigate('/presentation')}>
                        Start a Presentation
                    </button>
                </div>
            </motion.div>

            {/* Footer */}
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
    navbarLeft: {
        display: 'flex',
        alignItems: 'center',
        gap: '12px',
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
