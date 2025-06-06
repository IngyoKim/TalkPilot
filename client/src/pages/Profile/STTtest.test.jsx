import { render, screen, fireEvent } from '@testing-library/react';
import STTtest from './STTtest';
import { vi } from 'vitest';

vi.mock('../../components/SideBar', () => ({ __esModule: true, default: () => <div /> }));
vi.mock('./ProfileDropdown', () => ({ __esModule: true, default: () => <div /> }));

test('브라우저 STT 미지원 시 alert 발생', () => {
    const alertMock = vi.spyOn(window, 'alert').mockImplementation(() => { });
    Object.defineProperty(window, 'webkitSpeechRecognition', { value: null });
    Object.defineProperty(window, 'SpeechRecognition', { value: null });

    render(<STTtest />);
    fireEvent.click(screen.getByText('말하기 시작'));
    expect(alertMock).toHaveBeenCalledWith('이 브라우저는 STT를 지원하지 않습니다.');

    alertMock.mockRestore();
});
