# User-Facing Functionality Requirements by File

This document lists all user-facing or user-relevant functionality that needs to be implemented for each file in the clean slate architecture.

## App Layer

### AetherApp.swift
- Launch Aether with proper window sizing and positioning
- Handle app activation and deactivation
- Manage app preferences and settings menu
- Support multiple window instances if needed

### AppDelegate.swift  
- Show Aether icon in dock with proper branding
- Handle file associations for .md files dragged to dock
- Provide menu bar options for common actions
- Handle system sleep/wake for proper connection management

## Configuration Layer

### DesignTokens.swift
- Load typography settings that affect text readability
- Apply consistent colors for dark/light themes
- Set proper spacing for comfortable reading experience
- Handle design token updates without app restart

### EnvironmentConfig.swift
- Securely load API keys without exposing them to user
- Show helpful error messages when API keys are missing
- Support multiple .env file locations for different setups
- Validate API key format before attempting connections

### LLMProviderConfig.swift
- Discover available AI providers automatically
- Show user which providers are configured and working
- Load custom model names and endpoints from JSON
- Handle provider configuration changes without restart

### PersonaConfig.swift
- Discover personas from vault folder structure
- Show user available personas with their descriptions
- Handle persona frontmatter parsing for capabilities
- Refresh persona list when vault changes

### SlashCommandConfig.swift
- Load custom commands from markdown files in vault
- Show available slash commands to user with descriptions
- Support command arguments and help text
- Refresh commands when markdown files change

### VaultConfig.swift
- Handle vault path changes and migrations
- Create vault folders if they don't exist
- Show helpful errors when vault is inaccessible
- Support relative and absolute vault paths

## Models Layer

*Note: Models are pure data structures and don't contain user-facing functionality directly, but enable the functionality listed in Services/UI layers.*

## Services Layer

### Core Services

#### MessageRepository.swift
- Save user messages persistently across sessions
- Retrieve conversation history quickly
- Handle message search and filtering
- Support conversation export functionality

#### PersonaCoordinator.swift
- Parse first word of user input to select persona
- Route messages to appropriate persona automatically
- Show user which persona is currently active
- Handle persona switching mid-conversation

#### ConversationManager.swift
- Send user messages to AI providers
- Handle streaming responses for real-time feedback
- Manage conversation context and memory
- Show progress indicators during AI processing

#### TaxonomyService.swift
- Organize conversation topics automatically
- Allow users to search conversations by topic
- Evolve topic hierarchy based on usage patterns
- Show topic suggestions to users

### LLM Services

#### LLMManager.swift
- Route requests to available AI providers
- Handle provider failures transparently to user
- Show connection status for each provider
- Load balance across multiple providers

#### LLMResponseProcessor.swift
- Parse AI responses into taxonomy, response, and trim sections
- Extract actionable commands from AI responses
- Handle malformed responses gracefully
- Show parsing errors to user when needed

