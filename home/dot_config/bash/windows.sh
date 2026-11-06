# Load every Windows-specific snippet from windows/.
# (globstar is enabled in options.sh)

_windows_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/windows"

for _windows_file in "$_windows_dir"/*.sh; do
	[ -f "$_windows_file" ] && source "$_windows_file"
done

unset _windows_dir _windows_file
