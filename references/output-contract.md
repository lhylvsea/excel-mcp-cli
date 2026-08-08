# Output contract

Every completed workbook operation must hand off the following information:

| Field | Required content |
|---|---|
| Source | Exact input path and file extension |
| Output | Exact output path; state whether source was preserved |
| Changes | Sheets, ranges, formulas, tables, charts, queries, or VBA touched |
| Evidence | Read-back values/formulas/object lists and success results |
| Visual proof | Screenshot path for chart/layout/formatting changes |
| Limits | Locks, missing providers, VBA Trust Center, unverified items |

Use this compact structure:

~~~text
已完成：<one-line result>
输入：<absolute path>
输出：<absolute path>; 原文件<保留/按用户要求覆盖>
修改：<short list>
验证：<read-back evidence and screenshot if applicable>
限制：<warnings or none>
~~~

Do not say “已完成” when only a command was launched. Require CLI success,
read-back evidence, and a clean session close.
