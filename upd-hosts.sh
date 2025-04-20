#!/bin/sh
set -e

# Forrás URL-ek tömbje
sources="
  https://list.iblocklist.com/?list=qlprgwgdkojunfdlzsiv&fileformat=hosts&archiveformat=zip
  https://list.iblocklist.com/?list=cgbdjfsybgpgyjpqhsnd&fileformat=hosts&archiveformat=zip
  https://filters.hufilter.hu/hufilter-hosts.txt
  https://someonewhocares.org/hosts/zero/hosts
  https://someonewhocares.org/hosts/ipv6zero/hosts/
  https://raw.githubusercontent.com/StevenBlack/hosts/refs/heads/master/alternates/fakenews-gambling-porn/hosts
  https://winhelp2002.mvps.org/hosts.zip
  https://raw.githubusercontent.com/hagezi/dns-blocklists/main/hosts/multi.txt
  https://raw.githubusercontent.com/hagezi/dns-blocklists/main/hosts/multi-compressed.txt
  https://raw.githubusercontent.com/hagezi/dns-blocklists/refs/heads/main/hosts/light.txt
  https://raw.githubusercontent.com/hagezi/dns-blocklists/refs/heads/main/hosts/tif.txt
  https://raw.githubusercontent.com/hagezi/dns-blocklists/main/hosts/doh.txt
  https://raw.githubusercontent.com/hagezi/dns-blocklists/main/hosts/native.tiktok.extended.txt
"

# Kimeneti fájl
output_file="combined_hosts"

# Ideiglenes könyvtár létrehozása
temp_dir="$(mktemp -d)"
temp_file="$temp_dir/combined_hosts.tmp"

# Üres ideiglenes fájl létrehozása
> "$temp_file"

# Függőségek ellenőrzése
for cmd in curl unzip; do
  command -v "$cmd" >/dev/null 2>&1 || {
    echo >&2 "A '$cmd' nincs telepítve. Telepítsd, majd próbáld újra."
    exit 1
  }
done

# Hosts fájlok letöltése és feldolgozása
for url in $sources; do
  echo "Letöltés: $url"
  filename=$(basename "$url")
  filepath="$temp_dir/$filename"

  # Fájl letöltése hibakezeléssel
  if curl -fsSL "$url" -o "$filepath"; then
    echo "Sikeres letöltés: $filename"
  else
    echo "Hiba a letöltés során: $url. Az előző fájl kerül felhasználásra, ha elérhető."
    continue
  fi

  # Fájl kiterjesztésének vizsgálata és kicsomagolás
  case "$filename" in
    *.zip)
      echo "ZIP fájl kicsomagolása: $filename"
      unzip -p "$filepath" >> "$temp_file"
      ;;
    *)
      echo "Nem tömörített fájl feldolgozása: $filename"
      cat "$filepath" >> "$temp_file"
      ;;
  esac
done

# IP-címek cseréje és nem kívánt sorok eltávolítása
sed -e 's/^127\.0\.0\.1/0.0.0.0/' \
    -e '/family\.adguard/d' \
    -e '/opendns/d' "$temp_file" | sort -u > "$output_file"

# Ideiglenes fájlok törlése
rm -rf "$temp_dir"

echo "A hosts fájlok sikeresen egyesítve a(z) '$output_file' fájlba."
