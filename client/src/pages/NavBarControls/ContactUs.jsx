import { useState } from 'react';
import Sidebar from '../Navigations/SideBar';
import NavbarControls from '../Navigations/NavbarControl';

export default function ContactUs() {
    const [isSidebarOpen, setIsSidebarOpen] = useState(true);

    return (
        <div style={{ display: 'flex' }}>
            <Sidebar isOpen={isSidebarOpen} />
            <div style={{ flex: 1, marginLeft: isSidebarOpen ? 240 : 0 }}>
                <NavbarControls
                    isSidebarOpen={isSidebarOpen}
                    onToggleSidebar={() => setIsSidebarOpen(prev => !prev)}
                />
                <div style={{ padding: '20px' }}>
                    <h2>Contact Us</h2>
                    {/* 여기에 설정 관련 콘텐츠 추가 */}
                </div>
            </div>
        </div>
    );
}