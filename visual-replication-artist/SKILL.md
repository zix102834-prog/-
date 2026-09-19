---
name: visual-replication-artist
description: Inspect a reference poster, create a pixel-preserving annotated deconstruction, propose compatible replacements for subject, environment, and action, and optionally generate the migrated image when explicitly requested. Use for 海报拆解、视觉复刻、主体替换、场景迁移 or migration-prompt preparation; do not use it to copy source identity or build teaching HTML.
---

# 视觉复刻师

Turn a reference image into a testable visual specification, a non-destructive annotated deconstruction image, and—when requested—a migration-ready generation package.

## Choose the smallest run mode

- `analysis-only`: inspect, deconstruct, and create the annotated analysis image.
- `migration-planning`: additionally propose compatible replacements and prepare the generation kit. This is the default for visual-replication or prompt-planning requests.
- `generate-now`: complete planning, then generate and review the migrated image only after an explicit user request.

Record `run_mode` and `planning_mode` (`explore`, `refine`, or `finalize`) in the handoff YAML. Read [the visual-deconstruction schema](references/visual-deconstruction-schema.md) whenever the request needs an annotated image, migration options, or a generation package.

If no usable reference image is available, ask for one and stop. Inspect the supplied reference before making spatial or stylistic claims.

## Core transfer rules

Visual replication transfers observable relationships—composition, hierarchy, colour roles, material, depth, light direction, and reading order—not source identity.

1. **原图管风格**：整体气质、色彩关系、材质语言和摄影或插画特征。
2. **拆解图管结构**：构图区、层级、动线、文字区域和空间关系；它不是主要风格图。
3. **素材图管主体（可选）**：新主体的身份、形状、细节和外观。没有素材图时，用文字精确定义这些信息。
4. **卖点管文案**：文案必须跟随新主体和新卖点重新设计。

> **结构可以继承，内容必须重新设计。**

List source-specific subjects, people, characters, wording, logos, branded objects, signature props, locations, and story combinations under `source_content_to_avoid`. Do not use creator, studio, brand, or work names as style shortcuts.

Apply strong internal headline contrast only when it is visible in the inspected reference. In the food-poster example, modifiers or process words stay smaller and the core sensory character is the largest element. Do not impose this rule on text-free images or uniform editorial typography.

## Deconstruct the visual system

Build the following in the handoff YAML:

- one compact `style_summary`;
- relational, testable `style_fidelity_anchors`;
- source-specific `source_content_to_avoid`;
- concise findings for composition, hierarchy, colour, copy, material/depth, eye path, and transferable formula.

Each anchor states what is visible, where it appears, how it relates to nearby elements, and why the relationship affects reading order. Separate observation from interpretation. Do not guess exact fonts, production methods, provenance, or hidden intent.

## Create the annotated image deterministically

Prefer the bundled script whenever PowerShell and `System.Drawing` are available:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/create-deconstruction-board.ps1 `
  -ReferencePath <reference-image> `
  -SpecPath <deconstruction-spec.json> `
  -OutputPath <deconstruction-board.png>
```

The script places the original at 1:1 scale on a larger canvas, keeps all annotations outside the source rectangle, writes a separate PNG, and emits `<output>.integrity.json`. Treat the board as complete only when `pixel_integrity_exact` is `true`, the before/after hashes match, and the recorded source rectangle has the original dimensions.

Never overwrite the reference image. Never ask a generative image model to redraw, reconstruct, clean, translate, extend, or restyle the reference inside an analysis board. If the deterministic script is unavailable or integrity verification fails, deliver the textual/YAML analysis, set `composition_method: unavailable`, and state that a safe annotated image was not completed.

The board should show the full reference uncropped, three to five major zones, hierarchy and eye path, colour roles, copy roles, and a compact transferable formula. Labels must remain beside the evidence and never cover the source image.

## Plan replacements through the specialist contract

After deconstruction and annotation, read [the replacement-prompt specialist contract](references/replacement-prompt-subagent.md). Delegate to one subagent named **替换方案与提示词专家** when collaboration tools are available; otherwise follow the same contract locally and record `execution_mode: local_fallback`.

Pass only the completed handoff YAML, the user's fixed choices, a factual description of any optional material image, output language, aspect ratio, and planning mode. The specialist proposes options; it does not generate images, choose for the user, build HTML, or overwrite the handoff. The main agent reviews every proposal against anchors, exclusions, user constraints, and material identity.

Do not offer random substitutions. Every subject, environment, and action/state must fit the inherited silhouette, scale, direction, visual weight, depth, contrast, or story role. Use `explore` while the direction is open, `refine` when some categories are fixed, and `finalize` when subject, environment, and action/state are all fixed.

## Prepare the generation kit

The handoff requires:

1. **原图** — style and atmosphere.
2. **视觉拆解图** — structure and hierarchy.
3. **使用者确认的提示词** — new subject, environment, action/state, copy, format, additions, and exclusions.
4. **使用者自己的素材图（可选）** — new-subject identity and details when supplied.

The prompt must translate core anchors into actionable relationships, make the new premise primary, use newly authored copy, remove source identity, and include a source-specific negative prompt. Also provide a concise diff grouped as `preserved`, `changed`, `added`, and `removed`.

Do not mark the package ready until the original image, integrity-verified deconstruction image, and confirmed prompt exist and their roles are explicit. A missing material image never blocks readiness when the prompt defines the new subject precisely.

Stop at `awaiting_user_generation` unless the user explicitly requests `generate-now`. In `generate-now`, inspect the result for subject, hierarchy, text accuracy, exclusions, and structural fidelity before delivery. Do not build teaching HTML in this skill.

## Reference cases

Food-poster role examples:

- Style controller: `examples/food-poster/original-braised-pork.png`
- Structure controller: `examples/food-poster/layout-analysis.png`
- Migration evidence A: `examples/food-poster/case-a-braised-beef-noodle.png`
- Migration evidence B: `examples/food-poster/case-b-charcoal-lamb-skewers.png`

For a workflow with a material image and a separate colour reference, read `examples/watercolor-anime-migration/README.md`. In that case, the material image controls subject, people count, clothing, props, action, framing, and composition; the extra colour reference controls only palette relationships.

## Completion check

- The selected modes match the request and fixed choices.
- The reference was inspected and its source-specific identity is excluded from migration.
- The deconstruction board is non-destructive and its integrity report passes.
- Every core anchor is observable, relational, and testable.
- Specialist proposals trace to anchors and respect fixed choices.
- Required inputs are present and clearly labelled; the material image remains optional.
- No generation occurred without an explicit request, and no teaching HTML was created.
