
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

> [!NOTE]
> This is a simple and opinionated hobby project for personal use.

An R package with a [Rapp](https://cran.r-project.org/package=Rapp)-powered command line interface (CLI) to generate a mini weather report for a UK postcode.

Using data from the:

* [Open-Meteo](https://open-meteo.com) API
* [postcodes.io](https://postcodes.io/) API via the [{PostcodesioR}](https://docs.ropensci.org/PostcodesioR/) R package

## Install

You can install the package from the R console.

``` r
pak::pak("matt-dray/weva")
```

Once the package is installed, you can install the CLI via the R console.

``` r
weva::install_cli()
```

## Use

Run `weva` from a terminal with a valid UK postcode—the only required positional argument—to receive a tiny weather update and forecast.

```bash
weva wc2n5du
```
```
now 8.2°C ☀️ | +1h 7.6°C ☀️ 
```

The temperature values are styled with [ANSI escape codes](https://en.wikipedia.org/wiki/ANSI_escape_code) if your terminal supports them.

You can also supply options to:

* extend the 'later' forecast by a user-supplied number of `--hours` (shortcut `-h`)
* show interpreted `--datetimes` (`-d`) for each segment, rather than simple text
* show today's `--extremes` (`-e`) of temperature.

```bash
weva "WC2N 5DU" -h 24 -d -e
```
```
2026-02-28 20:30 8.2°C ☀️ | 2026-03-01 21:00 11.1°C ☁️ | 2026-02-28 6.9°C to 10.7°C 
```

Run `weva --help` for further information.

## CLI-first

This is a CLI-first package, but you can also use the exported `get_weather()` and `prepare_report()` functions in an R session.
