import { useState } from 'react';
import Sidebar from '../../components/SideBar';
import ProfileDropdown from './ProfileDropdown';

export default function ProjectRecord() {
    const [isSidebarOpen, setIsSidebarOpen] = useState(true);
    const toggleSidebar = () => setIsSidebarOpen(prev => !prev);

    return (
        < div >
            <Sidebar isOpen={isSidebarOpen} />
            <ProfileDropdown isSidebarOpen={isSidebarOpen} onToggleSidebar={toggleSidebar} />

        </div>
    )
}