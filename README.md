
# weva

<!-- badges: start -->
[![Project Status: Concept – Minimal or no implementation has been done
yet, or the repository is only intended to be a limited example, demo,
or
proof-of-concept.](https://www.repostatus.org/badges/latest/concept.svg)](https://www.repostatus.org/#concept)
[![R-CMD-check](https://github.com/matt-dray/hext/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/matt-dray/hext/actions/workflows/R-CMD-check.yaml)
[![format-check.yaml](https://github.com/matt-dray/hext/actions/workflows/format.yaml/badge.svg)](https://github.com/matt-dray/hext/actions/workflows/format.yaml)
[![jarl-check](https://github.com/matt-dray/hext/actions/workflows/lint.yaml/badge.svg)](https://github.com/matt-dray/hext/actions/workflows/lint.yaml)
<!-- badges: end -->

A [Rapp](https://cran.r-project.org/package=Rapp)-powered command line interface (CLI) for fetching weather from the [Open-Meteo](https://open-meteo.com) API for a given UK postcode.

> [!NOTE]
> This is an opinionated hobby project for personal use.
> It is not an R wrapper for the Open-Meteo API.

## Install

You can install like:

``` r
pak::pak("matt-dray/weva")
```

## Use

> [!NOTE]
> Tested on macOS only.

From an R console run:

``` r
weva::install_api()
```

Then, run `weva` from a terminal with the `--postcode` (`-p`) flag.

```bash
weva -p WC2N5DU
```

Run `weva --help` for further information.
