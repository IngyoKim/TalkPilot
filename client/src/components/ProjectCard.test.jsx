import { render, screen } from '@testing-library/react';
import ProjectCard from './ProjectCard';
import { vi } from 'vitest';

vi.mock('@/contexts/UserContext', () => ({
  useUser: () => ({ user: { uid: 'test-user', projectIds: {} }, setUser: vi.fn() }),
}));

vi.mock('@/utils/userProjects', () => ({
  __esModule: true,
  default: () => ({
    projects: [],
    create: vi.fn(),
    join: vi.fn(),
    update: vi.fn(),
    remove: vi.fn(),
    changeStatus: vi.fn(),
  }),
}));

vi.mock('@/pages/Profile/ProfileDropdown', () => ({
  __esModule: true,
  default: () => <div data-testid="mock-dropdown">Mocked Dropdown</div>,
}));

// ✅ 추가된 부분
vi.mock('@/components/SideBar', () => ({
  __esModule: true,
  Sidebar: () => <div data-testid="mock-sidebar">Mocked Sidebar</div>,
}));

test('ProjectCard: 프로젝트 추가 버튼이 렌더링됨', () => {
  render(<ProjectCard />);
  expect(screen.getByText('프로젝트 추가')).toBeInTheDocument();
});
