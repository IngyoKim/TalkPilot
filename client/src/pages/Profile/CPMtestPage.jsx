import { useState } from 'react';
import Sidebar from '../../components/SideBar';
import ProfileDropdown from './ProfileDropdown';

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

    const [currentIndex, setCurrentIndex] = useState(-1);
    const [mode, setMode] = useState('start'); // 'start' | 'exit' | 'next'

    const handleStart = () => {
        setCurrentIndex(0);
        setMode('exit');
    };

    const handleExit = () => {
        if (currentIndex === script.length - 1) {
            setCurrentIndex(-1);
            setMode('start');
        } else {
            setCurrentIndex(prev => prev + 1);
            setMode('next');
        }
    };

    const handleNext = () => {
        setMode('exit');
    };

    return (
        <div style={{ display: 'flex' }}>
            <Sidebar isOpen={isSidebarOpen} />
            <div style={{ marginLeft: isSidebarOpen ? 240 : 0, flex: 1 }}>
                <ProfileDropdown isSidebarOpen={isSidebarOpen} onToggleSidebar={handleToggleSidebar} />

                <div style={containerStyle}>
                    <p style={textStyle}>
                        {currentIndex === -1 ? script[0] : script[currentIndex]}
                    </p>

                    <div style={buttonContainerStyle}>
                        {mode === 'start' && (
                            <button onClick={handleStart} style={buttonStyleStart}>시작</button>
                        )}
                        {mode === 'exit' && (
                            <button onClick={handleExit} style={buttonStyleExit}>종료</button>
                        )}
                        {mode === 'next' && (
                            <>
                                <button onClick={handleNext} style={buttonStyleNext}>다음 문장</button>
                                <button onClick={handleStart} style={buttonStyleStart}>시작</button>
                            </>
                        )}
                    </div>
                </div>
            </div>
        </div>
    );
}

const containerStyle = {
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    justifyContent: 'center',
    height: '80vh',
    textAlign: 'center',
};

const textStyle = {
    fontSize: '2rem',
    marginBottom: '2rem',
};

const buttonContainerStyle = {
    display: 'flex',
    gap: '1rem',
};

const buttonStyleStart = {
    padding: '0.75rem 1.5rem',
    fontSize: '1rem',
    backgroundColor: '#4CAF50', // 초록
    color: 'white',
    border: 'none',
    borderRadius: '8px',
    cursor: 'pointer',
};

const buttonStyleNext = {
    ...buttonStyleStart,
    backgroundColor: '#2196F3', // 파랑
};

const buttonStyleExit = {
    ...buttonStyleStart,
    backgroundColor: '#F44336', // 빨강
};
