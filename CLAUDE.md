# CLAUDE.md

This file provides guidance for Claude Code when working in this repository.

## Repository Overview

**shopify-central** is a repository aggregation project that syncs and stores Shopify's public open-source repositories. It originated as a fork of Shopify's `.github` organization-level repository containing default community health files.

## Project Structure

```
shopify-central/
├── .github/
│   └── workflows/
│       ├── fetch.yml      # Fetches list of Shopify repos from GitHub API
│       ├── sync.yml       # Clones repos and adds them as subfolders
│       └── reposync.yml   # Main workflow orchestrating fetch + sync
├── profile/
│   └── README.md          # Organization profile README
├── CAREERS.md             # Shopify careers information
├── CODE_OF_CONDUCT.md     # Contributor Covenant Code of Conduct
├── README.md              # Repository description
└── SECURITY.md            # Bug bounty and security reporting info
```

## GitHub Actions Workflows

### reposync.yml (Main Workflow)
- Triggers on push to main or manual dispatch
- Orchestrates the fetch and sync jobs

### fetch.yml
- Fetches repository names from Shopify's GitHub organization via API
- Outputs `repo_list.txt` as an artifact

### sync.yml
- Clones each repository from the fetched list
- Removes `.git` directories from cloned repos
- Commits each as a subfolder on a dynamically named branch
- Pushes to ZoneCog/shopify-central

## Key Conventions

- **Branch Naming**: Sync branches follow pattern `shopify` or `shopify-v{N}` for versioning
- **Commit Style**: Each synced repo gets its own commit: "Add {repo} repository as a subfolder"
- **Excluded Repos**: The `.github` repository is skipped during sync

## Development Notes

- This repo may contain many subfolders (synced Shopify repos) after workflows run
- The root-level markdown files are community health defaults
- Workflows use `actions/upload-artifact@v2` and `actions/download-artifact@v2`

## Common Tasks

### Running the Sync Manually
Trigger via GitHub Actions > "Sync Repositories" > "Run workflow"

### Modifying Pagination
Edit `fetch.yml` to adjust the page range in the API fetch loop:
```yaml
for PAGE in {1..10}; do
```

## Contact

- Security issues: See SECURITY.md (Shopify Bug Bounty via HackerOne)
- Conduct: See CODE_OF_CONDUCT.md (opensource@shopify.com)
