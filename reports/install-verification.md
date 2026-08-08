# Install verification

This report records host-local verification without publishing machine-specific
paths, usernames, workbook attachments, or private logs.

- Package entrypoint: repository root SKILL.md
- Discovery: direct Codex Skill entrypoint verified on the reference Windows host
- Chinese discovery, usage, examples, notes, and boundaries: verified
- qiaomu-meta-skill package validation: passed
- Public clean-install verification: performed by the release workflow after the
  repository and tagged release are available

The published package requires Windows desktop Excel 2016 or later and a
locally installed ExcelMcp CLI. Host-specific executable paths are resolved at
runtime through EXCELMCP_CLI, PATH, known installation locations, and the
user's local workspace.
