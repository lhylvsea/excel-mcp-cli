# VBA, Power Query, and Data Model boundaries

## VBA

Use a macro-enabled workbook with the .xlsm extension when importing or
preserving VBA. Work on a copy unless overwrite is explicit.

~~~powershell
& $cli -q session open 'C:\path\macros.xlsm'
$session = ...returned sessionId...

& $cli -q vba import --session $session --module-name 'MonthlySummary' --vba-code-file 'C:\path\monthly-summary.vba'

# Run only when the user explicitly asks to execute it:
& $cli -q vba run --session $session --procedure-name 'MonthlySummary.Build'

& $cli -q session close --session $session --save
~~~

The user must enable Excel Trust Center access to the VBA project object model
when the runtime requires it. Never change this security setting automatically.
Do not import or run code from an unknown source. Report whether the macro was
only written, inspected, or actually executed.

## Power Query

Prefer testing M code before persisting a permanent query:

~~~powershell
& $cli -q powerquery evaluate --session $session --m-code-file 'C:\path\query.m'
& $cli -q powerquery create --session $session --query-name 'CleanData' --m-code-file 'C:\path\query.m'
& $cli -q powerquery refresh --session $session --query-name 'CleanData'
~~~

Refresh can take longer than ordinary range operations. Use a generous timeout
and report refresh failures rather than saving an unverified result.

## Data Model and DAX

For DAX, confirm that a source Table is in the Data Model and that the local
MSOLAP/Analysis Services provider is available. The agent should not silently
replace DAX with ordinary worksheet formulas. If the provider is missing, report
the prerequisite and stop at the last verified state.

## External connections

Refreshing connections can change data outside the workbook. Perform it only
when requested, and report the connection/query name and refresh result.
