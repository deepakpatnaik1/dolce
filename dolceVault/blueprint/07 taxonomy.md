# Taxonomy

The **taxonomy system** in Dolce is a living, self-consistent framework that organizes and evolves conversation data into a structured, searchable knowledge base. It is central to the memory cycle, enabling semantic retrieval and context preservation across interactions. Managed by **TaxonomyManager.swift** and defined in **taxonomy.json**, **taxonomy-management.md**, and **instructions-to-llm.md**, the system integrates with **OmniscientBundleBuilder.swift**, **ContextMemoryIndex.swift**, and the machine trim process (**machine-trim.md**). Below is a comprehensive explanation.

**Structure and Storage**:
- [x] **Location**: Stored in `/DolceVault/playbook/tools/taxonomy.json`, a JSON file containing hierarchical topics, relationships, contexts, and dependencies.
- [x] **Format**:
  - [x] `"topics"`: Nested hierarchy with up to three levels (e.g., `technology/ai/language-models`).
    - [x] Example: `"daily/food/vegetables"`, `"technology/web-development/css-frameworks"`.
  - [x] `"relationships"`: Predefined types (e.g., `boss-persona`, `tone-shift`, `trust-building`, `conflict-resolution`).
  - [x] `"contexts"`: Broad categories (e.g., `project-planning`, `problem-solving`, `knowledge-sharing`, `decision-making`).
  - [x] `"dependencies"`: Reference types (e.g., `builds_on`, `clarifies`, `challenges`, `resolves`).
- [x] **Example from taxonomy.json**:
  ```json
  {
    "topics": {
      "daily": {"subcategories": {"food": ["vegetables", "cooking", "nutrition"]}},
      "technology": {"subcategories": {"ai": ["language-models"], "web-development": ["css-frameworks"]}}
    },
    "relationships": ["boss-persona", "tone-shift"],
    "contexts": ["project-planning"],
    "dependencies": ["builds_on"]
  }
  ```

**Core Principles (taxonomy-management.md)**:
- [x] **Living Taxonomy**: Evolves naturally from conversation patterns while maintaining semantic consistency.
- [x] **Self-Organizing**: Automatically clusters related concepts without manual intervention.
- [x] **Validation-Driven**: New tags must align with existing patterns and pass consistency checks.

**Pre-Trim Validation Process (taxonomy-management.md)**:
- [x] Before creating a trim, **TaxonomyManager.swift**:
  - [x] Queries existing `taxonomy.json` for matching categories.
  - [x] Identifies the closest semantic parent.
  - [x] Validates naming (lowercase, hyphenated) and hierarchy depth (max 3 levels).
  - [x] Checks for near-duplicates and merges or rejects as needed.
  - [x] Assigns related concepts to consistent parent categories.

**New Category Creation Rules (taxonomy-management.md)**:
- [x] **Semantic Consistency**: Uses uniform naming (e.g., `technology-ai-language-models`) and logical grouping.
- [x] **Hierarchy Depth**: Limits to three levels, avoiding over-granular subcategories.
- [x] **Duplication Prevention**: Avoids near-duplicates (e.g., `tech` vs. `technology`) and merges overlapping concepts.

**Taxonomy Evolution Process (taxonomy-management.md)**:
- [x] **Natural Growth**: New categories emerge from dialogue, deepening hierarchies as topics specialize.
- [x] **Maintenance**: Supports merging, splitting, restructuring, or pruning categories based on usage.
- [x] **Implementation**: **TaxonomyManager.swift** methods like `validateTopicHierarchy()`, `addToTaxonomy()`, and `getTaxonomyContext()` handle evolution, with real-time updates during the memory cycle.

**Integration with Memory Cycle (instructions-to-llm.md, machine-trim.md)**:
- [x] **Step 1: Taxonomy Analysis**: **LLMManager.swift**, guided by **instructions-to-llm.md**, analyzes each turn for topic hierarchy, keywords, and dependencies. The LLM follows **taxonomy-management.md** rules to propose new categories or validate existing ones.
- [x] **Step 3: Machine Compression**: The LLM applies **machine-trim.md** rules to compress the turn, embedding metadata (e.g., `topic_hierarchy: technology/web-development/css-frameworks`, `keywords: [CSS-in-JS, React]`). **VaultWriter.swift** saves this as `Trim-YYYY-MM-DD-HHMM.md` in `journal/`, updating `taxonomy.json`.
- [x] **Real-Time Integration**: **OmniscientBundleBuilder.swift** includes the updated taxonomy in the next bundle, while **ContextMemoryIndex.swift** enables retrieval by topics, keywords, or dependencies.

**Tag Validation Algorithm (taxonomy-management.md)**:
- [x] **Topic Hierarchies**: Checks exact matches, validates naming, and creates new categories if consistent.
- [x] **Keywords**: Normalizes to lowercase, hyphenated format, and checks for duplicates.
- [x] **Emotion context**: Validates against predefined patterns and ensures coherence with context.

**Quality Metrics (taxonomy-management.md)**:
- [ ] **Consistency Score**: Tracks semantic coherence and duplicate detection.
- [ ] **Coverage Analysis**: Identifies gaps and optimizes based on usage frequency.
- [ ] **Evolution Tracking**: Logs changes to monitor growth and semantic drift.

**Implementation Guidelines (taxonomy-management.md)**:
- [x] **Backwards Compatibility**: Existing trims remain valid; new rules apply to future data.
- [x] **Error Handling**: Defaults to basic categories if `taxonomy.json` is missing.
- [ ] **Performance**: Caches taxonomy in memory and batches validations.

**User Interaction**:
- [x] The taxonomy supports retrieval in **ScrollbackView.swift** (e.g., `getJournalEntriesByTopic()`), reflecting evolved categories without manual input. The new **purge** feature (**VaultDeleter.swift**) can remove specific taxonomy entries via natural language or slash commands.

**Summary**:
Dolce's taxonomy system, managed by **TaxonomyManager.swift** and defined in **taxonomy.json**, **taxonomy-management.md**, and **instructions-to-llm.md**, is a dynamic, self-organizing structure that evolves with conversation patterns. It validates and integrates new categories during the memory cycle (**LLMManager.swift**, **VaultWriter.swift**), ensuring a coherent knowledge architecture for semantic retrieval across **ContextMemoryIndex.swift** and **OmniscientBundleBuilder.swift**.