import React from 'react';
import { Home, BarChart2, BookOpen, Calendar1 } from 'lucide-react';
import { motion } from 'framer-motion';

const mainColor = '#673AB7';

export default function Sidebar({ isOpen }) {
    return (
        <motion.aside
            initial={{ x: -240 }}
            animate={{ x: isOpen ? 0 : -240 }}
            transition={{ duration: 0.3 }}
            style={styles.sidebar}
        >
            <div style={styles.logo}>TalkPilot</div>
            <button style={styles.practiceBtn}>Add Project</button>
            <SidebarItem icon={<Home size={18} />} text="Home" />
            <SidebarItem icon={<Calendar1 size={18} />} text="Schedule" />
            <SidebarItem icon={<BarChart2 size={18} />} text="Dashboard" />
            <SidebarItem icon={<BookOpen size={18} />} text="My Learning" />
        </motion.aside>
    );
}

function SidebarItem({ icon, text }) {
    return (
        <div style={styles.sidebarItem}>
            {icon}
            <span style={{ marginLeft: 12 }}>{text}</span>
        </div>
    );
}

const styles = {
    sidebar: {
        width: '240px',
        backgroundColor: '#F5F7FF',
        display: 'flex',
        flexDirection: 'column',
        padding: '24px 16px',
        height: '100vh',
        position: 'fixed',
        top: 0,
        left: 0,
        zIndex: 999,
        boxShadow: '2px 0 6px rgba(0,0,0,0.05)',
    },
    logo: {
        fontSize: '28px',
        fontWeight: '700',
        color: mainColor,
        textAlign: 'center',
        marginBottom: '16px',
    },
    practiceBtn: {
        background: mainColor,
        color: '#fff',
        border: 'none',
        borderRadius: '8px',
        padding: '8px 16px',
        fontWeight: '600',
        cursor: 'pointer',
        marginBottom: '24px',
    },
    sidebarItem: {
        display: 'flex',
        alignItems: 'center',
        fontSize: '15px',
        fontWeight: '500',
        color: '#333',
        cursor: 'pointer',
        padding: '8px 12px',
        borderRadius: '6px',
        transition: 'background-color 0.2s ease',
    },
};
