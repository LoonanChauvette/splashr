# CRAN Submission Preparation with usethis

Below are the `usethis` calls to prepare your R package for its first CRAN submission, along with guidance on verifying your Git/GitHub setup.

---

## 1. Set up GitHub Actions for R CMD check

```r
usethis::use_github_action("check-standard")
```

This creates `.github/workflows/check-standard.yaml`, which runs `R CMD check` on push and pull request events across macOS, Windows, and Linux. It also adds a badge to your README.

Additional useful workflows:

```r
# Test coverage via codecov
usethis::use_github_action("test-coverage")

# pkgdown documentation site build
usethis::use_github_action("pkgdown")

# linting
usethis::use_github_action("lint")

# Release workflow (build binary, upload to release)
usethis::use_github_action("release")
```

If you have not yet connected GitHub Actions to your repository:

```r
# Ensure GITHUB_PAT is set and available
usethis::edit_r_environ(scope = "user")
# Add: GITHUB_PAT=ghp_xxxxxxxxxxxxxxxxxxxxxxx
```

Restart R after editing `.Renviron` so the PAT is picked up.

---

## 2. Add CRAN submission comments

```r
usethis::use_cran_comments()
```

This creates `cran-comments.md`. Edit it to include:

- **Test environments:** List the OS/R version combos you tested (e.g., local Windows 10, R-hub `rhub::check_for_cran()`, Win-builder `devtools::check_win_release()`).
- **R CMD check results:** State that there were no ERRORs, WARNINGs, or NOTEs (or explain any NOTEs, e.g., new submission NOTE).
- **Downstream dependencies:** State that there are none, or list packages and confirm you ran `revdepcheck`.

Example content for `cran-comments.md`:

```
## Test environments
- local Windows 10, R 4.3.0
- macOS (rhub), R release
- ubuntu 22.04 (rhub), R release and devel
- Windows (win-builder), R release and devel

## R CMD check results
0 errors | 0 warnings | 0 notes

This is a new submission.

## Downstream dependencies
There are currently no downstream dependencies for this package.
```

---

## 3. Create a release issue checklist

```r
usethis::use_release_issue()
```

This opens a GitHub issue in your repository with a pre-populated checklist of CRAN submission steps. The issue includes items like:

- Update `DESCRIPTION` (Version, Authors, Maintainer)
- Review ` cran-comments.md`
- Run `devtools::check()` locally
- Run `rhub::check_for_cran()`
- Run `devtools::check_win_release()` and `check_win_devel()`
- Run `devtools::release()` or submit via web upload
- Post-submission: respond to CRAN reviewer emails promptly

You can also manually create an issue using:

```r
usethis::use_github_issue(
  title = "CRAN submission v0.1.0",
  body = "Submission checklist:
- [ ] DESCRIPTION is correct
- [ ] NEWS.md updated
- [ ] cran-comments.md updated
- [ ] R CMD check passes locally
- [ ] rhub check passes
- [ ] win-builder check passes
- [ ] revdepcheck (n/a if no deps)
- [ ] submit to CRAN
- [ ] tag release on GitHub
- [ ] announce",
  labels = "release"
)
```

---

## 4. Add a lifecycle badge

```r
usethis::use_lifecycle_badge("stable")
```

This adds a lifecycle badge to your `README.Rmd`/`README.md`:

```
[![Lifecycle: stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/)
```

Valid stages are: `"experimental"`, `"maturing"`, `"stable"`, `"superseded"`, `"questioning"`, `"archived"`, `"dormant"`.

For a first CRAN release, `"stable"` is appropriate if the API is settled, or `"maturing"` if still evolving.

If you use `lifecycle` verbs in your code (e.g., `lifecycle::deprecate_soft()`), also run:

```r
usethis::use_lifecycle()
```

This adds `lifecycle` to `Imports` and creates `R/lifecycle.R` for managing badges and deprecations.

---

## 5. Prepare NEWS.md

```r
usethis::use_news_md()
```

This creates `NEWS.md` with a header template. Edit it to describe changes:

```markdown
# splashr (development version)

# splashr 0.1.0

* Initial CRAN submission.
* Core feature A added.
* Core feature B added.
* Added a `NEWS.md` file to track changes to the package.
```

The first heading should match the version in your `DESCRIPTION` (without the patch/development suffix). Use bullet points starting with `*` to list changes. Only include sections for released versions once they are on CRAN.

After editing, re-knit the README if it references NEWS content:

```r
devtools::build_readme()
```

---

## Full sequence (recommended order)

