# ExcelMcp CLI workflows

Use this file only after the task has triggered the skill and the target workbook
has been identified. Command names and flags are for the installed standalone
ExcelMcp CLI; run the live command help when a version differs.

## Session lifecycle

~~~powershell
$cli = 'C:\path\to\excelcli.exe'
$open = (& $cli -q session open 'C:\path\input.xlsx' | ConvertFrom-Json)
$session = $open.sessionId

& $cli -q sheet list --session $session
& $cli -q range get-values --session $session --sheet 'Sheet1' --range 'A1:D20'

# save only after validation
& $cli -q session close --session $session --save
~~~

For a new workbook use session create. Never reuse a session ID from another
process. If a command fails, list/close the session and report the failure.

## PowerShell JSON input

Prefer files because PowerShell can remove double quotes when passing inline JSON
to a native executable:

~~~powershell
$values = @(
  @('Product', 'Quantity', 'Unit Price'),
  @('Bentonite', 120, 680),
  @('Kaolin', 85, 920)
)
$valuesFile = Join-Path $env:TEMP 'excelmcp-values.json'
ConvertTo-Json -InputObject $values -Depth 5 |
  Set-Content -LiteralPath $valuesFile -Encoding UTF8

& $cli -q range set-values --session $session --sheet 'Sheet1' --range 'A1:C3' --values-file $valuesFile
~~~

For formulas use a two-dimensional formulas file and range set-formulas. Read
back both formulas and calculated values.

## Formula workflow

1. Read the target range and nearby headers.
2. Decide relative/absolute references and locale-safe function names.
3. Write formulas with range set-formulas.
4. Recalculate if calculation mode was manual.
5. Read formulas and values, and check cellErrors.
6. Save only after the result matches the requested logic.

For 10 or more writes, use calculationmode manual, perform writes, calculate at
workbook scope, and restore automatic. Use batch mode for long workflows.

## Table and chart workflow

~~~powershell
& $cli -q table create --session $session --sheet 'Sheet1' --table-name 'SalesTable' --range 'A1:D20' --has-headers true --table-style 'TableStyleMedium2'

& $cli -q chart create-from-range --session $session --sheet 'Sheet1' --source-range-address 'A1:B20' --chart-type 'ColumnClustered' --target-range 'F2:M16'

& $cli -q screenshot capture --session $session --sheet 'Sheet1' --range 'A1:M20' --quality High --output 'C:\path\verification.png'
~~~

Use target-range positioning where possible. The chart command may warn about
collisions; always capture a range that includes both source data and chart.

## Formatting workflow

Use one complete format-range call per target range:

~~~powershell
& $cli -q rangeformat format-range --session $session --sheet 'Sheet1' --range 'A1:D1' --bold true --font-color '#FFFFFF' --fill-color '#1F4E78' --horizontal-alignment center --vertical-alignment center --wrap-text true

& $cli -q range set-number-format --session $session --sheet 'Sheet1' --range 'C2:D20' --format-code '#,##0.00'
~~~

Autofit after data and headers are in place. Capture a screenshot when layout
quality matters.

## Discovery and error handling

- Use sheet list, table list, and chart list before creating objects with names.
- If the path is missing, stop and report it; do not retry a guessed path.
- If Excel reports a lock, ask the user to close the target workbook.
- Do not terminate visible user Excel processes.
- Do not hide errors by saving an unverified workbook.
