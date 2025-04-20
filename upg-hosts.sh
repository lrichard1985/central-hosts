#!/bin/sh
set -e

# Saját hosts fájl mentése
cp /etc/hosts /etc/hosts.local

# Központi hosts fájl letöltése
curl -s -o /etc/hosts.central "https://raw.githubusercontent.com/youruser/yourrepo/main/combined_hosts"

# Hosts fájlok egyesítése
cat /etc/hosts.local /etc/hosts.central > /etc/hosts
