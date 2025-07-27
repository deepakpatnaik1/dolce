# Memory

The memory cycle of Aether, a macOS desktop application, is a structured process that manages and evolves conversation data through a series of interconnected steps, ensuring real-time context preservation and semantic organization. Below is a comprehensive description of the entire cycle, including relevant file names:

**Boss Input Processing (MessageStore.swift)**:
- [x] The cycle begins when the user ("Boss") enters input via **InputBarView.swift**. The first word of the input (case-insensitive) is parsed by **MessageStore.swift** to target a specific persona (e.g., "Samara what is space?" sets Samara and sends "what is space?"). Subsequent inputs without a persona name continue with the current persona, maintaining context until a new persona is specified.

**Omniscient Bundle Assembly (OmniscientBundleBuilder.swift)**:
- [ ] **OmniscientBundleBuilder.swift** constructs a complete memory bundle for the targeted persona. This real-time, uncached assembly follows a fixed order:
  - [x] **Instructions Header**: Loads `instructions-to-llm.md` from the `tools/` folder, outlining the triple-task framework (taxonomy analysis, response, compression).
  - [x] **Boss Context**: Incorporates `boss/` folder content (e.g., `boss.md`) for user preferences and identity.
  - [x] **Persona Context**: Loads all `.md` files from the persona's folder (e.g., `personas/Samara/`) as a blob, defining the cognitive strategy.
  - [x] **Tools Context**: Includes `tools/` folder files (e.g., `machine-trim.md`, `taxonomy-management.md`) for methodologies and taxonomy rules.
  - [x] **Journal Context**: Fetches fresh content from `journal/` folder (`Trim-YYYY-MM-DD-HHMM.md`) with structured metadata.
  - [x] **Taxonomy Structure**: Integrates the current `taxonomy.json` for consistency.
  - [x] **User Message**: Adds the current Boss input.
- [x] The method `buildBundle(for persona: String, userMessage: String) -> String` returns a formatted bundle ready for LLM processing.

**LLM Request with Triple Instructions (LLMManager.swift)**:
- [x] **LLMManager.swift** coordinates with **ProviderRouter.swift** to route the bundle to an appropriate LLM provider (e.g., Fireworks, Claude, OpenAI, or local LLaMA via **LlamaService.swift**) based on **LLMProviders.json** configuration. The LLM receives the bundle with `instructions-to-llm.md` as a header, instructing it to perform three tasks:
  - [x] **Task 1**: Analyze the conversation for taxonomy classification.
  - [x] **Task 2**: Respond authentically as the persona.
  - [x] **Task 3**: Compress the entire turn with structured metadata.

**Triple Response Processing (LLMManager.swift, TaxonomyManager.swift)**:
- [x] **LLMManager.swift**'s `parsePersonaResponse()` processes the LLM's three-part response:
  - [x] **TAXONOMY_ANALYSIS Section**: Parsed and added to the living taxonomy by **TaxonomyManager.swift**'s `addToTaxonomy()` method, evolving `taxonomy.json` with new categories, validated via `validateTopicHierarchy()`.
  - [x] **MAIN_RESPONSE Section**: Displayed in **ScrollbackView.swift** for the Boss to see and saved to the superjournal via **VaultWriter.swift**.
  - [x] **MACHINE_TRIM Section**: Saved as a compressed turn (`Trim-YYYY-MM-DD-HHMM.md`) in the `journal/` folder with structured metadata (topic_hierarchy, keywords, dependencies, sentiment) by **VaultWriter.swift**'s `saveMachineTrim()`.

**Memory Integration Completion (MessageStore.swift, VaultWriter.swift)**:
- [x] **Superjournal**: **VaultWriter.swift**'s `autoSaveTurn()` saves the complete turn (Boss input + persona response) as `FullTurn-YYYY-MM-DD-HHMM.md` in the `superjournal/` folder for an audit trail.
- [x] **Journal**: The compressed trim with metadata is stored in `journal/`, immediately available for the next cycle.
- [x] **Taxonomy**: Updated `taxonomy.json` reflects real-time evolution, ensuring semantic consistency.
- [x] **ContextMemoryIndex.swift** reconstructs this data for **ScrollbackView.swift**, enabling taxonomy-aware retrieval (e.g., `getJournalEntriesByTopic()`, `getJournalEntriesByKeywords()`).

**The Wheel Turns (OmniscientBundleBuilder.swift, LLMManager.swift)**:
- [x] The cycle repeats for each new turn. Turn N+1 begins with fresh input processed by **MessageStore.swift**, assembling a new bundle via **OmniscientBundleBuilder.swift** that includes the previous turn's trim from `journal/`. **LLMManager.swift** sends this to the LLM, which generates a new triple response, continuing the feedback loop.
- [x] **Infinite Growth**: Each turn builds on all prior semantic memory without data loss, preserved in the superjournal.
- [x] **VaultLoader.swift** monitors the filesystem, hot-reloading changes to ensure real-time integration.

