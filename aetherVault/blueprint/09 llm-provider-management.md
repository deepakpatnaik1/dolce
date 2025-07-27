# LLM Provider Management

Aether supports multiple Large Language Model (LLM) providers through a unified routing system that ensures reliable AI responses regardless of individual service availability. The system automatically manages provider selection, handles failures gracefully, and maintains service health monitoring for optimal performance.

**Provider Support (ProviderRouter.swift, LLMConfiguration.swift)**:
- [x] **Fireworks AI**: High-performance LLaMA models with 1M token context support for comprehensive memory integration via **FireworksService.swift**
- [ ] **Anthropic Claude**: Real-time collaboration with Claude personas, context compression for ~200K token limits via **ClaudeService.swift**
- [x] **OpenAI**: GPT model access with configurable model selection via **OpenAIService.swift**
- [ ] **Local LLaMA**: Offline, privacy-focused alternative for cost-sensitive or secure environments via **LlamaService.swift**

**Automatic Failover (ProviderRouter.swift)**:
- [ ] **Priority-Based Routing**: Configurable provider priority through **LLMProviders.json**, automatically attempting the next available provider when the primary fails
- [ ] **Health Checking**: Real-time service availability monitoring with automatic routing around failed providers
- [ ] **Graceful Degradation**: Seamless fallback to alternative providers without interrupting conversations or losing context

**Configuration Management (LLMConfiguration.js, EnvFileParser.swift)**:
- [ ] **External Configuration**: Provider settings, model preferences, and routing rules defined in **LLMProviders.json** for runtime updates without code changes
- [x] **API Key Management**: Secure credential handling via **EnvFileParser.swift** from a single project .env file with intelligent path resolution
- [ ] **Model Selection**: Per-provider model configuration allowing fine-tuned control over which specific models handle requests

**Service Integration (HTTPRequestBuilder.swift, LLMResponseParser.swift)**:
- [ ] **Unified Request Handling**: Consistent HTTP request construction across all providers via **HTTPRequestBuilder.swift**, eliminating duplicate authentication and content-type logic
- [ ] **Response Standardization**: Uniform JSON response parsing via **LLMResponseParser.swift** ensuring reliable content extraction regardless of provider-specific response formats
- [ ] **Streaming Support**: Handles both streaming and non-streaming responses across all providers for flexible interaction modes

**Provider-Specific Capabilities**:
- [ ] **Context Length Optimization**: Automatically selects providers based on context requirements (1M tokens for Fireworks, 200K for Claude, standard limits for others)
- [ ] **Cost Management**: Routes to local LLaMA for cost-sensitive operations while maintaining cloud providers for complex tasks
- [ ] **Privacy Controls**: Offline-only routing option via local LLaMA for sensitive conversations requiring data locality

**System Health Monitoring (SystemHealthIndicator.swift)**:
- [ ] **Real-Time Status**: Green light indicator in **InputBarView.swift** shows when at least one provider is operational, with tooltip displaying active services
- [ ] **Service Discovery**: Automatic detection of available providers and their operational status
- [ ] **Graceful Handling**: Input bar remains functional even when no LLM services are available, allowing message composition and local operations

**Slash Command Integration (SlashCommandRouter.swift)**:
- [ ] **Dynamic Provider Switching**: Commands like /model fireworks, /model claude, /model openai, /model llama allow runtime provider selection
- [ ] **Configurable Commands**: Provider switching commands defined in **SlashCommands.json** for customizable workflows

The LLM provider management system ensures Aether maintains reliable AI capabilities across diverse infrastructure environments, from high-performance cloud services to privacy-focused local deployments, with automatic adaptation to changing service availability.