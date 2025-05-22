import { useState, useRef } from 'react';
import Sidebar from '../../components/SideBar';
import ProfileDropdown from '../Profile/ProfileDropdown';

const mainColor = '#673AB7';

export default function FileUploadPage() {
    const [isSidebarOpen, setIsSidebarOpen] = useState(true);
    const [files, setFiles] = useState([]);
    const fileInputRef = useRef(null);

    const handleFileChange = (e) => {
        const selectedFiles = Array.from(e.target.files);
        setFiles(prev => [...prev, ...selectedFiles]);
    };

    const handleCopy = () => {
        navigator.clipboard.writeText('여기에 추출된 텍스트가 들어갑니다.');
        alert('복사되었습니다.');
    };

    const handleUploadClick = () => {
        fileInputRef.current?.click();
    };

    return (
        <div style={styles.container}>
            <Sidebar isOpen={isSidebarOpen} />

            <div style={{ ...styles.content, marginLeft: isSidebarOpen ? 240 : 0 }}>
                <ProfileDropdown
                    isSidebarOpen={isSidebarOpen}
                    onToggleSidebar={() => setIsSidebarOpen(prev => !prev)}
                />

                <div style={styles.innerRow}>
                    {/* 파일 업로드 박스 */}
                    <div style={styles.box}>
                        <h3>.docx 파일 업로드</h3>

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

                        <button style={styles.actionButton} onClick={handleUploadClick}>
                            파일 선택
                        </button>
                        <input
                            type="file"
                            multiple
                            onChange={handleFileChange}
                            ref={fileInputRef}
                            style={{ display: 'none' }}
                        />
                    </div>

                    {/* 추출 결과 박스 */}
                    <div style={styles.box}>
                        <h3>추출 결과</h3>
                        <textarea
                            style={styles.resultTextarea}
                            value={`여기에 추출된 텍스트가 출력됨`}
                            readOnly
                        />
                        <button style={styles.actionButton} onClick={handleCopy}>
                            복사하기
                        </button>
                    </div>
                </div>
            </div>
        </div >
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
    innerRow: {
        display: 'flex',
        gap: '24px',
    },
    box: {
        flex: 1,
        padding: '24px',
        backgroundColor: '#fff',
        borderRadius: '8px',
        boxShadow: '0 0 10px rgba(0,0,0,0.2)',
        display: 'flex',
        flexDirection: 'column',
    },
    actionButton: {
        marginTop: 'auto',
        alignSelf: 'flex-end',
        padding: '10px 20px',
        backgroundColor: mainColor,
        color: '#fff',
        border: 'none',
        borderRadius: '6px',
        cursor: 'pointer',
        fontWeight: 'bold',
    },
    fileBox: {
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
    resultTextarea: {
        width: '100%',
        height: '150px',
        resize: 'none',
        padding: '12px',
        fontSize: '14px',
        border: '1px solid #ccc',
        borderRadius: '6px',
        backgroundColor: '#f9f9f9',
        marginBottom: '12px',
    },
};
