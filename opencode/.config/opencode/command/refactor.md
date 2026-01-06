---
description: Intelligent code refactoring with best practices and pattern application
agent: build
---

# Refactor Code

Refactor $ARGUMENTS with systematic approach:

## Assessment Phase
1. **Understand Current State**:
   - Read and analyze existing code
   - Identify code smells and issues
   - Note current patterns and conventions

2. **Define Objectives**:
   - Improve readability and maintainability
   - Extract reusable functions/components
   - Remove code duplication
   - Add proper typing and documentation
   - Optimize performance if needed

## Refactoring Strategies

**Extract Method/Function**:
- Long methods → smaller, focused functions
- Complex conditionals → named methods
- Repeated code → reusable utilities

**Rename for Clarity**:
- Unclear variable names → descriptive names
- Generic names → domain-specific terms
- Abbreviations → full words (where appropriate)

**Simplify Conditionals**:
- Nested if/else → guard clauses
- Complex boolean → named variables
- Switch statements → polymorphism (when applicable)

**Remove Duplication**:
- Similar code blocks → shared functions
- Repeated patterns → abstractions
- Copy-paste code → DRY principle

**Improve Structure**:
- God objects → single responsibility
- Tight coupling → dependency injection
- Poor separation → layered architecture
- Mixed concerns → proper boundaries

## Quality Checks

After refactoring:
1. **Verify Functionality**: Ensure behavior unchanged
2. **Run Tests**: All existing tests should pass
3. **Check Performance**: No degradation introduced
4. **Review Readability**: Code is more understandable
5. **Validate Patterns**: Follows project conventions

## Use Serena For
- Symbolic code analysis
- Finding all usages
- Refactoring suggestions
- Impact analysis

## Guidelines
- Refactor in small, incremental steps
- Preserve existing behavior (no feature changes)
- Keep tests passing throughout
- Update documentation as needed
- Consider backward compatibility
- Add comments explaining "why" not "what"

## Red Flags to Fix
- Functions > 50 lines
- Cyclomatic complexity > 10
- Nested loops/conditionals > 3 levels
- Magic numbers without explanation
- Global mutable state
- Tight coupling between modules
