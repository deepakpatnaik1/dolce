# Machine Trim

The **machine trim** feature in Aether is a standardized semantic compression process applied to every conversation turn, designed to preserve meaning while building a self-consistent, searchable knowledge base. Defined in the **machine-trim.md** document, it is executed uniformly by all AI personas as part of the memory cycle, guided by the triple-task instructions in **instructions-to-llm.md**. Below is a detailed explanation of the feature, including its rules and execution process.

**Purpose and Overview**:
- [x] Machine trim compresses the entire conversation turn (Boss's input and the persona's response) into a concise, semantically rich format, saved as `Trim-YYYY-MM-DD-HHMM.md` in the `AetherVault/journal/` folder with UTC timestamps.
- [x] It integrates with **TaxonomyManager.swift** to evolve the living `taxonomy.json`, enabling future retrieval by topics, keywords, and dependencies, as managed by **OmniscientBundleBuilder.swift** and **ContextMemoryIndex.swift**.

**Rules from machine-trim.md**:

- [x] **Universal Application**:
  - [x] All personas apply the same compression methodology, ensuring consistency across cognitive styles.

- [x] **Complete Turn Compression**:
  - [x] Captures the full exchange (Boss's input and persona response), not just the persona's output.

- [x] **No Abstraction or Synthesis**:
  - [x] Preserves the "he said / she said" turn structure.
  - [x] Avoids summarizing or rewording; each line represents one atomic idea or assertion.

- [x] **Identity Preservation**:
  - [x] Uses exact speaker labels: `Boss:` and `[Persona name]:` (e.g., `Samara:`), avoiding generic terms like `user:` or `ai:`.

- [x] **Hierarchical Topic Classification**:
  - [x] Employs a structured hierarchy: `category/subcategory/specific` (e.g., `daily/food/vegetables`).
  - [x] Requires checking existing `taxonomy.json` in `/AetherVault/playbook/tools/` and following patterns in **taxonomy-management.md** for new hierarchies.
  - [x] Ensures semantic clustering under consistent parent categories.

- [x] **Structured Keyword Extraction**:
  - [x] Extracts 3-7 semantic keywords (e.g., `[turnip, root-vegetable, culinary]`), prioritizing nouns, technical terms, proper names, and core concepts while excluding common words and articles.

- [x] **Cross-Turn Dependency Tracking**:
  - [x] Tracks references to prior turns with formats like `dependencies: [builds_on: previous discussion]` (e.g., `builds_on`, `clarifies`, `challenges`, `resolves`), included only when relevant.

- [x] **Context Tracking (When Significant)**:
  - [x] Records Boss's emotional sentiment (e.g., `sentiment: frustrated`) only when clearly present (frustration, excitement, etc.), skipped for routine exchanges.
  - Notes context deltas (e.g., trust shifts, epiphanies) only if significant, formatted as:
    ```text
    sentiment: [frustrated]
    context_deltas:
    - boss: tone softens toward [persona]
    ```

- [x] **Semantic Content Preservation**:
  - [x] **Keeps**: Insights, judgments, nouns, verbs, and adjectives with meaning; cognitive insights regardless of persona style.
  - [x] **Strips**: Hedges, fillers, articles (a, an, the), auxiliary verbs, and grammatically redundant words.
  - [x] Transforms sentences into phrase fragments with natural punctuation (e.g., "A red dwarf is a small star" → "red dwarf: small star type. burns slow, lives long").

- [x] **Markdown Format**:
  - [x] Saved as `Trim-YYYY-MM-DD-HHMM.md` in `AetherVault/journal/` with UTC timestamps.

**Execution Process**:
- [x] **Triggered by Instructions-to-LLM.md**: During the memory cycle, **LLMManager.swift** uses **OmniscientBundleBuilder.swift** to send the conversation turn to the LLM with **instructions-to-llm.md**, which mandates three tasks:
  - [x] **Taxonomy Analysis**: The LLM analyzes the turn, extracting hierarchy, keywords, and dependencies per Step 1.
  - [x] **Authentic Response**: The persona provides a natural, full-personality response per Step 2.
  - [x] **Machine Compression**: The LLM applies the machine trim rules from Step 3, compressing the turn with metadata from Step 1.
- [x] **Response Format**: The LLM returns:
  ```
  ---TAXONOMY_ANALYSIS---
  [Hierarchy, keywords, dependencies]
  ---MAIN_RESPONSE---
  [Persona's authentic response]
  ---MACHINE_TRIM---
  [Compressed turn with metadata]
  ```
- [x] **Integration**: **VaultWriter.swift** saves the `MACHINE_TRIM` section to `journal/`, updates `taxonomy.json` via **TaxonomyManager.swift**, and logs the full turn to `superjournal/` via `autoSaveTurn()`. **ContextMemoryIndex.swift** ensures the compressed data is available for future bundles.

**Examples from machine-trim.md**:
- [x] **Factual Exchange**: `topic_hierarchy: daily/food/vegetables`, `keywords: [turnip, root-vegetable]`, preserves exact dialogue without abstraction.
- [x] **Emotional Exchange**: `sentiment: frustrated`, includes context deltas for tone shifts, maintaining semantic intent.

**Summary**:
The machine trim feature standardizes compression across all personas, preserving turn structure and semantic meaning while building a dynamic taxonomy. Executed as the third step in the LLM's triple-task process (**instructions-to-llm.md**), it ensures Aether's memory grows intelligently, integrated by **VaultWriter.swift** and **TaxonomyManager.swift** into the memory cycle.