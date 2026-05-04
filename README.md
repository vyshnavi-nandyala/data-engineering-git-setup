# Data Engineering Git Setup

Professional Git configuration package for data engineering projects — beautiful colors, DE-specific aliases, pre-commit hooks, commit templates, and best practices.

## Quick Install (macOS)

```bash
git clone https://github.com/vyshnavi-nandyala/data-engineering-git-setup.git
cd data-engineering-git-setup
bash install.sh
```

Verify everything is working:
```bash
bash setup.sh
```

---

## What Gets Installed

| File | Destination | Purpose |
|---|---|---|
| `.gitconfig` | `~/.gitconfig` | Colors, aliases, settings |
| `.gitmessage` | `~/.gitmessage` | Commit message template |
| `.gitignore-data-engineering` | `~/.gitignore-data-engineering` | Global ignores for data files |
| `hooks/pre-commit` | `~/.git-hooks/pre-commit` | Pre-commit safety checks |

---

## Before & After

### `git status` — Before
```
On branch feature/add-ingestion
Changes not staged for commit:
  modified:   src/pipeline.py
  modified:   data/raw/sales.csv
Untracked files:
  logs/run.log
```

### `git de-status` — After
```
## feature/add-ingestion...origin/feature/add-ingestion
 M src/pipeline.py
?? logs/run.log

── Stashes ──
stash@{0}: WIP on feature/add-ingestion: a1b2c3d fix null handling
```

---

### `git log` — Before
```
commit a1b2c3d4e5f6
Author: Dev <dev@example.com>
Date:   Mon Jan 15 10:30:00 2024

    add parquet support
```

### `git de-log` — After
```
* a1b2c3d (2024-01-15 10:30) feat(data-ingestion): add parquet support [Dev] (HEAD -> main)
* 9f8e7d6 (2024-01-14 16:45) fix(pipeline): handle null order_date [Dev]
* 5c4b3a2 (2024-01-13 09:00) perf(transformation): partition by date [Dev]
```

---

## Aliases Reference

### Data Engineering Aliases

| Alias | Command | Description |
|---|---|---|
| `git de-status` | `git status -sb` + stash list | Enhanced status |
| `git de-log` | Graph log with colors | Pretty commit history |
| `git de-branch` | Branch list with icons | Branches with emoji icons |
| `git de-diff` | `git diff --stat --color` | Colored diff summary |
| `git de-commit` | Commit with template | Opens `.gitmessage` template |
| `git de-push` | Push + set upstream | Safe push with branch name |
| `git de-review` | Show staged diff | Review before committing |
| `git de-pipeline` | Log filtered for pipeline | Pipeline-related commits |
| `git de-data` | Log filtered for data | Data-change commits |
| `git de-schema` | Log filtered for schema | Schema-change commits |
| `git graph` | `--graph --oneline --all` | ASCII commit graph |
| `git standup` | Last 7 days | Weekly summary |
| `git today` | Last 24 hours | Today's commits |

### Standard Shortcuts

| Alias | Expands to |
|---|---|
| `git st` | `git status -sb` |
| `git co` | `git checkout` |
| `git br` | `git branch -vv` |
| `git cm "msg"` | `git commit -m "msg"` |
| `git amend` | `git commit --amend --no-edit` |
| `git unstage <file>` | `git reset HEAD <file>` |
| `git last` | `git log -1 HEAD --stat` |
| `git undo` | `git reset --soft HEAD~1` |
| `git graph` | `git log --graph --oneline --all` |
| `git standup` | Commits from last 7 days |
| `git clean-branches` | Delete merged local branches |

---

## Commit Message Convention

Format: `<type>(<scope>): <subject>`

### Types

