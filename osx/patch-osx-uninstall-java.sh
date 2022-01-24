#!/bin/bash
# Tim H 2020
# uninstall Java on OS X
set -e

echo "Uninstalling Java..."

rm -fr /Library/Internet\ Plug-Ins/JavaAppletPlugin.plugin
rm -fr /Library/PreferencePanes/JavaControlPanel.prefPane
rm -fr ~/Library/Application\ Support/Oracle/Java

echo "Successfully uninstalled Java."
