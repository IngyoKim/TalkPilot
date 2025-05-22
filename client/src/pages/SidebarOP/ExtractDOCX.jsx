import React, { useState } from 'react';
import Sidebar from '../../components/SideBar';
import ProfileDropdown from '../Profile/ProfileDropdown';

const mainColor = '#673AB7';

export default function FileUploadPage() {
    const [isSidebarOpen, setIsSidebarOpen] = useState(true);
    const [files, setFiles] = useState([]);

    const handleFileChange = (e) => {
        const selectedFiles = Array.from(e.target.files);
        setFiles(prev => [...prev, ...selectedFiles]);
    };

    return (
        <div style={styles.container}>
            <Sidebar isOpen={isSidebarOpen} />

            <div style={{ ...styles.content, marginLeft: isSidebarOpen ? 240 : 0 }}>
                <ProfileDropdown
                    isSidebarOpen={isSidebarOpen}
                    onToggleSidebar={() => setIsSidebarOpen(prev => !prev)}
                />

                <div style={styles.inner}>
                    <h2>파일 업로드</h2>
                    <input type="file" multiple onChange={handleFileChange} />

                    <div style={styles.fileBox}>
                        {files.length === 0 ? (
                            <p style={{ color: '#777' }}>선택된 파일이 없습니다.</p>
                        ) : (
                            files.map((file, index) => (
                                <div key={index} style={styles.fileItem}>
                                    {file.name}
                                </div>
                            ))
                        )}
                    </div>
                </div>
            </div>
        </div>
    );
}

const styles = {
    container: {
        display: 'flex',
    },
    content: {
        flexGrow: 1,
        padding: '24px',
        transition: 'margin-left 0.3s ease',
    },
    inner: {
        padding: '24px',
        backgroundColor: '#fff',
        borderRadius: '8px',
        boxShadow: '0 0 10px rgba(0,0,0,0.05)',
    },
    fileBox: {
        marginTop: 16,
        border: '1px solid #ccc',
        borderRadius: 8,
        padding: 16,
        minHeight: 100,
        backgroundColor: '#f9f9f9',
    },
    fileItem: {
        padding: '4px 0',
        fontSize: 14,
    },
};
