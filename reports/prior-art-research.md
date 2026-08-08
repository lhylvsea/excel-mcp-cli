# ExcelMcp CLI Skill prior-art research

- Research date: 2026-08-08
- Scope: a reusable Codex Skill that lets an agent operate on a user-provided '.xlsx' or '.xlsm' workbook through the local 'sbroenne/mcp-server-excel' CLI, without asking the user to manually run PowerShell for every operation.
- Authoring authority: 'qiaomu-meta-skill'

## Search record

The two catalog sources were kept separate because their metrics do not measure the same thing.

| Source | Query | Observed result | Interpretation |
|---|---|---|---|
| skills.sh | Excel CLI automation formulas charts VBA workbook edits | 'claude-office-skills/skills@excel-automation' 13.7K installs; 'sbroenne/mcp-server-excel@excel-mcp' 1.4K; 'daymade/claude-code-skills@excel-automation' 949; 'sbroenne/mcp-server-excel@excel-cli' 865 | Catalog install counts only; useful for relevance and adoption signals, not a quality ranking. |
| skills.sh | Excel MCP server CLI agent PowerShell workbook automation | Similar exact upstream entries plus adjacent Office skills | Confirms the upstream Excel CLI Skill is the closest prior art. |
| SkillsMP | Excel CLI automation formulas charts VBA workbook edits | Returned repository-level candidates such as 'NousResearch/hermes-agent', 'nexu-io/open-design', and 'bytedance/deer-flow'; no exact ExcelMcp CLI Skill was found in the returned set | Repository stars/skill counts are not interchangeable with skill installs; no exact implementation was adopted from this search. |
| SkillsMP | Excel MCP server CLI agent PowerShell workbook automation | Returned the same type of adjacent repository-level candidates; no exact local ExcelMcp CLI bridge | Evidence is insufficient to claim a second direct competitor. |

The raw search captures are stored beside this report:

- 'reports/skillsmp-excel-cli.json'
- 'reports/skillsmp-excel-mcp.json'

The unified qiaomu research helper initially could not resolve the PowerShell 'npx' shim from Python ('WinError 2'). The search was completed with the Windows executable shim 'npx.cmd'; this is a tooling limitation of the research runner, not evidence that the catalog is empty.

## References inspected

### 1. Official upstream Excel CLI Skill

Source: https://raw.githubusercontent.com/sbroenne/mcp-server-excel/main/skills/excel-cli/SKILL.md

Observed design:

- Windows desktop Excel is a real precondition.
- The normal lifecycle is create/open session, inspect, mutate, read back, then close.
- Session IDs must be captured and reused.
- The CLI exposes workbook, worksheet, range, table, chart, formatting, Power Query, DAX, and VBA operations.
- Batch mode and manual calculation are useful for larger edits.
- Errors should be read immediately after operations.

Decision:

- Keep the lifecycle, command-family map, and capability boundary.
- Adapt the execution layer for an agent Skill: deterministic executable resolution, upload/workbook discovery, copy-on-write protection, PowerShell-safe file inputs, screenshot evidence, and a fixed final handoff.
- Do not copy the upstream text as-is. In particular, the upstream inline JSON examples are fragile in Windows PowerShell; this package prefers '--values-file', '--formulas-file', and '--rows-file'.

### 2. Complementary 'claude-office-skills' Excel automation Skill

Source: https://raw.githubusercontent.com/claude-office-skills/skills/main/excel-automation/SKILL.md

Observed design:

- It treats Excel as a live application and emphasizes charts, formatting, formulas, VBA, and visual verification.
- It uses an 'xlwings'/Python-oriented runtime rather than 'excelcli.exe'.

Decision:

- Keep the emphasis on visual verification and chart/VBA workflows.
- Reject a second runtime framework in this package. Introducing xlwings would make the Skill less deterministic and would duplicate the installed ExcelMcp CLI capability.

## Keep / adapt / reject / invent

| Category | Decision | Concrete mechanism |
|---|---|---|
| Keep | Upstream session lifecycle | Resolve executable, open one session, discover before mutation, read back, close with explicit save choice. |
| Keep | Upstream command families | Sheet/range/table/chart/format/Power Query/DAX/VBA workflows are mapped in 'references/'. |
| Adapt | Upstream examples | Use PowerShell-safe JSON files instead of large inline JSON; use '-q' and 'ConvertTo-Json -InputObject'. |
| Adapt | Live-Excel visual check | Require screenshot evidence for chart/layout tasks and formula/error readback for data tasks. |
| Adapt | Generic agent instructions | Add Chinese trigger phrases, uploaded-file handling, copy-on-write, ambiguity pauses, and output contract. |
| Reject | Copying upstream Skill verbatim | It would not resolve the local binary or protect the uploaded original and it contains PowerShell-fragile input examples. |
| Reject | Second xlwings/Python framework | Adds dependency and runtime divergence when the requested 'excel-mcp-cli' is already available. |
| Reject | Automatic macro execution | VBA is high-impact and can change external state; import is supported, execution requires explicit user direction and a trust decision. |
| Reject | Runtime network install | The Skill uses the already-installed local CLI; network is not required during normal workbook operations. |
| Invent | Local executable resolver | 'scripts/resolve-excelcli.ps1' checks an explicit override, environment variable, PATH, known local locations, and the Codex workspace. |
| Invent | Copy-on-write helper | 'scripts/copy-workbook.ps1' refuses an existing target unless explicitly forced and prevents source/target identity mistakes. |
| Invent | Evidence-first output contract | Every task reports exact output path, changes, readback/screenshot evidence, warnings, and known limits. |
| Invent | Agent-facing workflow bridge | The user prompt names the operation; the Skill owns file discovery, session lifecycle, serialization, verification, and handoff. |

## Design claims

- Design advantage: fewer user-visible steps because PowerShell quoting, session handling, and cleanup are encoded in the Skill workflow.
- Validated advantage: the resolver, CLI version check, real workbook session open/read/close, and the existing chart demo run successfully on this Windows host; final machine-level Skill installation validation is recorded after the package is installed.
- Hypothesis: the fixed output contract and screenshot/readback rules will reduce silent spreadsheet mistakes in routine agent runs; this needs use across more workbooks to measure.

## Boundary

The package is for a Windows host with desktop Excel 2016 or later and a locally installed ExcelMcp CLI. It is not a promise of headless Linux/macOS operation, and it does not replace Excel's Trust Center, workbook permissions, external connection credentials, or user decisions about running VBA.

Copyright '(c) 向阳乔木'; X: https://x.com/vista8; GitHub: https://github.com/joeseesun/.
