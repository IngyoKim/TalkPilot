import { useState } from 'react';
import Sidebar from '@/components/SideBar';
import ProfileDropdown from '@/pages/Profile/ProfileDropdown';
import { useNavigate } from 'react-router-dom';

const mainColor = '#673AB7';

export default function AppDownload() {
    const [isSidebarOpen, setIsSidebarOpen] = useState(true);
    const navigate = useNavigate();

    return (
        <div style={{ display: 'flex' }}>
            <Sidebar isOpen={isSidebarOpen} />
            <div
                style={{
                    ...styles.content,
                    marginLeft: isSidebarOpen ? styles.sidebarWidth : 0,
                }}
            >
                <ProfileDropdown
                    isSidebarOpen={isSidebarOpen}
                    onToggleSidebar={() => setIsSidebarOpen(prev => !prev)}
                />

                <h2 style={styles.title}>앱 다운로드</h2>
                <p style={styles.description}>
                    TalkPilot 모바일 앱을 다운로드하여 발표 연습을 더 편하게 진행해보세요.
                </p>

                <div style={styles.downloadSection}>
                    <h3 style={styles.subtitle}>Android 다운로드</h3>

                    {/* 내부 앱 공유용 링크 */}
                    <a
                        href="#" // 내부 앱 공유 링크 (추후 교체)
                        style={styles.downloadBtn}
                        target="_blank"
                        rel="noopener noreferrer"
                        onClick={(e) => {
                            if (!e.currentTarget.href || e.currentTarget.href === window.location.href + '#') {
                                e.preventDefault();
                                alert('내부 앱 공유 링크가 아직 등록되지 않았습니다.');
                            }
                        }}
                    >
                        내부 앱 공유 링크 이동
                    </a>

                    {/* 직접 APK 다운로드 */}
                    <a
                        href="" // 다운로드 링크 추가하기
                        style={styles.downloadBtn}
                        download
                    >
                        직접 APK 다운로드
                    </a>

                    <h3 style={styles.subtitle}>(iOS는 현재 준비 중입니다)</h3>
                </div>

                <div style={styles.guideSection}>
                    <h3 style={styles.subtitle}>구글 플레이 개발자모드 & 내부 앱 공유 활성화 방법</h3>
                    <ol style={styles.guideList}>
                        <li>Google Play Store 앱 실행</li>
                        <li>Play Store 상단 프로필 → 설정 → 정보 → Play 스토어 버전 7회 클릭하여 개발자모드 활성화</li>
                        <li>설정 → 일반 → 개발자 설정 → 내부 앱 공유 ON 설정</li>
                        <li>내부 앱 공유 링크 클릭 시 설치 가능</li>
                    </ol>
                </div>

                <div style={styles.previewSection}>
                    <h3 style={styles.subtitle}>내부 앱 공유 화면 예시</h3>
                    <div style={styles.imageGrid}>
                        <img src="/assets/app_download/app_guide_01.png" alt="Guide 1" style={styles.previewImg} />
                        <img src="/assets/app_download/app_guide_02.png" alt="Guide 2" style={styles.previewImg} />
                        <img src="/assets/app_download/app_guide_03.gif" alt="Guide 3" style={styles.previewImg} />
                        <img src="/assets/app_download/app_guide_04.png" alt="Guide 4" style={styles.previewImg} />
                        <img src="/assets/app_download/app_guide_05.gif" alt="Guide 5" style={styles.previewImg} />
                    </div>
                </div>
            </div>
        </div>
    );
}

const styles = {
    sidebarWidth: 240,
    content: {
        flex: 1,
        padding: 20,
        boxSizing: 'border-box',
        transition: 'margin-left 0.3s ease',
    },
    title: {
        fontSize: '28px',
        fontWeight: '600',
        marginBottom: '12px',
    },
    description: {
        color: '#555',
        marginBottom: '24px',
    },
    guideSection: {
        marginBottom: '24px',
        padding: '16px',
        backgroundColor: '#f9f9f9',
        borderRadius: '8px',
        boxShadow: '0 2px 8px rgba(0,0,0,0.05)',
    },
    guideList: {
        paddingLeft: '20px',
        marginTop: '12px',
        color: '#333',
        lineHeight: 1.6,
    },
    downloadSection: {
        marginBottom: '32px',
        display: 'flex',
        flexDirection: 'column',
        gap: '12px',
    },
    subtitle: {
        fontSize: '18px',
        fontWeight: 'bold',
    },
    downloadBtn: {
        display: 'inline-block',
        backgroundColor: mainColor,
        color: 'white',
        padding: '12px 24px',
        borderRadius: '24px',
        textDecoration: 'none',
        fontSize: '16px',
        width: 'fit-content',
    },
    previewSection: {
        marginTop: '32px',
    },
    imageGrid: {
        display: 'grid',
        gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))',
        gap: '12px',
        marginTop: '12px',
    },
    previewImg: {
        width: '100%',
        borderRadius: '8px',
        objectFit: 'cover',
    },
};
