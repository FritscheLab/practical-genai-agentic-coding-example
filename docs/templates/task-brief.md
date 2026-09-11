# Explain the change you want

A useful brief answers the questions you would ask a labmate before changing their code: what should happen, where should I work, and how will we know it works? Fill in the expected results before asking for implementation. [Lesson 2](../lessons/02-specify.md) shows this with the plotting repair.

```markdown
## What I want to change
[One change and why it would help.]

## Where to work
Read AGENTS.md and REPO_MAP.md.
Relevant implementation: [paths]
Existing code contract and invented examples: [paths]
Files allowed to change: [paths]
Out of scope: [specific adjacent work]

## Keep the solution maintainable
Prefer the smallest clear change that meets the requirements.
Reuse the current structure and dependencies. Add abstractions only when
they clarify this task or remove actual duplication. Do not create an
unrequested framework, configuration system, or production pipeline.
If broader work is needed, explain the need and a simpler alternative,
then wait for my decision before expanding scope. Preserve useful validation and readable code.

## Agreed method
Inputs and units: [schema/reference]
Expected change: [the result a reader should see]
Examples: [the visible problem and independently specified expected behavior]
Outputs: [where the result belongs; specify formats only when needed]

## How to check it
[Small synthetic input -> independently worked expected result.]
Command: [exact command from repo root]
Expected behavior: [observable result]
Check existing behavior still works: [test commands]
Review whether each new dependency, file, and abstraction is necessary.

## Working together
Read the source and test code and briefly explain your approach.
Do not open participant data or diagnose individual records.
Ask if a missing method or access decision affects the work; otherwise proceed.
Implement the change, run the checks, inspect the diff, and update affected docs.
Tell me what changed, what you ran, the results, and anything still unresolved.
Do not edit expected results to make an implementation pass.
```
