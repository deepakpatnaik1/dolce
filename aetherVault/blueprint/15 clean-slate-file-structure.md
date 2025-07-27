# Clean Slate File Structure for Aether Rewrite

Based on analysis of the original codebase and Chapter 11b implementation plan, this document defines the atomic file structure for the Aether rewrite, prioritizing maximum separation of concerns.

## Design Philosophy

**Atomic Responsibility**: Each file should have exactly one reason to change. No file should handle multiple unrelated concerns.

**Clear Dependencies**: Dependencies flow in one direction only: UI → State → Coordinators → Services → Models

**Testability**: Every component can be unit tested independently without complex mocking.

## Complete File Structure

```
Aether/
├── App/
│   ├── AetherApp.swift                    # SwiftUI app entry point
│   └── AppDelegate.swift                  # macOS-specific app lifecycle
│
├── Configuration/                         # External configuration management
│   ├── DesignTokens.swift                # Loads design system from DesignTokens.json
│   ├── EnvironmentConfig.swift           # Parses .env files for API keys
│   ├── LLMProviderConfig.swift           # Loads provider settings from JSON
│   ├── PersonaConfig.swift               # Discovers personas from vault structure
│   ├── SlashCommandConfig.swift          # Loads custom commands from markdown
│   └── VaultConfig.swift                 # Manages vault directory paths
│
├── Models/                               # Pure data structures (no business logic)
│   ├── Core/
│   │   ├── ChatMessage.swift             # Message data with streaming support
│   │   ├── PersonaDefinition.swift       # Persona metadata and capabilities
│   │   ├── TaxonomyNode.swift            # Semantic classification structure
│   │   └── VaultEntry.swift              # File system entry metadata
│   ├── LLM/
│   │   ├── LLMProvider.swift             # Provider configuration data
│   │   ├── LLMRequest.swift              # Request payload structure
│   │   └── LLMResponse.swift             # Response data with sections
│   ├── Memory/
│   │   ├── MemoryBundle.swift            # Omniscient context bundle
│   │   ├── MachineTrim.swift             # Compressed conversation data
│   │   └── SuperJournalEntry.swift       # Full conversation log entry
│   └── Development/                       # Chapter 11: Development tool models
│       ├── ClaudeCodeOperation.swift     # Development operation metadata
│       ├── MCPServer.swift               # MCP server configuration
│       └── PermissionRule.swift          # Access control rules
│
├── Services/                             # Single-purpose business logic
│   ├── Core/
│   │   ├── MessageRepository.swift       # Message persistence operations only
│   │   ├── PersonaCoordinator.swift      # Persona selection and routing only
│   │   ├── ConversationManager.swift     # LLM request coordination only
│   │   └── TaxonomyService.swift         # Taxonomy classification operations
│   ├── LLM/
│   │   ├── LLMServiceProtocol.swift      # Common interface for all providers
│   │   ├── LLMManager.swift              # Provider routing and failover only
│   │   ├── LLMResponseProcessor.swift    # Parse triple-response sections
│   │   ├── OpenAIService.swift           # OpenAI API integration
│   │   ├── ClaudeService.swift           # Anthropic Claude API
│   │   ├── FireworksService.swift        # Fireworks AI integration
│   │   └── LlamaService.swift            # Local LLaMA integration
│   ├── Memory/
│   │   ├── OmniscientBundleBuilder.swift # Assembles complete context bundles
│   │   ├── ContextMemoryIndex.swift      # Semantic memory retrieval
│   │   ├── VaultLoader.swift             # Loads vault content into memory
│   │   └── VaultMonitor.swift            # Watches directory for changes
│   ├── Vault/
│   │   ├── FileOperationService.swift    # Pure file read/write operations
│   │   ├── CommandProcessor.swift        # Natural language file commands
│   │   ├── SuperJournalService.swift     # Automated conversation logging
│   │   └── TrimProcessor.swift           # Machine trim generation and saving
│   └── Development/                      # Chapter 11: Development capabilities
│       ├── ClaudeCodeSDK.swift           # Claude Code subprocess integration
│       ├── ClaudeCodeHooks.swift         # Development workflow automation
│       ├── MCPManager.swift              # Model Context Protocol server management
│       ├── DevWorkflowManager.swift      # Git, build, test automation
│       ├── PermissionManager.swift       # Security and access control
│       └── SlashCommandRouter.swift      # Command parsing and execution
│
├── Coordinators/                         # Cross-service orchestration
│   ├── AppCoordinator.swift              # Dependency injection container
│   ├── MemoryCoordinator.swift           # Memory system orchestration
│   ├── UICoordinator.swift               # UI state and navigation coordination
│   └── DevCoordinator.swift              # Development tool coordination
│
├── UI/                                   # Pure presentation layer
│   ├── Views/
│   │   ├── ContentView.swift             # Main app layout and glassmorphic design
│   │   ├── ScrollbackView.swift          # Message display with turn navigation
│   │   ├── InputBarView.swift            # Text input with dynamic sizing
│   │   ├── MessageBubbleView.swift       # Individual message rendering
│   │   └── DevToolsPanel.swift           # Development tools interface
│   ├── Components/
│   │   ├── SystemHealthIndicator.swift   # LLM provider status indicator
│   │   ├── ModelSwitcher.swift           # Provider/model selection UI
│   │   ├── VerticalRail.swift            # Left sidebar interface
│   │   └── PermissionPrompt.swift        # Security permission dialogs
│   └── Utilities/
│       ├── KeyboardHandler.swift         # Keyboard shortcut management
│       ├── FocusManager.swift            # Input focus coordination
│       ├── ScrollCoordinator.swift       # Smooth scrolling animations
│       └── TextMeasurementService.swift  # Text sizing calculations
│
├── State/                                # UI state management (ObservableObject)
│   ├── MessageStore.swift                # Pure UI message state (no business logic)
│   ├── InputState.swift                  # Input bar state and text handling
│   ├── NavigationState.swift             # Turn navigation and focus state
│   └── DevToolsState.swift               # Development panel state
│
├── Utilities/                            # Pure helper functions
│   ├── Extensions/
│   │   ├── String+Extensions.swift       # String manipulation helpers
│   │   ├── URL+Extensions.swift          # URL and path utilities
│   │   └── View+Extensions.swift         # SwiftUI view modifiers
│   ├── Networking/
│   │   ├── HTTPRequestBuilder.swift      # HTTP request construction
│   │   └── NetworkMonitor.swift          # Network connectivity monitoring
│   └── System/
│       ├── ImageDropHandler.swift        # Drag-and-drop file handling
│       ├── TerminalWatcher.swift         # Terminal command execution
│       └── MarkdownRenderer.swift        # Markdown to AttributedString
│
└── Resources/                            # External configuration files
    ├── Config/
    │   ├── LLMProviders.json             # Provider endpoints and models
    │   ├── SlashCommands.json            # Built-in command definitions
    │   └── DesignTokens.json             # Typography, colors, spacing
    └── Assets.xcassets/                  # App icons and images
```

