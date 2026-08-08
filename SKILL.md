---
name: excel-mcp-cli
description: '使用本机 ExcelMcp CLI（excelcli）操作真实 Microsoft Excel 工作簿。触发词包括：使用 excel-mcp-cli、使用 excelcli、用 Excel MCP CLI 操作这个表格、给上传的 Excel 增加图表、写公式、写宏、写 VBA、格式化、刷新 Power Query、批量修改工作簿。适用于 Windows 桌面版 Excel 2016+ 与 .xlsx/.xlsm；不适用于 Linux/macOS 无桌面服务器、纯解释、pandas/openpyxl-only 或非 Excel 文件。'
---

# ExcelMcp CLI workbook automation

Use the installed ExcelMcp CLI as the execution adapter. Keep the user-facing
interaction natural-language-first: the user should describe the workbook task,
while the agent resolves the CLI, runs the session workflow, validates the
result, and reports the output file.

## Required workflow

1. Resolve the executable before doing workbook work:

   ~~~powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File <skill-root>\scripts\resolve-excelcli.ps1
   ~~~

   Use the returned path for every command. Respect EXCELMCP_CLI when set.
   Do not silently install another Excel automation runtime.

2. Identify the exact uploaded or named workbook path with read-only discovery
   using "rg --files -g '*.xlsx' -g '*.xlsm'" or the app-provided attachment path.
   If there are multiple plausible files, use the filename and user context; ask
   only when the ambiguity would change the target. Never guess a username or
   invent a path.

3. Preserve the original by default. For edits, create a sibling/output copy
   with the same extension (.xlsx or .xlsm) unless the user explicitly asks
   to overwrite the source. Do not alter or delete the source implicitly.

4. Check for an existing Excel lock before opening. If the target workbook is
   open in a visible Excel window, ask the user to close it. Do not terminate
   user-visible Excel processes. ExcelMcp requires exclusive COM access.

5. Start exactly one session:

   - New workbook: session create FILE
   - Existing workbook: session open FILE
   - Parse the JSON sessionId; never guess it.
   - Use the same session ID for every subsequent command.

6. Discover before mutating:

   - sheet list
   - table list
   - chart list
   - targeted range values/formulas
   - relevant workbook features when using Power Query, DAX, PivotTables, or VBA

   Use the smallest range that answers the question. Do not overwrite a range
   before reading it unless the user explicitly supplies replacement content.

7. Apply the requested operation using CLI command groups:

   - Values/formulas: range set-values and range set-formulas.
   - Formatting: rangeformat format-range, rangeformat auto-fit-columns, and
     range set-number-format.
   - Tables: table create, table list, table resize, table set-style.
   - Charts: chart create-from-range or chart create-from-table; prefer
     target-range positioning.
   - Sheets: sheet list/create/rename/copy/delete.
   - Bulk writes: calculationmode set-mode manual, write, calculate, then restore
     automatic. Use batch mode for long multi-command workflows.
   - Power Query/DAX/PivotTables: read references/cli-workflows.md first.
   - VBA: read references/vba-and-powerquery.md first; use .xlsm and a code file.

   In Windows PowerShell, prefer values-file/formulas-file/rows-file over inline
   JSON. Native executable argument handling can strip JSON double quotes.

8. Validate every material change:

   - Read back values and formulas.
   - Confirm formulas have expected results and no cell errors.
   - List the created/changed Table, chart, worksheet, query, or macro.
   - For visual changes, capture the relevant range or sheet to PNG and inspect
     it; include the screenshot path in the handoff.
   - For VBA, report that execution requires the user's Excel Trust Center
     setting; never enable that setting automatically.

9. Always close the session in a finally-style cleanup:

   - Save only after the requested changes and read-back checks pass.
   - Use session close --save for a successful edit; omit --save to discard a
     failed/aborted test.
   - If a command fails, query session list and close the known session before
     ending. Report any remaining lock or Excel process instead of hiding it.

## Output contract

Finish with:

- exact output workbook path and whether the original was preserved;
- concise list of changes;
- read-back evidence: key values, formulas, object names, or counts;
- screenshot path when a chart/layout/formatting change was requested;
- warnings or missing prerequisites, especially Excel lock, VBA trust, MSOLAP,
  unsupported platform, or unverified visual quality.

Do not claim that an Excel file was edited unless the CLI returned success and
the changed content was read back. Do not claim a macro was executed unless the
runtime returned success.

## Capability boundary

This skill controls the installed desktop Excel through COM. It is not a file
parser, a Linux service, or a safe substitute for reviewing unknown macros.
Treat VBA import/run, Power Query refresh, external connections, and workbook
overwrite as consequential actions: perform them only when requested and report
the exact scope.

Copyright (c) 向阳乔木
https://x.com/vista8
https://github.com/joeseesun/
