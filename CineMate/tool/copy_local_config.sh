#!/usr/bin/env bash

set -euo pipefail

readonly destination="${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"

copy_if_present() {
    local source="$1"
    local filename="$2"

    if [[ -f "${source}" ]]; then
        /bin/mkdir -p "${destination}"
        /bin/cp "${source}" "${destination}/${filename}"
        echo "Copied local ${filename}"
    else
        /bin/rm -f "${destination}/${filename}"
        echo "Local ${filename} not found; portfolio demo mode remains available"
    fi
}

copy_if_present \
    "${SRCROOT}/CineMate/Features/Resources/Secrets.plist" \
    "Secrets.plist"

copy_if_present \
    "${SRCROOT}/CineMate/Core/Config/GoogleService-Info.plist" \
    "GoogleService-Info.plist"
