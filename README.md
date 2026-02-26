
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

An R package with a [Rapp](https://cran.r-project.org/package=Rapp)-powered command line interface (CLI) to generate a mini weather report for a UK postcode.

> [!NOTE]
> This is a simple and opinionated hobby project for personal use.

Using data from the:

* [Open-Meteo](https://open-meteo.com) API
* [postcodes.io](https://postcodes.io/) API via the [{PostcodesioR}](https://docs.ropensci.org/PostcodesioR/) R package

## Install

You can install like:

``` r
pak::pak("matt-dray/weva")
```

## Use

> [!NOTE]
> Tested on macOS only.

After installation, run this once from an R console:

``` r
weva::install_cli()
```

Then, whenever you want, run `weva` from a terminal with optional flags:

```bash
weva wc2n5du -h 24 -e 
```
```
now 11.5°C ☁️ | +48h 10.8°C 🌧️🪶 | today 10.9°C to 13°C
```

The first argument is positional and required: the UK postcode you want a report for (e.g. the above is Trafalgar Square).
Specify how many `--hours` (`-h`) later (default 3) for a forward-look.
Toggle on today's tempaerature `--extremes` (`-e`).

The full display is three sub-reports: now, later and today's extremes.
In the terminal, the temperature values are styled with ANSI codes.
The now and later reports show an emoji representation of the weather code for that time period.

Run `weva --help` for further information.
