import { useState, useRef } from 'react';
import Sidebar from './SideBar';
import ProfileDropdown from '../pages/Profile/ProfileDropdown';
import ToastMessage from './ToastMessage';
import mammoth from "mammoth/mammoth.browser";

const mainColor = '#673AB7';

export default function FileUploadPage() {
    const [isSidebarOpen, setIsSidebarOpen] = useState(true);
    const [files, setFiles] = useState([]);
    const [messages, setMessages] = useState([]);
    const [resultText, setResultText] = useState(''); // 추출된 텍스트 state 추가
    const fileInputRef = useRef(null);

    const showMessage = (text, type = 'green', duration = 3000) => {
        setMessages(prev => [...prev, { id: Date.now(), text, type, duration }]);
    };

    const handleFileChange = async (e) => {
        const selectedFiles = Array.from(e.target.files);
        if (selectedFiles.length === 0) {
            showMessage('선택된 파일이 없습니다.', 'red');
            return;
        }

        const file = selectedFiles[0]; // 첫 번째 파일만 처리
        setFiles(prev => [...prev, file]);

        try {
            if (file.type === 'text/plain') {
                const reader = new FileReader();
                reader.onload = () => {
                    setResultText(reader.result);
                    showMessage('텍스트 파일에서 텍스트를 추출했습니다.', 'green');
                };
                reader.readAsText(file);
            } else if (file.type === 'application/vnd.openxmlformats-officedocument.wordprocessingml.document') {
                const arrayBuffer = await file.arrayBuffer();
                const result = await mammoth.extractRawText({ arrayBuffer });
                setResultText(result.value.trim());
                showMessage('DOCX 파일에서 텍스트를 추출했습니다.', 'green');
            } else {
                showMessage('지원하지 않는 파일 형식입니다. (txt, docx만 지원)', 'red');
            }
        } catch (err) {
            console.error('파일 처리 오류:', err);
            showMessage('파일 처리 중 오류 발생', 'red');
        } finally {
            e.target.value = ''; // input 초기화
        }
    };

    const handleCopy = () => {
        navigator.clipboard.writeText(resultText);
        showMessage('텍스트가 복사되었습니다.', 'green');
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
                    <div style={styles.box}>
                        <h3>.txt / .docx 파일 업로드</h3>

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
                            accept=".txt,.docx"
                            onChange={handleFileChange}
                            ref={fileInputRef}
                            style={{ display: 'none' }}
                        />
                    </div>

                    <div style={styles.box}>
                        <h3>추출 결과</h3>
                        <textarea
                            style={styles.resultTextarea}
                            value={resultText}
                            readOnly
                        />
                        <button style={styles.actionButton} onClick={handleCopy}>
                            복사하기
                        </button>
                    </div>
                </div>
                <ToastMessage messages={messages} setMessages={setMessages} />
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
