# CRAN Submission Setup with usethis

Below are the `usethis` calls for each task, followed by instructions for verifying your Git/GitHub setup.

## 1. Set up GitHub Actions for R CMD check

`use_github_action()` adds a workflow from [r-lib/actions](https://github.com/r-lib/actions). When the workflow name starts with `"check-"`, it automatically saves the file as `R-CMD-check.yaml` and adds a badge to your README:

```r
library(usethis)

# Standard R CMD check workflow (multiple OS + R versions)
use_github_action("check-standard")

# Alternative: lighter check (Linux only, faster)
# use_github_action("check-release")
```

This creates `.github/workflows/R-CMD-check.yaml`, adds it to `.Rbuildignore`, and inserts a CI badge into your README.

**Optional extras** you might want at this stage:

```r
# Test coverage with Codecov
use_coverage()
use_github_action("test-coverage")
```

## 2. Add CRAN submission comments

`use_cran_comments()` creates `cran-comments.md` — the template file CRAN requires with your submission:

```r
use_cran_comments()
```

This opens the file for editing. Fill in the sections it generates, typically:

- **Test environments** — local OS/R version, GitHub Actions (macOS, Windows, Linux), win-builder, r-hub
- **R CMD check results** — "0 errors \| 0 warnings \| 0 notes" (or describe any notes)
- **Downstream dependencies** — list of reverse dependencies and whether they were checked

The file is automatically added to `.Rbuildignore` so it won't be included in the built package tarball.

## 3. Create a release issue checklist

`use_release_issue()` creates a GitHub issue with a pre-filled release checklist:

```r
# Interactively choose the version to release
use_release_issue()

# Or specify the version directly
use_release_issue("1.0.0")
```

This opens a GitHub issue on your repo with a structured checklist covering: `R CMD check` results, CRAN policies, revdep checks, docs, and post-submission steps. You work through the checklist items as you prepare the submission.

## 4. Add a lifecycle badge

There are two related functions:

```r
# Set up the lifecycle package dependency + copy badge images to man/figures/
use_lifecycle()

# Add the actual badge to your README
# stage is one of: "experimental", "stable", "superseded", "deprecated"
use_lifecycle_badge("stable")
```

`use_lifecycle()` adds lifecycle to `DESCRIPTION` (Imports), imports `lifecycle::deprecated()`, and copies badge images into `man/figures/`. `use_lifecycle_badge()` inserts the markdown badge into your README.

## 5. Prepare NEWS.md

`use_news_md()` creates a skeleton `NEWS.md` in the package root:

```r
use_news_md()
```

This produces a file with a top-level heading like:

```
# splashr (development version)

* ...
```

For your first CRAN release, edit it to document your initial release:

```markdown
# splashr 1.0.0

* Initial CRAN submission.
* First released version.
```

If you later need to bump the version, `use_version()` will also add a new heading to `NEWS.md` automatically:

```r
use_version("patch")  # or "minor", "major", "dev"
```

## Complete sequence (all together)

```r
library(usethis)

# CI
use_github_action("check-standard")

# CRAN submission template
use_cran_comments()

# Release checklist issue
use_release_issue()

# Lifecycle badge
use_lifecycle()
use_lifecycle_badge("stable")

# NEWS file
use_news_md()
```

After running these, commit all changes and push to GitHub:

```r
# If using usethis's PR workflow, or just use git directly
# gert::git_add(".")
# gert::git_commit("Prepare for CRAN submission")
# gert::git_push()
```

Then run `R CMD check` locally (or let GitHub Actions do it) and verify everything passes before submitting to CRAN.

---

## Checking your Git/GitHub setup

`git_sitrep()` ("situation report") is the one-stop diagnostic:

```r
# Full report: Git config, GitHub PAT, remotes, branch tracking
git_sitrep()

# Or scope it:
git_sitrep("git", "user")     # Git config at user level
git_sitrep("github", "project") # GitHub auth + project remotes
```

A healthy `git_sitrep()` output will show:

- **Git user.name and user.email** — set at user scope
- **Default Git protocol** — "https" (recommended) or "ssh"
- **GitHub PAT** — discovered and valid (not expired)
- **Project remote** — `origin` pointing to your GitHub repo
- **Current branch** — tracking `origin/main` (or `origin/master`)

### If anything is wrong, here's how to fix it:

**Set your Git identity** (if not configured):

```r
use_git_config(
  user.name  = "Your Name",
  user.email = "you@example.com"
)
```

**Create a GitHub PAT** (Personal Access Token):

```r
create_github_token()
```

This opens a pre-filled form on GitHub with recommended scopes (`repo`, `user`, `gist`, `workflow`). After creating the token, store it in the OS credential store:

```r
gitcreds::gitcreds_set()
```

**Verify the PAT is working**:

```r
gh_token_help()   # troubleshoot PAT discovery
git_sitrep()      # confirm everything is healthy
```

**If your project isn't on GitHub yet**:

```r
# Initialize Git (if not already done)
use_git()

# Create the GitHub repo and push
use_github()
```

`use_github()` checks that your local repo is in good shape (clean working tree, default branch, no existing `origin`), creates the GitHub repo, adds it as the `origin` remote, pushes, and calls `use_github_links()` to populate `URL`/`BugReports` in DESCRIPTION.

**Other useful checks**:

```r
git_remotes()              # list configured remotes (like `git remote -v`)
proj_sitrep()              # check active project / working directory
git_vaccinate()            # add common junk files to global .gitignore
```

### Recommended credential setup (HTTPS + PAT)

The usethis-recommended approach is:

1. Use **HTTPS** (not SSH) as your Git protocol — easier on all platforms.
2. Enable **2FA** on your GitHub account.
3. Use a **PAT** stored in the OS credential store (not in `.Renviron`).
4. Run `git_sitrep()` to confirm everything is wired up.

```r
use_git_protocol("https")     # set protocol preference
create_github_token()         # create PAT on GitHub
gitcreds::gitcreds_set()      # store PAT in credential store
git_sitrep()                  # verify the full setup
```
