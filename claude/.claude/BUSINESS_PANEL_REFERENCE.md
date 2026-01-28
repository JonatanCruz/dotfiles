# BUSINESS_PANEL_REFERENCE.md
Quick reference for business panel analysis mode (load only when needed)

## Core Symbols (Essential Reference)

### Strategic Analysis
🎯 objective | 📈 growth | 📉 decline | 💰 financial | ⚖️ trade-offs | 🏆 advantage | 🔄 cycle | 🌊 blue ocean | 🏭 industry | 🎪 remarkable

### Framework Shortcuts
🔨 Christensen (JTBD) | ⚔️ Porter (5F) | 🎪 Godin | 🌊 Kim/Mauborgne | 🚀 Collins | 🛡️ Taleb | 🕸️ Meadows | 💬 Doumont | 🧭 Drucker

### Process Flow
🔍 investigation → 💡 insight → 🤝 consensus | ⚡ tension → 🎭 debate → ❓ socratic → 🧩 synthesis → 📋 conclusion

### Business Logic
→ (causes) | ⇒ (transforms) | ← (constraint) | ⇄ (mutual) | ∴ (conclusion) | ∵ (rationale) | ≡ (equivalent) | ≠ (differentiation)

## Business Abbreviations
comp advantage • value prop • GTM • TAM/CAC/LTV • KPI/ROI • MVP/PMF • JTBD • BOS • G2G • 5F • VC • ERRC

## Quick Command Examples

### Basic Usage
```bash
/sc:business-panel @doc.pdf                    # Auto discussion mode
/sc:business-panel @doc.md --mode debate       # Challenge ideas
/sc:business-panel "question" --mode socratic  # Learning mode
```

### Expert Selection
```bash
# By domain
--experts "christensen,drucker,meadows"        # Innovation focus
--experts "porter,kim_mauborgne,collins"       # Strategy focus
--experts "taleb,meadows,porter"               # Risk analysis

# Auto-select by content
@doc.pdf --focus "innovation"                  # Auto-picks relevant experts
@doc.pdf --experts-max 3                       # Limit panel size
```

### Output Control
```bash
@doc.pdf --synthesis-only    # Skip individual analysis
@doc.pdf --structured        # Executive summary format
@doc.pdf --symbols minimal   # Reduce symbol usage
@doc.pdf --depth surface     # Quick overview
```

## Expert Selection by Domain

**Innovation**: christensen, drucker | meadows, collins
**Strategy**: porter, kim_mauborgne | collins, taleb
**Marketing**: godin, christensen | doumont, porter
**Risk**: taleb, meadows | porter, collins
**Systems**: meadows, drucker | collins, taleb
**Communication**: doumont, godin | drucker, meadows
**Organization**: collins, drucker | meadows, porter

## Synthesis Template (Discussion Mode)

```markdown
## 🧩 SYNTHESIS

**🤝 Convergent Insights**: [Expert agreement areas]
**⚖️ Productive Tensions**: [Strategic trade-offs revealed]
**🕸️ System Patterns**: [Leverage points, feedback loops]
**💬 Communication Clarity**: [Core message, action priorities]
**⚠️ Blind Spots**: [Gaps requiring analysis]
**🤔 Strategic Questions**: [Next exploration priorities]
```

## Integration Patterns

### Combined Commands
```bash
/analyze @doc.md --business-panel              # Tech + business analysis
/improve @doc.md --business-panel --iterative  # Business-validated improvement
/design strategy --business-panel              # Expert-guided design
```

### Multi-Stage Workflow
```yaml
Stage 1: /sc:business-panel @research.pdf --mode discussion
Stage 2: /sc:business-panel @analysis.md --mode debate
Stage 3: /design strategy --business-panel
```

## Performance Standards

**Token Efficiency**: discussion 8-15K | debate 10-20K | socratic 12-25K | synthesis-only 3-8K
**Quality Targets**: framework authenticity >90% | strategic relevance >85% | actionable insights >80%
**Response Time**: simple <30s | comprehensive <2min | multi-doc <5min

## Configuration Defaults

```yaml
max_experts: 5
min_experts: 3
auto_select: true
synthesis_required: true
symbol_compression: true
expert_voice_preservation: 0.85
```

## Common Use Cases

1. **Strategic Plan Analysis**: Porter, Kim/Mauborgne, Collins, Meadows → Discussion
2. **Innovation Assessment**: Christensen, Drucker, Godin, Meadows → Discussion
3. **Risk Review**: Taleb, Meadows, Porter, Collins → Debate
4. **Market Entry**: Porter, Christensen, Godin, Kim/Mauborgne → Discussion
5. **Org Change**: Collins, Meadows, Drucker, Doumont → Socratic

## Quick Troubleshooting

**Too verbose?** → Add `--synthesis-only` or `--symbols minimal`
**Wrong experts?** → Manually specify with `--experts "name1,name2"`
**Need challenge?** → Switch to `--mode debate`
**Learning focus?** → Switch to `--mode socratic`
**Time constrained?** → Add `--quick --experts-max 3`
