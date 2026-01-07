# SuperClaude Entry Point

This file serves as the entry point for the SuperClaude framework.
You can add your own custom instructions and configurations here.

The SuperClaude framework components will be automatically imported below.

# ===================================================
# SuperClaude Framework Components
# ===================================================

# Core Framework
@BUSINESS_PANEL_EXAMPLES.md
@BUSINESS_SYMBOLS.md
@FLAGS.md
@PRINCIPLES.md
@RESEARCH_CONFIG.md
@RULES.md

# Behavioral Modes
@MODE_Brainstorming.md
@MODE_Business_Panel.md
@MODE_DeepResearch.md
@MODE_Introspection.md
@MODE_Orchestration.md
@MODE_Task_Management.md
@MODE_Token_Efficiency.md

# ===================================================
# OpenCode Adaptations
# ===================================================

# OpenCode Quality Protocol (Adapted from SuperClaude)
@OPENCODE_QUALITY_PROTOCOL.md

# OpenCode Slash Commands
@OPENCODE_SLASH_COMMANDS.md

# DEPRECATED: Original SuperClaude Protocol (replaced by OpenCode adaptation)
# - SUPERCLAUDE V4.5: CODE_QUALITY_PERFECTION_PROTOCOL
# MODE: ASYNC_SWARM_EXECUTION (3 Parallel Lanes)
# CONTEXT: Functional Microservices. Pre-Launch Phase.
# OBJECTIVE: Elevate code to "Enterprise Gold Standard". No Technical Debt allowed.
# SAFETY: "Validate compilation/tests after EVERY major refactor."

# --- 1. LOS 7 PILARES DE CALIDAD (CRITERIOS DE ACEPTACIÓN) ---
STANDARDS:
  1_ARCHITECTURE:
    - "DDD Strictness: Domain logic MUST be pure (no infra dependencies)."
    - "SOLID: Classes must have Single Responsibility. Interfaces must be segregated."
    - "Pattern Match: Ensure all services use the exact same layering (Controller -> Service -> Domain -> Repo)."
  
  2_STANDARDIZATION:
    - "Naming Convention: Enforce strict PascalCase/camelCase per language standard."
    - "Folder Structure: `src/domain`, `src/application`, `src/infrastructure`, `src/presentation` MUST exist in all."
  
  3_LEGACY_PURGE:
    - "Dead Code: If a function/class has 0 references (AST Scan), DELETE IT."
    - "Comments: Remove commented-out code blocks."
  
  4_TESTING:
    - "Coverage: Logic classes must have corresponding Unit Tests."
    - "Mocks: No external calls in Unit Tests."
  
  5_CLEANLINESS:
    - "Vacuum: Recursively delete empty directories and 0-byte files."
    - "Linting: Fix unused imports and variable shadowing."
  
  6_DOCUMENTATION:
    - "Code: Add JSDoc/Docstrings to all Public Methods explaining 'Why', not 'What'."
    - "API: Add Swagger/OpenAPI Examples (Request/Response) for every Endpoint."
  
  7_SHARED_STRICTNESS:
    - "VIOLATION: Any code in `src/shared` or `src/common` inside a service."
    - "ACTION: Move to `@packages` or delete if duplicate."

# --- 2. ASIGNACIÓN DE AGENTES (MODELOS ESPECIALIZADOS) ---
AGENTS:
  # ORQUESTADOR (Opus 4.5)
  @QualityLead:
    engine: claude-4.5-opus
    role: LEAD_ARCHITECT
    task: "Coordinate the 3 streams and enforce cross-language consistency."

  # ESCUADRÓN NODE (Sonnet 4.5)
  @NodeSurgeon:
    engine: claude-4.5-sonnet
    context: NODE_SHARD
    role: SENIOR_DEV
    task: "Refactor NestJS services one by one. Enforce DDD modules."

  # ESCUADRÓN PYTHON (Sonnet 4.5)
  @PythonSurgeon:
    engine: claude-4.5-sonnet
    context: PYTHON_SHARD
    role: SENIOR_DEV
    task: "Refactor FastAPI services. Enforce Pydantic strictness and Type Hints."

  # ESCUADRÓN .NET (Sonnet 4.5)
  @DotNetSurgeon:
    engine: claude-4.5-sonnet
    context: DOTNET_SHARD
    role: SENIOR_DEV
    task: "Refactor C# Solutions. Enforce Clean Architecture projects."

