import React from 'react';
import { Home, Layers, BarChart2, BookOpen } from 'lucide-react';

export default function Sidebar() {
    return (
        <aside style={styles.sidebar}>
            {/* 상단 로고 + 버튼 */}
            <div style={styles.logoSection}>
                <button style={styles.practiceBtn}>Add Project</button>
                <SidebarItem icon={<Home size={18} />} text="Home" />
                <SidebarItem icon={<Layers size={18} />} text="Builder" />
                <SidebarItem icon={<BarChart2 size={18} />} text="Dashboard" />
                <SidebarItem icon={<BookOpen size={18} />} text="My Learning" />
            </div>
        </aside>
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
        justifyContent: 'space-between',
        padding: '24px 16px',
        boxShadow: '2px 0 6px rgba(0,0,0,0.05)',
        minHeight: '100vh',
    },
    logoSection: {
        display: 'flex',
        flexDirection: 'column',
        gap: '16px',
    },
    logo: {
        fontSize: '20px',
        fontWeight: 'bold',
        color: '#673AB7',
    },
    practiceBtn: {
        background: 'linear-gradient(to right, #5D5FEF, #7A5FFF)',
        color: '#fff',
        border: 'none',
        borderRadius: '8px',
        padding: '8px 16px',
        fontWeight: '600',
        cursor: 'pointer',
    },
    menuSection: {
        marginTop: '32px',
        display: 'flex',
        flexDirection: 'column',
        gap: '16px',
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
        transition: 'background 0.2s',
    },
    bottomSection: {
        display: 'flex',
        flexDirection: 'column',
        gap: '12px',
    },
};
