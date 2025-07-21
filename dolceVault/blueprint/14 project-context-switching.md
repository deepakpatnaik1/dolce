# Project Context Switching

Dolce enables seamless project context switching through natural language instructions to any persona. Projects are persona-agnostic workspaces containing specialized folders for different disciplines - marketing, development, finance, legal, etc. Only one project context is active at a time, ensuring focused collaboration without cross-project contamination.

## Project Structure

Each project in DolceVault follows a consistent folder structure that supports multi-persona collaboration:

```
DolceVault/
├── Dolce/                    # Current project (this software)
│   ├── blueprint/            # Development context (Claude)
│   │   ├── 01-overview.md
│   │   ├── 11-development-environment.md
│   │   ├── 14-project-context-switching.md
│   │   └── For Chapter 11/   # Detailed development specs
│   ├── marketing/            # Marketing context (Alicja)
│   ├── finance/              # Financial context (Sonja)
│   └── business/             # Business context (Vanessa)
├── FoodDeliveryApp/          # Mobile app project
│   ├── blueprint/            # Development context (Claude)
│   ├── marketing/            # Marketing strategy (Alicja)
│   ├── finance/              # Financial projections (Sonja)
│   └── business/             # Business planning (Vanessa)
├── PlatformGame/             # Game development project
│   ├── blueprint/            # Game development (Claude)
│   ├── marketing/            # Game marketing (Alicja)
│   ├── design/               # Creative direction (Eva)
│   └── finance/              # Revenue modeling (Sonja)
└── playbook/                 # Dolce's operational knowledge
    ├── boss/
    │   └── Boss.md           # Boss profile and preferences
    ├── persona/
    │   ├── claude/
    │   │   └── claude.md     # Claude persona definition
    │   ├── alicja/
    │   │   └── alicja.md     # Alicja persona definition
    │   └── sonja/
    │       └── sonja.md      # Sonja persona definition
    └── tools/
        └── ...
```

## Context Loading Mechanics

**Natural Language Project Loading**:
Users issue human-language instructions to any persona to switch project context. The targeted persona interprets the instruction and loads the appropriate project workspace.

**Examples**:
- "Claude, switch to the FoodDeliveryApp project and review the backend architecture"
- "Alicja, load the PlatformGame project and work on the marketing strategy"  
- "Sonja, analyze the FoodDeliveryApp budget projections"

**Single Active Project**: Only one project context remains loaded at any time. Loading a new project automatically unloads the current project context, ensuring clean separation between different initiatives.

**Universal Project Access**: Any persona can load any project. The persona accesses their specialized folder within the project structure (Claude→blueprint/, Alicja→marketing/, etc.).

## Memory Integration

**OmniscientBundleBuilder Enhancement**: The bundle assembly process includes the currently loaded project context for all personas, regardless of which persona originally loaded the project.

**Bundle Structure with Project Context**:
```
1. Instructions Header (tools/)
2. Boss Context (boss/)  
3. Persona Context (persona/[current_persona]/)
4. Tools Context (tools/)
5. Current Project Context ([current_project]/[persona_folder]/)
6. Journal Context (journal/)
7. Taxonomy Structure (taxonomy.json)
8. User Message
```

**Project Context Resolution**: Each persona accesses their designated folder within the active project:
- Claude: `[current_project]/blueprint/`
- Alicja: `[current_project]/marketing/`  
- Sonja: `[current_project]/finance/`
- Vanessa: `[current_project]/business/`
- Eva: `[current_project]/design/`

## Implementation Components

**ProjectContextManager.swift**: Manages active project state and context loading/unloading.

```swift
class ProjectContextManager: ObservableObject {
    @Published var currentProject: String?
    
    func loadProject(_ projectName: String, for persona: String) async
    func unloadCurrentProject() async  
    func getCurrentProjectContext(for persona: String) -> [String]
    func getAvailableProjects() -> [String]
}
```

**OmniscientBundleBuilder Integration**: Enhanced to include project context in bundle assembly when a project is loaded.

**Natural Language Processing**: Personas detect project loading instructions through pattern matching on user messages containing project names and loading verbs.

## Project Discovery

**Automatic Project Detection**: The system scans DolceVault/ for folders containing recognized project structure (blueprint/, marketing/, finance/, etc.).

**Project Registry**: Maintains a dynamic list of available projects for context switching validation and autocomplete suggestions.

**Project Metadata**: Each project folder optionally contains a `project.json` file with metadata:
```json
{
  "name": "FoodDeliveryApp",
  "description": "On-demand food delivery mobile application",
  "status": "active",
  "personas": ["claude", "alicja", "sonja", "vanessa"],
  "created": "2024-01-15",
  "lastActive": "2024-07-20"
}
```

## Context Isolation

**Clean Project Separation**: Loading a new project completely replaces the previous project context in memory. No information bleeds between projects.

**Persona-Specific Context**: Each persona only accesses their designated folder within the active project, maintaining role-based information boundaries.

**Conversation Continuity**: The active project context persists across persona switches within the same conversation session. Switching from Claude to Alicja maintains the same loaded project.

## Usage Patterns

**Project Initiation**: "Claude, start a new project called MobileGameStudio and set up the development structure"

**Context Switching**: "Alicja, switch to the FoodDeliveryApp project and review the marketing materials"

**Multi-Persona Collaboration**: Within a single conversation, multiple personas can work on the same project by accessing their specialized folders.

**Project Status**: "What project are we currently working on?" returns the active project name and context.

## File Organization

**Discipline-Specific Folders**: Each project contains folders aligned with persona specializations, ensuring relevant context loading for each team member.

**Consistent Structure**: All projects follow the same organizational pattern, enabling predictable context loading across different initiatives.

**Scalable Architecture**: The system supports unlimited projects and can accommodate new persona specializations by adding corresponding folders to the project structure.

This project context switching system transforms Dolce from a single-purpose assistant into a collaborative workspace where specialized personas contribute their expertise to shared initiatives through natural conversation.