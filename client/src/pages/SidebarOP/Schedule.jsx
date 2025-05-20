import { useState, useEffect, useRef } from 'react';
import FullCalendar from '@fullcalendar/react';
import dayGridPlugin from '@fullcalendar/daygrid';
import interactionPlugin from '@fullcalendar/interaction';

import Sidebar from '../../components/SideBar';
import ProfileDropdown from '../Profile/ProfileDropdown';

export default function SchedulePage() {
    const [events] = useState([]);
    const [isSidebarOpen, setIsSidebarOpen] = useState(true);
    const calendarRef = useRef(null);
    const selectedCellRef = useRef(null);

    useEffect(() => {
        setTimeout(() => {
            calendarRef.current?.getApi().updateSize();
        }, 300);
    }, [isSidebarOpen]);

    return (
        <div style={styles.container}>
            <Sidebar isOpen={isSidebarOpen} />
            <div
                style={{
                    ...styles.content,
                    marginLeft: isSidebarOpen ? 240 : 0,
                }}
            >
                <ProfileDropdown
                    isSidebarOpen={isSidebarOpen}
                    onToggleSidebar={() => setIsSidebarOpen(prev => !prev)}
                />
                <div style={styles.calendarWrapper}>
                    <h2>스케줄</h2>
                    <FullCalendar
                        ref={calendarRef}
                        plugins={[dayGridPlugin, interactionPlugin]}
                        initialView="dayGridMonth"
                        events={events}
                        height="auto"
                        dayHeaderDidMount={(args) => {
                            const day = args.date.getDay();
                            if (day === 0) args.el.style.color = 'red';
                            else if (day === 6) args.el.style.color = 'blue';
                        }}
                        dayCellDidMount={(args) => {
                            const day = args.date.getDay();
                            if (day === 0) args.el.style.color = 'red';
                            else if (day === 6) args.el.style.color = 'blue';

                            // 날짜 셀 클릭하면 선택 처리
                            args.el.style.cursor = 'pointer';
                            args.el.onclick = () => {
                                // 이전 선택 셀 초기화
                                if (selectedCellRef.current) {
                                    selectedCellRef.current.style.backgroundColor = '';
                                    selectedCellRef.current.style.color = '';
                                }

                                // 새 선택 셀 스타일 적용
                                args.el.style.backgroundColor = 'rgba(103,58,183, 0.3)';

                                // 참조 갱신
                                selectedCellRef.current = args.el;

                                // 해당 날짜로 이동 (원하는 경우)
                                calendarRef.current?.getApi().gotoDate(args.date);
                            };
                        }}
                    />
                </div>
            </div>
        </div>
    );
}

const styles = {
    container: {
        display: 'flex',
    },
    content: {
        flex: 1,
        transition: 'margin-left 0.3s ease',
    },
    calendarWrapper: {
        padding: '20px',
    },
};