#### OpenAIService.swift / ClaudeService.swift / etc.
- Maintain stable connections to AI providers
- Handle authentication and rate limiting
- Show provider-specific error messages
- Support provider-specific features (like Claude's thinking)

### Memory Services

#### OmniscientBundleBuilder.swift
- Assemble complete conversation context for AI
- Include relevant past conversations automatically
- Load persona instructions and vault content
- Show context size and token usage to user

#### ContextMemoryIndex.swift
- Enable semantic search across all conversations
- Retrieve relevant past discussions automatically
- Index conversations by keywords and topics
- Show search results with context snippets

#### VaultLoader.swift
- Load vault content for AI context
- Handle large vault folders efficiently
- Show progress for vault loading operations
- Cache frequently accessed vault content

#### VaultMonitor.swift
- Watch vault for file changes automatically
- Refresh AI context when vault changes
- Show notifications for vault updates
- Handle vault corruption and recovery

### Vault Services

#### FileOperationService.swift
- Create, read, update, delete files through conversation
- Handle file permissions and access errors
- Support drag-and-drop file operations
- Show file operation progress and results

#### CommandProcessor.swift
- Parse natural language file commands
- Execute file operations safely
- Show command results and confirmations
- Handle command errors with helpful messages

#### SuperJournalService.swift
- Save complete conversation logs automatically
- Enable conversation replay and analysis
- Handle log file rotation and cleanup
- Show storage usage and cleanup options

#### TrimProcessor.swift
- Generate compressed conversation summaries
- Save semantic content for future reference
- Handle trim generation errors gracefully
- Show trim processing progress

### Development Services (Chapter 11)

#### ClaudeCodeSDK.swift
- Execute development commands through conversation
- Show command output and progress in real-time
- Handle subprocess errors with helpful messages
- Support interactive development workflows

#### ClaudeCodeHooks.swift
- Execute custom workflows automatically
- Show hook execution results to user
- Handle hook failures gracefully
- Allow users to configure hook behavior

#### MCPManager.swift
- Connect to external development tools
- Show available MCP servers and their status
- Handle MCP authentication flows
- Display MCP tool results in conversation

#### DevWorkflowManager.swift
- Execute git operations through conversation
- Run build and test commands automatically
- Show development progress and results
- Handle development tool errors with context

#### PermissionManager.swift
- Control access to system operations
- Show permission prompts with clear explanations
- Remember user permission preferences
- Handle enterprise security policies

#### SlashCommandRouter.swift
- Execute slash commands from user input
- Show available commands with autocomplete
- Handle command arguments and validation
- Display command help and usage information

## Coordinators Layer

### AppCoordinator.swift
- Initialize all services in correct order
- Handle service dependencies and failures
- Show app startup progress and errors
- Coordinate shutdown procedures gracefully

### MemoryCoordinator.swift
- Coordinate memory operations across services
- Show memory usage and optimization status
- Handle memory conflicts and consistency
- Enable memory debugging for power users

### UICoordinator.swift
- Coordinate UI state across components
- Handle navigation and focus management
- Show loading states during operations
- Manage UI responsiveness during heavy operations

### DevCoordinator.swift
- Coordinate development tool operations
- Show development status and progress
- Handle development environment setup
- Manage development workflow state

## UI Layer

### Views

#### ContentView.swift
- Display main app interface with proper layout
- Handle window resizing and state preservation
- Show glassmorphic design with proper transparency
- Maintain consistent spacing and typography

#### ScrollbackView.swift
- Display conversation history with proper formatting
- Enable smooth scrolling and navigation
- Show message timestamps and persona indicators
- Support text selection and copying

#### InputBarView.swift
- Provide text input with dynamic sizing
- Handle multi-line input with proper formatting
- Show typing indicators and input validation
- Support file drag-and-drop operations

#### MessageBubbleView.swift
- Display individual messages with persona styling
- Show message metadata (time, persona, status)
- Handle long messages with proper wrapping
- Support message actions (copy, reference, etc.)

#### DevToolsPanel.swift
- Show development tools and their status
- Display command output and progress
- Handle tool configuration and preferences
- Show development workflow state

### Components

#### SystemHealthIndicator.swift
- Show connection status for all AI providers
- Display system health with color coding
- Show tooltip with detailed status information
- Handle status updates in real-time

#### ModelSwitcher.swift
- Allow users to select AI provider/model
- Show available models with descriptions
- Handle model switching during conversation
- Display current model information

#### VerticalRail.swift
- Provide left sidebar with navigation options
- Show conversation list and organization
- Handle conversation switching and management
- Display vault status and quick actions

#### PermissionPrompt.swift
- Show security permission requests clearly
- Explain why permissions are needed
- Remember user choices for future requests
- Handle permission denial gracefully

### UI Utilities

#### KeyboardHandler.swift
- Handle keyboard shortcuts for common actions
- Support vim mode for text editing
- Enable quick navigation and commands
- Show keyboard shortcut hints to users

#### FocusManager.swift
- Manage input focus across components
- Handle focus restoration after operations
- Show focus indicators clearly
- Support accessibility focus management

#### ScrollCoordinator.swift
- Provide smooth scrolling animations
- Handle turn-based navigation smoothly
- Support auto-scroll to new messages
- Enable manual scroll position control

#### TextMeasurementService.swift
- Calculate proper text sizing for readability
- Handle dynamic text sizing preferences
- Support responsive layout adjustments
- Optimize text rendering performance

## State Layer

### MessageStore.swift
- Maintain conversation state for UI display
- Handle message updates and streaming
- Show conversation loading and error states
- Support conversation filtering and search UI

### InputState.swift
- Manage text input state and validation
- Handle input history and suggestions
- Show input progress and character counts
- Support draft message persistence

### NavigationState.swift
- Track current conversation and turn position
- Handle navigation history and back/forward
- Show navigation indicators and breadcrumbs
- Support deep linking to specific turns

### DevToolsState.swift
- Maintain development panel state
- Show tool status and progress information
- Handle tool configuration and preferences
- Support development workflow state

## Key User Experience Flows

### Primary Conversation Flow
1. User types message → InputBarView captures text
2. PersonaCoordinator parses persona from first word
3. ConversationManager sends to appropriate AI provider
4. MessageBubbleView displays streaming response
5. TrimProcessor saves conversation automatically

### Memory and Search Flow
1. User searches past conversations → ContextMemoryIndex performs search
2. TaxonomyService organizes results by topic
3. ScrollbackView displays relevant conversations
4. User can reference past context automatically

### Development Workflow (Chapter 11)
1. User requests code changes → DevWorkflowManager executes
2. ClaudeCodeSDK integrates with development tools
3. PermissionManager handles security confirmations
4. DevToolsPanel shows progress and results

### File and Vault Operations
1. User drags files → ImageDropHandler processes upload
2. FileOperationService handles file operations
3. VaultMonitor updates AI context automatically
4. CommandProcessor executes natural language file commands

This comprehensive list ensures every user-facing aspect of Aether is properly planned and implemented across the atomic file structure.