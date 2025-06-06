import '@testing-library/jest-dom';
import { render, screen } from '@testing-library/react';
import ToastMessage from './ToastMessage';

test('ToastMessage: 메시지가 렌더링 되는가?', () => {
  const messages = [
    { id: 1, text: 'Success!', type: 'green', duration: 1000 },
    { id: 2, text: 'Error!', type: 'red', duration: 1000 },
  ];
  const setMessages = vi.fn();

  render(<ToastMessage messages={messages} setMessages={setMessages} />);
  expect(screen.getByText('Success!')).toBeInTheDocument();
  expect(screen.getByText('Error!')).toBeInTheDocument();
});
