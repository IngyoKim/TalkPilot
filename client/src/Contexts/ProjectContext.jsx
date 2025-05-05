import { createContext } from 'react';

const ProjectContext = createContext();

export function ProjectProvider({ children }) {
    return (
        <ProjectContext.Provider value={{}}>
            {children}
        </ProjectContext.Provider>
    );
}

export default ProjectContext;
