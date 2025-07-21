# File Operations and Vault Management

Dolce provides comprehensive file management capabilities through a structured vault system that handles conversational file creation, intelligent processing, and safe deletion operations. The vault serves as the central repository for all conversation data, project documentation, and semantic memory, organized in a hierarchical structure that supports both automated and user-directed file operations.

**Vault Structure (VaultConfig.swift)**:
- [ ] **Configurable Location**: Vault path is configurable rather than hardcoded, enabling relocation, remote mounting, and flexible deployment across different environments
- [ ] **Hierarchical Organization**: Structured folder system with distinct purposes: playbook/ for governance, journal/ for semantic memory, superjournal/ for audit logs, projects/ for documentation, and trash/ for recoverable deletions
- [ ] **Hot Reloading**: Filesystem monitoring via **VaultLoader.swift** detects changes and updates the system in real-time without requiring restarts

**Conversational File Creation (VaultWriter.swift)**:
- [ ] **Natural Language Commands**: Users create files through conversational instructions like "Write a new strategy note to journal titled Clarity Over Complexity. Content begins..." with the active persona interpreting and executing the command
- [ ] **Directory Creation**: Automatically creates folders and directory structures as needed based on user instructions
- [ ] **Flexible Organization**: No rigid syntax requirements - users organize content naturally through descriptive commands processed by AI personas
- [ ] **Agentic Auto-Save**: Automated saving of conversation turns via autoSaveTurn() and compressed memory via saveMachineTrim() without manual intervention

**File Upload and Processing (ImageDropHandler.swift)**:
- [ ] **Drag-and-Drop Interface**: Input bar accepts file drops using SwiftUI's .onDrop, displaying a blue-tinted overlay with "Drop files here to add to the chat" during drag operations
- [ ] **Multiple File Types**: Supports images (PNG, JPG), PDFs, plaintext, Markdown, and code files (Swift, JS, Python) with appropriate handling for each type
- [ ] **Preview System**: Clean preview section appears beneath the input bar showing thumbnails, filenames, and remove icons for each uploaded file
- [ ] **AI Analysis Pipeline**: Uploaded files are analyzed by the active persona, with insights processed through the machine-trim pipeline and saved as semantic content in the journal
- [ ] **Content Extraction**: Original files are discarded after analysis, retaining only the meaningful semantic content as compressed markdown entries
- [ ] **Text Blob Handling**: Copy-pasted text content is treated as .md files and displayed alongside other uploads in the preview area

**Safe Deletion System (VaultDeleter.swift)**:
- [ ] **Natural Language Deletion**: Users issue deletion commands like "Delete the last strategy note we wrote to the projects folder" with personas interpreting intent and confirming scope
- [ ] **Soft Deletion**: All deletions move files to vault/trash/ with timestamps (e.g., Deleted-YYYY-MM-DD-filename.md) ensuring complete reversibility
- [ ] **Granular Control**: Supports deletion at any level from specific files to entire project folders, with persona logic determining appropriate scope
- [ ] **User Confirmation**: Dangerous operations require explicit approval, with safety checks enforced through persona privilege systems

**Specialized Folders**:
- [ ] **journal/**: Contains compressed semantic memory (Trim-YYYY-MM-DD-HHMM.md) with structured metadata for real-time integration into future conversations
- [ ] **superjournal/**: Maintains complete audit logs (FullTurn-YYYY-MM-DD-HHMM.md) preserving full conversation context for deep recall and quality assessment
- [ ] **projects/**: Organizes project-specific documentation and decisions by project name for contextual knowledge management
- [ ] **playbook/**: Houses governance definitions, persona configurations, and system tools including the living taxonomy and compression methodologies
- [ ] **trash/**: Non-destructive deletion repository with timestamped recovery capabilities

**Integration with Memory System**:
- [ ] **Real-Time Loading**: **OmniscientBundleBuilder.swift** loads fresh journal content for each conversation turn without caching, ensuring current context
- [ ] **Taxonomy Integration**: File operations update the living taxonomy via **TaxonomyManager.swift**, maintaining semantic consistency across the knowledge base
- [ ] **Memory Cycle Integration**: New files immediately become available for context inclusion in subsequent AI interactions through the omniscient bundle system

**Slash Command Support (SlashCommandRouter.swift)**:
- [ ] **Dynamic Commands**: Runtime-configurable slash commands for file operations (e.g., /delete-last-trim, /purge-project-notes) parsed from **SlashCommands.json**
- [ ] **Batch Operations**: Support for date-range deletions and bulk operations via commands like /purge-all-trims-before 2025-07-01
- [ ] **Safe Execution**: All slash command file operations maintain the same safety protocols as natural language commands

**Security and Access Control**:
- [ ] **Persona Privileges**: File access controlled through persona configuration with allow_terminal_access and similar permissions in persona frontmatter
- [ ] **User Approval Gates**: Sensitive operations require explicit user confirmation, preventing accidental data loss or unauthorized access
- [ ] **Audit Trail**: Complete operation logging ensures accountability and enables forensic analysis of file system changes

The vault management system transforms file operations from technical tasks into natural conversation, while maintaining enterprise-grade safety, organization, and auditability throughout the knowledge lifecycle.