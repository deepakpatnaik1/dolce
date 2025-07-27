# Input bar

The **InputBarView.swift** defines the user-facing input bar in Aether, a macOS desktop application, providing a centralized interface for interacting with AI personas. Below is a comprehensive overview of its features and functionality:

**Visual Design (InputBarView.swift)**:
- [x] **Glassmorphic Styling**: Semi-transparent background with elegant inner/outer glow effects and 12px rounded corners for a premium aesthetic.
- [ ] ==**Placeholder Text**: Displays "Ask anything..." with optimized opacity to guide user input.==
- [ ] **Green Operational Indicator**: Embedded on the right, showing system status (at least one LLM service and persona registry operational), with a tooltip listing active services.
- [ ] **Plus Button**: Located on the left, enables attachment uploads (e.g., images, PDFs, code files).

**Layout (InputBarView.swift)**:
- [x] **Fixed Width**: Maintains a 592px content area, centered with equal spacing on both sides, consistent with **ScrollbackView.swift** for a stable, Claude-inspired layout.
- [x] **Responsive Behavior**: Adapts to window resizing (e.g., via Magnet app) without altering content width, ensuring no layout jumps.
- [x] **Perfect Centering**: Uses `GeometryReader` and `HStack` with `Spacer()` for equal empty space on both sides.

**Interaction and Behavior (InputBarView.swift)**:
- [ ] **Auto-Focus**: Activates on app launch with immediate cursor blinking for instant typing.
- [x] **Text Area Expansion**: Grows upward smoothly with spring physics animation, maintaining vertical symmetry at maximum height. The bottom border remains fixed.
- [ ] **Height Management**:
  - [x] Starts at a compact default height with optimized text-to-border spacing.
  - [x] Expands based on line count, with a maximum height constraint to prevent excessive growth.
  - [x] Supports internal scrolling when content exceeds the visible area, keeping the bottom border static.
- [ ] **Send Controls**:
  - [ ] `Enter`: Adds a new line.
  - [x] `Cmd+Enter`: Sends the message and resets the input bar to its compact state.
- [ ] ==**Trim Functionality**: Typing "§" triggers special trim operations, processed via **VaultWriter.swift** for saving compressed content to the journal.==
- [x] **Persona Targeting**:
  - [x] Parses the first word (case-insensitive) to select the active persona (e.g., "Samara what is space?" sets Samara as the current persona and sends "what is space?").
  - [x] Subsequent messages without a persona name continue with the current persona.
  - [x] Switches personas when a new persona name is used (e.g., "Vlad analyze this" switches to Vlad).

**File Upload Support (ImageDropHandler.swift)**:
- [ ] **Drag-and-Drop**: The input bar detects file drag gestures using SwiftUI's `.onDrop`, showing a blue-tinted overlay with "Drop files here to add to the chat."
- [ ] **Supported File Types**: Images (PNG, JPG), PDFs, plaintext, Markdown, and code files (Swift, JS, Python, etc.).
- [ ] **Preview UI**: Displays thumbnails, filenames, and remove icons below the input bar for each uploaded file.
- [ ] **Post-Processing**: Files are analyzed by the active persona, compressed via the machine-trim pipeline (**VaultWriter.swift**), and saved as markdown in the journal folder. Original files are discarded after processing, retaining only the semantic content.
- [ ] Blobs of text copy-pasted in the input bar should be treated as .md files and displayed in the input bar along with other files. 

**Keyboard Shortcuts (KeyboardHandler.swift)**:
- [x] **Message Sending**: `Cmd+Enter` sends the input
- [ ] Enter` adds a new line.
- [x] **Navigation Support**: Works with global shortcuts like `Option+↑/↓` for conversation turn navigation
- [x] `Shift+Option+↑/↓` for smooth scrolling in **ScrollbackView.swift**.

**Integration with Memory System (VaultWriter.swift, OmniscientBundleBuilder.swift)**:
- [x] User inputs are processed by **MessageStore.swift** for persona targeting and bundled with context (instructions, persona data, journal, taxonomy) via **OmniscientBundleBuilder.swift**.
- [x] Inputs contribute to the memory cycle, with responses saved to the superjournal (`FullTurn-YYYY-MM-DD-HHMM.md`) and compressed trims to the journal (`Trim-YYYY-MM-DD-HHMM.md`) via **VaultWriter.swift**.

**Slash Commands (SlashCommandRouter.swift)**:
- [ ] Supports dynamic slash commands (e.g., `/delete-last-trim`, `/model claude`) entered in the input bar, parsed at runtime, and routed to memory operations or model switching.
- [ ] Commands are configurable via **SlashCommands.json** and can be created or modified through natural language.

**Design Stability**:
- [x] **No Layout Jumps**: Fixed 592pxpx content width ensures consistent text wrapping and measurement.
- [x] **Professional Stability**: Smooth animations and locked bottom border maintain a polished appearance, with styling constants defined in **DesignTokens.json**.

**Summary**:
The input bar, primarily defined in **InputBarView.swift**, is the user's primary interface for interacting with Aether's AI personas. It supports text input with persona targeting, file uploads, slash commands, and keyboard-driven navigation, all within a visually appealing, fixed-width, glassmorphic design. It integrates seamlessly with the memory cycle (**OmniscientBundleBuilder.swift**, **VaultWriter.swift**) and navigation systems (**KeyboardHandler.swift**, **SlashCommandRouter.swift**), enabling structured, context-aware conversations with robust auditability and semantic organization.