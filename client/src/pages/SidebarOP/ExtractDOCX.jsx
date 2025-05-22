import { useRef, useState } from 'react';
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

    const handleFileButtonClick = () => {
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

                        <button style={styles.actionButton} onClick={handleFileButtonClick}>
                            파일 선택
                        </button>
                        <input
                            ref={fileInputRef}
                            id="fileInput"
                            type="file"
                            multiple
                            onChange={handleFileChange}
                            style={{ display: 'none' }}
                        />

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

                    {/* 추출 결과 박스 */}
                    <div style={styles.box}>
                        <h3>추출 결과</h3>
                        <textarea
                            style={styles.resultTextarea}
                            value={`여기에 추출된 텍스트가 들어갑니다.`}
                            readOnly
                        />
                        <button
                            style={styles.actionButton}
                            onClick={() =>
                                navigator.clipboard.writeText('여기에 추출된 텍스트가 들어갑니다.')
                            }
                        >
                            복사하기
                        </button>
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
    uploadBox: {
        marginBottom: '16px',
    },

    uploadButton: {
        display: 'inline-block',
        padding: '10px 20px',
        backgroundColor: '#673AB7',
        color: '#fff',
        fontWeight: 'bold',
        borderRadius: '6px',
        cursor: 'pointer',
        transition: 'background-color 0.2s ease',
        userSelect: 'none',
    },
    fileItem: {
        padding: '4px 0',
        fontSize: 14,
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
        boxShadow: '0 0 10px rgba(0,0,0,0.05)',
        display: 'flex',
        flexDirection: 'column',
    },
    resultBox: {
        marginTop: '12px',
        border: '1px solid #ccc',
        borderRadius: '8px',
        padding: '16px',
        minHeight: '100px',
        backgroundColor: '#f1f1f1',
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

    copyButton: {
        alignSelf: 'flex-end',
        padding: '8px 16px',
        backgroundColor: '#673AB7',
        color: '#fff',
        border: 'none',
        borderRadius: '6px',
        cursor: 'pointer',
        fontWeight: 'bold',
    },
};
