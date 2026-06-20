# Contributing to r-lib/gargle: The Complete `usethis::pr_*` Workflow

This guide walks through the entire workflow for contributing to the
[r-lib/gargle](https://github.com/r-lib/gargle) package on GitHub using the
`usethis` package's pull request helpers.

## Prerequisites

Before starting, ensure you have the following installed and configured:

```r
# Install required packages if not already installed
install.packages(c("usethis", "gert", "gh", "curl"))

# Configure your Git identity (run once, ever)
usethis::use_git_config(
  user.name  = "Your Name",
  user.email = "you@example.com"
)

# Set up a GitHub personal access token (PAT) if you haven't already
usethis::git_default_branch()          # check default branch awareness
gh::gh_whoami()                        # verify your GitHub auth is working
# If gh::gh_whoami() errors, run:
usethis::create_github_token()        # opens browser to create a PAT
gitcreds::gitcreds_set()              # stores the PAT for git + gh
```

You also need:

- A GitHub account.
- Git installed locally and available on your `PATH`.
- R and RStudio or your preferred R environment.

---

## Step 1 — Fork and Clone the Repository

The `usethis` package provides a single function that forks the target
repository on GitHub (if you haven't already), then clones **your fork**
to a local directory under a configurable base path.

```r
# Fork r-lib/gargle to your GitHub account and clone it locally
usethis::create_from_github(
  repo_spec  = "r-lib/gargle",
  fork       = TRUE,          # create a fork under YOUR account
  destdir    = file.path("~/R", "packages"),  # where to clone locally
  rstudio_open = TRUE         # open a new RStudio project for it
)
```

What happens internally:

1. `create_from_github()` checks whether `r-lib/gargle` already has a
   fork under your GitHub account. If not, it forks the repo via the
   GitHub API.
2. It clones **your fork** (e.g. `yourname/gargle`) to
   `~/R/packages/gargle`.
3. It sets up the **origin** remote to point at your fork.
4. It adds a **upstream** remote pointing at `r-lib/gargle`, so you can
   pull upstream changes later.
5. It opens a new RStudio Project (if `rstudio_open = TRUE`).

Verify your remotes:

```r
# Confirm the remote configuration
usethis::git_default_branch()
gert::git_remote_ls()
```

You should see something like:

```
origin    https://github.com/yourname/gargle.git
upstream  https://github.com/r-lib/gargle.git
```

---

## Step 2 — Make Sure You Are on the Default Branch and Up to Date

Before creating a feature branch, return to the default branch
(typically `main`) and sync with upstream so your branch starts from the
latest state.

```r
# Check which branch you're on
usethis::git_default_branch()         # returns e.g. "main"
gert::git_branch()                   # shows current branch name

# Pull latest from upstream into your local default branch
usethis::pr_pull_upstream()           # pulls from upstream remote
```

If `pr_pull_upstream()` is not appropriate (e.g. you have unrelated
local commits), you can pull manually:

```r
# Manual sync from upstream main into your local main
gert::git_fetch("upstream")
gert::git_merge("upstream/main")
gert::git_push()  # push your local main up to origin (your fork)
```

---

## Step 3 — Create the Feature Branch `fix-token-refresh`

Now create a new branch to hold your work. `usethis::pr_init()` creates
and checks out a new branch configured to push to your fork's `origin`.

```r
# Initialize a new pull-request branch
usethis::pr_init("fix-token-refresh")
```

This is equivalent to:

```sh
git checkout -b fix-token-refresh
git push -u origin fix-token-refresh
```

but `pr_init()` also sets internal usethis state so that subsequent
`pr_*` functions know you are "in" a pull request workflow on this
branch.

Confirm you are on the new branch:

```r
gert::git_branch()   # should return "fix-token-refresh"
```

---

## Step 4 — Make Your Changes

Edit the relevant source files to implement your fix for the token
refresh bug. Typical places to look in gargle:

- `R/auth.R`           — token acquisition and storage
- `R/refresh-token.R`  — token refresh logic (if it exists)
- `R/cred_funs.R` / `R/credentials.R` — credential handling
- `tests/testthat/test-auth.R` — existing tests for auth/token flow

Example skeleton of a change you might make:

```r
# In R/refresh-token.R (or the relevant file)

refresh_oauth_token <- function(token, app) {
  # Check if the token is expired or nearing expiry
  if (token_is_valid(token)) {
    return(token)
  }

  # Attempt to refresh using the stored refresh_token
  if (is.null(token$credentials$refresh_token)) {
    cli::cli_abort("Token cannot be refreshed: no refresh_token available.")
  }

  # Perform the refresh
  new_token <- httr::POST(
    url = token_endpoint(app),
    body = list(
      grant_type    = "refresh_token",
      refresh_token = token$credentials$refresh_token,
      client_id      = app$key,
      client_secret  = app$secret
    ),
    encode = "form"
  )

  # Update and return the refreshed token
  token$credentials <- httr::content(new_token)
  token
}
```

After making changes:

```r
# Run the package checks to ensure your changes don't break anything
devtools::load_all()
devtools::test()                 # run the test suite
devtools::check()                # full R CMD check
# Optionally:
devtools::document()            # if you changed any roxygen docs
```

Fix any problems `check()` reports before moving on.

---

## Step 5 — Commit Your Changes

Use `usethis::pr_commit()` (a thin wrapper around `gert::git_add()` +
`gert::git_commit()`) or commit manually with `gert`:

```r
# Stage and commit all modified files
usethis::pr_commit(
  message = "Fix token refresh when refresh_token is missing or stale",
  all = TRUE       # stage all changes, not just tracked-and-modified
)
```

Or, manually:

```r
# Manual staging + commit
gert::git_add(files = ".")
gert::git_commit(
  message = "Fix token refresh when refresh_token is missing or stale"
)
```

Follow the gargle/recommended convention for commit messages:
imperative mood, short first line, optionally a body explaining *why*.

---

## Step 6 — Push the Branch and Create the Pull Request

```r
# Push the branch to your fork (origin) and open a PR against r-lib/gargle
usethis::pr_push()   # pushes current branch to origin/fix-token-refresh
usethis::pr_open()           # opens a browser to create the PR on GitHub
```

`pr_open()` opens your default browser at the GitHub "Open a pull
request" page, pre-filled with:

- **base repository:** `r-lib/gargle`
- **base branch:** `main` (the default branch)
- **head repository:** `yourname/gargle`
- **head branch:** `fix-token-refresh`
- A title (the last commit message, by default)
- A body template (`usethis` inserts a short PR template)

Edit the title and body in the browser, then click **Create pull
request**.

### Alternative: Create the PR programmatically

If you prefer not to use the browser flow, you can open the PR directly
via the `gh` API:

```r
# Programmatically open a pull request
gh::gh(
  "POST /repos/{owner}/{repo}/pulls",
  owner = "r-lib",
  repo  = "gargle",
  title = "Fix token refresh when refresh_token is missing or stale",
  head  = "yourname:fix-token-refresh",   # yourfork:branch
  base  = "main",
  body  = "
## Summary

This PR fixes a bug in gargle's OAuth token refresh path where a
`refresh_token` that is missing or stale causes a silent failure.

## Related issue

Closes #123.
"
)
```

---

## Step 7 — View and Manage the Pull Request

```r
# View the PR (opens it in your browser)
usethis::pr_view()

# Or programmatically fetch PR metadata
gh::gh(
  "/repos/{owner}/{repo}/pulls/{number}",
  owner = "r-lib",
  repo  = "gargle",
  number = 42   # the PR number returned by pr_open() or GitHub
)
```

---

## Step 8 — Handle Review Feedback

When reviewers request changes, update your local branch, make edits,
commit, and push again:

```r
# Pull the latest version of YOUR PR branch from origin (your fork)
usethis::pr_pull()

# Make edits in your editor ...

# Commit the updates
usethis::pr_commit(
  message = "Address review: handle NULL refresh_token more gracefully"
)

# Push the new commits up — they auto-append to the existing PR
usethis::pr_push()
```

If the upstream `main` branch moves while your PR is open and you need
to incorporate those changes, rebase your branch onto upstream and
force-push to your fork:

```r
# Sync with upstream and rebase your branch on top of latest main
usethis::pr_pull_upstream()          # fetch + merge upstream main
gert::git_rebranch(branch = "fix-token-refresh")
```

Or, to explicitly rebase:

```r
gert::git_fetch("upstream")
gert::git_rebase(commit = "upstream/main", branch = "fix-token-refresh")
gert::git_push(force = TRUE)  # only force-push to your fork's feature branch, never to main
```

> **Warning:** Force-pushing rewrites history on your feature branch.
> Only force-push to **your fork's** feature branch — never to
> `r-lib/gargle` or its `main`/`master` branch.

---

## Step 9 — After the PR Is Merged

Once your PR is merged into `r-lib/gargle`, switch back to the default
branch, sync with upstream, and clean up the local feature branch:

```r
# Return to the default branch (main)
usethis::pr_finish()

# What pr_finish() does:
#   1. Switches to the default branch (main / master)
#   2. Pulls the latest from upstream (r-lib/gargle)
#   3. Pushes the updated main up to your fork (origin)
#   4. Deletes the local feature branch fix-token-refresh
#   5. Deletes the remote feature branch on your fork

# Verify you're back on main and up to date
gert::git_branch()                  # "main"
gert::git_log(max = 5)              # recent commits match upstream
```

If `pr_finish()` doesn't delete the remote branch on your fork, do it
manually:

```r
# Delete the remote feature branch on your fork
gert::git_branch_delete(
  branch = "fix-token-refresh",
  remote = "origin"
)

# Or via the GitHub API
gh::gh(
  "DELETE /repos/{owner}/{repo}/git/refs/heads/{branch}",
  owner  = "yourname",
  repo   = "gargle",
  branch = "fix-token-refresh"
)
```

---

## Quick Reference: The Complete Workflow at a Glance

```r
# ---- One-time setup ----
usethis::use_git_config(user.name = "Your Name", user.email = "you@example.com")
usethis::create_github_token()   # if needed
gitcreds::gitcreds_set()

# ---- Per-contribution workflow ----
# 1. Fork + clone
usethis::create_from_github("r-lib/gargle", fork = TRUE,
                            destdir = file.path("~/R", "packages"))

# 2. Sync with upstream before branching
usethis::pr_pull_upstream()

# 3. Create the feature branch
usethis::pr_init("fix-token-refresh")

# 4. Make changes (edit R/*.R, tests, etc.)
devtools::load_all(); devtools::test(); devtools::check()

# 5. Commit
usethis::pr_commit(message = "Fix token refresh ...", all = TRUE)

# 6. Push + open PR
usethis::pr_push()
usethis::pr_open()

# 7. Respond to reviews
usethis::pr_pull()                         # pull updates to your branch
# ...edit... commit...
usethis::pr_commit("Address review feedback")
usethis::pr_push()

# 8. After merge — cleanup
usethis::pr_finish()
```

---

## Key `usethis::pr_*` Functions Reference

| Function                   | Purpose                                                        |
|---------------------------|-----------------------------------------------------------------|
| `pr_init(branch)`         | Create + checkout a new branch for a PR; set up push tracking.  |
| `pr_push()`               | Push the current branch to `origin` (your fork).               |
| `pr_pull()`               | Pull the current PR branch from `origin`.                     |
| `pr_pull_upstream()`      | Pull the default branch from `upstream` (r-lib/gargle) and merge into your local default branch. |
| `pr_open()`               | Open a browser to create the PR on GitHub.                     |
| `pr_view()`               | View the PR on GitHub in a browser.                           |
| `pr_commit(message)`     | Stage + commit changes on the current PR branch.               |
| `pr_finish()`             | Switch to default branch, sync, delete local + remote feature branch. |

## Common Gotchas

1. **Pushing to the wrong remote.** `pr_push()` pushes to `origin` (your
   fork), not `upstream` (r-lib/gargle). You cannot push to `upstream`
   without write access — that's the whole point of the fork/PR model.

2. **Forgetting to sync before branching.** If you branch from a stale
   `main`, your PR may have merge conflicts. Always run
   `pr_pull_upstream()` first.

3. **Force-pushing to the wrong branch.** Only force-push to your fork's
   feature branch. Never force-push to `main` or to `r-lib/gargle`.

4. **Commit message style.** gargle follows the tidyverse style:
   imperative mood (`"Fix token refresh"`), not
   (`"Fixed token refresh"` or `"Fixes token refresh"`).

5. **Failing `R CMD check`.** gargle is a CRAN package; your PR should
   pass `devtools::check()` cleanly (no notes or warnings if
   avoidable).

6. **PAT expiry.** If `pr_open()` or `create_from_github()` fails with
   a 401/403, your GitHub PAT may have expired. Re-run
   `gitcreds::gitcreds_set()` with a fresh token.

---

This is the complete `usethis::pr_*` workflow from fork through PR
merge and cleanup, applied to contributing a `fix-token-refresh` change
to `r-lib/gargle`.
