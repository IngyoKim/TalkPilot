import { useState } from 'react';
import Sidebar from '../Navigations/SideBar';
import NavbarControls from '../Navigations/NavbarControl';

const mainColor = '#673AB7';

export default function HelpCenter() {

    // 사이드바 열림/닫힘 상태 관리
    const [isSidebarOpen, setIsSidebarOpen] = useState(true);

    return (
        <div style={{ display: 'flex' }}>
            {/* 사이드바 */}
            <Sidebar isOpen={isSidebarOpen} />

            {/* 메인 컨텐츠 영역 */}
            <div
                style={{
                    flex: 1,
                    marginLeft: isSidebarOpen ? 240 : 0,
                    transition: 'margin-left 0.3s ease',
                }}
            >
                {/* 상단 바 제어 버튼 */}
                <NavbarControls
                    isSidebarOpen={isSidebarOpen}
                    onToggleSidebar={() => setIsSidebarOpen((prev) => !prev)}
                />

                <div style={styles.container}>
                    {/* 왼쪽: 사용자 입력 폼 */}
                    <div style={styles.left}>
                        <h2 style={styles.heading}>How can we help?</h2>
                        <p style={styles.description}>
                            Send us a message or question and we’ll help you as soon as we can.
                        </p>
                        <input style={styles.input} placeholder="이름" />
                        <input style={styles.input} placeholder="이메일 주소" />
                        <textarea style={styles.textarea} placeholder="내용" />
                        <button style={styles.sendBtn}>전달</button>
                    </div>

                    {/* 오른쪽: 오피스 정보 카드 및 로고 */}
                    <div style={styles.right}>
                        <OfficeCard
                            city="CheongJu"
                            address="충청북도 청주시 서원구 충대로 1 E8-1 어딘가"
                            phone="010-8120-2338"
                            hours="(10AM~5PM 평일)"
                        />
                        {/* 대학교 로고 */}
                        <img
                            src="/assets/CBNU_white.png"
                            alt="Chungbuk National University Logo"
                            style={styles.logo}
                        />
                    </div>
                </div>
            </div>
        </div>
    );
}

/**
 * OfficeCard 컴포넌트
 * - 도시명, 주소, 문의 전화, 운영 시간 및 지도 보기 버튼 표시
 */
function OfficeCard({ city, address, phone, hours }) {
    return (
        <div style={styles.officeCard}>
            <h3 style={styles.officeCity}>{city}</h3>
            <p style={styles.officeText}>{address}</p>
            {phone && (
                <p style={styles.officeText}>
                    <b>일반 문의 및 청구:</b><br />
                    {phone}<br />
                    {hours}
                </p>
            )}
            <button style={styles.viewMapBtn}>View Map</button>
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
    description: {
        color: '#555',
        marginBottom: '20px',
    },
    input: {
        padding: '12px',
        marginBottom: '15px',
        fontSize: '16px',
        border: '1px solid #ccc',
        borderRadius: '6px',
    },
    textarea: {
        padding: '12px',
        height: 100,
        fontSize: '16px',
        border: '1px solid #ccc',
        borderRadius: '6px',
        marginBottom: '20px',
        resize: 'vertical',
    },
    sendBtn: {
        backgroundColor: mainColor,
        color: 'white',
        border: 'none',
        padding: '12px',
        borderRadius: '24px',
        fontSize: '16px',
        cursor: 'pointer',
        width: '150px',
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
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'space-between',
        height: '100%',
    },
    officeCard: {
        flex: 1,
        margin: 0,
    },
    logo: {
        width: 160,
        opacity: 0.8,
        marginLeft: '20px',
    },
    officeCity: {
        fontSize: '22px',
        fontWeight: '600',
        marginBottom: '10px',
    },
    officeText: {
        whiteSpace: 'pre-line',
        marginBottom: '10px',
        lineHeight: '1.5',
    },
    viewMapBtn: {
        border: '1px solid white',
        backgroundColor: 'transparent',
        color: 'white',
        padding: '8px 16px',
        borderRadius: '20px',
        cursor: 'pointer',
        fontWeight: '500',
    },
};
