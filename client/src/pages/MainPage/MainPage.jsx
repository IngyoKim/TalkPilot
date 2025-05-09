import React from 'react';
import { Home, Calendar, User } from 'lucide-react';
import { motion } from 'framer-motion';

export default function MainPage() {
    return (
        <div style={styles.container}>
            {/* Top Navbar */}
            <div style={styles.navbar}>
                <h1 style={styles.title}>TalkPilot</h1>
                <div style={styles.navButtons}>
                    <button style={styles.navButton}>Script</button>
                    <button style={styles.navButton}>Schedule</button>
                    <User size={24} />
                </div>
            </div>

            {/* Main Content */}
            <motion.div
                style={styles.mainContent}
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
            >
                <h2 style={styles.welcomeText}>Welcome to TalkPilot!</h2>
                <button style={styles.startButton}>Start a New Presentation</button>

                <div style={styles.grid}>
                    <button style={styles.card}>
                        <Calendar size={40} style={{ marginBottom: 12 }} />
                        <div style={styles.cardText}>Schedule</div>
                    </button>
                    <button style={styles.card}>
                        <Home size={40} style={{ marginBottom: 12 }} />
                        <div style={styles.cardText}>Project</div>
                    </button>
                    <button style={styles.card}>
                        <User size={40} style={{ marginBottom: 12 }} />
                        <div style={styles.cardText}>Profile</div>
                    </button>
                </div>
            </motion.div>

            <footer style={styles.footer}>
                © 2025 TalkPilot. All rights reserved.
            </footer>
        </div>
    );
}

const styles = {
    container: {
        minHeight: '100vh',
        display: 'flex',
        flexDirection: 'column',
        backgroundColor: '#f7f7f7',
    },
    navbar: {
        display: 'flex',
        justifyContent: 'space-between',
        alignItems: 'center',
        padding: '16px 32px',
        backgroundColor: '#fff',
        boxShadow: '0 2px 4px rgba(0,0,0,0.1)',
    },
    title: {
        fontSize: '28px',
        fontWeight: 'bold',
    },
    navButtons: {
        display: 'flex',
        alignItems: 'center',
        gap: '16px',
    },
    navButton: {
        padding: '8px 16px',
        backgroundColor: 'transparent',
        color: '#555',
        border: 'none',
        cursor: 'pointer',
        fontSize: '16px',
    },
    mainContent: {
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        padding: '48px 16px',
        flex: 1,
    },
    welcomeText: {
        fontSize: '24px',
        fontWeight: '600',
        marginBottom: '24px',
    },
    startButton: {
        padding: '12px 24px',
        marginBottom: '48px',
        backgroundColor: '#3b82f6',
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
        backgroundColor: '#fff',
        borderRadius: '12px',
        boxShadow: '0 2px 8px rgba(0,0,0,0.1)',
        cursor: 'pointer',
        transition: 'all 0.2s',
    },
    cardText: {
        fontSize: '16px',
        fontWeight: '500',
    },
    footer: {
        textAlign: 'center',
        padding: '16px',
        fontSize: '12px',
        color: '#888',
        backgroundColor: '#fff',
    },
};
