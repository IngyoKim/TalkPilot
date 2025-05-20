import { useState } from 'react';
import { motion } from 'framer-motion';
import { useNavigate } from 'react-router-dom';
import {
    FaHome,
    FaCalendarAlt,
    FaChalkboardTeacher,
    FaFileAlt,
    FaFileInvoice,
} from 'react-icons/fa';

const mainColor = '#673AB7';

export default function Sidebar({ isOpen }) {
    return (
        <motion.aside
            initial={{ x: -240 }}
            animate={{ x: isOpen ? 0 : -240 }}
            transition={{ duration: 0.3 }}
            style={styles.sidebar}
        >
            <div style={styles.logo} onClick={() => window.location.reload()}>
                TalkPilot
            </div>
            <button style={styles.practiceBtn}>Add Project</button>

            {sidebarItems.map(({ icon, text }) => (
                <SidebarItem key={text} icon={icon} text={text} />
            ))}
        </motion.aside>
    );
}

function SidebarItem({ icon, text }) {
    const [isHovered, setIsHovered] = useState(false);
    const navigate = useNavigate();

    const handleClick = () => {
        if (text === 'Home') {
            navigate('/');
        }
        else if (text === 'Schedule') {
            navigate('/schedule');
        }
        else if (text === 'My Presentation') {
            navigate('/presentation');
        }
    };
    return (
        <div
            style={{
                ...styles.sidebarItem,
                backgroundColor: isHovered ? '#e5e7eb' : 'transparent',
            }}
            onMouseEnter={() => setIsHovered(true)}
            onMouseLeave={() => setIsHovered(false)}
            onClick={handleClick}
        >
            {icon}
            <span style={{ marginLeft: 12 }}>{text}</span>
        </div>
    );
}

const sidebarItems = [
    { icon: <FaHome size={18} />, text: 'Home' },
    { icon: <FaCalendarAlt size={18} />, text: 'Schedule' },
    { icon: <FaChalkboardTeacher size={18} />, text: 'My Presentation' },
    { icon: <FaFileAlt size={18} />, text: 'Extract .txt' },
    { icon: <FaFileInvoice size={18} />, text: 'Extract .docx' },
];

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
        cursor: 'pointer',
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
        fontSize: '18px',
        fontWeight: '500',
        color: '#333',
        cursor: 'pointer',
        padding: '8px 12px',
        borderRadius: '6px',
        transition: 'background-color 0.2s ease',
    },
};
