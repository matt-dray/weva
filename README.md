
# weva

<!-- badges: start -->
[![Project Status: Concept – Minimal or no implementation has been done
yet, or the repository is only intended to be a limited example, demo,
or
proof-of-concept.](https://www.repostatus.org/badges/latest/concept.svg)](https://www.repostatus.org/#concept)
[![R-CMD-check](https://github.com/matt-dray/weva/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/matt-dray/weva/actions/workflows/R-CMD-check.yaml)
[![format-check.yaml](https://github.com/matt-dray/weva/actions/workflows/format.yaml/badge.svg)](https://github.com/matt-dray/weva/actions/workflows/format.yaml)
[![jarl-check](https://github.com/matt-dray/weva/actions/workflows/lint.yaml/badge.svg)](https://github.com/matt-dray/weva/actions/workflows/lint.yaml)
[![Blog
posts](https://img.shields.io/badge/rostrum.blog-posts-008900?labelColor=000000&logo=data%3Aimage%2Fgif%3Bbase64%2CR0lGODlhEAAQAPEAAAAAABWCBAAAAAAAACH5BAlkAAIAIf8LTkVUU0NBUEUyLjADAQAAACwAAAAAEAAQAAAC55QkISIiEoQQQgghRBBCiCAIgiAIgiAIQiAIgSAIgiAIQiAIgRAEQiAQBAQCgUAQEAQEgYAgIAgIBAKBQBAQCAKBQEAgCAgEAoFAIAgEBAKBIBAQCAQCgUAgEAgCgUBAICAgICAgIBAgEBAgEBAgEBAgECAgICAgECAQIBAQIBAgECAgICAgICAgECAQECAQICAgICAgICAgEBAgEBAgEBAgICAgICAgECAQIBAQIBAgECAgICAgIBAgECAQECAQIBAgICAgIBAgIBAgEBAgECAgECAgICAgICAgECAgECAgQIAAAQIKAAAh%2BQQJZAACACwAAAAAEAAQAAAC55QkIiESIoQQQgghhAhCBCEIgiAIgiAIQiAIgSAIgiAIQiAIgRAEQiAQBAQCgUAQEAQEgYAgIAgIBAKBQBAQCAKBQEAgCAgEAoFAIAgEBAKBIBAQCAQCgUAgEAgCgUBAICAgICAgIBAgEBAgEBAgEBAgECAgICAgECAQIBAQIBAgECAgICAgICAgECAQECAQICAgICAgICAgEBAgEBAgEBAgICAgICAgECAQIBAQIBAgECAgICAgIBAgECAQECAQIBAgICAgIBAgIBAgEBAgECAgECAgICAgICAgECAgECAgQIAAAQIKAAA7)](https://www.rostrum.blog/index.html#category=weva)
<!-- badges: end -->

An R package with a [Rapp](https://cran.r-project.org/package=Rapp)-powered command-line interface (CLI) to generate a limited and opinionated weather report for a UK postcode.

Uses data from the:

* [Open-Meteo](https://open-meteo.com) API
* [postcodes.io](https://postcodes.io/) API

## Install

You can install the package from the R console.

``` r
install.packages("pak") # if not yet installed
pak::pak("matt-dray/weva")
```

Then you can install the CLI.

``` r
weva::install_cli()
```

## Use

Run `weva` from a terminal with a valid UK postcode—the only required positional argument—to receive a tiny weather report with segments for now and later.

```bash
weva wc2n5du
```
```
now 8.2°C ☀️ | +1h 7.6°C ☀️ 
```

The temperature values are styled with [ANSI escape codes](https://en.wikipedia.org/wiki/ANSI_escape_code) if your terminal supports them.

You can also supply options to:

* extend the forecast by a user-supplied number of `--hours` (shortcut `-h`)
* show a segment with today's `--extremes` (`-e`) of temperature

```bash
weva "WC2N 5DU" -h 24 -e
```
```
now 8.2°C ☀️ | +24h 11.1°C ☁️ | today 6.9°C to 10.7°C 
```

The Open-Meteo API returns 'current' data at the nearest 15 minutes and 'hourly' at the top of the hour.
{weva} aligns these by rounding to the nearest hour before adding the user's `--hours` input.

To give more precise time-related information, you can show interpreted `--datetimes` (`-d`) for each segment.

```bash
weva "WC2N 5DU" -h 24 -e -d
```
```
2026-02-28 20:30 8.2°C ☀️ | 2026-03-01 21:00 11.1°C ☁️ | 2026-02-28 6.9°C to 10.7°C 
```

Run `weva --help` for further information.
