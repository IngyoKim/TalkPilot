import { useState } from 'react';

import Sidebar from '@/components/SideBar';
import ProfileDropdown from '@/pages/Profile/ProfileDropdown';

const mainColor = '#673AB7';

export default function Contact() {

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
                    {/* 왼쪽: 사용자 입력 폼 */}
                    <div style={styles.left}>
                        <h2 style={styles.heading}>물어보실게 있으신가요?</h2>
                        <p style={styles.description}>
                            메시지나 질문을 보내주시면 저희가 도와드리겠습니다. 협업 관련 연락도 받습니다.
                        </p>
                        <input style={styles.input} placeholder="이름" />
                        <input style={styles.input} placeholder="이메일 주소" />
                        <textarea style={styles.textarea} placeholder="내용" />
                        <button style={styles.sendBtn}>전달하기</button>
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
                            alt="CBNU Logo"
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
                    <b>일반 문의:</b><br />
                    {phone}<br />
                    {hours}
                </p>
            )}
            <button style={styles.viewMapBtn} onClick={() =>
                window.open(
                    'https://www.google.co.kr/maps/dir//%EC%B6%A9%EC%B2%AD%EB%B6%81%EB%8F%84+%EC%B2%AD%EC%A3%BC%EC%8B%9C+%EC%84%9C%EC%9B%90%EA%B5%AC+%EC%B6%A9%EB%8C%80%EB%A1%9C+1+%EC%B6%A9%EB%B6%81%EB%8C%80%ED%95%99%EA%B5%90+%EA%B3%B5%EA%B3%BC%EB%8C%80%ED%95%991%ED%98%B8%EA%B4%80/data=!4m8!4m7!1m0!1m5!1m1!1s0x3565298c2b8fa25f:0xaed1ccc87a1c3f0f!2m2!1d127.4582894!2d36.6266955?hl=ko&entry=ttu',
                    '_blank'
                )
            }
            >위치 확인
            </button>
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
        width: '100px',
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
