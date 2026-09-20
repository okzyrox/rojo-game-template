#!/bin/bash
# Installs packages, and set's up overture bindings + fixes types

set -euo pipefail

# Install Toolkits
rokit install

# Install Packages
wally install

## Process Types
echo "Processing Types..."
rojo sourcemap default.project.json --output sourcemap.json
wally-package-types --sourcemap sourcemap.json Packages/
wally-package-types --sourcemap sourcemap.json ServerPackages/

## Process Packages
process_packages() {
	local package_dir="$1"

	find "$package_dir" -maxdepth 1 -type f \( -name '*.lua' -o -name '*.luau' \) | while IFS= read -r file; do
		local base_name
		local target_file
		local meta_file

		base_name="$(basename "$file")" # raw
		target_file="$package_dir/${base_name%.*}.lua"
		meta_file="$package_dir/${base_name%.*}.meta.json"

		if [[ "$file" != "$target_file" ]]; then
			mv "$file" "$target_file"
		fi

		cat > "$meta_file" <<'EOF' # output overture meta
{
	"properties": {
		"Tags": [
			"oLibrary"
		]
	}
}
EOF
	done
}

echo "Processing Packages..."
process_packages "Packages"
process_packages "ServerPackages"

echo "Installed Packages"
