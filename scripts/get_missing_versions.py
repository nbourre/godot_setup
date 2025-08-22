import os
import requests
import re
import json
from dotenv import load_dotenv

load_dotenv()

# Set your GitHub token and repo here for local testing
#GH_TOKEN = os.environ.get('GH_TOKEN', '<your_github_token>')
GH_TOKEN = os.environ.get('gh_token')
REPO = os.environ.get('REPO', 'nbourre/godot_setup')

headers = {
    "Authorization": f"token {GH_TOKEN}",
    "Accept": "application/vnd.github+json",
}

godot_resp = requests.get("https://api.github.com/repos/godotengine/godot/releases", headers=headers)
godot_resp.raise_for_status()
godot_releases = godot_resp.json()
stable = [r for r in godot_releases if not r.get('prerelease', False) and not r.get('draft', False)]
tags = [r['tag_name'].lstrip('v') for r in stable]

versions = []
for t in tags:
    m = re.match(r'(\d+)\.(\d+)(?:\.(\d+))?', t)
    if m:
        major, minor, patch = m.groups()
        minor = minor or '0'
        patch = patch or '0'
        versions.append((int(major), int(minor), int(patch), t))

latest_per_major = {}
for v in sorted(versions, reverse=True):
    major = v[0]
    if major not in latest_per_major:
        latest_per_major[major] = v[3]

repo_resp = requests.get(f"https://api.github.com/repos/{REPO}/releases", headers=headers)
repo_resp.raise_for_status()
repo_releases = repo_resp.json()
repo_tags = set(r['tag_name'].lstrip('v') for r in repo_releases)

missing = [tag for _, tag in sorted(latest_per_major.items()) if tag not in repo_tags]
print(f"Missing major versions: {missing}")
with open('missing_versions.json', 'w') as f:
    json.dump(missing, f)
print("Saved missing versions to missing_versions.json")
