# markdown-cv

A data-driven CV maintained in YAML and rendered to HTML and PDF using Jekyll.

This fork reads structured data from [`mlgill.github.io/_data/`](https://github.com/mlgill/mlgill.github.io) and renders it as a printable CV. Deploys via Netlify.

## Quick Start

```bash
# Serve locally (requires sibling mlgill.github.io repo)
npm run serve
# or: bundle exec jekyll serve --port 4001

# Generate PDFs (requires Chromium)
npm run pdf

# Generate and open PDFs
npm run pdf:open
```

## CV Versions

| Version | Source | Output | Content |
|---------|--------|--------|---------|
| Descriptive | `index.md` | `GillMichelle_DescriptiveCV.pdf` | All visible entries |
| Concise | `concise.md` | `GillMichelle_ConciseCV.pdf` | Selected entries only |

## Requirements

- Ruby 3.3+ with Bundler
- Node.js with npm
- Chromium (for PDF generation)
- Sibling `mlgill.github.io` repository

## Documentation

See [PLAN.md](PLAN.md) for detailed architecture, file structure, and configuration.

## License

[MIT License](LICENSE)
