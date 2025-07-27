# Design Policies

- **Do this! Enforce separation of concern**: Assign distinct responsibilities to each component (e.g., **InputBarView.swift** for UI input, **OmniscientBundleBuilder.swift** for memory assembly) to avoid overlap and maintain clarity.
- **Do this! Implement modularity**: Structure code into independent, reusable modules (e.g., **LLMManager.swift** for orchestration, **TaxonomyManager.swift** for taxonomy) with clear interfaces, enabling easy updates or replacements.
- **Do this! Avoid hardcoding**: Store all constants (e.g., vault paths in **VaultConfig.swift**, API keys via **EnvFileParser.swift**, UI styles in **DesignTokens.json**) in configurable files, ensuring flexibility across environments.
- **Do this! Eliminate redundancy**: Remove duplicate logic (e.g., consolidate HTTP handling in **HTTPRequestBuilder.swift**, response parsing in **LLMResponseParser.swift**) to streamline code and reduce maintenance overhead.
- **Do this! Provide clear documentation**: Include detailed comments in every file (e.g., **ScrollbackView.swift**, **machine-trim.md**) explaining purpose, usage, and edge cases, ensuring readability and maintainability for all developers.