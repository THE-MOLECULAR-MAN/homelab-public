#!/bin/bash
# Tim H 2022

# https://www.home-assistant.io/installation/alternative#install-home-assistant-container
# sudo docker pull homeassistant/home-assistant:stable
# TZ = America/New_York
# https://www.home-assistant.io/docs/locked_out/
hass --script auth --config /config change_password oldusernamehere newpasswordhere
# restart the container
