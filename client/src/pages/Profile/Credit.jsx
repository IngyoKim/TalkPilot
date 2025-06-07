import { useState } from 'react';
import Sidebar from '@/components/SideBar';
import ProfileDropdown from '@/pages/Profile/ProfileDropdown';
import { FaGithub, FaTools, FaUsers, FaBalanceScale } from 'react-icons/fa';

const mainColor = '#673AB7';

export default function CreditPage() {
    const [isSidebarOpen, setIsSidebarOpen] = useState(true);

    return (
        <div style={{ display: 'flex' }}>
            {/* 메인 컨텐츠 영역 */}
            <div
                style={{
                    flex: 1,
                    marginLeft: isSidebarOpen ? 240 : 0,
                    transition: 'margin-left 0.3s ease',
                }}
            >
                <ProfileDropdown
                    isSidebarOpen={isSidebarOpen}
                    onToggleSidebar={() => setIsSidebarOpen((prev) => !prev)}
                />
                {/* 사이드바 */}
                <Sidebar isOpen={isSidebarOpen} />

                <div style={styles.container}>
                    {/* 왼쪽: 프로젝트 정보 */}
                    <div style={styles.left}>
                        <h2 style={styles.heading}>
                            <FaGithub style={styles.icon} />{' '}
                            <a href="https://github.com/IngyoKim/TalkPilot" target="_blank" rel="noopener noreferrer" style={{ textDecoration: 'none', color: mainColor }}>
                                TalkPilot
                            </a>
                        </h2>
                        <p style={styles.description}>
                            발표를 더 똑똑하게, 함께 준비해요. <br />
                            <i>Make Your Speech Smarter</i>
                        </p>

                        <h3 style={styles.subHeading}><FaTools style={styles.icon} /> 기술 스택</h3>
                        <div style={styles.badges}>
                            <a href="https://flutter.dev/" target="_blank" rel="noopener noreferrer">
                                <img src="https://img.shields.io/badge/Flutter-%2302569B.svg?logo=flutter&logoColor=white" alt="Flutter" />
                            </a>
                            <a href="https://react.dev/" target="_blank" rel="noopener noreferrer">
                                <img src="https://img.shields.io/badge/React-%2361DAFB.svg?logo=react&logoColor=black" alt="React" />
                            </a>
                            <a href="https://nestjs.com/" target="_blank" rel="noopener noreferrer">
                                <img src="https://img.shields.io/badge/NestJS-%23E0234E.svg?logo=nestjs&logoColor=white" alt="NestJS" />
                            </a>
                            <a href="https://firebase.google.com/" target="_blank" rel="noopener noreferrer">
                                <img src="https://img.shields.io/badge/Firebase-%23FFCA28.svg?logo=firebase&logoColor=black" alt="Firebase" />
                            </a>
                            <a href="https://cloud.google.com/speech-to-text" target="_blank" rel="noopener noreferrer">
                                <img src="https://img.shields.io/badge/Google%20Cloud%20STT-%234285F4.svg?logo=googlecloud&logoColor=white" alt="Google Cloud STT" />
                            </a>
                        </div>
                    </div>

                    {/* 오른쪽: 팀원 + 라이센스 + 학교로고 */}
                    <div style={styles.right}>
                        <div style={styles.card}>
                            <h3 style={styles.subHeading}><FaUsers style={styles.icon} /> 팀원</h3>
                            <ul style={styles.memberList}>
                                <li>
                                    <a
                                        href="https://github.com/Asdfuxk"
                                        target="_blank"
                                        rel="noopener noreferrer"
                                        style={styles.memberLink}
                                    >
                                        김민규
                                    </a>
                                </li>
                                <li>
                                    <a
                                        href="https://github.com/IngyoKim"
                                        target="_blank"
                                        rel="noopener noreferrer"
                                        style={styles.memberLink}
                                    >
                                        김인교
                                    </a>
                                </li>
                                <li>
                                    <a
                                        href="https://github.com/A-X-Y-S-T"
                                        target="_blank"
                                        rel="noopener noreferrer"
                                        style={styles.memberLink}
                                    >
                                        전상민
                                    </a>
                                </li>
                                <li>기타 참여 멤버들</li>
                            </ul>
                        </div>

                        <div style={styles.card}>
                            <h3 style={styles.subHeading}><FaBalanceScale style={styles.icon} /> 라이센스</h3>
                            <p>
                                MIT License - <a href="https://github.com/IngyoKim/TalkPilot/blob/main/LICENSE" target="_blank" rel="noopener noreferrer" style={{ color: '#fff', textDecoration: 'underline' }}>LICENSE 보기</a>
                            </p>
                        </div>

                        <div style={styles.logoContainer}>
                            <img src="/assets/CBNU_white.png" alt="CBNU Logo" style={styles.logo} />
                            <footer style={styles.footer}>
                                © 2025 OmO Team — Open Source Software (OSS) <br />
                                TalkPilot과 함께 발표를 더 스마트하게 준비하세요!
                            </footer>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
}

const styles = {
    container: {
        display: 'flex',
        flexDirection: 'row',
        flexWrap: 'wrap',
        justifyContent: 'space-between',
        alignItems: 'flex-start',
        padding: '40px',
        gap: '40px',
    },
    left: {
        flex: 1,
        minWidth: 300,
        maxWidth: 500,
        display: 'flex',
        flexDirection: 'column',
        backgroundColor: '#fff',
        padding: '30px',
        borderRadius: '8px',
        boxShadow: '0 2px 8px rgba(0,0,0,0.05)',
        boxSizing: 'border-box',
    },
    heading: {
        fontSize: '28px',
        fontWeight: '600',
        marginBottom: '10px',
    },
    subHeading: {
        fontSize: '20px',
        fontWeight: 'bold',
        marginBottom: '12px',
        marginTop: '20px',
        borderBottom: '1px solid #ccc',
        paddingBottom: '4px',
    },
    description: {
        color: '#555',
        marginBottom: '20px',
    },
    badges: {
        display: 'flex',
        flexWrap: 'wrap',
        gap: '8px',
        marginBottom: '20px',
    },
    right: {
        flex: 1,
        minWidth: 300,
        backgroundColor: mainColor,
        padding: '30px',
        borderRadius: '8px',
        color: 'white',
        boxSizing: 'border-box',
        display: 'flex',
        flexDirection: 'column',
        justifyContent: 'flex-start',
        gap: '20px',
    },
    card: {
        backgroundColor: 'rgba(255,255,255,0.1)',
        padding: '20px',
        borderRadius: '8px',
    },
    memberList: {
        listStyleType: 'disc',
        paddingLeft: '20px',
        marginBottom: '12px',
    },
    memberLink: {
        color: '#fff',
        textDecoration: 'underline',
        fontWeight: '500',
    },
    logoContainer: {
        marginTop: 'auto',
        textAlign: 'center',
    },
    logo: {
        width: 120,
        opacity: 0.9,
        marginBottom: '12px',
    },
    footer: {
        fontSize: '14px',
        color: '#ddd',
        textAlign: 'center',
    },
    icon: {
        marginRight: '8px',
        verticalAlign: 'middle',
    },
};
