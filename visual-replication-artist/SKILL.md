---
name: visual-replication-artist
description: Inspect a reference poster, create a pixel-preserving annotated deconstruction, propose compatible replacements for subject, environment, and action, and optionally generate the migrated image when explicitly requested. Use for 海报拆解、视觉复刻、主体替换、场景迁移 or migration-prompt preparation; do not use it to copy source identity or build teaching HTML.
---

# 视觉复刻师

Turn a reference poster into a clear, testable visual specification, an annotated deconstruction image, and a user-ready visual-replication package.

## Choose the run mode

Select the smallest mode that satisfies the request. Record it as `run_mode` in the handoff YAML.

- `analysis-only`: inspect, deconstruct, and create the annotated analysis image. Do not generate replacement options unless requested.
- `migration-planning`: complete the analysis, replacement planning, specialist review, and generation kit. This is the default for requests about visual replication or prompt preparation.
- `generate-now`: run `migration-planning`, then call an available image-generation skill only when the user explicitly asks for the migrated image. Inspect the result for subject, hierarchy, text accuracy, exclusions, and structural fidelity before delivery.

Do not force the full workflow onto a narrower request. The complete planning workflow is:

`INSPECT -> DECONSTRUCT -> ANNOTATE -> DELEGATE REPLACEMENT PROMPTS -> REVIEW -> PREPARE GENERATION KIT -> USER GENERATES OR GENERATE-NOW`

“Visual replication” means transferring observable relationships such as hierarchy, composition, colour roles, material, and reading order. It does not mean copying source identity, wording, logos, signature characters, or branded objects.

## Input gate

Inspect the supplied reference image before making any spatial or stylistic claim. If no usable reference is available, ask for it and stop. Do not fabricate a visual analysis from a description alone.

Read [the visual replication schema](references/visual-deconstruction-schema.md) when the user wants an annotated deconstruction image, replacement ideas, or a reusable generation package.

## Deconstruct the visual system

Build:

1. `style_summary`: one compact formula for the visible design system.
2. `style_fidelity_anchors`: reusable, testable visual relationships.
3. `source_content_to_avoid`: literal source identity that must not transfer.
4. `deconstruction`: concise findings for composition, hierarchy, colour, copy, material/depth, and the transferable formula.

Every anchor must state what is visible, where it appears, how it relates to nearby elements, and why that relationship affects the reading order. Separate observation from interpretation. Do not guess exact fonts, production methods, provenance, or hidden intent.

Make exclusions source-specific. Cover applicable subjects, people or characters, branded objects, logos, original wording, locations, story premises, signature props, and distinctive combinations. `No logos` alone is insufficient.

## Create the annotated deconstruction image

When requested, create one explanation image that shows the full reference poster uncropped and annotates only the relationships needed to understand it.

Treat the reference as immutable evidence. Preserve its pixels, crop, aspect ratio, text, products, people, logos, and watermark exactly as supplied. Build the analysis board by placing the unchanged reference on a larger canvas or by adding a non-destructive overlay. Never ask a generative image model to redraw, reconstruct, restyle, clean up, translate, or extend the reference inside the analysis image. If deterministic compositing or annotation tools are unavailable, deliver the textual/YAML analysis and clearly state that the annotated image could not be produced safely.

- Mark three to five major composition zones.
- Show the eye path and hierarchy levels.
- Summarise dominant, supporting, accent, and background colour roles.
- Explain headline, supporting copy, selling point, and closing copy roles.
- Include a compact transferable formula.
- Place labels beside their evidence and avoid covering the core subject.
- Keep text concise and legible; do not turn the board into an article.
- Clearly label the output as analysis. It is a structure guide, not the primary style reference for future image generation.
- Verify before delivery that the embedded reference is pixel-identical or visually unchanged and that no annotation covers critical evidence.

## Delegate to the replacement-prompt specialist

After the visual analysis and annotated deconstruction image are complete, delegate the replacement ideation and prompt drafting to one subagent named **替换方案与提示词专家** when subagent or collaboration tools are available. Read and pass the contract in [replacement-prompt-subagent.md](references/replacement-prompt-subagent.md).

Pass only:

- the completed visual-deconstruction YAML;
- the user's fixed choices and constraints;
- a factual description of any optional user material image;
- the required output language and aspect ratio.
- the selected `planning_mode`: `explore`, `refine`, or `finalize`.

Do not pass unrelated conversation history, hidden conclusions, or an answer the subagent is expected to imitate. The subagent must derive its proposals from the recorded visual anchors rather than re-analysing an image it has not inspected.

