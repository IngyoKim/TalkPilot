import { render, waitFor } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import PrivateRoute from './PrivateRoute';

test('PrivateRoute: 로딩 중일 때는 null을 반환', async () => {
  const { container } = render(
    <MemoryRouter>
      <PrivateRoute><div>Protected</div></PrivateRoute>
    </MemoryRouter>
  );

  await waitFor(() => {
    expect(container.firstChild).toBeNull();
  });
});