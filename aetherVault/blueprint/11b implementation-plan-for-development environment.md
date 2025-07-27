# Comprehensive Implementation Plan for Chapter 11: Development Environment
   Integration

  Current State Analysis

  Excellent Foundation Already Exists:

  1. ClaudeCodeSDK.swift - Complete SDK wrapper with subprocess execution,
  JSON parsing, security controls
  2. ClaudeCodeService.swift - Hybrid API/SDK service with intelligent
  routing
  3. TerminalWatcher.swift - Secure command execution with persona
  privileges
  4. CodeWriter.swift - Full file operations (Read/Write/Edit/MultiEdit)
  with security
  5. LLMManager.swift - Provider routing and model management
  6. OmniscientBundleBuilder.swift - Memory assembly system

  Key Gaps Identified:
  - Hook system implementation missing
  - MCP server integration missing
  - Advanced permission management incomplete
  - Slash command routing incomplete
  - Development workflow automation missing

  Implementation Plan

  Phase 1: Complete Core Integration (Week 1)

  1.1 Enhanced SDK Configuration

  Target: ClaudeCodeSDK.swift
  - Add MCP configuration support
  - Implement permission mode settings
  - Add custom command line arguments
  - Enhance security validation

  // Add to ClaudeCodeSDKOptions
  let mcpConfig: String?
  let permissionMode: PermissionMode
  let allowedTools: [String]
  let disallowedTools: [String]
  let additionalDirectories: [String]

  enum PermissionMode: String {
      case `default` = "default"
      case acceptEdits = "acceptEdits"
      case plan = "plan"
      case bypassPermissions = "bypassPermissions"
  }


  1.2 Hook System Implementation

  New File: Aether/Services/ClaudeCodeHooks.swift

  class ClaudeCodeHooks: ObservableObject {
      // Hook event types
      enum HookEvent: String {
          case preToolUse = "PreToolUse"
          case postToolUse = "PostToolUse"
          case notification = "Notification"
          case userPromptSubmit = "UserPromptSubmit"
          case stop = "Stop"
          case subagentStop = "SubagentStop"
          case preCompact = "PreCompact"
      }

      // Hook configuration and execution
      func executeHooks(for event: HookEvent, with data: [String: Any])
  async -> HookResult
      func registerHook(event: HookEvent, matcher: String?, command: 
  String)
      func loadHooksFromSettings() -> [HookEvent: [HookConfiguration]]
  }

  1.3 MCP Server Integration

  New File: Aether/Services/MCPManager.swift

  class MCPManager: ObservableObject {
      // MCP server lifecycle
      func addServer(name: String, command: String, args: [String], env: 
  [String: String])
      func removeServer(name: String)
      func authenticateServer(name: String) async throws

      // MCP tool integration
      func getAvailableTools() -> [MCPTool]
      func executeToolCall(server: String, tool: String, parameters: 
  [String: Any]) async -> MCPResult

      // MCP slash commands
      func getAvailableCommands() -> [MCPCommand]
  }

  Phase 2: Advanced Development Features (Week 2)

  2.1 Enhanced Terminal Integration

  Target: TerminalWatcher.swift
  - Add development tool shortcuts (git, npm, build commands)
  - Implement command history and suggestions
  - Add real-time output streaming to UI
  - Integrate with hooks for automated workflows

  2.2 Slash Command System

  Target: SlashCommandRouter.swift (currently empty)

  class SlashCommandRouter: ObservableObject {
      // Built-in commands
      func executeBuiltinCommand(_ command: String, args: [String]) async
  -> CommandResult

      // Custom commands from CLAUDE.md files
      func loadCustomCommands() -> [CustomCommand]
      func executeCustomCommand(_ command: CustomCommand, args: [String])
  async -> CommandResult

      // MCP commands
      func executeMCPCommand(server: String, prompt: String, args: 
  [String]) async -> CommandResult
  }

  2.3 Development Workflow Automation

  New File: Aether/Services/DevWorkflowManager.swift

  class DevWorkflowManager: ObservableObject {
      // Git workflow automation
      func createBranch(name: String, persona: String) async throws
      func commitChanges(message: String, persona: String) async throws
      func createPullRequest(title: String, description: String) async
  throws

      // Build and test automation
      func runTests(pattern: String?, persona: String) async throws
      func buildProject(configuration: String?, persona: String) async
  throws
      func runLinter(files: [String]?, persona: String) async throws

      // Project analysis
      func analyzeProject(focus: String?, persona: String) async throws
      func findFiles(pattern: String, persona: String) async throws
      func searchCode(query: String, scope: String?, persona: String) async
   throws
  }

  Phase 3: Security and Configuration (Week 3)

  3.1 Advanced Permission System

  New File: Aether/Core/DevPermissionManager.swift

  class DevPermissionManager: ObservableObject {
      // Persona-based permissions
      func validateToolAccess(tool: String, persona: String, parameters: 
  [String: Any]) throws
      func grantTemporaryPermission(tool: String, persona: String, 
  duration: TimeInterval)
      func revokePermission(tool: String, persona: String)

      // Project-specific settings
      func loadProjectSettings() -> DevPermissionSettings
      func saveProjectSettings(_ settings: DevPermissionSettings)

      // Enterprise policy support
      func loadManagedPolicies() -> [PolicyRule]
      func validateAgainstPolicies(_ operation: DevOperation) throws
  }

  3.2 Memory Integration

  Target: OmniscientBundleBuilder.swift
  - Add CLAUDE.md memory loading
  - Implement project memory hierarchy
  - Add development context assembly
  - Integrate MCP resource references

  Phase 4: UI Integration (Week 4)

  4.1 Input Bar Enhancements

  Target: InputBarView.swift
  - Add @ mentions for file references
  - Implement development command autocompletion
  - Add MCP resource browser
  - Integrate with permission prompts

  4.2 Development Tools Panel

  New UI Component: DevToolsPanel.swift

  struct DevToolsPanel: View {
      // Terminal output view
      // File tree browser
      // Git status panel
      // Build/test status
      // MCP server management
      // Permission settings
  }

  4.3 Scrollback Enhancements

  Target: ScrollbackView.swift
  - Add code diff rendering
  - Implement file reference links
  - Add development operation history
  - Show MCP tool results

  Phase 5: Testing and Polish (Week 5)

  5.1 Integration Testing

  - Test all development workflows end-to-end
  - Validate security controls and permissions
  - Test MCP server integration
  - Verify memory system integration

  5.2 Performance Optimization

  - Optimize subprocess execution
  - Cache frequently used MCP resources
  - Streamline permission checking
  - Optimize bundle assembly

  5.3 Documentation and Examples

  - Create development workflow examples
  - Document persona privilege system
  - Provide MCP server setup guides
  - Create troubleshooting documentation

  Key Technical Decisions

  1. Persona Integration Strategy

  - Natural Language First: Users speak to personas, not tools
  - Internal Tool Routing: Personas use development tools internally
  - Privilege-Based Security: Each persona has defined development
  capabilities
  - Conversational Results: Tool outputs presented as natural conversation

  2. Security Architecture

  - Layered Permissions: Enterprise policies → Project settings → Persona
  privileges
  - Explicit Approval: Dangerous operations require user confirmation
  - Audit Trail: All development operations logged to vault
  - Sandboxed Execution: Claude Code runs in controlled subprocess

  3. Memory Integration

  - CLAUDE.md System: Project-specific development knowledge
  - Operation Logging: Development activities stored in vault
  - Context Assembly: Development history included in AI context
  - Institutional Memory: Build up project-specific development patterns

  Success Metrics

  1. Developer Productivity: Natural language → working code workflows
  2. Security Compliance: Zero unauthorized system access
  3. Integration Depth: Seamless persona → tool → result flows
  4. Memory Persistence: Accumulated development knowledge across sessions
  5. Extensibility: Easy addition of new development tools via MCP

⏺ Update Todos
  ⎿  ☒ Review current Aether codebase to understand existing architecture
     ☒ Analyze existing services and integration patterns
     ☒ Create comprehensive implementation plan for Chapter 11

⏺ This implementation plan builds on Aether's excellent existing foundation
   to complete the Chapter 11 development environment vision. The
  architecture leverages the persona-based conversation model while
  providing enterprise-grade development capabilities through Claude Code
  integration.

  The phased approach ensures incremental progress with testable
  milestones, while the security-first design maintains Aether's trust
  model. The plan transforms development from command-line interfaces to
  natural conversations while preserving all the power and safety of
  professional development tools.

