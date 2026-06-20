# Contributing to r-lib/gargle: The Complete usethis `pr_*` Workflow

This guide walks through the full contributor workflow using the `usethis` package — from forking and cloning `r-lib/gargle`, to creating a feature branch, making changes, submitting a pull request, handling review feedback, and cleaning up after merge.

---

## Prerequisites

Before starting, make sure your Git and GitHub setup is in order:

```r
library(usethis)

# Check your Git/GitHub health
git_sitrep()
```

`git_sitrep()` reports on your current Git and GitHub configuration — both at the user level and project level. It will tell you whether your `user.name` and `user.email` are set, whether a GitHub Personal Access Token (PAT) is discovered, and which protocol (HTTPS vs SSH) is active.

If you need to configure your Git identity:

```r
use_git_config(
  user.name  = "Your Name",
  user.email = "you@example.com"
)
```

If you don't yet have a GitHub PAT (or need a new one):

```r
create_github_token()
```

This opens a browser to GitHub's token-generation form with recommended scopes (`repo`, `user`, `gist`, `workflow`) pre-selected. Store the token securely (e.g., in the git credential store or as an environment variable).

Finally, it's good practice to vaccinate your global `.gitignore` against common accidental commits:

```r
git_vaccinate()
```

This adds `.Rproj.user`, `.Rhistory`, `.Rdata`, `.httr-oauth`, `.DS_Store`, and `.quarto` to your global `.gitignore`.

---

## Step 1 — Fork and Clone with `create_from_github()`

```r
library(usethis)

create_from_github("r-lib/gargle")
```

### What this does

