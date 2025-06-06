import '@testing-library/jest-dom';
import { render, fireEvent } from '@testing-library/react';
import SocialLoginButton from './SocialLoginButton';

test('SocialLoginButton: 구글 버튼 렌더링 및 클릭 이벤트', () => {
  const handleClick = vi.fn();
  const { getByText } = render(<SocialLoginButton provider="google" onClick={handleClick} />);
  const button = getByText('구글 계정으로 로그인');
  fireEvent.click(button);
  expect(handleClick).toHaveBeenCalled();
});
