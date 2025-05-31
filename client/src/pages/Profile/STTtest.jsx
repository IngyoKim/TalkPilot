import { useState } from 'react';
import Sidebar from '../../components/SideBar';
import ProfileDropdown from './ProfileDropdown';

export default function STTtest() {
    const [isSidebarOpen, setIsSidebarOpen] = useState(true);
    const [transcript, setTranscript] = useState('');
    const [isListening, setIsListening] = useState(false);

    const toggleSidebar = () => setIsSidebarOpen(prev => !prev);

    const handleClick = () => {
        const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;

        if (!SpeechRecognition) {
            alert("이 브라우저는 STT를 지원하지 않습니다.");
            return;
        }

        const recognition = new SpeechRecognition();
        recognition.lang = 'ko-KR';
        recognition.interimResults = false;
        recognition.maxAlternatives = 1;

        recognition.onstart = () => {
            setIsListening(true);
            setTranscript('듣는 중...');
        };

        recognition.onresult = (event) => {
            const result = event.results[0][0].transcript;
            setTranscript(result);
        };

        recognition.onerror = (event) => {
            alert('음성 인식 중 오류 발생: ' + event.error);
            setIsListening(false);
        };

        recognition.onend = () => {
            setIsListening(false);
        };

        recognition.start();
    };

    return (
        <div>
            <Sidebar isOpen={isSidebarOpen} />
            <ProfileDropdown isSidebarOpen={isSidebarOpen} onToggleSidebar={toggleSidebar} />

            <div style={{
                ...styles.pageContainer,
                marginLeft: isSidebarOpen ? 260 : 0,
            }}>
                <div style={styles.leftArea}>
                    <h1 style={styles.title}>STT 테스트</h1>
                    <p style={styles.description}>
                        마이크 버튼을 클릭하면 음성이 텍스트로 변환됩니다.
                    </p>
                    <button onClick={handleClick} style={styles.button}>
                        {isListening ? '듣는 중...' : '말하기 시작'}
                    </button>
                </div>

                <div style={styles.rightArea}>
                    {transcript && (
                        <div style={styles.outputBox}>
                            <strong style={{ fontSize: '24px' }}>결과</strong>
                            <p style={styles.outputText}>{transcript}</p>
                        </div>
                    )}
                </div>
            </div>
        </div>
    );
}

const mainColor = '#673AB7';

const styles = {
    pageContainer: {
        display: 'flex',
        flexDirection: 'row',
        padding: '80px 32px',
        transition: 'margin-left 0.3s ease',
        height: '100vh',
        boxSizing: 'border-box',
    },
    leftArea: {
        flex: 1,
        paddingRight: '24px',
    },
    rightArea: {
        flex: 1,
        paddingLeft: '24px',
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'flex-start',
        justifyContent: 'flex-start',
        overflowY: 'auto',
    },
    title: {
        fontSize: '28px',
        fontWeight: '700',
    },
    description: {
        marginTop: '16px',
        fontSize: '16px',
    },
    button: {
        marginTop: '24px',
        padding: '12px 24px',
        fontSize: '16px',
        fontWeight: 'bold',
        backgroundColor: mainColor,
        color: '#fff',
        border: 'none',
        borderRadius: '8px',
        cursor: 'pointer',
    },
    outputBox: {
        padding: '32px',
        backgroundColor: '#f1f1f1',
        borderRadius: '16px',
        width: '100%',
        maxWidth: '100%',
        boxShadow: '0 4px 12px rgba(0,0,0,0.1)',
        marginTop: '16px',
    },
    outputText: {
        fontSize: '20px',
        lineHeight: '1.6',
        color: '#333',
        whiteSpace: 'pre-wrap',
    },
};
