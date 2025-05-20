#!/bin/bash

location_data=$(curl -s "http://ip-api.com/json/" 2>/dev/null)

CITY=$(echo "$location_data" | jq -r '.city // empty')
CITY=$(echo "$CITY" | tr ' ' '_')
COUNTRY=$(echo "$location_data" | jq -r '.countryCode // empty')

if [[ -n "$CITY" && -n "$COUNTRY" ]]; then
	weather_info=$(curl -s "wttr.in/$CITY?format=%c+%C+%t" 2>/dev/null)

	if [[ -n "$weather_info" ]]; then
		echo "$COUNTRY, $CITY: $weather_info"
	else
		echo "Weather info unavailable for $COUNTRY, $CITY"
	fi
else
	echo "Unable to determine you location"
fi
