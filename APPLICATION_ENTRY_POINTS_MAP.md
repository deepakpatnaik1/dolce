# Aether Application Entry Points and Control Flow Map

## Primary Entry Point

### 1. `aetherApp.swift` - Main Application Entry
```swift
@main
struct aetherApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```
**Role**: SwiftUI application bootstrap
**Flow**: Launches directly into `ContentView()`

---

## Primary UI Layer

### 2. `ContentView.swift` - Root View Controller
**Entry**: Called by `aetherApp.swift`
**Responsibilities**:
- Initializes all core services and state managers
- Sets up primary UI structure (ZStack with background, ScrollbackView, InputBarView)
- Handles app-level drag & drop functionality
- Manages app lifecycle and state restoration

**Key Service Initializations**:
```swift
@StateObject private var messageStore = MessageStore()
@StateObject private var conversationOrchestrator: ConversationOrchestrator
@StateObject private var fileDropHandler = FileDropHandler()
@StateObject private var inputBarCoordinator: InputBarCoordinator
```

**Control Flow from ContentView**:
1. **UI Components**:
   - `ScrollbackView(messages: messageStore.messages)` - Message display
   - `InputBarView(fileDropHandler: fileDropHandler, coordinator: inputBarCoordinator)` - User input
   - `DragDropZone()` - File drop overlay

2. **State Restoration**:
   - `restorePersistedState()` - Restores persona and memory state
   - Uses `VaultStateManager.shared.loadCurrentPersona()`
   - Uses `PersonaSessionManager.shared.setCurrentPersona()`

---

## Core Orchestration Layer

### 3. `ConversationOrchestrator.swift` - Main Conversation Controller
**Entry**: Initialized in `ContentView`
**Responsibilities**:
- Orchestrates AI conversation flow
- Manages message routing to AI services
- Handles both memory-enabled and legacy conversation flows
- Coordinates with APIClient and ResponseParser

**Key Methods**:
- `sendMessage()` - Standard message sending
- `sendMessageWithAttachments()` - File-attached messages
- `getAIResponse()` - Routes to memory system or direct API

**Control Flow**:
```
User Input → InputBarCoordinator → ConversationOrchestrator
                                 ↓
                    [Memory System Check]
                                 ↓
           MemoryOrchestrator  OR  Direct API Call
                     ↓                     ↓
              Memory Processing    HTTPExecutor → ResponseParser
                     ↓                     ↓
                 MessageStore ← ← ← ← ← Response
```

### 4. `InputBarCoordinator.swift` - Input Processing Controller  
**Entry**: Initialized in `ContentView`, used by `InputBarView`
**Responsibilities**:
- Processes user input and commands
- Handles file selection and validation
- Manages persona detection and model switching
- Coordinates keyboard commands and special modes (journal, turn mode)

**Key Processing Flow**:
1. **Text Input**: `handleTextChange()` → Persona detection → Model switching
2. **Send Action**: `handleSendAction()` → Message composition → `ConversationOrchestrator.sendMessageWithAttachments()`
3. **File Picking**: `handleFilePickAction()` → File validation → FileDropHandler
4. **Commands**: Slash commands (/journal, /delete) and keyboard shortcuts

---

## State Management Layer

### 5. `MessageStore.swift` - Message State Manager
**Entry**: Initialized in `ContentView`
**Responsibilities**:
- Maintains @Published messages array for SwiftUI
- Handles message persistence (when memory system enabled)
- Provides message CRUD operations
- Manages streaming message updates

### 6. Shared Managers (Singletons)
**Entry**: Accessed via `.shared` throughout application

- **`RuntimeModelManager.shared`** - AI model selection state
- **`PersonaSessionManager.shared`** - Current persona state  
- **`MemoryOrchestrator.shared`** - Memory system coordination
- **`TurnManager.shared`** - Turn mode navigation state

---

## Service Layers

### 7. Memory System Services (Optional)
**Entry**: Via `MemoryOrchestrator` when `AppConfigurationLoader.isMemorySystemEnabled`

**Flow**:
```
MemoryOrchestrator → JournalManager → VaultReader/VaultWriter
                  → LLMProviderFactory → Provider Services (Anthropic/OpenAI/Fireworks)
                  → TaxonomyEvolver → VaultStateManager
```

### 8. Direct API Services (Legacy/Fallback)
**Entry**: Via `ConversationOrchestrator` when memory system disabled

**Flow**:
```
ConversationOrchestrator → APIConfigurationProvider → HTTPExecutor → ResponseParser
```

### 9. File Processing Services
**Entry**: Via `InputBarCoordinator` and `FileDropHandler`

**Services**:
- `FilePickerService` - File selection UI
- `FileValidator` - File type/size validation  
- `FileReader` - Content extraction and preview generation

---

## Configuration and Bootstrap

### 10. Configuration Loaders
**Entry**: Called during app initialization and throughout lifecycle

- **`AppConfigurationLoader`** - Feature flags and memory system config
- **`APIConfigurationProvider`** - AI service credentials and endpoints
- **`PersonaMappingLoader`** - Persona-to-model mappings
- **`VaultPathProvider`** - File system paths for persistence

---

## Control Flow Summary

### Primary Message Flow:
```
User Input → InputBarView → InputBarCoordinator → ConversationOrchestrator
                                                         ↓
                                              [Memory System Check]
                                                         ↓
                                   MemoryOrchestrator OR Direct API
                                                         ↓
                                                  MessageStore
                                                         ↓
                                                  ScrollbackView (UI Update)
```

### File Handling Flow:
```
File Drop/Pick → FileDropHandler → FileValidator → FileReader → DroppedFile
                                                                      ↓
                                                              InputBarCoordinator
                                                                      ↓
                                                          MessageComposer.compose()
                                                                      ↓
                                                          ConversationOrchestrator
```

### Persona/Model Switching Flow:
```
Text Input → PersonaDetector → PersonaSessionManager → RuntimeModelManager
                                        ↓
                                PersonaMappingLoader (get default model)
                                        ↓
                              Model Selection Update (with provider prefix)
```

This architecture follows a clear separation of concerns with:
- **Entry Point**: `aetherApp.swift` → `ContentView.swift`
- **Orchestration**: `ConversationOrchestrator`, `InputBarCoordinator`  
- **State**: `MessageStore`, Shared Managers
- **Services**: Memory System, API Services, File Services
- **Configuration**: Various configuration loaders and providers
