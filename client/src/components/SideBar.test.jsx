import '@testing-library/jest-dom';
import { render, screen } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import Sidebar from './SideBar';

test('Sidebar: 로고와 버튼이 렌더링됨', () => {
  render(<Sidebar isOpen={true} />, { wrapper: MemoryRouter });
  expect(screen.getByText('TalkPilot')).toBeInTheDocument();
  expect(screen.getByText('Make your speech smarter')).toBeInTheDocument();
});
