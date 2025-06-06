// App.test.jsx
import { render } from '@testing-library/react';
import App from './App';

describe('App', () => {
    it('전체 앱이 정상 렌더링된다', () => {
        const { container } = render(<App />);
        expect(container).toBeDefined();
    });
});
