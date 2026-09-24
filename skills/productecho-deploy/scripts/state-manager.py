#!/usr/bin/env python3
"""ProductEcho Local Project State Manager.

Maintains bidirectional state linking at <target_root>/.productecho/state.json
and ensures .productecho/ is added to .gitignore.
"""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

STATE_DIR_NAME = ".productecho"
STATE_FILE_NAME = "state.json"
GITIGNORE_ENTRY = ".productecho/"


def get_state_file_path(target_root: Path) -> Path:
    return target_root / STATE_DIR_NAME / STATE_FILE_NAME


def ensure_gitignore(target_root: Path) -> bool:
    """Ensure .productecho/ is present in .gitignore at target_root or git root."""
    gitignore_path = target_root / ".gitignore"
    if not gitignore_path.exists():
        gitignore_path.write_text(f"{GITIGNORE_ENTRY}\n", encoding="utf-8")
        print(f"Created .gitignore with {GITIGNORE_ENTRY} at {gitignore_path}")
        return True

    content = gitignore_path.read_text(encoding="utf-8")
    for line in content.splitlines():
        cleaned = line.strip().rstrip("/")
        if cleaned in (".productecho", "/.productecho"):
            return False

    separator = "" if content.endswith("\n") or not content else "\n"
    gitignore_path.write_text(f"{content}{separator}{GITIGNORE_ENTRY}\n", encoding="utf-8")
    print(f"Added {GITIGNORE_ENTRY} to {gitignore_path}")
    return True


def detect_remote_repo(target_root: Path) -> str | None:
    """Detect git remote origin slug 'owner/repo'."""
    try:
        res = subprocess.run(
            ["git", "config", "--get", "remote.origin.url"],
            cwd=target_root,
            capture_output=True,
            text=True,
            check=False,
        )
        url = res.stdout.strip()
        if not url:
            return None
        cleaned = url.removesuffix(".git").rstrip("/")
        match = re.search(r"[:/]([a-zA-Z0-9_.-]+/[a-zA-Z0-9_.-]+)$", cleaned)
        return match.group(1) if match else None
    except Exception:
        return None


def read_state(target_root: Path) -> dict | None:
    path = get_state_file_path(target_root)
    if not path.exists():
        return None
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except Exception as exc:
        print(f"Error reading state file {path}: {exc}", file=sys.stderr)
        return None


def write_state(
    target_root: Path,
    app_name: str,
    db_id: str | None = None,
    root_dir: str | None = None,
    remote_repo: str | None = None,
) -> Path:
    state_dir = target_root / STATE_DIR_NAME
    state_dir.mkdir(parents=True, exist_ok=True)
    state_file = state_dir / STATE_FILE_NAME

    existing = read_state(target_root) or {}
    now_iso = datetime.now(timezone.utc).isoformat()

    final_repo = remote_repo or existing.get("remote_repo") or detect_remote_repo(target_root)
    final_db = db_id if db_id is not None else existing.get("db_identifier")
    final_root = root_dir if root_dir is not None else existing.get("root_directory")

    payload = {
        "version": "1.0",
        "application_name": app_name,
        "db_identifier": final_db,
        "root_directory": final_root,
        "remote_repo": final_repo,
        "updated_at": now_iso,
    }

    state_file.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    ensure_gitignore(target_root)
    return state_file


def main() -> None:
    parser = argparse.ArgumentParser(description="ProductEcho Project State Manager")
    subparsers = parser.add_subparsers(dest="command", required=True)

    # get command
    get_p = subparsers.add_parser("get", help="Read project state")
    get_p.add_argument("--path", default=".", help="Target root directory")

    # set command
    set_p = subparsers.add_parser("set", help="Write/update project state")
    set_p.add_argument("--path", default=".", help="Target root directory")
    set_p.add_argument("--app", required=True, help="ProductEcho application name")
    set_p.add_argument("--db", default=None, help="Linked PostgreSQL db_identifier")
    set_p.add_argument("--root-dir", default=None, help="Monorepo root directory")
    set_p.add_argument("--repo", default=None, help="GitHub repository slug (owner/repo)")

    # ensure-gitignore command
    gi_p = subparsers.add_parser("check-gitignore", help="Ensure .productecho/ is in .gitignore")
    gi_p.add_argument("--path", default=".", help="Target root directory")

    # detect-repo command
    dr_p = subparsers.add_parser("detect-repo", help="Detect remote git repo slug")
    dr_p.add_argument("--path", default=".", help="Target root directory")

    args = parser.parse_args()
    target_path = Path(args.path).resolve()

    if args.command == "get":
        state = read_state(target_path)
        if state is None:
            print(f"No .productecho/state.json found in {target_path}", file=sys.stderr)
            sys.exit(1)
        print(json.dumps(state, indent=2))

    elif args.command == "set":
        file_path = write_state(
            target_root=target_path,
            app_name=args.app,
            db_id=args.db,
            root_dir=args.root_dir,
            remote_repo=args.repo,
        )
        print(f"Project state persisted at {file_path}")

    elif args.command == "check-gitignore":
        modified = ensure_gitignore(target_path)
        print("Gitignore verified." if not modified else ".gitignore updated with .productecho/")

    elif args.command == "detect-repo":
        repo = detect_remote_repo(target_path)
        if repo:
            print(repo)
        else:
            print("No remote git repository detected.", file=sys.stderr)
            sys.exit(1)


if __name__ == "__main__":
    main()
