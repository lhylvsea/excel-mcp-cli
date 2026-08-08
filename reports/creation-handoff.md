# Creation handoff: excel-mcp-cli 0.1.0

## 1. Result

- Skill: 'excel-mcp-cli' 0.1.0
- Job: let an agent operate a supplied '.xlsx' or '.xlsm' through the local ExcelMcp CLI, including formulas, charts, formatting, Tables, PivotTables, Power Query, DAX, VBA, screenshots, and batch edits.
- Local package path: repository root (host-specific path intentionally omitted from the public package)
- Publication status: prepared for public GitHub publication; private host installation details are intentionally omitted.

## 2. Reference skills studied

- Official upstream 'sbroenne/mcp-server-excel@excel-cli', source https://raw.githubusercontent.com/sbroenne/mcp-server-excel/main/skills/excel-cli/SKILL.md. The catalog signal observed on 2026-08-08 was 865 skills.sh installs for the 'excel-cli' entry; this is an adoption signal, not a quality score. Learned the Excel session lifecycle, command families, calculation controls, error readback, and workbook close discipline. Applied in 'SKILL.md' and 'references/cli-workflows.md'.
- 'claude-office-skills/skills@excel-automation', source https://raw.githubusercontent.com/claude-office-skills/skills/main/excel-automation/SKILL.md. The catalog signal observed on 2026-08-08 was 13.7K skills.sh installs for the adjacent automation entry; this is an adoption signal, not a quality score. Learned the emphasis on charts, VBA, and visual verification. Applied as screenshot/readback requirements in 'SKILL.md' and 'references/output-contract.md'; its xlwings runtime was not adopted.

## 3. Absorbed and rejected

- Keep: one-session lifecycle, discover-before-mutate, command-family routing, immediate readback, explicit close/save.
- Adapt: inline JSON examples became PowerShell-safe '--values-file', '--formulas-file', and '--rows-file' workflows; Chinese triggers, uploaded-file discovery, copy-on-write, screenshot evidence, and final output contract were added.
- Reject: copying the upstream Skill verbatim, adding an xlwings/Python runtime, automatic macro execution, and runtime network installation.
- Invent: local executable resolver, source-copy helper, agent-facing workflow bridge, and evidence-first output contract.

## 4. Advantages and highlights

- [design advantage] This package explicitly connects a natural-language workbook request to executable resolution, session lifecycle, PowerShell-safe serialization, readback, screenshot evidence, and cleanup.
- [validated advantage] The trigger suite passed 13/13 cases with zero false positives and zero false negatives; the local ExcelMcp CLI v1.10.5 opened, read, and closed a real workbook successfully.
- [hypothesis] Copy-on-write plus a required output contract is expected to reduce accidental source overwrites and silent spreadsheet mistakes; comparison across multiple user workbooks is missing evidence.

## 5. Verification and limits

- Package structure: validated by qiaomu-meta-skill 'validate_skill.py'.
- Trigger behavior: 'reports/trigger-eval.json'.
- Skill IR: 'reports/skill-ir.json'.
- Runtime evidence: 'reports/output-evidence.json' after the local smoke test.
- Machine installation evidence: 'reports/install-verification.md' after copying into the Codex Skill directory.
- Limits: Windows desktop Excel 2016+, local 'excelcli.exe', workbook permissions, external connection credentials, Excel Trust Center, and user decisions about running VBA remain required. Headless Linux/macOS/server execution is excluded.
