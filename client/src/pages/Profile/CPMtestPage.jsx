import { useState } from 'react';
import Sidebar from '../../components/SideBar';
import ProfileDropdown from './ProfileDropdown';

export default function CPMtestPage() {
    const [isSidebarOpen, setIsSidebarOpen] = useState(true);
    const handleToggleSidebar = () => setIsSidebarOpen(prev => !prev);

    return (
        <div style={{ display: 'flex' }}>
            <Sidebar isOpen={isSidebarOpen} />
            <div style={{ marginLeft: isSidebarOpen ? 240 : 0, flex: 1 }}>
                <ProfileDropdown isSidebarOpen={isSidebarOpen} onToggleSidebar={handleToggleSidebar} />

            </div>
        </div>
    );
}

const styles = {
    content: {
        padding: '80px 32px', // 상단 profile 공간 확보
    },
    title: {
        fontSize: '28px',
        fontWeight: 'bold',
        color: '#333',
        marginBottom: '16px',
    },
    description: {
        fontSize: '16px',
        color: '#666',
    },
};
