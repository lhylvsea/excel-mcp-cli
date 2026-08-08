# excel-mcp-cli

让 Codex、Claude Code、Cursor 等智能体通过本机 ExcelMcp CLI 直接操作真实
Microsoft Excel：读写单元格、写公式、创建图表、格式化、Table、PivotTable、
Power Query、DAX、VBA、截图和批量工作簿处理。

## 适用条件

- Windows 10/11 或 Windows Server 桌面环境；
- Microsoft Excel 2016+ 已安装；
- 已有 ExcelMcp CLI 可执行文件 excelcli.exe；
- 适合用户上传或指定的 xlsx/xlsm 工作簿；
- 不适合 Linux/macOS、无桌面服务器、纯解析任务或高并发批处理。

## 安装到 Codex

公开仓库 Skill 的安装命令是 `npx skills add lhylvsea/excel-mcp-cli --skill excel-mcp-cli`；本包当前是本机安装包，因此使用下面的本地复制命令，也可以直接从该公开仓库安装。
上游项目与命令说明：https://github.com/sbroenne/mcp-server-excel

将整个 skill 目录复制到 Codex 的 skills 目录：

~~~powershell
$target = Join-Path $env:USERPROFILE '.codex\skills\excel-mcp-cli'
Copy-Item -LiteralPath '<this-package-directory>' -Destination $target -Recurse -Force
~~~

当前本机的 CLI 路径是：

~~~powershell
$env:EXCELMCP_CLI = 'C:\path\to\excelcli.exe'
~~~

Skill 自带的 resolve-excelcli.ps1 也会搜索 PATH、C:\Tools\ExcelMcp 和
Documents\Codex 下的已安装版本；不设置 EXCELMCP_CLI 也可以工作。

安装后重启 Codex，使新的 Skill 元数据重新加载。当前对话已经验证了包文件，
但新 Skill 是否被当前正在运行的会话热加载，取决于客户端。

## 触发词与调用方式

不需要用户手动执行 PowerShell。上传 Excel 后直接说目标，例如：

1. “使用 excel-mcp-cli 打开这个生产报表，在销售额区域增加一个柱形图，保存为新文件，并给我截图。”
2. “使用 excelcli 给这张产量表补充销售额公式，检查合计是否正确，不要覆盖原文件。”
3. “使用 excel-mcp-cli 在这个 xlsm 中新增一个 VBA 模块，写入月度汇总宏；先不要运行宏。”
4. “使用 excel-mcp-cli 把这个目录里的工作簿统一设置表头、数字格式和自动列宽，并逐个报告输出文件。”

智能体应自行完成：定位文件、保护原件、打开 session、发现工作表、执行命令、
读回验证、截图和保存关闭。

## 中文使用说明

- 输入：上传或指定一个 xlsx/xlsm，并说明要修改的工作表、范围、公式、图表、宏或批处理目标。
- 主要流程：解析文件、复制原件、解析 CLI、打开一个 session、先发现再修改、读回验证、按需截图、保存并关闭。
- 产物：输出工作簿副本、公式或对象的读回证据、图表或版式截图，以及警告和限制。
- 验证：检查关键值、公式结果、错误单元格、对象名称和 Excel 进程清理状态。

## 示例应用场景

1. 给销售明细增加柱形图并保存副本。
2. 为产量和金额列写公式，核对合计并报告读回值。
3. 在 xlsm 中导入 VBA 模块，但在用户明确决定前不运行宏。
4. 批量格式化目录内的工作簿并逐个输出验证结果。

## 重要行为

- 默认保留原始文件，输出到副本；
- 所有命令共享一个 session ID；
- 修改后必须读回验证；
- 图表或版式修改后必须截图检查；
- PowerShell 下优先使用 JSON 文件参数；
- VBA 不会自动开启 Trust Center 设置；
- 目标文件被 Excel 占用时不强杀用户进程；
- 完成后必须关闭 session，避免残留 Excel 锁。

## 注意事项与限制

- 需要 Windows 桌面版 Excel 2016+ 和本机 excelcli.exe；不支持 Linux/macOS 无桌面服务器。
- 默认不覆盖上传原件；工作簿被 Excel 占用时先提示用户关闭，不强杀可见 Excel。
- VBA、Power Query、外部连接和覆盖原文件都可能产生外部影响；宏运行与 Trust Center 设置必须由用户明确决定。

## 验证

~~~powershell
python scripts/validate_skill.py .
python scripts/trigger_eval.py . --cases evals/trigger_cases.json
python scripts/export_skill_ir.py . --output reports/skill-ir.json
python scripts/release_check.py . --phase local --run-tests
~~~

运行时可先检查 CLI：

~~~powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/resolve-excelcli.ps1
~~~

## Troubleshooting / 故障排查

- 找不到 excelcli：设置 EXCELMCP_CLI，或把 CLI 所在目录加入 PATH；
- Workbook is locked：关闭目标 workbook 的其他 Excel 窗口；
- VBA access denied：用户在 Excel Trust Center 中启用对应设置；
- DAX/DMV 失败：检查 MSOLAP/Power BI Desktop 组件；
- 文件不存在：停止并报告确切路径，不要猜路径或重复重试；
- 修改后未保存：检查 session close 是否带 --save，以及是否读回成功。

版权与署名：Copyright (c) 向阳乔木  
https://x.com/vista8  
https://github.com/joeseesun/

<!-- qiaomu-meta-skill legacy natural-example marker: 你可以直接这样说 -->
