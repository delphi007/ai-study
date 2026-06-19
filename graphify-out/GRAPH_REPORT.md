# Graph Report - ai-study  (2026-06-19)

## Corpus Check
- 8 files · ~590 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 132 nodes · 124 edges · 12 communities (8 shown, 4 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Community 0|Community 0]]
- [[_COMMUNITY_Community 1|Community 1]]
- [[_COMMUNITY_Community 2|Community 2]]
- [[_COMMUNITY_Community 3|Community 3]]
- [[_COMMUNITY_Community 4|Community 4]]
- [[_COMMUNITY_Community 5|Community 5]]
- [[_COMMUNITY_Community 6|Community 6]]
- [[_COMMUNITY_Community 7|Community 7]]
- [[_COMMUNITY_Community 8|Community 8]]
- [[_COMMUNITY_Community 9|Community 9]]
- [[_COMMUNITY_Community 10|Community 10]]
- [[_COMMUNITY_Community 11|Community 11]]

## God Nodes (most connected - your core abstractions)
1. `stageRuntimeControl` - 9 edges
2. `stages` - 9 edges
3. `publicSurface` - 5 edges
4. `publicSurface` - 5 edges
5. `languageResolution` - 3 edges
6. `critical` - 3 edges
7. `fetch` - 3 edges
8. `thinking` - 3 edges
9. `execution` - 3 edges
10. `review` - 3 edges

## Surprising Connections (you probably didn't know these)
- None detected - all connections are within the same source files.

## Communities (12 total, 4 thin omitted)

### Community 0 - "Community 0"
Cohesion: 0.08
Nodes (25): completedAt, status, completedAt, status, completedAt, status, completedAt, status (+17 more)

### Community 1 - "Community 1"
Cohesion: 0.08
Nodes (23): active, blockedOn, completed, currentStage, currentStageKey, languageResolution, language, source (+15 more)

### Community 2 - "Community 2"
Cohesion: 0.08
Nodes (23): active, blockedOn, completed, currentStage, currentStageKey, languageResolution, language, source (+15 more)

### Community 3 - "Community 3"
Cohesion: 0.08
Nodes (23): active, choiceSurfaceState, controlState, criticalFetchLoopCount, criticalFetchLoopMax, currentStage, dispatchChain, dispatchedAgents (+15 more)

### Community 4 - "Community 4"
Cohesion: 0.22
Nodes (9): stageRuntimeControl, activationMode, createdAt, driverMode, executionLeasePolicy, factGatePolicy, hookGateMode, promptFingerprint (+1 more)

### Community 5 - "Community 5"
Cohesion: 0.33
Nodes (5): mode, scriptMtimeMs, startedAt, status, updatedAt

### Community 6 - "Community 6"
Cohesion: 0.4
Nodes (5): publicSurface, hiddenInternalFields, nativeEnhancementAllowed, popupRequired, primaryDisplay

### Community 7 - "Community 7"
Cohesion: 0.4
Nodes (5): publicSurface, hiddenInternalFields, nativeEnhancementAllowed, popupRequired, primaryDisplay

## Knowledge Gaps
- **108 isolated node(s):** `PreToolUse`, `PreToolUse`, `schemaVersion`, `active`, `runId` (+103 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **4 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `stages` connect `Community 0` to `Community 3`?**
  _High betweenness centrality (0.123) - this node is a cross-community bridge._
- **Why does `stageRuntimeControl` connect `Community 4` to `Community 3`?**
  _High betweenness centrality (0.049) - this node is a cross-community bridge._
- **What connects `PreToolUse`, `PreToolUse`, `schemaVersion` to the rest of the system?**
  _108 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Community 0` be split into smaller, more focused modules?**
  _Cohesion score 0.08 - nodes in this community are weakly interconnected._
- **Should `Community 1` be split into smaller, more focused modules?**
  _Cohesion score 0.08 - nodes in this community are weakly interconnected._
- **Should `Community 2` be split into smaller, more focused modules?**
  _Cohesion score 0.08 - nodes in this community are weakly interconnected._
- **Should `Community 3` be split into smaller, more focused modules?**
  _Cohesion score 0.08 - nodes in this community are weakly interconnected._