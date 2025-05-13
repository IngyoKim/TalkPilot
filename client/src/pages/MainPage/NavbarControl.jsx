import React, { useState } from 'react';
import { ChevronLeft, ChevronRight, User } from 'lucide-react';

const mainColor = '#673AB7';

export default function NavbarControls({ isSidebarOpen, onToggleSidebar, onProfileClick }) {
    const [isHovered, setIsHovered] = useState(false);

    const ArrowIcon = () => {
        if (isSidebarOpen) {
            return isHovered ? <ChevronRight size={20} /> : <ChevronLeft size={20} />;
        } else {
            return isHovered ? <ChevronLeft size={20} /> : <ChevronRight size={20} />;
        }
    };

    return (
        <div style={styles.container}>
            <div
                style={styles.arrowToggle}
                onClick={onToggleSidebar}
                onMouseEnter={() => setIsHovered(true)}
                onMouseLeave={() => setIsHovered(false)}
            >
                <ArrowIcon />
            </div>
            <div style={styles.profileIcon} onClick={onProfileClick}>
                <User size={20} color={mainColor} strokeWidth={2} />
            </div>
        </div>
    );
}

const styles = {
    container: {
        display: 'flex',
        alignItems: 'center',
        marginLeft: '240px',
        gap: '16px',
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
};
