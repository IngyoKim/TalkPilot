import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import MainPage from './MainPage';
import { vi } from 'vitest';

const mockCreate = vi.fn();
const mockJoin = vi.fn();
const mockUpdate = vi.fn();
const mockRemove = vi.fn();
const mockChangeStatus = vi.fn();

vi.mock('@/contexts/UserContext', () => ({
    useUser: () => ({ user: { uid: 'testUid' }, setUser: vi.fn() }),
}));
vi.mock('@/utils/userProjects', () => ({
    default: () => ({
        projects: getMockProjects(),
        create: mockCreate,
        join: mockJoin,
        update: mockUpdate,
        remove: mockRemove,
        changeStatus: mockChangeStatus,
    }),
}));
const getMockProjects = () => [
    {
        id: 'proj1',
        title: '삭제할 프로젝트',
        description: '설명입니다',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
        ownerUid: 'owner1',
        status: 'preparing',
    },
];

it('프로젝트 생성 및 참여 흐름에서 mock 함수들이 올바르게 호출되어야 함', async () => {
    const alertMock = vi.spyOn(window, 'alert').mockImplementation(() => { });

    render(
        <MemoryRouter>
            <MainPage />
        </MemoryRouter>
    );

    fireEvent.click(screen.getByText('프로젝트 추가'));
    fireEvent.change(screen.getByLabelText('제목'), {
        target: { value: '테스트 프로젝트' },
    });
    fireEvent.change(screen.getByLabelText('설명'), {
        target: { value: '테스트 설명' },
    });

    const createButtons = screen.getAllByText('생성');
    fireEvent.click(createButtons[1]);

    await waitFor(() => {
        expect(mockCreate).toHaveBeenCalledWith({
            title: '테스트 프로젝트',
            description: '테스트 설명',
        });
    });

    fireEvent.click(screen.getByText('프로젝트 추가'));
    fireEvent.click(screen.getByText('참여'));

    const joinButtons = screen.getAllByText('참여');
    fireEvent.click(joinButtons[1]);

    await waitFor(() => {
        expect(alertMock).toHaveBeenCalledWith('유효한 프로젝트 ID를 입력하세요.');
    });

    fireEvent.click(screen.getByText('프로젝트 추가'));
    fireEvent.click(screen.getByText('참여'));

    fireEvent.change(screen.getByLabelText('참여할 프로젝트 ID'), {
        target: { value: 'abc123' },
    });
    fireEvent.click(screen.getAllByText('참여')[1]);

    await waitFor(() => {
        expect(mockJoin).toHaveBeenCalledWith('abc123');
    });
    alertMock.mockRestore();
});
it(' 프로젝트 삭제 시 mockRemove가 호출되어야 함', async () => {
    const confirmMock = vi.spyOn(window, 'confirm').mockReturnValue(true);

    render(
        <MemoryRouter>
            <MainPage />
        </MemoryRouter>
    );

    fireEvent.click(screen.getByText('⋮'));

    fireEvent.click(screen.getByText('삭제'));

    await waitFor(() => {
        expect(mockRemove).toHaveBeenCalledWith('proj1');
    });

    confirmMock.mockRestore();
});

it(' 상태 변경 시 mockChangeStatus가 호출되어야 함', async () => {
    render(
        <MemoryRouter>
            <MainPage />
        </MemoryRouter>
    );

    expect(screen.getByText('삭제할 프로젝트')).toBeInTheDocument();
    fireEvent.click(screen.getByText('⋮'));
    const candidateDots = Array.from(document.querySelectorAll('div')).filter(
        (el) =>
            el.style.width === '14px' && el.style.height === '14px' && el.style.cursor === 'pointer'
    );

    expect(candidateDots.length).toBeGreaterThan(0);

    fireEvent.click(candidateDots[0]);

    fireEvent.click(
        screen.getByText((text, el) => el?.tagName === 'SPAN' && text === '보류')
    );

    await waitFor(() => {
        expect(mockChangeStatus).toHaveBeenCalledWith('proj1', '보류');
    });
});

it(' 프로젝트 생성 실패 시 alert가 호출되어야 함', async () => {
    mockCreate.mockRejectedValueOnce(new Error('생성 실패'));

    const alertMock = vi.spyOn(window, 'alert').mockImplementation(() => { });

    render(
        <MemoryRouter>
            <MainPage />
        </MemoryRouter>
    );

    fireEvent.click(screen.getByText('프로젝트 추가'));
    fireEvent.change(screen.getByLabelText('제목'), { target: { value: '실패' } });
    fireEvent.change(screen.getByLabelText('설명'), { target: { value: '에러' } });
    fireEvent.click(screen.getAllByText('생성')[1]);

    await waitFor(() => {
        expect(alertMock).toHaveBeenCalledWith('프로젝트 저장 중 오류 발생');
    });

    alertMock.mockRestore();
});

it(' 프로젝트 삭제 실패 시 alert가 호출되어야 함', async () => {
    mockRemove.mockRejectedValueOnce(new Error('삭제 실패'));
    const confirmMock = vi.spyOn(window, 'confirm').mockReturnValue(true);
    const alertMock = vi.spyOn(window, 'alert').mockImplementation(() => { });

    render(
        <MemoryRouter>
            <MainPage />
        </MemoryRouter>
    );

    fireEvent.click(screen.getByText('⋮'));
    fireEvent.click(screen.getByText('삭제'));

    await waitFor(() => {
        expect(alertMock).toHaveBeenCalledWith('삭제 중 오류 발생');
    });

    confirmMock.mockRestore();
    alertMock.mockRestore();
});

it('상태 변경 실패 시 alert가 호출되어야 함', async () => {
    mockChangeStatus.mockRejectedValueOnce(new Error('상태 변경 실패'));
    const alertMock = vi.spyOn(window, 'alert').mockImplementation(() => { });

    render(
        <MemoryRouter>
            <MainPage />
        </MemoryRouter>
    );

    const dot = Array.from(document.querySelectorAll('div')).find(
        (el) => el.style.width === '14px' && el.style.cursor === 'pointer'
    );

    expect(dot).toBeTruthy();

    fireEvent.click(dot);

    fireEvent.click(
        screen.getByText((t, el) => el?.tagName === 'SPAN' && t === '보류')
    );

    await waitFor(() => {
        expect(alertMock).toHaveBeenCalledWith('상태 변경 중 오류 발생');
    });

    alertMock.mockRestore();
});

it('✏️ 수정 버튼 클릭 시 모달이 열리고 기존 값이 입력되어야 함', async () => {
    render(
        <MemoryRouter>
            <MainPage />
        </MemoryRouter>
    );

    fireEvent.click(screen.getByText('⋮'));

    fireEvent.click(screen.getByText('수정'));

    await waitFor(() => {
        expect(screen.getByLabelText('제목')).toHaveValue('삭제할 프로젝트');
        expect(screen.getByLabelText('설명')).toHaveValue('설명입니다');
    });
});



