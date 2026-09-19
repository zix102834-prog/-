# Visual Replication Handoff Contract

Maintain this YAML document from inspection through the user's next image-generation handoff. A separate Poster Show workflow may consume it when available, but that integration is optional.

```yaml
schema_version: "1.1"
run_mode: migration-planning # analysis-only | migration-planning | generate-now
planning_mode: explore # explore | refine | finalize
stage: deconstruct

style_summary: ""

style_fidelity_anchors:
  - id: anchor-01
    category: composition
    observation: "Concrete visible relationship in the reference."
    location: "upper-left / centre / lower-third / full-frame / other"
    effect: "Likely perceptual effect, explicitly labelled as interpretation."
    core: true

source_content_to_avoid:
  - id: avoid-01
    category: subject
    literal_content: "Specific source subject, wording, logo, branded object, location, prop, or premise."
    replacement_rule: "What must change in a later migration."

deconstruction:
  composition:
    summary: ""
    zones: []
    eye_path: ""
  visual_hierarchy:
    levels: []
  colour:
    dominant: ""
    supporting: ""
    accent: ""
    background: ""
    contrast_rule: ""
  copy:
    headline_role: ""
    supporting_role: ""
    selling_point_role: ""
    closing_role: ""
  material_and_depth:
    summary: ""
    layers: []
  transferable_formula: ""

replacement_options:
  subjects:
    - option: ""
      replaces: ""
      fit_reason: ""
      required_supporting_details: []
      source_details_to_remove: []
  environments:
    - option: ""
      fit_reason: ""
      spatial_and_light_changes: []
  actions_or_states:
    - option: ""
      fit_reason: ""
      movement_or_eye_path_effect: ""
  coherent_combinations:
    - subject: ""
      environment: ""
      action_or_state: ""
      rationale: ""

migration_inputs:
  selected_subject: ""
  selected_environment: ""
  selected_action_or_state: ""
  main_text: ""
  supporting_text: ""
  accent_symbol: ""
  aspect_ratio: ""
  audience: ""
  constraints: []

migration_prompt: ""
prompt_status: suggested
negative_prompt: ""
prompt_diff:
  preserved: []
  changed: []
  added: []
  removed: []

artifacts:
  reference_image: ""
  deconstruction_image: ""
  reference_integrity:
    composition_method: deterministic-overlay # deterministic-overlay | side-by-side-canvas | unavailable
    report_path: ""
    source_pixel_sha256: ""
    embedded_pixel_sha256: ""
    pixel_integrity_exact: false
    original_pixels_preserved: false
    original_crop_preserved: false
    original_text_preserved: false
  user_material_images: []

generation_kit:
  original_role: "style and atmosphere"
  deconstruction_role: "structure and hierarchy"
  user_material_optional: true
  user_material_role: "new subject identity and details when supplied"
  prompt_role: "new content, action, environment, copy, and constraints"
  ready: false

specialist_run:
  specialist: "替换方案与提示词专家"
  execution_mode: subagent # subagent | local_fallback
  contract: "references/replacement-prompt-subagent.md"
  status: not_run # not_run | complete | blocked
  selected_direction_id: ""
  main_agent_review:
    anchors_supported: false
    exclusions_respected: false
    user_constraints_respected: false
    optional_material_handled: false
    prompts_are_standalone: false
    combinations_are_coherent: false
    notes: []

generation_run:
  requested: false
  status: not_run # not_run | complete | blocked
  output_image: ""
  review:
    subject_correct: false
    hierarchy_preserved: false
    text_accurate: false
    exclusions_respected: false
    source_identity_not_copied: false
    notes: []
```

## Field rules

### `style_fidelity_anchors`

Use stable IDs. Each anchor must describe observable evidence and a relationship, not a loose ingredient list. Set `core: true` only when its absence would materially break the extracted visual system.

Useful categories include `composition`, `hierarchy`, `typography`, `colour-light`, `photography`, `material`, `layering-depth`, and `motion`.

### `source_content_to_avoid`

Use stable IDs and source-specific descriptions. Cover applicable subject, person or character, brand mark, branded object, wording, language, location, prop, story premise, and signature combination.

### `deconstruction`

Keep each value concise enough for a visual annotation board. Prefer three to five zones, hierarchy levels, colour roles, copy roles, or depth layers rather than long prose.

### `migration_inputs` and prompts

Fill these fields only with the user's chosen direction or clearly label the result as a suggestion. The prompt must specify the new subject, environment, action/state, copy, format, visual relationships, and exclusions. Set `prompt_status` to `confirmed` only after the user confirms or directly supplies the prompt.

### `artifacts`

- `reference_image` points to the inspected source poster.
- `deconstruction_image` points to the completed annotated analysis image.
- `user_material_images` contains the user's own reference images for the new subject when supplied; it may remain empty.

The reference and deconstruction image paths must exist before the generation kit is marked ready. User material images are optional. For a script-generated board, copy the integrity report path and hashes into `reference_integrity`; set all integrity booleans true only when the report shows matching hashes, original dimensions, and no annotation overlap. If deterministic compositing is unavailable or verification fails, set `composition_method: unavailable`, leave the checks false, and do not claim the board was safely completed.

### `generation_kit`

The required inputs are the original image, annotated deconstruction image, and confirmed prompt. The user's own material image is optional. Set `ready: true` when the three required inputs exist and their roles are explicitly stated. If no material image is supplied, the prompt must define the new subject precisely enough to replace that reference role.

### `specialist_run`

Use the linked subagent contract after the deconstruction image is complete. Set `execution_mode: subagent` when a real collaboration tool is used; use `local_fallback` only when none is available. The main agent must review every field before offering the directions to the user or copying a selected direction into `migration_inputs`.

## Stage values

Use:

- `deconstruct` while inspecting and analysing;
- `annotate` while creating the deconstruction image;
- `propose_replacements` while generating subject, environment, and action/state options;
- `prepare_generation_kit` while finalising the four inputs;
- `awaiting_user_generation` after the complete package is handed to the user.
- `generate` while fulfilling an explicit `generate-now` request;
- `complete` after the generated output passes review.

## Ready-state invariant

Set `generation_kit.ready: true` only when the original and verified board paths exist, a coherent direction and confirmed prompt are recorded, required/optional input roles are labelled, and the specialist review fields pass. In `generate-now`, set `stage: complete` only after all applicable generation-review fields pass.
