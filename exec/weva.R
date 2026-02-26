#!/usr/bin/env Rapp
#| name: weva
#| description: A micro weather report using 'Open-Meteo' and 'postcode.io'

#| description: A UK postcode
postcode <- NULL

#| description: Hours from now to report for (up to seven days)
#| short: h
hours <- 3L

#| description: Show min and max temperature?
#| short: e
extremes <- FALSE

get_weather(postcode) |>
  prepare_report(hours, extremes) |>
  cat()
