import { useState } from 'react';
import Sidebar from '../../components/SideBar';
import ProfileDropdown from './ProfileDropdown';

export default function STTtest() {
    const [isSidebarOpen, setIsSidebarOpen] = useState(true);
    const [transcript, setTranscript] = useState(''); // 음성 인식 결과 텍스트 저장
    const [isListening, setIsListening] = useState(false); // 현재 음성 인식 중인지 여부

    const toggleSidebar = () => setIsSidebarOpen(prev => !prev); // 사이드바 열기/닫기 토글

    const handleClick = () => {
        // 브라우저의 STT API객체 가져오기
        const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;

        if (!SpeechRecognition) {
            alert("이 브라우저는 STT를 지원하지 않습니다.");
            return;
        }

        // 음성 인식 인스턴스 생성
        const recognition = new SpeechRecognition();
        recognition.lang = 'ko-KR';
        recognition.interimResults = false; // 중간 결과를 사용하지 않음
        recognition.maxAlternatives = 1; // 최대 대안 결과 1개

        // 음성 인식 시작 시 호출되는 이벤트 핸들러
        recognition.onstart = () => {
            setIsListening(true); // UI에 듣는 중 표시
            setTranscript('듣는 중...');
        };

        // 음성 인식 결과를 처리하는 이벤트 핸들러
        recognition.onresult = (event) => {
            const result = event.results[0][0].transcript; // 결과 텍스트 추출
            setTranscript(result); // 텍스트 상태 업데이트
        };

        // 오류 발생 시 처리
        recognition.onerror = (event) => {
            alert('음성 인식 중 오류 발생: ' + event.error);
            setIsListening(false);
        };

        // 음성 인식이 종료되었을 때 호출
        recognition.onend = () => {
            setIsListening(false);
        };

        recognition.start(); // 음성 인식 시작
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
