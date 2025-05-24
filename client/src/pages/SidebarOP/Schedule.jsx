import { useState, useEffect, useRef } from 'react';
import FullCalendar from '@fullcalendar/react';
import dayGridPlugin from '@fullcalendar/daygrid';
import interactionPlugin from '@fullcalendar/interaction';

import Sidebar from '../../components/SideBar';
import ProfileDropdown from '../Profile/ProfileDropdown';

export default function SchedulePage() {
    const [events] = useState([]);
    const [isSidebarOpen, setIsSidebarOpen] = useState(true);
    const calendarRef = useRef(null);           // FullCalendar 인스턴스 참조
    const selectedCellRef = useRef(null);       // 마지막 클릭된 날짜 셀 참조

    useEffect(() => {
        setTimeout(() => {
            calendarRef.current?.getApi().updateSize();
        }, 300);
    }, [isSidebarOpen]);

    // 요일별 색상 지정
    const handleDayHeaderDidMount = (args) => {
        const day = args.date.getDay();
        if (day === 0) args.el.style.color = 'red';
        else if (day === 6) args.el.style.color = 'blue';
    };

    // 날짜 셀 렌더링 및 클릭 이벤트
    const handleDayCellDidMount = (args) => {
        const day = args.date.getDay();
        if (day === 0) args.el.style.color = 'red';
        else if (day === 6) args.el.style.color = 'blue';

        args.el.style.cursor = 'pointer';

        args.el.onclick = () => {
            // 이전 선택 셀 스타일 초기화
            if (selectedCellRef.current) {
                selectedCellRef.current.style.backgroundColor = '';
                selectedCellRef.current.style.color = '';
            }

            // 현재 셀 선택 스타일 적용
            args.el.style.backgroundColor = '#D1C4E9';
            selectedCellRef.current = args.el;

            // 해당 날짜로 이동
            calendarRef.current?.getApi().gotoDate(args.date);
        };
    };

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
                    <FullCalendar
                        ref={calendarRef}
                        plugins={[dayGridPlugin, interactionPlugin]}
                        initialView="dayGridMonth"
                        events={events}
                        height="auto"
                        dayHeaderDidMount={handleDayHeaderDidMount}
                        dayCellDidMount={handleDayCellDidMount}
                        headerToolbar={{
                            left: '',
                            center: 'title',
                            right: 'prev,next today'
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
