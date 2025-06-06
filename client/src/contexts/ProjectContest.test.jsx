import { render, screen } from '@testing-library/react';
import ProjectContext, { ProjectProvider } from './ProjectContext';
import { useContext } from 'react';

function TestComponent() {
    const value = useContext(ProjectContext);
    return <div>{typeof value === 'object' ? 'Context OK' : 'Context Fail'}</div>;
}

test('ProjectProvider: 빈 context 제공 확인', () => {
    render(
        <ProjectProvider>
            <TestComponent />
        </ProjectProvider>
    );

    expect(screen.getByText('Context OK')).toBeInTheDocument();
});
