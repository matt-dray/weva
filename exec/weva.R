#!/usr/bin/env Rapp
#| name: weva
#| description: A micro weather report with 'Open-Meteo' and 'postcodes.io' APIs

#| description: A UK postcode
postcode <- NULL

#| description: Hours from now for the 'later' segment (up to three days)
#| short: h
hours <- 1L

#| description: Show API and calculated datetimes in 'now' and 'later' segments?
#| short: d
datetimes <- FALSE

#| description: Show a segment for today's min and max temperatures?
#| short: e
extremes <- FALSE

get_latlon(postcode) |>
  get_weather() |>
  write_report(
    hours_to_forecast = hours,
    show_datetimes = datetimes,
    show_extremes = extremes
  ) |>
  cat()
