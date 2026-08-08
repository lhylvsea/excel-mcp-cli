# excel-mcp-cli 中文使用说明

## 触发词与调用方式

上传或指定 Excel 文件后，直接说“使用 excel-mcp-cli”或“使用 excelcli”，再描述要做的事情即可。也可以说“用 Excel MCP CLI 操作这个表格”“给上传的 Excel 增加图表”“写公式”“写宏”“写 VBA”“格式化”“刷新 Power Query”或“批量修改工作簿”。

## 主要流程

Skill 会定位准确的 xlsx/xlsm，默认复制原件，解析本机 excelcli.exe，打开一个 session，先读取工作表和目标范围，再执行修改，读回关键值/公式/错误，必要时截图，最后按验证结果保存并关闭 session。

## 示例应用场景

1. “使用 excel-mcp-cli 给这个销售明细增加销售额柱形图，保存为新文件并截图。”
2. “使用 excelcli 给数量和单价写收入公式，核对总计，不能覆盖原文件。”
3. “使用 Excel MCP CLI 在这个 xlsm 中导入 VBA 模块，先不要运行宏。”
4. “使用 excel-mcp-cli 批量格式化这个目录中的工作簿，并逐个报告输出路径。”

## 产物与验证

默认产物是输出工作簿副本；图表或版式任务还会给出 PNG 截图。交付说明会列出实际输出路径、变更范围、公式和数值读回、对象名称、截图路径、警告以及未验证能力。

## 注意事项与限制

- 需要 Windows 桌面版 Excel 2016+ 和本机 excelcli.exe；不支持 Linux/macOS 无桌面服务器。
- 默认不覆盖上传原件；文件被 Excel 占用时要求用户关闭目标工作簿，不强杀可见 Excel 进程。
- VBA、Power Query、DAX、外部连接和宏运行受 Excel Trust Center、组件、权限和凭据影响。
- “写入 VBA”与“运行 VBA”是两种不同操作；除非用户明确要求且风险已确认，Skill 不自动运行宏。
