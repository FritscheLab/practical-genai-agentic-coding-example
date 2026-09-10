# Look after the people behind the data

Someone in the lab will eventually ask, “Can I try this on my study?” Start by checking the data and the service together. We owe that care to participants, students, colleagues, and the people who trusted us with their information.

This teaching repository uses **synthetic data only**. Keep real records, PHI, PII, and credentials out of its files, agent conversations, screenshots, and workshop demonstrations. A small invented example is usually enough to work through a coding problem.

**University guidance reviewed: September 5, 2026.** The links below describe University of Michigan requirements. If you are in another lab or institution, follow your own policies, agreements, and support routes.

## Check the service as well as the model

At U-M, sensitive institutional data may go into an AI service only when a university contract or data agreement permits that use. Services without such an agreement are limited to university data classified as **Low**. Check the exact service, account, model, connection, and data type in the [U-M AI data guidance](https://safecomputing.umich.edu/protect-the-u/safely-use-sensitive-data/AI-and-UM-Data) and [Sensitive Data Guide](https://safecomputing.umich.edu/dataguide/) before using study information. The detailed service listings may require U-M sign-in.

A familiar model name does not carry approval from one product to another. For a concrete example, the current [Claude Code via U-M GPT Toolkit guidance](https://its.umich.edu/computing/ai/claude-code-gpt-toolkit#sensitive-data) explicitly excludes electronic protected health information. Having access to that service does not make it suitable for an ePHI task. Likewise, a personal API key or an agent permission prompt does not establish university approval.

If the permitted use is unclear, keep working with synthetic examples and ask your unit's IT or security contact. U-M's AI data guidance also directs questions to ITS Information Assurance through the ITS Service Center. You do not need to settle an unfamiliar policy question alone.

## Recognize PHI and PII in ordinary work

**PHI** means protected health information; **PII** means personally identifiable information. A debug extract can contain a medical-record number, an email address, a full birth date, or a combination of details that identifies someone. Student and employee records, research participant information, and nonpublic study material also need appropriate handling. U-M classifies HIPAA-regulated PHI as High; other identifiable information depends on its context. Use the [classification examples](https://safecomputing.umich.edu/protect-the-u/safely-use-sensitive-data/examples-by-level) when deciding what you have.

In this pipeline, **cleaned means the filtering and selection rules were applied**. It does not mean de-identified. The outputs retain synthetic person IDs, dates of birth, and ZIP prefixes, and extra input columns can pass through. Changing a name or replacing an ID is not enough to establish that a real dataset is safe to share. Use the invented fixtures for the entire lesson.

## Notice the small ways information travels

The everyday habits below help keep a routine coding task small and understandable:

| While you are working | A useful habit |
| --- | --- |
| Opening a project in an agent | Open this repository on its own. Check additional folders, open editor context, and connected services before giving the agent work. |
| Asking about an error | Reproduce it with synthetic rows. Read the command, paths, and surrounding output before pasting a traceback or sharing your screen. |
| Sharing a run | Inspect the manifest, summary, and logs. This pipeline records commands, input paths, working directories, and error text without redacting them. |
| Adding a tool or API key | Check what it can read or change and which account it uses. Keep keys out of prompts, screenshots, shared settings, and shell commands that will be saved. |
| Installing a suggested package or running a command | Check the package's real source and the command's destination. For the lesson, use the documented dependencies and inspect edits before keeping them. |

These habits fit U-M's [secure coding guidance](https://safecomputing.umich.edu/protect-the-u/secure-coding), which distinguishes work on synthetic examples from higher-risk uses involving real records, sensitive logs, unfamiliar packages, or public deployment.

`.gitignore` helps keep generated files out of Git; it does not prevent an agent from reading them or remove earlier commits. A separate folder and a local terminal are also not proof that information stays on your computer. The client can send context to its model service, and connected tools have their own access. The included Codex network setting limits local command networking; it does not make the model local or certify the setup for protected data.

## Bring reviewed code to a study deliberately

Develop and check the change using synthetic fixtures, then review the method and code with a collaborator. For a real study, use the institution-approved analysis environment and keep records, detailed outputs, and logs there. Confirm which results may leave that environment before sharing them. This demo does not supply clinical validation, de-identification, or approval to process study records.

Check that the proposed AI use and data flow fit the study's protocol, consent, and data-use agreements. U-M's HRPP guidance distinguishes general project support from AI used in participant interaction, data collection, or research-data analysis. Within the latter scope, changes in AI use require IRB review and approval before implementation. Ask the study team or IRB when the boundary is unclear. [AI use in human research](https://hrpp.umich.edu/aiinhumanresearch/).

U-M also requires human review of generated code and appropriate acknowledgment of AI use in scholarship. Keep enough detail in the handoff to explain the assistance and checks, and follow the applicable study, journal, and university requirements. [Appropriate use of AI services](https://genai.umich.edu/resources/appropriate-use).

## If something goes to the wrong place

Stop the upload or agent action if it is still running, avoid sharing the information further, and contact your unit's IT or security team promptly. U-M asks people to report actual or suspected incidents as soon as possible; Michigan Medicine has a HITS reporting route. Follow the [incident reporting instructions](https://safecomputing.umich.edu/report-it-security-incident). A mistake is easier to address when the people who can help hear about it early.