| Type | When to use |
|---|---|
| `feat` | New feature or capability |
| `fix` | Bug fix |
| `refactor` | Code restructure (no behaviour change) |
| `perf` | Performance improvement |
| `docs` | Documentation only |
| `test` | Add or update tests |
| `chore` | Build, deps, tooling |
| `data` | Data file or dataset changes |
| `schema` | Database/table schema changes |
| `revert` | Revert a previous commit |

### Scopes

`data-ingestion` · `transformation` · `pipeline` · `quality` · `deployment` · `monitoring` · `infrastructure` · `dbt` · `airflow` · `glue` · `redshift` · `s3`

### Examples

```
feat(data-ingestion): add support for Parquet file format
fix(pipeline): handle null values in order_date column
perf(transformation): partition by date to reduce S3 scan cost
schema(dbt): add customer_tier column to dim_customers
refactor(quality): extract validator into reusable class
chore(deps): upgrade pandas to 2.1.0
data(s3): update sample dataset for 2024 Q1
test(pipeline): add unit tests for incremental processing
```

---

## Pre-commit Hook Checks

Every `git commit` automatically runs:

| Check | What it does | On failure |
|---|---|---|
| Branch protection | Blocks commits directly to `main`/`master` | Hard block |
| Secret detection | Scans for AWS keys, passwords, tokens | Hard block |
| Large file check | Warns if files >5MB or data extensions staged | Warning |
| Python syntax | Runs `py_compile` on staged `.py` files | Hard block |
| Commit message | Validates `type(scope): subject` format | Warning |

To skip hooks in an emergency (not recommended):
```bash
git commit --no-verify -m "emergency fix"
```

---

## Branching Strategy

```
main          ←── production-ready, protected
  └── develop ←── integration branch
        ├── feat/add-parquet-ingestion
        ├── fix/null-handling-order-date
        ├── data/update-q1-sample-data
        ├── schema/add-customer-tier-column
        └── perf/partition-by-date
```

### Branch Naming

| Prefix | Use for |
|---|---|
| `feat/` | New features |
| `fix/` | Bug fixes |
| `data/` | Data updates |
| `schema/` | Schema migrations |
| `perf/` | Performance work |
| `refactor/` | Refactoring |
| `docs/` | Documentation |
| `chore/` | Maintenance |

---

## Tracking Data Schema Changes

Use `git de-schema` to find all schema-related commits:
```bash
git de-schema
# shows commits matching: schema|migration|alter|table|column|dbt|model
```

Tag schema versions for easy rollback:
```bash
git tag -a schema-v1.2 -m "schema: add customer_tier, refund_count columns"
git push origin --tags
```

---

## Manual Installation (step-by-step)

```bash
# 1. Copy gitconfig
cp .gitconfig ~/.gitconfig

# 2. Set your identity
git config --global user.name "Your Name"
git config --global user.email "you@example.com"

# 3. Install commit template
cp .gitmessage ~/.gitmessage
git config --global commit.template ~/.gitmessage

# 4. Install pre-commit hook globally
mkdir -p ~/.git-hooks
cp hooks/pre-commit ~/.git-hooks/pre-commit
chmod +x ~/.git-hooks/pre-commit
git config --global core.hooksPath ~/.git-hooks

# 5. Install global gitignore
cp .gitignore-data-engineering ~/.gitignore-data-engineering
git config --global core.excludesFile ~/.gitignore-data-engineering

# 6. Verify
bash setup.sh
```

---

## Troubleshooting

**Aliases not working**
```bash
git config --global --list | grep alias
# If empty: re-run install.sh --force
```

**Pre-commit hook not running**
```bash
git config --global core.hooksPath
# Should print: /Users/<you>/.git-hooks
ls -la ~/.git-hooks/pre-commit
# Should be executable (-rwxr-xr-x)
```

**Colors not showing in terminal**
```bash
git config --global color.ui always
# Or add to ~/.bashrc / ~/.zshrc:
export TERM=xterm-256color
```

**`git de-log` shows no output**
```bash
# Make sure you have at least one commit:
git log --oneline
```