**Purge Feature (VaultDeleter.swift, SlashCommandRouter.swift, InputBarView.swift)**:

The new "purge" feature allows users ("Boss") to remove data from Aether's memory at any granularity level, either through natural language instructions to personas or via slash commands in **InputBarView.swift**. This functionality enhances control over the memory cycle by enabling selective data deletion.

- [ ] **Natural Language Instructions (VaultDeleter.swift)**:
  - [ ] Users can issue commands like "Delete the last strategy note we wrote to the projects folder" in the input bar. The active persona interprets this via **VaultDeleter.swift**, which confirms user intent and moves the targeted file (e.g., `Clarity Over Complexity.md`) to `vault/trash/` as a soft deletion (e.g., `Deleted-YYYY-MM-DD-filename.md`).
  - [ ] Granularity ranges from specific files (e.g., a single trim) to broader categories (e.g., all notes in a project folder), with persona logic determining the scope based on context.

- [ ] **Slash Commands (SlashCommandRouter.swift)**:
  - [ ] Users can enter commands like `/purge-last-trim`, `/purge-project-notes`, or `/purge-all-trims-before 2025-07-01` directly in **InputBarView.swift**. **SlashCommandRouter.swift** parses these at runtime, routing them to **VaultDeleter.swift** for execution.
  - [ ] Commands are configurable via **SlashCommands.json**, allowing dynamic addition or modification, and support fine-grained deletion (e.g., specific turns, date ranges, or taxonomy categories).

- [ ] **Implementation Details**:
  - [ ] **Soft Deletion**: All purges move files to `vault/trash/`, ensuring reversibility and maintaining an audit trail.
  - [ ] **Memory Update**: After deletion, **OmniscientBundleBuilder.swift** excludes purged data from future bundles, and **ContextMemoryIndex.swift** updates the scrollback display (**ScrollbackView.swift**) to reflect the change.
  - [ ] **User Confirmation**: Dangerous operations (e.g., `/purge-all`) require approval, enforced by persona privileges in **VaultDeleter.swift**.

**Project Blueprint Architecture (Development Context Memory)**:

Aether implements a sophisticated project-specific development memory system that resolves the naming conflict between Anthropic's CLAUDE.md concept and Aether's persona system. This architecture provides project-specific development context while maintaining clear separation from persona definitions.

**Folder Structure**:
```
AetherVault/
├── Aether/                    # Current project (this software)
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
└── playbook/                 # Aether's operational knowledge
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

**Key Design Principles**:
- **Separation of Concerns**: Persona definitions (who Claude is) vs. project context (what Claude knows about projects)
- **Project Isolation**: Each software project gets its own blueprint folder with complete development context
- **Hierarchical Knowledge**: Project blueprints can have sub-folders for detailed specifications
- **Memory Integration**: OmniscientBundleBuilder loads from current project's blueprint during development work
- **Naming Resolution**: Aether's "blueprint" system serves the same purpose as Anthropic's "CLAUDE.md" concept

**Development Context Loading**:
When Claude performs development work, the memory system includes:
1. **Persona Context**: `playbook/persona/claude/claude.md` (who Claude is)
2. **Project Context**: `CurrentProject/blueprint/` (what Claude knows about this project)
3. **Development Patterns**: Accumulated development knowledge and architectural decisions
4. **Implementation History**: Previous development conversations and decisions

This architecture ensures Claude has both personality consistency (persona) AND deep project knowledge (blueprint) while maintaining clean separation between different software projects.

**Supporting Components**:
- [x] **PersonaRegistry.swift**: Manages persona metadata (e.g., `displayName(for id: String)`) for UI display and validation.
- [x] **VaultConfig.swift**: Configures the vault location for flexibility and testability.
- [x] **DesignTokens.json**: Provides styling constants (e.g., font sizes) for consistent rendering.
- [x] **EnvFileParser.swift**: Resolves API keys from the `.env` file for secure configuration.
- [x] **HTTPResponseParser.swift**: Ensures consistent response handling across providers.

**Summary**:
The Aether memory cycle is a continuous process where Boss input triggers bundle assembly (**OmniscientBundleBuilder.swift**), LLM processing (**LLMManager.swift**), and triple-response handling (**TaxonomyManager.swift**, **VaultWriter.swift**). This results in taxonomy evolution, displayed responses, and compressed memory storage, feeding back into the next cycle. The system ensures a complete, evolving knowledge base with no data loss, managed through the vault structure (**VaultLoader.swift**, **VaultDeleter.swift**).