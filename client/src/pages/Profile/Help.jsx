import { useState } from 'react';
import Sidebar from '../../components/SideBar';
import { FaSearch } from "react-icons/fa";
import ProfileDropDown from './ProfileDropdown';

export default function ContactUs() {
    const [isSidebarOpen, setIsSidebarOpen] = useState(true);
    const [query, setQuery] = useState('');

    const items = [
        'TalkPilot이 뭔가요?',
        '처음엔 어떻게 사용하나요?',
        '다른 사용자들은 어떻게 초대하나요?',
        '프로젝트는 무슨 기능이 있나요?'
    ];

    const filteredItems = items.filter(item =>
        item.toLowerCase().includes(query.toLowerCase())
    );

    return (
        <div style={styles.wrapper}>
            <Sidebar isOpen={isSidebarOpen} />
            <div
                style={{
                    ...styles.content,
                    marginLeft: isSidebarOpen ? styles.sidebarWidth : 0,
                }}
            >
                <ProfileDropDown
                    isSidebarOpen={isSidebarOpen}
                    onToggleSidebar={() => setIsSidebarOpen(prev => !prev)}
                />

                {/*검색창*/}
                <div style={styles.searchWrapper}>
                    <FaSearch style={styles.searchIcon} />
                    <input
                        type="text"
                        placeholder="검색어를 입력하세요, 만약 없으면 Contact Us에 들어가서 문의하세요"
                        value={query}
                        onChange={e => setQuery(e.target.value)}
                        style={styles.input}
                    />
                </div>

                {/*검색 결과 리스트*/}
                <ul style={styles.list}>
                    {filteredItems.length > 0 ? (
                        filteredItems.map((item, idx) => (
                            <li key={idx} style={styles.listItem}>{item}</li>
                        ))
                    ) : (
                        <li style={styles.listItem}>검색 결과가 없습니다.</li>
                    )}
                </ul>
            </div>
        </div>
    );
}

const styles = {
    searchWrapper: {
        position: 'relative',
        width: '100%',
        margin: '16px 0',
    },
    searchIcon: {
        position: 'absolute',
        top: '50%',
        left: '12px',
        transform: 'translateY(-50%)',
        pointerEvents: 'none',
    },
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
    input: {
        width: '100%',
        padding: '8px 12px 8px 36px',
        fontSize: 16,
        margin: '16px 0',
        boxSizing: 'border-box',
    },
    list: {
        listStyle: 'none',
        padding: 0,
        margin: 0,
    },
    listItem: {
        padding: '4px 0',
    },
};