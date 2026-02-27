#!/usr/bin/env Rapp
#| name: weva
#| description: A micro weather report with 'Open-Meteo' and 'postcodes.io' APIs

#| description: A UK postcode
postcode <- NULL

#| description: Hours hence for the future-look segment (up to three days)
#| short: h
hours <- 1L

#| description: Show segment for today's min- and max-temperature?
#| short: e
extremes <- FALSE

get_weather(postcode) |>
  prepare_report(hours, extremes) |>
  cat()
