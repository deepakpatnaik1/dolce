# TAXONOMY MANAGEMENT

## Self-Consistent Tag Taxonomy System

This document defines how to build and maintain a living, self-consistent taxonomy for Aether's journal system.

---

### Core Principles

**Living Taxonomy**: The taxonomy evolves naturally from conversation patterns while maintaining semantic consistency.

**Self-Organizing**: Tags automatically cluster into hierarchies without manual intervention.

**Validation-Driven**: New tags must fit existing patterns and pass consistency checks.

---

### Taxonomy Structure

**Storage Location**: `/AetherVault/playbook/tools/taxonomy.json`

**Hierarchical Format**:
```json
{
  "topics": {
    "technology": {
      "ai": ["language-models", "training", "inference"],
      "development": ["architecture", "debugging", "testing"]
    },
    "philosophy": {
      "ethics": ["decision-making", "responsibility", "consequences"],
      "epistemology": ["knowledge", "belief", "truth"]
    },
    "daily": {
      "food": ["cooking", "nutrition", "ingredients"],
      "health": ["exercise", "wellness", "medical"]
    }
  },
  "relationships": ["boss-persona", "tone-shift", "trust-building", "conflict-resolution"],
  "contexts": ["project-planning", "problem-solving", "knowledge-sharing", "decision-making"],
  "dependencies": ["builds_on", "clarifies", "challenges", "resolves"]
}
```

---

### Pre-Trim Validation Process

**Before creating any trim:**

1. **Query Existing Taxonomy**: Check `/AetherVault/playbook/tools/taxonomy.json` for existing categories
2. **Semantic Matching**: Find closest existing category for topic hierarchy
3. **Pattern Validation**: Ensure new hierarchies follow established patterns
4. **Consistency Check**: Verify no near-duplicate categories exist
5. **Cluster Assignment**: Group related concepts under consistent parent categories

---

### New Category Creation Rules

**Semantic Consistency**:
- Use consistent naming conventions (lowercase, hyphenated for compound terms)
- Group related concepts under logical parent categories
- Maintain semantic distance between categories

**Hierarchy Depth**:
- Maximum 3 levels: `category/subcategory/specific`
- Avoid over-granular subcategories that fragment the taxonomy
- Prefer broader categories that can encompass related concepts

**Duplication Prevention**:
- Don't create near-duplicates (e.g., "technology" and "tech")
- Check for semantic overlap before creating new categories
- Merge concepts into existing categories when possible

---

### Taxonomy Evolution Process

**Natural Growth**:
- New categories emerge from actual conversation patterns
- Hierarchies deepen as topics become more specific
- Related concepts naturally cluster under semantic parents

**Maintenance Operations**:
- **Merge**: Combine semantically similar categories
- **Split**: Divide overly broad categories when needed
- **Restructure**: Reorganize hierarchies for better semantic grouping
- **Prune**: Remove unused or redundant categories

---

### Tag Validation Algorithm

**For Topic Hierarchies**:
1. Check if exact category exists
2. Find semantic parent category
3. Validate naming consistency
4. Ensure proper hierarchy depth
5. Create new category if needed

**For Keywords**:
1. Normalize to lowercase, hyphenated format
2. Check for semantic duplicates
3. Validate against existing keyword patterns
4. Add to appropriate category context

**For Relationships**:
1. Validate against existing relationship patterns
2. Ensure consistent speaker labeling
3. Check for semantic coherence with context

---

### Implementation Guidelines

**Backwards Compatibility**:
- Existing trims remain valid during taxonomy evolution
- New validation rules apply only to future trims
- Migration tools handle historical data updates

**Error Handling**:
- Graceful degradation when tools/taxonomy.json is missing
- Default categories for essential topic areas
- Validation warnings for inconsistent tags

**Performance Optimization**:
- Cache taxonomy in memory for fast lookups
- Batch validation for multiple trims
- Incremental updates for taxonomy changes

---

### Quality Metrics

**Consistency Score**:
- Measure semantic coherence across categories
- Track duplicate/near-duplicate detection
- Monitor hierarchy depth distribution

**Coverage Analysis**:
- Identify gaps in topic coverage
- Track category usage frequency
- Optimize taxonomy structure based on actual usage

**Evolution Tracking**:
- Log taxonomy changes over time
- Monitor category creation/deletion patterns
- Analyze semantic drift in conversation topics

---

### Recap

The taxonomy management system ensures Aether's journal maintains a living, self-consistent organization that grows intelligently with conversation history. Through structured validation and natural evolution, the taxonomy enables precise semantic retrieval while preserving the coherent knowledge architecture necessary for omniscient persona context.