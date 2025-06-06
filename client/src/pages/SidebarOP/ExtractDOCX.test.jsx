import { render, screen, fireEvent } from "@testing-library/react";
import { MemoryRouter } from "react-router-dom";
import ExtractDOCX from "./ExtractDOCX";

// ✅ 모킹
vi.mock('@/contexts/UserContext', () => ({
    useUser: () => ({ user: { uid: 'test-user' }, setUser: vi.fn() }),
}));
vi.mock('@/components/SideBar', () => ({
    default: () => <div data-testid="MockSidebar" />,
}));
vi.mock('@/pages/Profile/ProfileDropdown', () => ({
    default: () => <div data-testid="MockProfileDropdown" />,
}));
vi.mock('@/components/ToastMessage', () => ({
    default: () => <div data-testid="MockToast" />,
}));

describe("📄 ExtractDOCX", () => {
    it("파일 선택 버튼 렌더링", () => {
        render(
            <MemoryRouter>
                <ExtractDOCX />
            </MemoryRouter>
        );

        expect(screen.getByText("파일 선택")).toBeInTheDocument();
        expect(screen.getByText("복사하기")).toBeInTheDocument();
    });

    it("복사 버튼 클릭 시 clipboard 호출", () => {
        const clipboardSpy = vi.fn();
        Object.assign(navigator, {
            clipboard: { writeText: clipboardSpy },
        });

        render(
            <MemoryRouter>
                <ExtractDOCX />
            </MemoryRouter>
        );

        fireEvent.click(screen.getByText("복사하기"));
        expect(clipboardSpy).toHaveBeenCalled();
    });
});
