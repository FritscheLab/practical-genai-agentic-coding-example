# Keep study data outside the demo

**Give the agent approved code, invented examples, and the teaching chart.** Keep participant records, PHI, PII, credentials, and study logs outside this workspace and out of prompts or screenshots.

**U-M guidance reviewed: September 5, 2026; agent data boundaries: September 10, 2026.** Other institutions have their own policies and agreements.

## Give the agent code and invented examples

Explore plotting functions, layout settings, and tests. Do not ask the agent to inspect participant records or explain why an individual data point failed. For debugging, reproduce the problem with an invented example.

Use a separate workspace containing code permitted for the selected service. Review code too: embedded records, credentials, paths, and error messages can disclose information.

## Check the service as well as the model

| Before using study material | Check |
| --- | --- |
| Service and account | U-M permits sensitive institutional data only where a university contract or data agreement covers the use. Without one, university data is limited to **Low**. See [AI data requirements](https://safecomputing.umich.edu/protect-the-u/safely-use-sensitive-data/AI-and-UM-Data) and the [Sensitive Data Guide](https://safecomputing.umich.edu/dataguide/); some listings require sign-in. |
| Exact connection | Approval does not transfer with a model name. For example, [Claude Code through U-M GPT Toolkit](https://its.umich.edu/computing/ai/claude-code-gpt-toolkit#sensitive-data) excludes ePHI. A personal API key is not institutional approval. |
| Unclear permission | Stay with invented examples and contact your unit's IT/security team or ITS Information Assurance through the ITS Service Center. |

## Recognize PHI and PII in ordinary work

**PHI:** protected health information. **PII:** personally identifiable information. Identifiers, dates, or combinations of details may identify someone. U-M classifies HIPAA-regulated PHI as High; other information depends on context. Consult the [classification examples](https://safecomputing.umich.edu/protect-the-u/safely-use-sensitive-data/examples-by-level).

Renaming identifiers—or sharing an aggregate—does not automatically make a result safe to disclose.

## Notice the small ways information travels

- A local terminal can send context to a remote model; see [Claude Code's data flow](https://code.claude.com/docs/en/data-usage#local-claude-code-data-flow-and-dependencies).
- Read-only permissions and no-training promises are not permission to share study information.
- `.gitignore` affects Git, not agent access. A Codex command-network setting does not make the model local.
- Review open folders, editor context, connected tools, and screenshots. Keep keys out of saved commands and shared settings. Check package sources and command destinations. [Secure coding guidance](https://safecomputing.umich.edu/protect-the-u/secure-coding).

## Bring reviewed code to a study deliberately

Develop with invented examples, review the method and code, then run it in the approved analysis environment. Keep records and detailed outputs there; confirm what may leave before sharing results.

Check the protocol, consent, and data-use agreements. U-M HRPP distinguishes general project support from AI in participant interaction, data collection, or research-data analysis; changes within the latter scope require prior IRB review and approval. Ask the study team or IRB about uncertain cases. [AI in human research](https://hrpp.umich.edu/aiinhumanresearch/).

Review generated code and acknowledge AI use as required by your institution, study, and journal. [U-M appropriate use](https://genai.umich.edu/resources/appropriate-use).

## If something goes to the wrong place

Stop the action, avoid further sharing, and contact IT/security promptly. U-M asks for actual or suspected incidents to be reported as soon as possible; Michigan Medicine has a HITS route. [Incident reporting](https://safecomputing.umich.edu/report-it-security-incident).