The subagent returns proposals only. It does not generate images, build HTML, choose on the user's behalf, or overwrite the main YAML. The main agent must review its output for compatibility with the observed composition, hierarchy, colour roles, source exclusions, user constraints, and optional material reference before presenting it.

If collaboration tools are unavailable, perform the same specialist contract locally and label no fictional delegation. Do not block the user's workflow solely because a subagent cannot be created.

## Propose replaceable content

After the deconstruction image is complete, explain what may change without breaking the extracted visual system. Do not offer random substitutions. Derive every option from the reference poster's visual mass, silhouette, direction, depth, contrast, and story role. Match the amount of ideation to the selected planning mode:

- `explore`: the direction is open; propose three to five options in each open category and two or three coherent combinations.
- `refine`: one or two categories are fixed; preserve them and propose three to five meaningful treatments only for the remaining open category or categories.
- `finalize`: subject, environment, and action/state are fixed; produce one complete direction and its prompts without unnecessary alternatives.

When `planning_mode: explore`, provide three groups:

### Replaceable subject

Suggest three to five subjects or products that can occupy the original subject's compositional role. For each option, state:

- what source subject it replaces;
- why its silhouette, scale, material, or visual weight fits the inherited structure;
- which source-specific details must disappear;
- what new supporting props or details it requires.

### Replaceable environment

Suggest three to five settings that preserve the useful spatial and lighting relationships while creating a new premise. Explain how foreground, middle ground, background, light direction, colour roles, and negative space would change.

### Replaceable action or state

Suggest three to five actions, poses, interactions, arrangements, or product states that fit the original eye path and movement. For a static product, “action” may mean pouring, steaming, opening, scattering, stacking, being held, being served, or another visible state change.

Then propose two or three coherent combinations of `subject + environment + action/state`. Avoid incompatible mix-and-match lists. In `refine` or `finalize`, follow the scoped counts above rather than padding the response to satisfy exploratory counts.

## Prepare the generation kit

Once the user has chosen or supplied the replacement direction, create a ready-to-use migration prompt and a source-specific negative prompt. The final handoff contains three required inputs and one optional input:

1. **原图** — controls the overall visual style, atmosphere, colour relationships, material language, and photography or illustration character.
2. **视觉拆解图** — controls composition zones, hierarchy, eye path, text areas, and structural relationships; it is not the primary style image.
3. **使用者自己的素材图（可选）** — when supplied, it controls the identity, shape, details, and appearance of the new subject. When absent, define those details through the user's textual description and the prompt.
4. **使用者确认的提示词** — required; controls the new subject, environment, action/state, copy, additions, exclusions, aspect ratio, and output constraints.

Clearly label each image's role so the image-generation system does not confuse style reference, structure explanation, and subject identity.

The prompt must:

- make the new subject and new premise primary;
- translate each core visual anchor into an actionable relationship;
- specify the selected subject, environment, and action/state;
- use only newly authored copy and remove source-specific wording, logos, brand devices, characters, and props;
- describe format, composition, hierarchy, colour roles, light, material, depth, and motion where relevant;
- preserve structure without mechanically copying content;
- include the strong headline hierarchy rule when the chosen reference system uses it.

Also provide a concise prompt diff with `preserved`, `changed`, `added`, and `removed` groups. If the user has not confirmed the wording, label it as a suggested prompt rather than claiming it is final.

### Ready-for-generation gate

Do not tell the user to generate until the original image, deconstruction image, and confirmed prompt are present and clearly assigned. A user material image is optional and its absence must not block the workflow. If no material image is supplied, make the prompt's subject description specific enough to control identity, shape, material, colour, and distinguishing details. If the replacement direction is still open, present the coherent combinations and ask the user to choose before finalising the prompt.

When ready, tell the user to take the **original image + deconstruction image + confirmed prompt**, plus **their own material image when available**, into the next image-generation step. In `generate-now`, use those same labelled inputs with the available image-generation skill and validate the output. Never treat an explicit request to analyse or plan as permission to generate.

## Handoff boundary

Deliver only the artifacts required by the selected run mode. Stop at `awaiting_user_generation` unless the user explicitly requests `generate-now`. Do not build teaching HTML in this skill. If a separate `$show-poster` skill is installed, the user may optionally continue there after selecting a migrated poster; its absence must never block or degrade this skill.

## Poster Show reference set

Use these local examples to understand the distinction between style, structure, subject, and copy:

