# Deep Research Configuration

## Core Settings

```yaml
research_defaults:
  planning_strategy: unified
  max_hops: 5
  confidence_threshold: 0.7
  memory_enabled: true
  parallel_first: true  # MANDATORY
  sequential_override_requires_justification: true

parallel_execution_rules:
  DEFAULT_MODE: PARALLEL  # CRITICAL

  mandatory_parallel:
    - Multiple search queries
    - Batch URL extractions
    - Independent analyses
    - Non-dependent hops

  sequential_only_if:
    - Explicit dependency (Hop N requires N-1)
    - Resource constraint (rate limits)
    - User debugging request

  batch_sizes:
    searches: 5
    extractions: 3
    analyses: 2

hop_configuration:
  max_depth: 5
  timeout_per_hop: 60s
  parallel_hops: true
  loop_detection: true

confidence_scoring:
  weights: {relevance: 0.5, completeness: 0.5}
  thresholds: {min: 0.6, target: 0.8}

self_reflection:
  frequency: after_each_hop
  triggers: [confidence_below_threshold, contradictions_detected, time_elapsed_80pct]

tool_coordination:
  discovery_primary: tavily
  extraction_smart_routing: true
  reasoning_engine: sequential
  memory_backend: serena
  parallel_tool_calls: true
```

## Strategy Selection

```yaml
planning_only: {clarity: high, execution: immediate}
intent_planning: {clarity: low, max_questions: 3, execution: after_clarification}
unified: {clarity: variable, user_feedback: true, execution: after_confirmation}
```

## Source Credibility

```yaml
tier_1: {score: 0.9-1.0, types: [academic, government, official_docs]}
tier_2: {score: 0.7-0.9, types: [established_media, industry_reports, expert_blogs]}
tier_3: {score: 0.5-0.7, types: [community, verified_social, wikipedia]}
tier_4: {score: 0.3-0.5, types: [forums, unverified_social, personal_blogs]}
```

## Depth Profiles

```yaml
quick: {sources: 10, hops: 1, time: 2min, confidence: 0.6, extract: tavily_only}
standard: {sources: 20, hops: 3, time: 5min, confidence: 0.7, extract: selective}
deep: {sources: 40, hops: 4, time: 8min, confidence: 0.8, extract: comprehensive}
exhaustive: {sources: 50+, hops: 5, time: 10min, confidence: 0.9, extract: all_sources}
```

## Extraction Routing

```yaml
use_tavily: [static_html, simple_structure, public_access]
use_playwright: [javascript_required, dynamic_content, auth_needed, screenshots]
use_context7: [technical_docs, api_refs, framework_guides]
use_native: [local_files, simple_explanations, code_generation]
```

## Replanning Thresholds

```yaml
confidence: {critical: <0.4, low: <0.6, acceptable: 0.6-0.7, good: >0.7}
time: {warning: 70%, critical: 90%}
quality: {min_sources: 3, max_contradictions: 30%, max_gaps: 50%}
```

## Performance Limits

```yaml
caching:
  tavily_results: 1h
  playwright_extractions: 24h
  sequential_analysis: 1h

resource_limits:
  max_research_time: 10min
  max_search_iterations: 10
  max_memory: 100MB
```

## MCP Integration

```yaml
tavily: {role: primary_search, fallback: native_websearch}
playwright: {role: complex_extraction, fallback: tavily_extraction}
sequential: {role: reasoning_engine, fallback: native_reasoning}
context7: {role: technical_docs, fallback: tavily_search}
serena: {role: memory_management, fallback: session_only}
```

## Error Handling

```yaml
tavily: {api_key_missing: check_env, rate_limit: exponential_backoff, no_results: expand_terms}
playwright: {timeout: skip_or_increase, nav_failed: mark_inaccessible, screenshot_failed: continue}
quality: {low_confidence: replan, contradictions: seek_more, insufficient: expand_scope}
```
