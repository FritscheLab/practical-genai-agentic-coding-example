# Keep control of the agent and your work

**Give an agent a clear job and only the access needed for it. Keep enough understanding to review its work and continue without it.** These habits matter even when the last several requests worked perfectly.

Read this before the first execution request in [VS Code setup](../setup/vscode-copilot.md). The same principles apply to the [CLI appendix](../appendix/command-line.md) and other clients.

## About AI assistance in this guide

This guide and exercise were developed with **substantial AI assistance**, including drafting text, writing and revising code, and helping with tests and reviews. In that sense, we are practising what we teach. AI-assisted review is not independent human validation. See the [Sources and testing record](https://fritschelab.org/practical-genai-agentic-coding-guide/docs/reference/sources.html) for what was checked and what remains untested.

### Review before use; no warranty

**Use this material at your own risk.** The guide, exercise code, agent instructions, and examples are provided **“as is,” without warranty of any kind**, to the extent permitted by applicable law. There is no assurance of accuracy, completeness, security, or suitability for a particular purpose. The warranty disclaimer and limitation of liability in **sections 15–17 of the GPL-3.0 license** govern, including the qualifications stated there. Each repository includes its license in `LICENSE`: [guide license](https://github.com/FritscheLab/practical-genai-agentic-coding-guide/blob/main/LICENSE), [exercise license](https://github.com/FritscheLab/practical-genai-agentic-coding-example/blob/main/LICENSE). This notice does not replace or change those license terms.

Before running or adapting the material, you should independently review the **code, dependencies, agent instructions and skills, requested permissions, and outputs**. Test with nonsensitive examples in an appropriately isolated environment, verify results, and follow your institution's requirements. You are responsible for deciding whether and how to use or modify the material and for the actions you authorize an agent to take. Documentation, prompts, agent agreement, and passing automated checks are not safety or correctness guarantees.

## Approval is a decision

Repeated requests can become a habit of clicking **Allow** to keep things moving. This is **approval fatigue**: the prompts remain visible, but attention to their consequences fades. VS Code identifies this as a reason to combine meaningful approvals with restricted execution. A familiar command name or a confident explanation does not establish safety. [Approval fatigue and sandboxing](https://code.visualstudio.com/docs/agents/concepts/trust-and-safety#why-sandboxing-matters).

Before approving, identify:

1. **Purpose:** how does this action serve the task you agreed on?
2. **Scope:** which files, folders, settings, accounts, or network destinations can it affect?
3. **Consequences:** what could it overwrite, delete, expose, or spend? Can you recover?
4. **Duration:** does this approve one action, or future actions too?

You need not memorize shell syntax. You should be able to explain the effect of the request. If you cannot, choose **Skip** or deny the request and ask:

```text
Do not execute this action yet. Explain its purpose, exact files and
destinations, possible overwrites or external effects, and the scope and
duration of the requested permission. Propose a narrower action if possible.
```

Compare the explanation with the actual request; the agent can misunderstand its own command. Ask an experienced colleague if the consequences remain unclear. Do not approve just because a run failed or a workshop is running out of time.

## Recognize the boundaries of this exercise

| Request | What to establish before approving |
| --- | --- |
| Run the existing behavior tests | Correct repository, known test files, and the selected Python environment or R runtime. Tests execute code; their name alone is no guarantee. |
| Install Python plotting requirements | The existing requirements file, installation into this repository's `.venv`, and an expected package source. R needs no extra packages for this exercise. |
| Render the repaired chart | Output stays in `runs/with-fix/`; the baseline is preserved. Replacing the candidate PNG during verification is expected. |
| Use administrator rights, change global settings, or delete an unrelated folder | Stop and establish why this is needed. Ordinary plot repair does not require these powers. Separate an approved installer from later exercise commands. |
| Upload files, push to GitHub, connect a service, or read credentials | These exceed the required local exercise. Decline and return to the agreed task. Review any later sharing as a separate decision. |

Avoid broad “always allow” rules for an interpreter or shell: Python, R, and shell tools can run many different programs. Prefer a single action or a narrowly bounded session when that is enough. Keep **Manual permissions** (**Default permissions** in our screenshots); do not select **Allow all**, an unrestricted/bypass mode, or **Autopilot** simply to remove interruptions. Saved approvals can still apply in Manual mode. [VS Code approval levels and scope](https://code.visualstudio.com/docs/agents/run/approvals).

In VS Code's Command Palette, **Chat: Manage Tool Approval** reviews saved tool approvals; **Chat: Reset Tool Confirmations** clears saved confirmations. Custom terminal and URL rules have their own settings, so also inspect those if actions keep running unexpectedly. [Manage approvals](https://code.visualstudio.com/docs/agents/run/approvals#manage-tool-approvals).

## What sandboxing protects

A **sandbox** enforces limits on what a process can read, write, and reach over the network. It reduces the damage an erroneous or manipulated command can do. It can still permit a wrong edit, deletion within an allowed folder, or an unwanted action at an allowed destination.

| Control | What it provides |
| --- | --- |
| A prompt, `AGENTS.md`, or a reviewed plan | Instructions about intended behavior; these do not enforce access restrictions. |
| Approval controls | Decide which tool actions need your consent, including any saved exceptions. |
| A filesystem/network sandbox | Enforces the configured boundaries for the tools it covers. |
| Git history | Helps review and recover committed source. It cannot undo an upload or recover every ignored/untracked file. |

**Local** names the Copilot session target; it does not mean the model runs offline or the session is sandboxed. A `.venv` separates Python dependencies. `.gitignore` keeps matching untracked files out of Git's normal change list. Neither restricts an agent's access. Keep study data and credentials outside the exercise and follow the [lab data guidance](lab-data-policy.md).

Current VS Code documentation describes a **preview terminal sandbox**, off by default, for macOS, Linux, and WSL2; native Windows is not listed as supported. On a supported setup, the permission picker's **Sandboxing for terminal** control enables it. If activation fails or you cannot establish that it is active, treat the session as unsandboxed and resolve the reported setup problem before relying on those restrictions. To retain ordinary approval handling for sandboxed commands, open Settings, search `chat.agent.sandbox.allowAutoApprove`, and turn it off; sandboxed commands otherwise default to automatic approval. Availability and required dependencies vary. [Sandbox configuration](https://code.visualstudio.com/docs/agents/run/approvals#configure-the-sandbox).

This sandbox covers terminal commands and child processes. Other tools, extensions, connectors, and model-bound context have separate controls. Treat a request to run **outside the sandbox**, or to retry with broader network access, as a new decision about access. Read the exact exception before consenting. In Claude Code, actively choose its own Manual/Plan controls and inspect its separate sandbox settings; Copilot's checkbox does not configure Anthropic's native Claude Code extension. [VS Code execution risks](https://code.visualstudio.com/docs/agents/run/security), [Claude sandbox scope](https://code.claude.com/docs/en/sandboxing#scope).

Trust only the reviewed exercise folder in Workspace Trust. Trusting a parent extends trust to its subfolders. Instructions found in a file, website, or tool result can try to redirect an agent; they do not authorize it to expand your task or disclose information. [Workspace Trust](https://code.visualstudio.com/docs/editing/workspaces/workspace-trust), [prompt injection](https://code.visualstudio.com/docs/agents/run/security#security-risks-to-be-aware-of).

## Stay able to work without an agent

**Overreliance can leave you with working code that you cannot explain, debug, or maintain independently. A successful agent run is not evidence that you learned the method.** You remain responsible for the code and scientific decisions you use.

Access or permission can change when you move to another country, institution, or employer, or when budgets, services, or connectivity change. Keep source, dependencies, tests, and instructions usable without a particular assistant or chat history. This exercise's Python/R programs and checks run without an AI service; the CLI appendix records the commands.

- Before asking, sketch your own approach or diagnosis, even briefly.
- After a repair, close Chat and explain the changed function and why its checks are appropriate. Look up anything you cannot explain.
- Regularly make a small change or debug a problem without an agent, using documentation and your editor's ordinary tools. Use the appendix to practise running checks yourself.
- Watch for opening Chat before thinking, feeling unable to start without it, or repeatedly exceeding the time or spending limits you chose. Pause, set a bounded task, and try a session with the extension disabled.

If AI use is prohibited in your new setting, use your independent workflow and follow that setting's rules. Do not move restricted work to a personal account to keep using an agent.

## Keep the solution proportional to the task

**Working code can still be a poor repair if you cannot maintain it.** An agent may turn a small plotting change into a configurable pipeline with classes, wrappers, new dependencies, and many files. Passing tests does not establish that this extra machinery is needed, efficient, or understandable.

Ask for the smallest clear change that meets the actual requirements. Here that means repairing the existing plotting function and preserving its interface. A new helper can be useful when it removes real duplication or clarifies a calculation; a framework for hypothetical future datasets needs a separate justification. Avoid both needless architecture and dense code written merely to minimize line count.

Before accepting a large diff, ask: What requirement needs each new file or abstraction? Can I trace the values from constants to bars? Can I make a small future change without asking the agent to explain its architecture? Has it added repeated file reads, rendering, or other work without a reason? Treat speed claims as unverified until measured.

The planning and implementation prompts, `AGENTS.md`, and the `plot-review` skill carry this expectation. If the result grows beyond the brief, request a simpler proposal, review its tradeoffs, and rerun the checks after any simplification. Keep the validation and accessibility work the task actually requires.

## If something unexpected happens

Stop the agent and any still-running command. Stopping does not reverse completed actions. Review the changed-file list, command output, and any affected external service before resuming. Restore only changes you understand; **Discard All** can remove work you meant to keep. If information was exposed, follow your institution's [incident guidance](lab-data-policy.md#if-something-goes-to-the-wrong-place).

*Permission and sandbox documentation reviewed September 11, 2026. Sandbox activation and approval-reset controls were not tested through the UI for this guide; existing screenshots demonstrate the controls and actions listed on the [online Sources page](https://fritschelab.org/practical-genai-agentic-coding-guide/docs/reference/sources.html).*
