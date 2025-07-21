# Scrollback

The **ScrollbackView.swift** file defines the scrollback area in Dolce, a macOS desktop application, serving as the primary interface for viewing and navigating conversation history with AI personas. Below is a comprehensive overview of its user-facing features and functionality:

**Visual Design (ScrollbackView.swift)**:
- [x] **Fixed-Width Layout**: Maintains a 592px content area, centered with equal empty space on both sides using `GeometryReader` and `HStack` with `Spacer()`, ensuring consistency with **InputBarView.swift**.
- [x] **Responsive Spacing**: Only surrounding space adjusts to window size (e.g., full-screen, 2/3, or 1/3 via Magnet app), preserving content width for a stable, Claude-inspired aesthetic.
- [x] **App Background**: Soft black with gradients, creating a distraction-free, dark-themed writing environment.
- [x] **Unified Team Display**: All messages (from Boss and personas like Vanessa, Gunnar, Vlad, Samara, Claude) appear in a single, left-aligned vertical thread. No left/right distinction; each message is labeled with the persona's name and their chosen emoji.
- [x] **Visual Grouping**: Consecutive messages from the same speaker are visually grouped for clarity.

**Content Rendering (ScrollbackView.swift, MarkdownRenderer.swift)**:
- [ ] **Rich Markdown Parsing**: Supports headers, bullet points, emphasis, inline code, and quote formatting (>) with visual indentation, styled via **DesignTokens.json**.
- [ ] **Syntax Highlighting**: Code blocks are highlighted for readability, handled by **MarkdownRenderer.swift**.
- [ ] **Link Auto-Detection**: Detects and formats links with project-aware linking for seamless navigation.
- [ ] **Content-Type Styling**: Unique styles for code, file names, tasks, definitions, and system messages, ensuring visual distinction.
- [ ] **Message Anchoring**: Each message is addressable via a unique ID (e.g., `#message-124`) for precise referencing.

**Navigation Features (ScrollbackView.swift, KeyboardHandler.swift)**:
- [x] **Turn-Based Navigation**:
  - [x] **Option+↑/↓**: Enters "Turn Mode," isolating individual Boss+Persona exchange pairs (question + response), hiding other messages for focused review.
  - [x] **Entry**: `Option+↑` starts at the latest turn; `Option+↓` starts at the earliest.
  - [x] **Turn Jumping**: Subsequent `Option+↑/↓` navigates between turns.
  - [x] **Exit**: `Esc` returns to the full conversation view, auto-scrolling to the latest message.
- [ ] **Traditional Navigation**:
  - [x] **Shift+Option+↑/↓**: Smoothly scrolls in 100pt increments for long messages within the current view.
  - [ ] **Mouse Selection**: Users can drag-select text across multiple message bubbles.
  - [ ] **Copy Operations**: Supports `Cmd+C` and context menu copy, with immediate highlight clearing via `clearTextSelection()`.
- [x] **Auto-Scroll**: New messages automatically scroll into view, disabled in Turn Mode for focused navigation.
- [x] **Smooth Transitions**: Animated scrolling between turns and back to full view ensures a polished experience.

**Visual Design Updates (ScrollbackView.swift)**:
- [x] **Boss and Speaker Tags**: The Boss tag is styled with a blue left border and the label "Boss" in a clean, readable font from **DesignTokens.json** (likely iA Writer Quattro V). The speaker tag for Samara features a green left border with the name "Samara", reflecting the persona's visual identity. Both tags are left-aligned above their respective messages, maintaining a uniform, minimalistic look without persona-specific coloring beyond the border and emoji.
- [x] **Streaks**: Thin horizontal lines (streaks) in matching colors (blue for Boss, green for Samara) extend across the full 600px width beneath each tag, separating messages visually. These streaks use a subtle gradient effect from the soft black background, enhancing readability and aligning with the dark-themed, distraction-free aesthetic. The styling ensures a professional, Claude-like appearance, consistent with the fixed-width layout.
- [ ] Colors for Boss and AI personas are codified in a .md file in the vault. 

**Interaction (ScrollbackView.swift, MessageBubbleView.swift)**:
- [ ] **Message Bubbles**: Each message is rendered via **MessageBubbleView.swift** with configurable typography from **DesignTokens.json**. Features include:
  - [ ] Clickable elements for copying or referencing messages.
  - [ ] Hover states and cursor changes for interactive elements.
  - [ ] No persona-specific emojis; personas provide their own visual identity (e.g., emojis).
- [ ] **Claude Integration**: Claude messages, injected via **ClaudeService.swift**, appear and behave like other persona responses in the unified thread.

**Memory and Context Integration (ContextMemoryIndex.swift)**:
- [x] **Conversation History**: Reconstructs the scrollback display from superjournal files (`FullTurn-YYYY-MM-DD-HHMM.md`) using **ContextMemoryIndex.swift**, ensuring accurate UI representation.
- [x] **Taxonomy-Aware Retrieval**: Supports searching conversation history by:
  - [x] **Hierarchical Topics**: Via `getJournalEntriesByTopic()`.
  - [x] **Keywords**: Via `getJournalEntriesByKeywords()` for semantic matching.
  - [x] **Dependencies**: Via `getJournalEntriesByDependencies()` for cross-turn analysis.
  - [x] **Sentiment**: Via `getJournalEntriesBySentiment()` for emotionally significant moments.
- [x] **No Truncation**: Preserves all conversation data, organizing it for display without deletion, aligning with Dolce's memory philosophy.

**Scroll Management (ScrollbackView.swift)**:
- [x] **Auto-Scroll to Latest**: Ensures new messages are visible, with smooth animations for appending messages.
- [x] **Turn Mode Isolation**: Disables auto-scroll during turn navigation to maintain focus on the selected exchange.
- [x] **No Visual Clutter**: Clean presentation without turn indicators, letting focused content stand out.

**Design Stability (ScrollbackView.swift)**:
- [x] **Fixed 592px Content Area**: Prevents stretching or shrinking, ensuring professional stability across window sizes.
- [x] **Magnet App Compatibility**: Works seamlessly with window sizing (full-screen, 2/3, 1/3).
- [x] **No Layout Jumps**: Eliminates disruptive animations for a consistent, polished appearance.

**Summary**:
The scrollback area, primarily defined in **ScrollbackView.swift**, is a fixed-width, centered, dark-themed interface for viewing and navigating Dolce's conversation history. It supports rich markdown rendering (**MarkdownRenderer.swift**), unified team display, and advanced navigation (turn-based via `Option+↑/↓`, smooth scrolling via `Shift+Option+↑/↓`, per **KeyboardHandler.swift**). Users can select and copy text, review specific exchanges, and retrieve conversations by topic, keywords, dependencies, or sentiment (**ContextMemoryIndex.swift**). The scrollback integrates with Claude responses (**ClaudeService.swift**) and maintains a stable, professional aesthetic, serving as a team journal with microscope-like focus capabilities.