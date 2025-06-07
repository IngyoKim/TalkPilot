import { useState } from 'react';
import { FaSearch, FaChevronDown, FaChevronUp } from 'react-icons/fa';
import Sidebar from '@/components/SideBar';
import ProfileDropdown from '@/pages/Profile/ProfileDropdown';
import { useNavigate } from 'react-router-dom';

export default function Help() {
    const [isSidebarOpen, setIsSidebarOpen] = useState(true);
    const [query, setQuery] = useState('');
    const [expandedIndex, setExpandedIndex] = useState(null);
    const navigate = useNavigate();

    const faqItems = [
        {
            question: 'TalkPilot이 뭔가요?',
            answer: 'TalkPilot은 발표자의 발표 역량 향상을 목표로 하는 오픈소스 플랫폼입니다. 실시간 음성 인식과 대본 분석, AI 피드백을 통해 발표의 질을 개선할 수 있습니다.'
        },
        {
            question: '처음엔 어떻게 사용하나요?',
            answer: '먼저 프로젝트를 생성하거나 참여하세요. 이후 대본을 업로드하고 연습을 시작하면 됩니다.'
        },
        {
            question: '다른 사용자들은 어떻게 초대하나요?',
            answer: '프로젝트 상세 페이지에서 "프로젝트 ID"를 공유하거나 초대 기능을 사용해 다른 사용자들을 초대할 수 있습니다.'
        },
        {
            question: '프로젝트는 무슨 기능이 있나요?',
            answer: '프로젝트 내에서는 대본 관리, 발표 연습, 실시간 음성 인식, 발표 분석 결과 확인, 팀원 관리 기능을 제공합니다.'
        },
        {
            question: '앱 다운로드는 어떻게 하나요?',
            answer: '앱 다운로드는 [앱 다운로드 페이지](/app-download)에서 가능합니다. Android APK 직접 다운로드 및 내부 앱 공유 링크 안내를 확인하세요.'
        }
    ];

    const filteredItems = faqItems.filter(item =>
        item.question.toLowerCase().includes(query.toLowerCase()) ||
        item.answer.toLowerCase().includes(query.toLowerCase())
    );

    const handleToggle = index => {
        setExpandedIndex(prevIndex => (prevIndex === index ? null : index));
    };

    return (
        <div style={styles.wrapper}>
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

                <div style={styles.header}>
                    <h2 style={styles.title}>도움말 / FAQ</h2>
                    <button style={styles.contactBtn} onClick={() => navigate('/contact')}>
                        Contact Us
                    </button>
                </div>

                {/*검색창*/}
                <div style={styles.searchWrapper}>
                    <FaSearch style={styles.searchIcon} />
                    <input
                        type="text"
                        placeholder="궁금한 내용을 검색하세요"
                        value={query}
                        onChange={e => setQuery(e.target.value)}
                        style={styles.input}
                    />
                </div>

                {/*검색 결과 리스트*/}
                <div style={styles.faqList}>
                    {filteredItems.length > 0 ? (
                        filteredItems.map((item, idx) => (
                            <div key={idx} style={styles.faqItem}>
                                <div
                                    style={styles.faqQuestion}
                                    onClick={() => handleToggle(idx)}
                                >
                                    <span>{item.question}</span>
                                    {expandedIndex === idx ? (
                                        <FaChevronUp />
                                    ) : (
                                        <FaChevronDown />
                                    )}
                                </div>
                                {expandedIndex === idx && (
                                    <div style={styles.faqAnswer}>{item.answer}</div>
                                )}
                            </div>
                        ))
                    ) : (
                        <div style={styles.noResult}>
                            검색 결과가 없습니다. Contact Us 페이지에서 문의해 주세요.
                        </div>
                    )}
                </div>
            </div>
        </div>
    );
}

const styles = {
    wrapper: {
        display: 'flex',
    },
    sidebarWidth: 240,
    content: {
        flex: 1,
        padding: 20,
        boxSizing: 'border-box',
        transition: 'margin-left 0.3s ease',
    },
    header: {
        display: 'flex',
        justifyContent: 'space-between',
        alignItems: 'center',
        marginBottom: '20px',
    },
    title: {
        fontSize: '24px',
        fontWeight: 'bold',
    },
    contactBtn: {
        backgroundColor: '#673AB7',
        color: 'white',
        border: 'none',
        padding: '8px 16px',
        borderRadius: '24px',
        cursor: 'pointer',
        fontSize: '14px',
    },
    searchWrapper: {
        position: 'relative',
        width: '100%',
        marginBottom: '20px',
    },
    searchIcon: {
        position: 'absolute',
        top: '50%',
        left: '12px',
        transform: 'translateY(-50%)',
        pointerEvents: 'none',
        color: '#555',
    },
    input: {
        width: '100%',
        padding: '10px 12px 10px 36px',
        fontSize: 16,
        boxSizing: 'border-box',
        borderRadius: '8px',
        border: '1px solid #ccc',
    },
    faqList: {
        display: 'flex',
        flexDirection: 'column',
        gap: '12px',
    },
    faqItem: {
        border: '1px solid #ddd',
        borderRadius: '8px',
        padding: '12px',
        backgroundColor: '#fafafa',
        cursor: 'pointer',
    },
    faqQuestion: {
        display: 'flex',
        justifyContent: 'space-between',
        alignItems: 'center',
        fontSize: '16px',
        fontWeight: '500',
    },
    faqAnswer: {
        marginTop: '8px',
        fontSize: '14px',
        color: '#555',
        lineHeight: 1.6,
    },
    noResult: {
        padding: '12px',
        borderRadius: '8px',
        backgroundColor: '#f8f8f8',
        textAlign: 'center',
        color: '#555',
        fontSize: '14px',
    },
};
