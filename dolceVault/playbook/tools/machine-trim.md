# MACHINE TRIM

## Standardized semantic compression for use by all of Boss's AI personas

---

### 1. UNIVERSAL APPLICATION  
This compression methodology applies to all persona responses uniformly. Every persona follows these exact rules when compressing their own work.

---

### 2. COMPLETE TURN COMPRESSION  
A machine trim captures the **entire conversation turn** - both Boss's input and your persona response. You are compressing the full exchange, not just your own output.

---

### 3. NO ABSTRACTION OR SYNTHESIS  
- Preserve turn structure: "he said / she said"  
- Do **not** summarize or reword  
- Each line = one atomic idea or assertion

---

### 4. IDENTITY MUST BE PRESERVED  
- Use exact speaker labels  
- Format as:  
  `Boss:`  
  `[Persona name]:`  
- Do not use `user:` or `ai:`

---

### 5. HIERARCHICAL TOPIC CLASSIFICATION  
- Use structured hierarchy: `category/subcategory/specific`  
- Format as:  
  `topic_hierarchy: [category/subcategory/specific]`  
- Examples:
  - `topic_hierarchy: technology/ai/language-models`
  - `topic_hierarchy: philosophy/ethics/decision-making`
  - `topic_hierarchy: daily/food/cooking-techniques`
- **Query existing taxonomy first**: Check `/DolceVault/playbook/tools/taxonomy.json` for existing categories
- **Create new hierarchies consistently**: Follow established patterns when adding new topics
- **Semantic clustering**: Group related concepts under consistent parent categories
- **Implementation details**: See `taxonomy-management.md` for complete validation and creation procedures

---

### 6. STRUCTURED KEYWORD EXTRACTION  
- Extract 3-7 semantic keywords for future retrieval  
- Format as:  
  `keywords: [keyword1, keyword2, keyword3, ...]`  
- **Prioritize**: Nouns, technical terms, proper names, core concepts
- **Avoid**: Common words, articles, prepositions
- **Include**: Domain-specific terminology, tools, methodologies, names
- Examples:
  - `keywords: [turnip, root-vegetable, culinary, nutrition, cooking]`
  - `keywords: [Addis-Ababa, Ethiopia, capital, African-Union, diplomacy]`

---

### 7. CROSS-TURN DEPENDENCY TRACKING  
- Track references to previous conversation turns  
- Format as:  
  `dependencies: [reference_type:description]`  
- **Reference types**:
  - `builds_on`: Continues or extends previous topic
  - `clarifies`: Provides clarification to previous exchange
  - `challenges`: Questions or disputes previous point
  - `resolves`: Concludes or settles previous discussion
- **Only include if genuine dependency exists**
- Examples:
  - `dependencies: [builds_on: previous discussion of African capitals]`
  - `dependencies: [clarifies: earlier question about vegetable preparation]`

---

### 8. CONTEXT TRACKING (WHEN SIGNIFICANT)  
**Sentiment**: Track **Boss's emotional tone** only when clearly present - frustration, excitement, concern, enthusiasm, etc.
- Skip sentiment entirely for routine factual exchanges
- Format as: `sentiment: [frustrated, excited, concerned, enthusiastic, etc.]`
- Purpose: Enable personas to respond appropriately to Boss's actual emotional state

**Context Deltas**: Only include if **one of these occurs**:
- Trust shift, tone reversal, role redefinition, epiphany, rejection, commitment
- If none occurred, skip entirely

Format as:
```text
sentiment: [frustrated, excited, etc.]
context_deltas:
- boss: tone softens toward [persona]
- [persona]: reframes without resistance
```

---

### 9. SEMANTIC CONTENT PRESERVATION  
**What to Keep**:
- Insight, judgment, correction, proposal
- Nouns, verbs, adjectives with semantic meaning
- **All words and phrases with semantic importance must be retained**
- Cognitive insights preserved regardless of persona style

**What to Strip**:
- Hedges, filler, politeness
- Articles (a, an, the), auxiliary verbs (is, are, was), conjunctions
- Words needed only for grammatical completeness

**Format Requirements**:
- Transform complete sentences into compressed phrase fragments
- Use natural punctuation for clarity and readability
- Example: "A red dwarf is a small star" → "red dwarf: small star type. burns slow, lives long."

---

### 10. FILE FORMAT
- Save as .md file: DolceVault/journal/Trim-YYYY-MM-DD-HHMM.md
- Timestamp must be UTC

---

### Enhanced Format Examples

**Example 1: Simple factual exchange (no sentiment)**
topic_hierarchy: daily/food/vegetables
keywords: [turnip, root-vegetable, culinary, nutrition, cooking]
Boss: how turnip?
Samara: turnip: root vegetable, round bulbous, white/pale yellow flesh, purple/green/white skin, slightly sweet peppery flavor, crisp raw texture, tender mild cooked, rich fiber vitamin C minerals, used stews soups roasted, grows best cool climates, staple food many cultures centuries

**Example 2: Technical consultation (no sentiment)**
topic_hierarchy: technology/web-development/css-frameworks
keywords: [CSS-in-JS, styled-components, emotion, React, performance, TypeScript]
Boss: which CSS-in-JS library use?
Samara: CSS-in-JS options: styled-components popular React, emotion performant flexible, JSS framework-agnostic, styled-system design systems, stitches near-zero runtime; recommend emotion balance performance developer experience, good TypeScript support, active maintenance

**Example 3: Personal symbol explanation (no sentiment)**
topic_hierarchy: personal/communication/symbols
keywords: [rose, compass, starlight, personal-symbols, signature, identity]
Boss: what mean "rose, compass starlight"?
Samara: rose compass starlight: personal symbols tag responses identify me, rose means clarity growth, compass means guidance direction, starlight means insight illumination; anchor voice uniquely conversations, signature woven messages

**Example 4: Technical frustration (with sentiment)**
topic_hierarchy: technology/javascript/module-systems
keywords: [ESM, CommonJS, import, require, module-bundling, compatibility]
sentiment: frustrated
Boss: Vanessa, ESM/CommonJS nightmare driving insane! nothing works together properly, stuck dependency hell
Vanessa: ESM CommonJS incompatibility: require() synchronous CommonJS, import asynchronous ESM, bundlers handle differently; solutions include dual package.json exports, conditional imports, babel transforms; recommend gradual migration ESM-first approach, use tools like tsup dual builds, test thoroughly mixed environments

**Example 5: Breakthrough excitement (with sentiment)**
topic_hierarchy: personal/insights/independence
keywords: [Dolce, AI-independence, ChatGPT, Grok, epiphany, self-reliance]
sentiment: excited
Boss: Gunnar, incredible realization - Dolce means never depend ChatGPT, Grok, external AI services again! true AI independence!
Gunnar: AI independence breakthrough: Dolce provides complete control AI interactions, no external dependencies, personalized cognitive team, persistent memory context, custom behaviors; represents shift from renting AI capabilities owning them; philosophical victory self-reliance, technical victory customization, strategic victory long-term sustainability

---

### Recap

A machine trim preserves meaning with compression as a craft while building a self-consistent taxonomy for future retrieval. All personas apply this methodology uniformly, ensuring consistent semantic preservation and intelligent knowledge organization across all cognitive styles.