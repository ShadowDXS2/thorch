#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
mock_dir="${THORCH_FIRSTBOOT_MOCK_DIR:-${repo_root}/.mock/firstboot}"

mkdir -p "${mock_dir}"

if ! python3 - <<'PY' >/dev/null 2>&1
try:
    import PyQt6  # noqa: F401
except ImportError:
    import PySide6  # noqa: F401
PY
then
  export THORCH_FIRSTBOOT_CTL="${repo_root}/scripts/mock-thorch-firstbootctl"
  export THORCH_FIRSTBOOT_QML="${repo_root}/packages/thorch-firstboot/payload/usr/share/thorch/firstboot/qml/Main.qml"
  export THORCH_FIRSTBOOT_STATE_FILE="${mock_dir}/state.json"
  export THORCH_FIRSTBOOT_DONE_FILE="${mock_dir}/done"
  export THORCH_FIRSTBOOT_NO_PKEXEC=1
  export THORCH_FIRSTBOOT_MOCK_REBOOT=1
  export THORCH_FIRSTBOOT_BOOT_ROLE="${THORCH_FIRSTBOOT_BOOT_ROLE:-sd}"
  export THORCH_FIRSTBOOT_STEAM_SETUP_CMD="${THORCH_FIRSTBOOT_STEAM_SETUP_CMD:-printf 'Mock: FEX ready\\nMock: Steam launcher ready\\n'}"
  export THORCH_FIRSTBOOT_STEAM_LAUNCH_CMD="${THORCH_FIRSTBOOT_STEAM_LAUNCH_CMD:-printf 'Mock: SteamOS mode started\\n'}"
  export THORCH_FIRSTBOOT_WAYDROID_SETUP_CMD="${THORCH_FIRSTBOOT_WAYDROID_SETUP_CMD:-printf 'Mock: Waydroid package installed\\nMock: Android images initialized\\n'}"
  chmod +x "${THORCH_FIRSTBOOT_CTL}"

  if command -v qml6 >/dev/null 2>&1; then
    cat >&2 <<EOF
PyQt6/PySide6 are not installed for this Python, so using the QML-only mock backend.
This exercises the UI safely, but not the Python launcher bridge.
EOF
    exec qml6 --dummy-data "${repo_root}/scripts/firstboot-dummydata" -f "${repo_root}/packages/thorch-firstboot/payload/usr/share/thorch/firstboot/qml/Main.qml"
  fi

  cat >&2 <<EOF
PyQt6/PySide6 are not installed for this Python, and qml6 is unavailable.
The mock helper is ready and writes only under:
  ${mock_dir}
EOF
  exit 1
fi

export THORCH_FIRSTBOOT_CTL="${repo_root}/scripts/mock-thorch-firstbootctl"
export THORCH_FIRSTBOOT_QML="${repo_root}/packages/thorch-firstboot/payload/usr/share/thorch/firstboot/qml/Main.qml"
export THORCH_FIRSTBOOT_STATE_FILE="${mock_dir}/state.json"
export THORCH_FIRSTBOOT_DONE_FILE="${mock_dir}/done"
export THORCH_FIRSTBOOT_NO_PKEXEC=1
export THORCH_FIRSTBOOT_MOCK_REBOOT=1
export THORCH_FIRSTBOOT_BOOT_ROLE="${THORCH_FIRSTBOOT_BOOT_ROLE:-sd}"
export THORCH_FIRSTBOOT_STEAM_SETUP_CMD="${THORCH_FIRSTBOOT_STEAM_SETUP_CMD:-printf 'Mock: FEX ready\\nMock: Steam launcher ready\\n'}"
export THORCH_FIRSTBOOT_STEAM_LAUNCH_CMD="${THORCH_FIRSTBOOT_STEAM_LAUNCH_CMD:-printf 'Mock: SteamOS mode started\\n'}"
export THORCH_FIRSTBOOT_WAYDROID_SETUP_CMD="${THORCH_FIRSTBOOT_WAYDROID_SETUP_CMD:-printf 'Mock: Waydroid package installed\\nMock: Android images initialized\\n'}"

chmod +x "${THORCH_FIRSTBOOT_CTL}"
exec python3 "${repo_root}/packages/thorch-firstboot/payload/usr/bin/thorch-firstboot" --force