```r
# Run these one at a time, editing files as prompted

usethis::use_github_action("check-standard")
usethis::use_github_action("test-coverage")

usethis::use_news_md()                 # then edit NEWS.md
usethis::use_lifecycle_badge("stable")
usethis::use_cran_comments()           # then edit cran-comments.md
usethis::use_release_issue()           # opens GitHub issue

# Final verification before submission
devtools::check()                      # local R CMD check
rhub::check_for_cran()                # cross-platform check
devtools::check_win_release()
devtools::check_win_devel()
```

---

## Checking your Git/GitHub setup is correct

### A. Verify Git is configured and the repo is initialized

```r
# Check git config
gert::git_config(global = TRUE)
# Should show user.name and user.email

# Check repo status
gert::git_status()
# Should show your package files, no surprises

# Check remote
gert::git_remote_info()
# Should list 'origin' pointing to your GitHub repo
```

### B. Verify the GitHub connection via usethis

```r
# This checks that git, GitHub PAT, and repo are wired together
usethis::git_sitrep()
```

`git_sitrep()` prints a report covering:
- **Git installation:** path and version
- **Git config:** user name and email (global and local)
- **Current project:** R package path, active git branch
- **GitHub remote:** repo URL, whether it is a fork
- **Personal access token:** whether `GITHUB_PAT`/`GITHUB_TOKEN` is found in `.Renviron`, and whether it is valid
- **GitHub user:** the user associated with the PAT
- **Scopes:** token scopes (must include `repo`, `workflow` for Actions)

If anything is missing, `git_sitrep()` tells you which `usethis::use_*()` or `gert::git_config()` call to run to fix it.

### C. Verify the PAT and scopes

```r
# Check that the token is set
gh::gh_whoami()
```

This returns your GitHub login, name, and token scopes. Required scopes for CI/CD:

- `repo` (full control of private repos)
- `workflow` (required for GitHub Actions workflows in the `.github/workflows` directory)

If scopes are missing, create a new PAT at https://github.com/settings/tokens (classic) with the `repo` and `workflow` scopes, then:

```r
usethis::edit_r_environ(scope = "user")
# Replace GITHUB_PAT value
# Restart R
```

### D. Verify GitHub Actions will trigger

After pushing the `.github/workflows/*.yaml` files:

1. Go to your repo on GitHub: **Actions** tab.
2. Confirm the workflows appear and run on the next push/PR.
3. If the Actions tab says "Workflows aren't being run because this repository is not the default branch," check that you pushed to the default branch or that the workflow's `on:` triggers include your branch.

Check that the default branch is correct:

```r
gert::git_branch()
#                 branch commit
# 1* HEADBranch    main   abc123
```

### E. Common issues and fixes

| Problem | Fix |
|---|---|
| `git_sitrep()` says no PAT | Run `usethis::create_github_token()` (requires `gert` + `gh`), then `usethis::edit_r_environ()` to add it |
| `gh::gh_whoami()` returns error | PAT is invalid or expired; regenerate it |
| `use_github_action()` fails with auth error | Re-authorize: `gh::gh_set_token(Sys.getenv("GITHUB_PAT"))` and confirm scopes include `repo`, `workflow` |
| Actions don't trigger | Confirm `.github/workflows/*.yaml` is committed and pushed to the default branch; check workflow `on:` keys |
| `use_release_issue()` fails to open issue | Confirm `origin` remote is set; `usethis::use_github_push()` or manually `git remote add origin <url>` |
| Remote missing | `gert::git_remote_add(name = "origin", url = "https://github.com/USER/splashr.git")` then `git push -u origin HEAD` |

### F. Verify the remote is correct end-to-end

```r
# Inspect remote URL
gert::git_remote_list()
#   name    url
# 1 origin  https://github.com/yourname/splashr.git

# Test that you can list the remote
gert::git_ls_tree(ref = "origin/HEAD")
```

If the remote URL uses SSH and you prefer HTTPS (or vice versa), update it:

```r
gert::git_remote_set_url(
  name = "origin",
  url  = "git@github.com:yourname/splashr.git"
)
```

---

## Summary of usethis calls

| Goal | Call | File/Effect created |
|---|---|---|
| CI: R CMD check | `usethis::use_github_action("check-standard")` | `.github/workflows/check-standard.yaml` + README badge |
| CRAN comments | `usethis::use_cran_comments()` | `cran-comments.md` |
| Release issue | `usethis::use_release_issue()` | GitHub issue with checklist |
| Lifecycle badge | `usethis::use_lifecycle_badge("stable")` | README badge |
| NEWS file | `usethis::use_news_md()` | `NEWS.md` |
| Git/GitHub check | `usethis::git_sitrep()` | Console diagnostic report |
