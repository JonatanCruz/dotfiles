---
description: Comprehensive code analysis across quality, security, performance, and architecture
agent: review
---

# Code Analysis

Perform comprehensive analysis of $ARGUMENTS focusing on:

## Quality Assessment
**Code Quality**:
- Code smells and anti-patterns
- Complexity metrics (cyclomatic, cognitive)
- Maintainability index
- Code duplication detection

**Best Practices**:
- Language-specific conventions
- Design pattern usage
- SOLID principles adherence
- Clean code principles

## Security Analysis
**Vulnerability Scanning**:
- OWASP Top 10 risks
- Injection vulnerabilities (SQL, XSS, CSRF)
- Authentication/Authorization flaws
- Sensitive data exposure

**Secure Coding**:
- Input validation patterns
- Output encoding practices
- Cryptography usage
- Dependency vulnerabilities

## Performance Review
**Bottlenecks**:
- Algorithm complexity (Big O analysis)
- Database query efficiency
- Memory usage patterns
- Network call optimization

**Optimization Opportunities**:
- Caching strategies
- Lazy loading patterns
- Resource pooling
- Batch processing

## Architecture Assessment
**Design Patterns**:
- Pattern appropriateness
- Separation of concerns
- Dependency management
- Modularity and cohesion

**Technical Debt**:
- Dead code identification
- Deprecated API usage
- TODOs and FIXMEs
- Legacy code markers

## Reporting Format

Provide findings with:
1. **Severity**: Critical, High, Medium, Low, Info
2. **Category**: Quality, Security, Performance, Architecture
3. **Location**: File and line numbers
4. **Description**: Clear explanation of the issue
5. **Recommendation**: Actionable fix with code examples
6. **Impact**: Business and technical consequences

## Tools to Use
- Use `grep` for pattern matching
- Use `read` for file inspection
- Use Serena for symbolic analysis
- Reference best practices via Context7

## Output Structure
1. Executive Summary
2. Critical Findings (immediate action required)
3. High Priority Issues
4. Medium/Low Priority Improvements
5. Positive Observations
6. Recommendations Roadmap
