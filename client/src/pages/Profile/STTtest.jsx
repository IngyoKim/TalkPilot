import { useState } from 'react';
import Sidebar from '../../components/SideBar';
import ProfileDropdown from './ProfileDropdown';

export default function STTtest() {
    const [isSidebarOpen, setIsSidebarOpen] = useState(true);
    const [transcript, setTranscript] = useState('');
    const [clickCount, setClickCount] = useState(0);

    const toggleSidebar = () => setIsSidebarOpen(prev => !prev);

    const handleClick = () => {
        const dummyTexts = [
            "이것은 STT 테스트 페이지입니다.",
            "버튼을 누르면 더미 텍스트가 출력됩니다.",
        ];
        setTranscript(dummyTexts[clickCount % dummyTexts.length]);
        setClickCount(prev => prev + 1);
    };

    return (
        <div>
            <Sidebar isOpen={isSidebarOpen} />
            <ProfileDropdown isSidebarOpen={isSidebarOpen} onToggleSidebar={toggleSidebar} />

            <div style={{
                ...styles.pageContainer,
                marginLeft: isSidebarOpen ? 260 : 0,
            }}>
                <h1 style={styles.title}>STT 테스트</h1>
                <p style={styles.description}>
                    버튼 클릭 시 텍스트가 출력됩니다.
                </p>
                <button onClick={handleClick} style={styles.button}>
                    텍스트 출력
                </button>

                {transcript && (
                    <div style={styles.outputBox}>
                        <strong>결과:</strong>
                        <p>{transcript}</p>
                    </div>
                )}
            </div>
        </div>
    );
}

const mainColor = '#673AB7';

const styles = {
    pageContainer: {
        padding: '80px 32px',
        transition: 'margin-left 0.3s ease',
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
        marginTop: '32px',
        padding: '16px',
        backgroundColor: '#f1f1f1',
        borderRadius: '8px',
        maxWidth: '600px',
    },
};