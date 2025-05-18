import { useState, useRef, useEffect } from 'react';
import {
    FaChevronLeft, FaChevronRight, FaUser, FaCog,
    FaQuestionCircle, FaEnvelope, FaSignOutAlt, FaUserEdit
} from 'react-icons/fa';
import { useNavigate } from 'react-router-dom';
import { logout } from '../../utils/auth/auth';
import { useUser } from '../../contexts/UserContext';

const mainColor = '#673AB7';

export default function NavbarControls({ isSidebarOpen, onToggleSidebar }) {
    const navigate = useNavigate();
    const { user } = useUser();
    const [isHovered, setIsHovered] = useState(false);
    const [menuOpen, setMenuOpen] = useState(false);
    const menuRef = useRef(null);

    const handleLogout = async () => {
        const confirmed = window.confirm("로그아웃을 하시겠습니까?");
        if (!confirmed) return;
        try {
            await logout();
            navigate('/login');
        } catch (error) {
            alert('로그아웃 중 오류가 발생했습니다.');
        }
    };

    useEffect(() => {
        function onClickOutside(error) {
            if (menuRef.current && !menuRef.current.contains(error.target)) {
                setMenuOpen(false);
            }
        }
        document.addEventListener('mousedown', onClickOutside);
        return () => document.removeEventListener('mousedown', onClickOutside);
    }, []);

    const ArrowIcon = () => {
        if (isSidebarOpen) {
            return isHovered ? <FaChevronRight size={20} /> : <FaChevronLeft size={20} />;
        } else {
            return isHovered ? <FaChevronLeft size={20} /> : <FaChevronRight size={20} />;
        }
    };

    const menuItems = [
        { icon: <FaUserEdit />, label: 'Account Detail', onClick: () => console.log('계정 더보기') },
        { icon: <FaCog />, label: 'Setting', onClick: () => console.log('설정') },
        { icon: <FaQuestionCircle />, label: 'Help Center', onClick: () => console.log('도움말') },
        { icon: <FaEnvelope />, label: 'Contact us', onClick: () => console.log('문의하기') },
        { icon: <FaSignOutAlt />, label: 'Log Out', onClick: handleLogout, isDanger: true },
    ];

    return (
        <div style={styles.container}>
            <div
                style={{ ...styles.arrowToggle, left: isSidebarOpen ? 260 : 20 }}
                onClick={onToggleSidebar}
                onMouseEnter={() => setIsHovered(true)}
                onMouseLeave={() => setIsHovered(false)}
            >
                <ArrowIcon />
            </div>

            <div style={styles.profileContainer} ref={menuRef}>
                <div style={styles.profileIcon} onClick={() => setMenuOpen(o => !o)}>
                    <FaUser size={20} color={mainColor} />
                </div>

                {menuOpen && (
                    <div style={styles.dropdown}>
                        <div style={styles.userInfo}>
                            <span style={styles.userName}>{user?.name || 'Guest'}</span>
                            <span style={styles.userEmail}>{user?.email || 'guest@example.com'}</span>
                        </div>
                        <div style={styles.divider} />
                        {menuItems.map((item, i) => (
                            <div
                                key={i}
                                style={{
                                    ...styles.menuItem,
                                    color: item.isDanger ? '#e53935' : '#333',
                                }}
                                onClick={() => {
                                    item.onClick();
                                    setMenuOpen(false);
                                }}
                            >
                                <span style={styles.iconWrapper}>{item.icon}</span>
                                <span>{item.label}</span>
                            </div>
                        ))}
                    </div>
                )}
            </div>
        </div>
    );
}
