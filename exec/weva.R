#!/usr/bin/env Rapp
#| name: weva
#| description: A basic weather report using the 'Open-Meteo' API

#| description: A UK postcode
#| short: p
postcode <- ""

get_weather(postcode = postcode) |> prepare_report() |> cat()
