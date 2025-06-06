import { render, screen } from "@testing-library/react";
import { MemoryRouter, Routes, Route } from "react-router-dom";
import ProjectDetail from "./ProjectDetail";

// ✅ UserContext mocking
vi.mock("@/contexts/UserContext", () => ({
    useUser: () => ({
        user: { uid: "mock-user" },
        setUser: vi.fn(),
    }),
}));

// ✅ projectAPI mocking
vi.mock("@/utils/api/project", () => ({
    fetchProjectById: vi.fn().mockResolvedValue({
        id: "p1",
        title: "Test Title",
        description: "Test Description",
        script: "Test Script",
        scheduledDate: "2025-06-06",
        participants: { "mock-user": "owner" },
        ownerUid: "mock-user",
        createdAt: new Date("2025-01-01").toISOString(),
        updatedAt: new Date("2025-06-01").toISOString(),
    }),
    updateProject: vi.fn(),
}));

// ✅ userAPI mocking
vi.mock("@/utils/api/user", () => ({
    fetchUserByUid: vi.fn().mockResolvedValue({
        nickname: "Mock Owner",
    }),
}));

describe("📄 ProjectDetail", () => {
    it("프로젝트 정보 렌더링", async () => {
        render(
            <MemoryRouter initialEntries={["/project/p1"]}>
                <Routes>
                    <Route path="/project/:id" element={<ProjectDetail />} />
                </Routes>
            </MemoryRouter>
        );

        // ✅ project.title 입력 필드 확인
        const titleInput = await screen.findByDisplayValue("Test Title");
        expect(titleInput).toBeInTheDocument();

        // ✅ 텍스트 존재 확인
        expect(screen.getByText("프로젝트 정보")).toBeInTheDocument();
        expect(screen.getByText(/소유자:/)).toHaveTextContent("Mock Owner");
        expect(screen.getByText(/참여자 수:/)).toHaveTextContent("참여자 수: 1");
    });
});
