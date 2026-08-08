import json
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


class SkillPackageTests(unittest.TestCase):
    def test_required_files_exist(self):
        for relative in (
            "SKILL.md",
            "README.md",
            "agents/interface.yaml",
            "manifest.json",
            "evals/trigger_cases.json",
            "evals/output_cases.json",
            "reports/prior-art-research.md",
            "reports/creation-handoff.md",
            "reports/trigger-eval.json",
            "reports/skill-ir.json",
            "reports/output-evidence.json",
        ):
            self.assertTrue((ROOT / relative).is_file(), relative)

    def test_manifest_and_evidence_versions_match(self):
        manifest = json.loads((ROOT / "manifest.json").read_text(encoding="utf-8"))
        skill_ir = json.loads((ROOT / "reports/skill-ir.json").read_text(encoding="utf-8"))
        package = skill_ir["package"]
        self.assertEqual(manifest["name"], package["name"])
        self.assertEqual(manifest["version"], package["version"])
        self.assertEqual(manifest["maturity_tier"], "governed")

    def test_trigger_report_passes(self):
        report = json.loads((ROOT / "reports/trigger-eval.json").read_text(encoding="utf-8"))
        self.assertTrue(report["ok"])
        self.assertEqual(report["summary"]["total"], report["summary"]["passed"])
        self.assertEqual(report["summary"]["false_positive"], 0)
        self.assertEqual(report["summary"]["false_negative"], 0)

    def test_no_nested_skill_entrypoint(self):
        nested = [path for path in ROOT.rglob("SKILL.md") if path != ROOT / "SKILL.md"]
        self.assertEqual(nested, [])


if __name__ == "__main__":
    unittest.main()
