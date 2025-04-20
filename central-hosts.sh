#!/bin/sh
set -e

# Forrás URL-ek tömbje
sources="
  https://list.iblocklist.com/?list=qlprgwgdkojunfdlzsiv&fileformat=hosts&archiveformat=7z
  https://list.iblocklist.com/?list=cgbdjfsybgpgyjpqhsnd&fileformat=hosts&archiveformat=7z
  https://filters.hufilter.hu/hufilter-hosts.txt
  https://someonewhocares.org/hosts/zero/hosts
  https://someonewhocares.org/hosts/ipv6zero/hosts/
  https://raw.githubusercontent.com/StevenBlack/hosts/refs/heads/master/alternates/fakenews-gambling-porn/hosts
  https://winhelp2002.mvps.org/hosts.zip
  https://raw.githubusercontent.com/hagezi/dns-blocklists/main/hosts/multi.txt
  https://raw.githubusercontent.com/hagezi/dns-blocklists/main/hosts/multi-compressed.txt
  https://raw.githubusercontent.com/hagezi/dns-blocklists/refs/heads/main/hosts/light.txt
  https://raw.githubusercontent.com/hagezi/dns-blocklists/refs/heads/main/hosts/light-compressed.txt
  https://raw.githubusercontent.com/hagezi/dns-blocklists/refs/heads/main/hosts/tif.txt
  https://raw.githubusercontent.com/hagezi/dns-blocklists/refs/heads/main/hosts/tif-compressed.txt
  https://raw.githubusercontent.com/hagezi/dns-blocklists/main/hosts/doh.txt
  https://raw.githubusercontent.com/hagezi/dns-blocklists/main/hosts/doh-compressed.txt
  https://raw.githubusercontent.com/hagezi/dns-blocklists/main/hosts/native.tiktok.extended.txt
"

# Ideiglenes fájlok és könyvtárak
temp_dir="$(mktemp -d)"
temp_file="$temp_dir/combined_hosts.tmp"
output_file="combined_hosts"

# Üres ideiglenes fájl létrehozása
> "$temp_file"

# Függőségek ellenőrzése
command -v curl >/dev/null 2>&1 || { echo >&2 "A 'curl' nincs telepítve. Telepítsd, majd próbáld újra."; exit 1; }
command -v unzip >/dev/null 2>&1 || { echo >&2 "Az 'unzip' nincs telepítve. Telepítsd, majd próbáld újra."; exit 1; }
command -v 7z >/dev/null 2>&1 || { echo >&2 "A '7z' nincs telepítve. Telepítsd a 'p7zip-full' csomagot, majd próbáld újra."; exit 1; }

# Hosts fájlok letöltése és feldolgozása
for url in $sources; do
  echo "Letöltés: $url"
  filename=$(basename "$url")
  filepath="$temp_dir/$filename"

  # Fájl letöltése
  curl -sSL "$url" -o "$filepath"

  # Fájl kiterjesztésének vizsgálata és kicsomagolás
  case "$filename" in
    *.zip)
      echo "ZIP fájl kicsomagolása: $filename"
      unzip -p "$filepath" >> "$temp_file"
      ;;
    *.7z)
      echo "7Z fájl kicsomagolása: $filename"
      7z e -so "$filepath" >> "$temp_file"
      ;;
    *)
      echo "Nem tömörített fájl feldolgozása: $filename"
      cat "$filepath" >> "$temp_file"
      ;;
  esac
done

# Redundáns sorok eltávolítása
sort -u "$temp_file" > "$output_file"

# Ideiglenes fájlok törlése
rm -rf "$temp_dir"

echo "A hosts fájlok sikeresen egyesítve a(z) '$output_file' fájlba."
