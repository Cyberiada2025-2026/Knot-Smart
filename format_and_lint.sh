#!/bin/sh

gdformat $(find ./src/ -name '*.gd' -not -path "./src/addons/*")

gdlint $(find ./src/ -name '*.gd' -not -path "./src/addons/*" -not -path "./src/script_templates/*")
