# Physican To Voter Linkage Repository:

Welcome to our repository for the physician-to-voter linkage and subsequent
analyses.

## Layout:

This repository is organized as follows:

```
.
├── code
│   ├── 00_unzip_l2.R
│   ├── 01_extract_l2.R
│   ├── 03_clean_physician_data.R
│   ├── 04_locality_sensitive_hash.R
│   ├── 05_match_model.R
│   └── match_diagnostics.R
├── figures
│   ├── age_dist_hist.png
│   ├── at_a_glance.png
│   ├── matches_by_state.png
│   ├── processing.png
│   └── screenshot.png
├── linkage_slides.Rmd
├── pres.bib
├── README.md
└── _targets.R
```

The `code/` directory houses the functions used to complete the linkage and
subsequent diagnostics.

## Other Useful Links:

Package site for [zoomerjoin](https://github.com/beniaminogreen/zoomerjoin),
our in-house package to perform fast fuzzy-linking on name.
