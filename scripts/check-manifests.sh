#!/usr/bin/env bash
set -euo pipefail

# Fork check for the .claude-plugin manifests. Nothing here uses Claude Code,
# so upstream's `claude plugin validate` step does not apply; run this instead
# after touching marketplace.json or plugin.json.
#
# Errors (exit 1): either file is not valid JSON, a listed skill path is
# missing or ships no valid SKILL.md, or a fork-grouped skill also lands in
# plugin.json. Warnings (exit 0): promoted skills missing their README entry.

REPO="$(cd "$(dirname "$0")/.." && pwd)"

python3 - "$REPO" <<'EOF'
import json
import os
import re
import sys

repo = sys.argv[1]
plugin_dir = os.path.join(repo, ".claude-plugin")
errors = []
warnings = []


def load(name):
    path = os.path.join(plugin_dir, name)
    try:
        with open(path) as f:
            return json.load(f)
    except (OSError, json.JSONDecodeError) as e:
        errors.append(f"{name}: {e}")
        return None


market = load("marketplace.json")
plugin = load("plugin.json")
if errors:
    print("\n".join(errors))
    sys.exit(1)

market_groups = {
    p.get("name", "?"): p.get("skills", []) for p in market.get("plugins", [])
}
market_paths = [s for skills in market_groups.values() for s in skills]
plugin_paths = plugin.get("skills", [])

frontmatter = re.compile(r"\A---\n(.*?)\n---", re.DOTALL)


def check_skill(path, listed_in):
    skill_dir = os.path.normpath(os.path.join(repo, path.lstrip("./")))
    name = os.path.basename(skill_dir)
    md = os.path.join(skill_dir, "SKILL.md")
    if not os.path.isdir(skill_dir):
        errors.append(f"{listed_in}: missing directory {path}")
        return
    if not os.path.isfile(md):
        errors.append(f"{listed_in}: no SKILL.md under {path}")
        return
    with open(md) as f:
        head = f.read(2000)
    m = frontmatter.match(head)
    fields = {}
    if m:
        for line in m.group(1).splitlines():
            if ":" in line:
                k, v = line.split(":", 1)
                fields[k.strip()] = v.strip()
    if "name" not in fields or "description" not in fields:
        errors.append(f"{listed_in}: {path}/SKILL.md lacks name/description frontmatter")
    elif fields["name"] != name:
        errors.append(
            f"{listed_in}: {path}/SKILL.md names {fields['name']!r}, directory is {name!r}"
        )


for path in market_paths:
    check_skill(path, "marketplace.json")
for path in plugin_paths:
    check_skill(path, "plugin.json")

fork_grouped = set(market_groups.get("our-conventions", []))
in_both = fork_grouped & set(plugin_paths)
for path in sorted(in_both):
    errors.append(f"{path} is fork-grouped but also listed in plugin.json")

with open(os.path.join(repo, "README.md")) as f:
    readme = f.read()
for bucket in ("engineering", "productivity"):
    bucket_dir = os.path.join(repo, "skills", bucket)
    for name in sorted(os.listdir(bucket_dir)):
        if os.path.isfile(os.path.join(bucket_dir, name, "SKILL.md")):
            if f"{name}/SKILL.md" not in readme:
                warnings.append(f"skills/{bucket}/{name} has no top-level README.md entry")

for w in warnings:
    print(f"warning: {w}")
if errors:
    print("\n".join(f"error: {e}" for e in errors))
    sys.exit(1)
print(f"ok: {len(market_paths)} marketplace skills, {len(plugin_paths)} plugin skills")
EOF