`create_from_github()` accepts a `repo_spec` — here `"r-lib/gargle"`, though it also accepts full URLs like `"https://github.com/r-lib/gargle"`. When called on a repo you **cannot** push to (which is the case for `r-lib/gargle` unless you're a maintainer), it defaults to `fork = TRUE` and performs a **fork-and-clone**:

1. **Forks** `r-lib/gargle` into your own GitHub account (e.g., `yourusername/gargle`).
2. **Clones** your fork locally into a new directory (named after the repo, placed in `destdir` or a conspicuous default location like your Desktop).
3. Sets the **`origin` remote** to point to your fork.
4. Sets the **`upstream` remote** to point to the original `r-lib/gargle` source repo.
5. Sets the local **default branch** (typically `main`) to **track `upstream/main`** and immediately pulls, so your local default branch is up-to-date even if your fork was stale.
6. Opens the project in RStudio if applicable.

After this call you are on the default branch (`main`), synced with `upstream`, and in the perfect position to start a PR with `pr_init()`.

### Useful optional arguments

| Argument | Purpose |
|----------|---------|
| `destdir` | Destination directory for the clone. Defaults to `usethis.destdir` option or a conspicuous location. |
| `fork = TRUE` | Force fork-and-clone behaviour. |
| `protocol = "https"` | Use HTTPS (default) or `"ssh"` for Git operations. |
| `host` | For GitHub Enterprise instances; auto-detected from URL specs. |

```r
# Example with explicit destination and HTTPS protocol
create_from_github(
  "r-lib/gargle",
  destdir = "~/projects",
  protocol = "https"
)
```

---

## Step 2 — Create a Feature Branch with `pr_init()`

```r
pr_init(branch = "fix-token-refresh")
```

### What this does

`pr_init()` is the contributor's entry point into the PR workflow. It:

1. **Ensures your local repo is up-to-date** — syncs the default branch with `upstream` before branching.
2. **Creates and checks out** a new local branch named `fix-token-refresh`.

Nothing is pushed to GitHub yet — that happens when you call `pr_push()`.

### Important: never commit to the default branch of a fork

Always work on a feature branch. Branch names should consist of **lowercase letters, numbers, and hyphens** (e.g., `fix-token-refresh`).

---

## Step 3 — Make Your Changes

Now you're on the `fix-token-refresh` branch. Edit files, add new code, update tests, etc. For example, if you're fixing a token-refresh bug, you might work on the relevant R source file and its test:

```r
# Open (or create) the R source file you need to edit
use_r("token-refresh")     # opens R/token-refresh.R

# Open (or create) the corresponding test file
use_test("token-refresh")  # opens tests/testthat/test-token-refresh.R
```

After making your edits, **commit your changes** using your usual Git workflow (via RStudio's Git pane, the terminal, or `gert`):

```bash
# From the terminal (or RStudio Git pane)
git add .
git commit -m "Fix token refresh edge case when expiry is near"
```

Repeat the edit–commit cycle as many times as needed. Each commit on `fix-token-refresh` will be part of the PR.

---

## Step 4 — Push and Create the Pull Request with `pr_push()`

```r
pr_push()
```

### What this does

The **first** call to `pr_push()` on a branch:

1. **Pushes** the local `fix-token-refresh` branch to `origin` (your fork on GitHub).
2. **Opens a browser window** to GitHub where you can create the pull request (or a draft PR) against the `r-lib/gargle` upstream repo.

Fill in the PR title and description in the browser, then click "Create pull request."

### Subsequent calls

If you make more commits locally and call `pr_push()` again, it ensures your local branch has all remote changes and then pushes your new commits, **updating the existing PR**. No new PR is created.

---

## Step 5 — Handle Review Feedback

Once maintainers review your PR, there are two common scenarios:

### Scenario A: Maintainer requests changes

1. Make the requested changes locally (still on `fix-token-refresh`).
2. Commit them.
3. Push the update:

```r
pr_push()
```

This adds the new commits to the existing PR.

### Scenario B: Maintainer pushes commits to your PR branch

If a maintainer adds commits directly to your PR branch on GitHub, pull those changes down:

```r
pr_pull()
```

`pr_pull()` pulls changes from the remote tracking branch into your local branch so you stay in sync.

### Keeping your branch up-to-date with upstream

If the upstream `main` branch has advanced significantly and you need to incorporate those changes (e.g., to resolve merge conflicts):

```r
pr_merge_main()
```

This pulls changes from the **default branch of the source repo** (`upstream/main`) into your current `fix-token-refresh` branch. Resolve any conflicts, commit, and then `pr_push()` again.

### Viewing the PR in your browser

```r
pr_view()
```

Opens the PR associated with your current branch in the browser. You can also view a specific PR by number:

```r
pr_view(number = 123)
```

---

## Step 6 — Clean Up After Merge with `pr_finish()`

Once your PR is merged:

```r
pr_finish()
```

### What this does

`pr_finish()` performs post-PR cleanup. It does **not** merge or close the PR (that's done on GitHub). Instead it:

1. **Switches back** to the default branch (`main`).
2. **Pulls** the latest from `upstream` so your local `main` reflects the merged changes.
3. **Deletes** the local `fix-token-refresh` branch.
4. **Removes** the associated remote tracking branch.

If you have multiple PRs and want to clean up a specific one:

```r
pr_finish(number = 123)
```

---

## Complete Workflow — All in One Place

```r
library(usethis)

# --- Prerequisites (one-time setup) ---
git_sitrep()                         # verify Git/GitHub health
use_git_config(                      # set your Git identity (if needed)
  user.name  = "Your Name",
  user.email = "you@example.com"
)
create_github_token()                # create a PAT (if needed)
git_vaccinate()                      # protect global .gitignore

# --- 1. Fork and clone ---
create_from_github("r-lib/gargle")
# → Forks r-lib/gargle to your GitHub account
# → Clones your fork locally
# → Sets origin → your fork, upstream → r-lib/gargle
# → Opens the project

# --- 2. Create feature branch ---
pr_init(branch = "fix-token-refresh")
# → Syncs default branch with upstream
# → Creates and checks out fix-token-refresh

# --- 3. Make changes ---
use_r("token-refresh")               # open/create R source file
use_test("token-refresh")            # open/create test file
# ... edit, run tests, commit ...

# --- 4. Push and create PR ---
pr_push()
# → Pushes fix-token-refresh to origin (your fork)
# → Opens browser to create the PR on GitHub

# --- 5. Handle review feedback ---
# If changes requested:
#   ... edit, commit ...
pr_push()                            # update the existing PR

# If maintainer pushed to your branch:
pr_pull()                            # pull their changes locally

# If upstream main has moved and you need to sync:
pr_merge_main()                      # merge upstream/main into your branch
#   ... resolve conflicts, commit ...
pr_push()                            # push updated branch

# View the PR anytime:
pr_view()

# --- 6. Clean up after merge ---
pr_finish()
# → Switches to default branch
# → Pulls latest from upstream
# → Deletes local fix-token-refresh branch
# → Removes remote tracking branch
```

---

## Quick Reference: All `pr_*()` Functions

| Function | Role | Signature | Description |
|----------|------|-----------|-------------|
| `pr_init(branch)` | Contributor | `pr_init(branch)` | Start a new PR: sync default branch, create & checkout feature branch |
| `pr_resume(branch)` | Both | `pr_resume(branch = NULL)` | Resume work on an existing local PR branch (interactive selection if no arg) |
| `pr_fetch(number)` | Maintainer | `pr_fetch(number = NULL, target = c("source", "primary"))` | Fetch a PR for review into a local tracking branch |
| `pr_push()` | Both | `pr_push()` | First call: push branch to origin & open PR creation in browser. Later calls: update existing PR |
| `pr_pull()` | Contributor | `pr_pull()` | Pull changes from the remote tracking branch (e.g., maintainer's commits) |
| `pr_merge_main()` | Both | `pr_merge_main()` | Merge the default branch of the source repo into the current PR branch |
| `pr_view(number)` | Both | `pr_view(number = NULL, target = c("source", "primary"))` | Open the PR in a browser |
| `pr_pause()` | Both | `pr_pause()` | Sync with remote PR changes, then switch back to default branch and pull from upstream |
| `pr_finish(number)` | Both | `pr_finish(number = NULL, target = c("source", "primary"))` | Post-merge cleanup: switch to default, pull, delete local & remote PR branch |
| `pr_forget()` | Both | `pr_forget()` | Abandon the current PR branch — local cleanup only, no remote deletion or PR closing |

---

## Tips and Best Practices

- **Never commit directly to the default branch** of a fork. Always use `pr_init()` to create a feature branch first.
- **Use descriptive branch names** with lowercase letters, numbers, and hyphens (e.g., `fix-token-refresh`, `add-oauth-flow`).
- **Keep commits focused** — one logical change per commit makes review easier.
- **Run `git_sitrep()`** if anything seems off with your Git/GitHub setup.
- **Use `pr_pause()`** when you want to temporarily switch back to the default branch to work on something else, then `pr_resume("fix-token-refresh")` to return to your PR work.
- **Use `pr_forget()`** if you decide to abandon a PR entirely — it cleans up the local branch without touching the remote or closing the PR on GitHub.
- **Keep your fork's default branch in sync** — `create_from_github()` sets up tracking to `upstream`, and `pr_finish()` / `pr_pause()` both pull from upstream, so you always have the latest.
