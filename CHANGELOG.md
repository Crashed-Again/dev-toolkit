# dev-toolkit v1.1

**Release date:** 2026-09-28
**Previous version:** v1.0

The installer grows up: modes, safety checks, and a much nicer install experience.

## Highlights

- Toggle between **install**, **update**, and **uninstall** modes from the menu
- **Elevation prompt** on startup for system-wide installs
- **Progress bar** on every winget operation
- **Reboot detection** with a reboot-now prompt at the end
- **Combined browser prompt** for apps without a winget package
- **`?` help screen** and a dedicated **winget status check**

## Added

- **Uninstall mode** — press `R` to toggle remove mode. The menu turns red and `I` runs `winget uninstall` on the selected apps. Apps without a winget ID are reported as "must be removed manually."
- **Update mode** — press `U` to run `winget upgrade` on every selected app with a winget package.
- **Elevated relaunch prompt** — on startup the script detects whether it's running as Administrator and offers `[E] Relaunch elevated / [C] Continue / [Q] Quit`. Recommended for VirtualBox, Android Studio, and other system-wide installs.
- **winget status check** — press `W` for a screen showing whether winget is installed, its version, source list, and a live connectivity test.
- **Progress bar** — installs, uninstalls, and upgrades show `[3/8] ########............ 37% -- Obsidian`.
- **Reboot detection** — catches exit code `3010` and the Windows pending-reboot registry flags, then offers to reboot (10-second countdown via `shutdown /r /t 10`).
- **Help screen** — press `?` for a cheat sheet of menu keys, modes, winget fallback, elevation, and reboot logic.
- **Combined browser prompt** — apps without a winget package are batched into a single `Open all of them now? [Y/N]` prompt instead of one prompt per app.
- **Colored menu** — selected items are green, unselected items are grey, uninstall mode turns the banner red.

## Changed

- **Menu layout** is more compact — all commands fit on two lines.
- **winget installs** now run with `--silent` for a cleaner console.

## Fixed

- Declining the browser prompt no longer aborts the remaining installs — the script continues to `Done.` regardless of choice.
- winget auto-install path falls back to browser mode correctly when elevation is unavailable.
- Various prompt-flow issues when winget was missing at start.

## Requirements

- Windows 10 1809 or newer (for `winget` and ANSI colors)
- Administrator recommended for some installs (VirtualBox, Android Studio)

---

## Changelog

### Added

- Uninstall mode (`R` toggles, `I` runs) using `winget uninstall`
- Update mode (`U`) using `winget upgrade` for selected apps
- Elevated relaunch prompt on startup (`E` / `C` / `Q`)
- winget status check screen (`W`) with version, sources, and connectivity test
- Progress bar for install, uninstall, and upgrade operations
- Reboot detection via exit code `3010` and Windows pending-reboot registry keys
- Reboot-now prompt with 10-second countdown
- Help screen (`?`) with menu keys, modes, and behavior reference
- Combined browser prompt for apps without a winget package
- Colored menu (green selected, grey unselected, red in uninstall mode)

### Changed

- Menu layout is more compact
- winget installs run with `--silent`

### Fixed

- Declining the browser prompt no longer aborts the remaining installs
- winget auto-install path falls back to browser mode when elevation is unavailable
- Various prompt-flow issues when winget was missing at start