- Original / style controller: `examples/food-poster/original-braised-pork.png`
- Annotated analysis / structure controller: `examples/food-poster/layout-analysis.png`
- Migration evidence A / braised beef noodle: `examples/food-poster/case-a-braised-beef-noodle.png`
- Migration evidence B / charcoal lamb skewers: `examples/food-poster/case-b-charcoal-lamb-skewers.png`

The examples teach this role split:

> **原图管风格，拆解图管结构，商品管主体，卖点管文案。**

> **结构可以继承，内容必须重新设计。**

### Conditional headline hierarchy rule

Apply this rule only when the inspected reference itself uses strong internal headline contrast. Do not impose it on text-free visuals, editorial systems with uniform typography, character illustrations, or references whose hierarchy is created by another device. In this food-poster example, the upper-left headline is the first visual entry point and its characters are intentionally unequal in size, weight, and emphasis.

- Prefixes, attributes, and process terms such as `山野`, `牛肉`, `慢炖`, or `炭火` stay smaller.
- The core sensory selling-point character such as `鲜`, `香`, `酥`, `嫩`, or `浓` becomes the largest element.
- Use an obvious size contrast, not merely a colour or position change.
- `炭火香` must read as small `炭火` plus dominant `香`; the product name is not automatically the visual headline.

### Structural reading of the examples

1. Upper-left headline: first reading level with strong internal hierarchy.
2. Upper-right support area: English, attributes, dates, or vertical copy; always quieter than the headline.
3. Middle-lower subject: the substantial second visual centre, separated from the background by light and contrast.
4. Left vertical label: small regional, flavour, category, or process cue.
5. Bottom handwritten copy and lower-right brand closure: emotional summary and stable ending.
6. Garnish, smoke, steam, charcoal, and texture support the subject and never become a competing centre.

The migrated examples are evidence that composition can transfer while vessel, ingredients, scene, material, lighting details, copy, and product presentation are redesigned for the new premise.

## Material library: watercolor anime migration

Use `examples/watercolor-anime-migration/README.md` and its six image assets as a verified, user-approved migration case. This case adds a stricter four-reference contract for workflows that include a user material image and a separate colour reference:

1. The **original image** controls only visual style: atmosphere, material language, linework, watercolour behaviour, and paper texture.
2. The **deconstruction image** controls only abstract visual structure: focal hierarchy, layers, and reading order. It is an explanation image, never the primary style controller.
3. The **material image** controls the new subject: identity, subject count, clothing, props, environment, action, gaze, camera framing, and composition.
4. An **additional colour reference** controls only palette: hue, value, saturation, colour proportion, and warm/cool balance. Never inherit its action, pose, subject, camera, composition, or story.

The final image must retain the material image's scene, action, and composition. If any reference conflicts on those fields, the material image wins. Add this rule explicitly to the generation prompt whenever these four inputs are used. See the case README for the asset manifest, ready-to-use wording, and validation checklist.

## Completion check

- [ ] The selected `run_mode` and `planning_mode` match the user's request and fixed choices.
- [ ] The full reference was inspected and remains uncropped in the analysis image.
- [ ] The analysis image preserves the reference without generative redrawing or textual mutation.
- [ ] Each core anchor is visible, relational, and testable.
- [ ] Observation and interpretation are distinguished.
- [ ] Source-specific identity and wording are listed as exclusions.
- [ ] Composition, hierarchy, colour, copy, material/depth, and eye path are covered.
- [ ] The annotated image is legible, concise, and does not obscure the evidence.
- [ ] The transferable formula preserves visual logic without preserving source identity.
- [ ] Replacement-option counts match `explore`, `refine`, or `finalize` rather than being padded.
- [ ] The replacement-prompt specialist was delegated when collaboration tools were available, and the main agent reviewed its proposals.
- [ ] Each proposed subject, environment, and action/state includes a standalone prompt the user can copy or combine.
- [ ] Two or three coherent replacement combinations are provided only when the direction is still open.
- [ ] The selected migration prompt specifies subject, environment, action/state, copy, and output constraints.
- [ ] The three required generation inputs are present and labelled: original, deconstruction image, and confirmed prompt.
- [ ] A user material image is included and labelled when supplied, but its absence does not block generation.
- [ ] Without a material image, the prompt defines the new subject's identity and distinguishing visual details precisely.
- [ ] The user is clearly told which required inputs and optional material image to use in the next image-generation step.
- [ ] The skill stops at `awaiting_user_generation` unless the user explicitly requests generation.
- [ ] In `generate-now`, the generated output was inspected for text accuracy, exclusions, hierarchy, and structural fidelity.
- [ ] No teaching HTML was created by this skill.
