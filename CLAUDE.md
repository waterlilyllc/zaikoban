# AI-DLC and Spec-Driven Development

Kiro-style Spec Driven Development implementation on AI-DLC (AI Development Life Cycle)

## Project Context

### Paths
- Steering: `.kiro/steering/`
- Specs: `.kiro/specs/`

### Steering vs Specification

**Steering** (`.kiro/steering/`) - Guide AI with project-wide rules and context
**Specs** (`.kiro/specs/`) - Formalize development process for individual features

### Active Specifications
- Check `.kiro/specs/` for active specifications
- Use `/kiro:spec-status [feature-name]` to check progress

## Development Guidelines
- Think in English, generate responses in Japanese. All Markdown content written to project files (e.g., requirements.md, design.md, tasks.md, research.md, validation reports) MUST be written in the target language configured for this specification (see spec.json.language).

## Minimal Workflow
- Phase 0 (optional): `/kiro:steering`, `/kiro:steering-custom`
- Phase 1 (Specification):
  - `/kiro:spec-init "description"`
  - `/kiro:spec-requirements {feature}`
  - `/kiro:validate-gap {feature}` (optional: for existing codebase)
  - `/kiro:spec-design {feature} [-y]`
  - `/kiro:validate-design {feature}` (optional: design review)
  - `/kiro:spec-tasks {feature} [-y]`
- Phase 2 (Implementation): `/kiro:spec-impl {feature} [tasks]`
  - `/kiro:validate-impl {feature}` (optional: after implementation)
- Progress check: `/kiro:spec-status {feature}` (use anytime)

## Development Rules
- 3-phase approval workflow: Requirements → Design → Tasks → Implementation
- Keep steering current and verify alignment with `/kiro:spec-status`
- Follow the user's instructions precisely, and within that scope act autonomously: gather the necessary context and complete the requested work end-to-end in this run, asking questions only when essential information is missing or the instructions are critically ambiguous.

## Ticket Execution Policy（本プロジェクトのデフォルト）
- 各 GitHub チケットに着手したら、Kiro 全フェーズを **一気通貫** で実装完了まで通す。
  1. `/kiro:spec-init` → 2. `/kiro:spec-requirements` → 3. `/kiro:validate-gap` → 4. `/kiro:spec-design -y` → 5. `/kiro:validate-design` → 6. `/kiro:spec-tasks -y` → 7. `/kiro:spec-impl` → 8. `/kiro:validate-impl`
- **設計は手厚く（SDD）**: データモデル・コンポーネント分割・インターフェース・例外系・非機能要件（アクセシビリティ / パフォーマンス / セキュリティ）まで design.md に書き切る。
- **実装は TDD 厳守**: Red（失敗テスト先行）→ Green（最小実装）→ Refactor の順で 1 単位ずつ進める。テスト無しの実装は原則禁止。
- **承認**: 各フェーズ完了時に内容サマリーを提示するが、ユーザーからの停止指示がなければ `-y` で継続。明示的な停止または修正要求のみ待つ。
- 完了時にコミット・Issue クローズ方針を提案する。

## Steering Configuration
- Load entire `.kiro/steering/` as project memory
- Default files: `product.md`, `tech.md`, `structure.md`
- Custom files are supported (managed via `/kiro:steering-custom`)