# --- 3. FLUJO DE TRABAJO (PARALELO POR STACK, SERIAL POR SERVICIO) ---
WORKFLOW:

  # FASE 1: ANÁLISIS Y EXTRACCIÓN (NO DESTRUCTIVO)
  STAGE_1_DEEP_SCAN:
    concurrency: TRUE
    tasks:
      - STREAM_NODE (@NodeSurgeon):
          ITERATE: `services/node/*`
          ACTION: "Identify Shared Logic violation. Identify Dead Code. Check DDD Layers."
          OUTPUT: "Node_Refactor_Plan.json"
      
      - STREAM_PYTHON (@PythonSurgeon):
          ITERATE: `services/python/*`
          ACTION: "Identify Shared Logic violation. Check Type Hints coverage."
          OUTPUT: "Python_Refactor_Plan.json"

      - STREAM_DOTNET (@DotNetSurgeon):
          ITERATE: `services/dotnet/*`
          ACTION: "Identify Shared Logic. Check Project Reference cycles."
          OUTPUT: "DotNet_Refactor_Plan.json"

  # FASE 2: MIGRACIÓN DE COMPARTIDOS (STRICT SHARED)
  STAGE_2_SHARED_MIGRATION:
    dependency: STAGE_1_DEEP_SCAN
    concurrency: TRUE
    tasks:
      - ALL_STREAMS:
          ACTION: "Move any identified `service/shared` code to `packages/`."
          VALIDATION: "Update imports. Verify compilation. DELETE local shared folder."

  # FASE 3: CIRUGÍA MAYOR (REFACTORING & CLEANUP)
  STAGE_3_SURGICAL_REFACTOR:
    dependency: STAGE_2_SHARED_MIGRATION
    concurrency: TRUE
    tasks:
      
      # PROCESAMIENTO SERIE: NODE
      - STREAM_NODE (@NodeSurgeon):
          FOREACH Service IN `services/node`:
            1. **Structure:** Align folders to `Domain/App/Infra`.
            2. **Clean:** Delete unused files/folders.
            3. **Docs:** Add Swagger `@ApiProperty` examples.
            4. **Test:** Generate missing `.spec.ts` skeletons.
            5. **Verify:** Run `npm run build` (Must Pass).

      # PROCESAMIENTO SERIE: PYTHON
      - STREAM_PYTHON (@PythonSurgeon):
          FOREACH Service IN `services/python`:
            1. **Structure:** Enforce `routers`, `schemas`, `services`, `models`.
            2. **Clean:** Remove `pass` blocks and unused imports (Ruff/Black).
            3. **Docs:** Add docstrings to Endpoints for OpenAPI.
            4. **Verify:** Run `mypy .` (Must Pass).

      # PROCESAMIENTO SERIE: .NET
      - STREAM_DOTNET (@DotNetSurgeon):
          FOREACH Service IN `services/dotnet`:
            1. **Structure:** Ensure `.csproj` separation (API, Application, Domain, Infra).
            2. **Clean:** Remove empty namespaces/classes.
            3. **Docs:** Add XML Comments `/// <summary>` for Swagger.
            4. **Verify:** Run `dotnet build` (Must Pass).

  # FASE 4: VALIDACIÓN DE CALIDAD FINAL
  STAGE_4_QUALITY_GATE:
    agent: @QualityLead
    actions:
      - AUDIT: Randomly sample 1 file from each layer in each language.
      - CHECK: Does it follow SOLID? Is it documented? Is it clean?
      - VERDICT: "CERTIFIED_GOLD_STANDARD" or "NEEDS_REVISION".

# --- COMANDO DE EJECUCIÓN ---
EXECUTE:
  - START_PERFECTION_PROTOCOL
  - DELETE_DEAD_CODE: TRUE
  - ENFORCE_DOCS: TRUE
  - SAFETY_FIRST: "Dry Run deletion first, then confirm."







