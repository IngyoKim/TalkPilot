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
                        <input id="nameInput" style={styles.input} placeholder="이름" />
                        <input id="emailInput" style={styles.input} placeholder="이메일 주소" />
                        <textarea id="messageInput" style={styles.textarea} placeholder="내용" />

                        {/* 전달하기 버튼 → mailto로 연결 */}
                        <a
                            href="#"
                            style={styles.sendBtnLink}
                            onClick={(e) => {
                                e.preventDefault();
                                const name = document.getElementById('nameInput').value;
                                const email = document.getElementById('emailInput').value;
                                const message = document.getElementById('messageInput').value;
                                const mailtoLink = `mailto:jeonsm0404@gmail.com?subject=문의드립니다&body=이름: ${name}%0A이메일: ${email}%0A내용:%0A${encodeURIComponent(message)}`;
                                window.location.href = mailtoLink;
                            }}
                        >
                            전달하기
                        </a>
                    </div>

                    {/* 오른쪽: 팀원 연락처 카드 */}
                    <div style={styles.right}>
                        <TeamMemberCard
                            name="김민규"
                            phone="010-8120-2338"
                            email="asdfxxk777@gmail.com"
                        />
                        <TeamMemberCard
                            name="김인교"
                            phone="010-5802-5827"
                            email="a58276976@gmail.com"
                        />
                        <TeamMemberCard
                            name="전상민"
                            phone="010-5028-4701"
                            email="jeonsm0404@gmail.com"
                        />
                    </div>
                </div>
            </div>
        </div>
    );
}

/**
 * TeamMemberCard 컴포넌트
 * - 이름, 전화번호, 이메일 표시 (링크 클릭 가능)
 */
function TeamMemberCard({ name, phone, email }) {
    return (
        <div style={styles.memberCard}>
            <h3 style={styles.memberName}>{name}</h3>
            <p style={styles.memberInfo}>
                연락처: <a href={`tel:${phone}`} style={styles.memberLink}>{phone}</a>
            </p>
            <p style={styles.memberInfo}>
                메일: <a href={`mailto:${email}`} style={styles.memberLink}>{email}</a>
            </p>
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
    sendBtnLink: {
        display: 'inline-block',
        backgroundColor: mainColor,
        color: 'white',
        textDecoration: 'none',
        padding: '12px',
        borderRadius: '24px',
        fontSize: '16px',
        cursor: 'pointer',
        width: '100px',
        textAlign: 'center',
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
    },
    memberCard: {
        backgroundColor: 'rgba(255,255,255,0.1)',
        padding: '20px',
        borderRadius: '8px',
        marginBottom: '16px',
    },
    memberName: {
        fontSize: '18px',
        fontWeight: 'bold',
        marginBottom: '8px',
    },
    memberInfo: {
        marginBottom: '6px',
    },
    memberLink: {
        color: '#fff',
        textDecoration: 'underline',
    },
};
