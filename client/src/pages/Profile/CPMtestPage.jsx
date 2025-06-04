import { useState } from 'react';
import Sidebar from '@/components/SideBar';
import ProfileDropdown from '@/pages/Profile/ProfileDropdown';

export default function CPMtestPage() {
    const [isSidebarOpen, setIsSidebarOpen] = useState(true);
    const handleToggleSidebar = () => setIsSidebarOpen(prev => !prev);

    const script = [
        '안녕하세요, 오늘 발표를 시작하겠습니다.',
        '이 프로젝트는 지난 몇 개월 동안 진행되었습니다.',
        '주요 목표는 사용자의 편의성을 높이는 것이었습니다.',
        '다음으로는 구현 과정에 대해 설명드리겠습니다.',
        '경청해 주셔서 감사합니다.'
    ];

    const [currentIndex, setCurrentIndex] = useState(0);
    const [started, setStarted] = useState(false);

    const handleStart = () => setStarted(true);

    const handleExit = () => {
        if (currentIndex === script.length - 1) {
            setCurrentIndex(0);
            setStarted(false);
        } else {
            setCurrentIndex(prev => prev + 1);
            setStarted(false);
        }
    };

    const sidebarWidth = isSidebarOpen ? 240 : 60;

    return (
        <div style={{ display: 'flex' }}>
            <Sidebar isOpen={isSidebarOpen} />
            <div
                style={{
                    flex: 1,
                    paddingLeft: sidebarWidth,
                    transition: 'padding-left 0.3s ease',
                }}
            >
                <ProfileDropdown isSidebarOpen={isSidebarOpen} onToggleSidebar={handleToggleSidebar} />

                <div style={styles.container}>
                    <p style={styles.description}>테스트 문장입니다. 그대로 읽으시면 CPM이 나옵니다.</p>
                    <p style={styles.text}>{script[currentIndex]}</p>

                    <div style={styles.buttonContainer}>
                        {!started ? (
                            <button onClick={handleStart} style={styles.buttonBase}>시작</button>
                        ) : (
                            <button
                                onClick={handleExit}
                                style={styles.buttonBase}
                            >
                                {currentIndex === script.length - 1 ? '처음으로' : '종료'}
                            </button>
                        )}
                    </div>
                </div>
            </div>
        </div>
    );
}

const mainColor = '#673AB7';

const styles = {
    container: {
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        height: '80vh',
        textAlign: 'center',
        transition: 'all 0.3s ease',
    },
    description: {
        fontSize: '1.2rem',
        color: '#333',
        marginTop: '-8vh',
        marginBottom: '2rem',
    },
    text: {
        fontSize: '2rem',
        marginBottom: '2rem',
    },
    buttonContainer: {
        display: 'flex',
        gap: '1rem',
    },
    buttonBase: {
        padding: '0.75rem 1.5rem',
        fontSize: '1rem',
        color: 'white',
        border: 'none',
        borderRadius: '8px',
        cursor: 'pointer',
        backgroundColor: mainColor,
    }
};
