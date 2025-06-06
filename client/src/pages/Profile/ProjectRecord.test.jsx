import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import ProjectRecord from './ProjectRecord';
import { vi } from 'vitest';

vi.mock('@/components/SideBar', () => ({ __esModule: true, default: () => <div /> }));
vi.mock('@/pages/Profile/ProfileDropdown', () => ({ __esModule: true, default: () => <div /> }));
vi.mock('@/components/ToastMessage', () => ({ __esModule: true, default: () => null }));

test('프로젝트 카드 렌더링 및 삭제 버튼 동작', async () => {
    render(<ProjectRecord />);
    expect(await screen.findByText('AI 프로젝트 발표')).toBeInTheDocument();

    const deleteButton = screen.getAllByRole('button').find(btn => btn.innerHTML.includes('svg'));
    fireEvent.click(deleteButton);

    await waitFor(() => {
        expect(screen.getByText('정말로 삭제하시겠습니까?')).toBeInTheDocument();
    });
});
