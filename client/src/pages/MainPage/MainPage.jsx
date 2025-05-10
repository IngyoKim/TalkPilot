import React from 'react';
import { Home, Calendar, User } from 'lucide-react';
import { motion } from 'framer-motion';
import { useNavigate } from 'react-router-dom';

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

            {/* 경계선 */}
            <div style={styles.divider} />

            {/* Main Content */}
            <motion.div
                style={styles.mainContent}
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
            >
                <div style={styles.headerSection}>
                    <h2 style={styles.welcomeText}>Welcome to TalkPilot!</h2>
                    <button style={styles.startButton}>Start a New Presentation</button>
                </div>

                <div style={styles.grid}>
                    <button style={styles.card}>
                        <Calendar size={40} style={{ marginBottom: 12, color: '#000000' }} />
                        <div style={styles.cardText}>Schedule</div>
                    </button>
                    <button style={styles.card}>
                        <Home size={40} style={{ marginBottom: 12, color: '#000000' }} />
                        <div style={styles.cardText}>Project</div>
                    </button>
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
    mainContent: {
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        padding: '48px 16px',
        flex: 1,
        color: mainColor,
    },
    headerSection: {
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        gap: '24px',
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
    grid: {
        display: 'grid',
        gridTemplateColumns: 'repeat(auto-fit, minmax(120px, 1fr))',
        gap: '16px',
        width: '100%',
        maxWidth: '800px',
    },
    card: {
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        padding: '24px',
        backgroundColor: '#FFFFFF',
        borderRadius: '12px',
        boxShadow: '0 2px 8px rgba(0,0,0,0.1)',
        cursor: 'pointer',
        transition: 'all 0.2s',
        border: `2px solid #000000`,
    },
    cardText: {
        fontSize: '16px',
        fontWeight: '500',
        color: '#000000',
    },
    footer: {
        textAlign: 'center',
        padding: '16px',
        fontSize: '12px',
        color: '#000000',
        backgroundColor: '#FFFFFF',
    },
};