## Detailed Component Explanations

### App Layer
**Purpose**: Application lifecycle and entry points
- **AetherApp.swift**: SwiftUI `@main` app struct, window configuration
- **AppDelegate.swift**: macOS-specific behaviors, menu bar, dock interactions

### Configuration Layer
**Purpose**: Load external settings without hardcoding
- **DesignTokens.swift**: Centralizes all UI constants from JSON file
- **EnvironmentConfig.swift**: Secure API key loading from `.env` files
- **LLMProviderConfig.swift**: Dynamic provider discovery and configuration
- **PersonaConfig.swift**: Scans vault for persona definitions with YAML frontmatter
- **SlashCommandConfig.swift**: Discovers custom commands from markdown files
- **VaultConfig.swift**: Manages all vault directory paths and structure

### Models Layer
**Purpose**: Pure data structures with no dependencies
- **Core Models**: Basic data types for messages, personas, taxonomy
- **LLM Models**: Request/response structures for provider communication
- **Memory Models**: Data formats for omniscient bundles and compressed memory
- **Development Models**: Chapter 11 data structures for development tools

### Services Layer
**Purpose**: Single-responsibility business operations

#### Core Services
- **MessageRepository**: Database operations for message persistence
- **PersonaCoordinator**: Parses first word, routes to correct persona
- **ConversationManager**: Orchestrates LLM requests and responses
- **TaxonomyService**: Manages semantic classification and evolution

#### LLM Services
- **LLMManager**: Routes requests to available providers with failover
- **LLMResponseProcessor**: Parses triple-response format (taxonomy/response/trim)
- **Provider Services**: Individual integrations for OpenAI, Claude, etc.

#### Memory Services
- **OmniscientBundleBuilder**: Assembles complete context from vault
- **ContextMemoryIndex**: Semantic search and retrieval
- **Vault Services**: File operations and monitoring

#### Development Services (Chapter 11)
- **ClaudeCodeSDK**: Subprocess integration with Claude Code CLI
- **MCPManager**: Model Context Protocol server management
- **DevWorkflowManager**: Git, build, test automation
- **PermissionManager**: Security controls and access policies

### Coordinators Layer
**Purpose**: Orchestrate multiple services without business logic
- **AppCoordinator**: Dependency injection, service lifecycle
- **MemoryCoordinator**: Memory system orchestration
- **UICoordinator**: UI state synchronization
- **DevCoordinator**: Development tool coordination

### UI Layer
**Purpose**: Pure presentation with no business logic
- **Views**: Major UI components (ContentView, ScrollbackView, InputBarView)
- **Components**: Reusable UI elements
- **Utilities**: UI-specific helpers and coordinators

### State Layer
**Purpose**: SwiftUI ObservableObject state management only
- Clean separation from business logic
- Pure UI state with computed properties
- Delegates business operations to coordinators

### Utilities Layer
**Purpose**: Pure functions with no side effects
- **Extensions**: Language and framework extensions
- **Networking**: HTTP utilities
- **System**: OS integration helpers

## Key Architectural Benefits

### 1. **Maximum Testability**
Each component can be unit tested independently:
```swift
// Test MessageRepository without UI
let repository = MessageRepository()
let message = ChatMessage(content: "test")
XCTAssertNoThrow(try repository.save(message))
```

### 2. **Clear Dependency Flow**
```
UI Views → State → Coordinators → Services → Models
                    ↓
              Configuration
```

### 3. **Easy Feature Addition**
New capabilities require minimal changes:
- Add model for data structure
- Add service for business logic
- Add UI component for presentation
- Wire together in coordinator

### 4. **Chapter 11 Integration**
Development features cleanly separated:
- Services handle Claude Code integration
- Models define development operations
- UI components provide development interface
- Coordinators manage development workflows

### 5. **Maintenance Benefits**
- **Single Responsibility**: Each file has one reason to change
- **Atomic Changes**: Modifications are localized and predictable
- **Clear Ownership**: Easy to identify where functionality lives
- **Reduced Coupling**: Changes in one area don't cascade unexpectedly

## Migration Strategy

1. **Phase 1**: Create structure, migrate pure data models
2. **Phase 2**: Extract and test atomic services
3. **Phase 3**: Implement coordinators for orchestration
4. **Phase 4**: Build UI with new state management
5. **Phase 5**: Add Chapter 11 development features

This structure transforms the sophisticated original architecture into an even more maintainable system where every component has atomic responsibility and clear boundaries.