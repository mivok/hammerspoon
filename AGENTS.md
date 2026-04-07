# AGENTS.md

Guidance for coding agents working in this Hammerspoon configuration.

## Project Overview

This repo is a personal Hammerspoon configuration. `init.lua` is the entry point and loads a private config from `~/.config/hammerspoon/config.lua`, then wires together audio monitoring, push-to-talk, hotkeys, window management, Stream Deck layers, RPC, and meeting controls.

Core modules:

- `init.lua`: bootstraps Fennel support, private config, modules, auto-reload, and a garbage-collection timer.
- `actions.lua`: shared callbacks for hotkeys and Stream Deck buttons, including audio device switching, app toggles, AWS login helpers, remote actions, and clipboard sync.
- `hotkeys.lua`: keyboard bindings, including Launchpad F13-F20 and Hyper key bindings.
- `ptt.lua`: push-to-talk / push-to-mute behavior and mute-state enforcement.
- `audio.lua`: input mute watcher and on-screen mute indicator canvas.
- `streamdeck.lua`: top-level Stream Deck layer definitions.
- `streamdeck/streamdeck.lua`: Stream Deck runtime, layer switching, status refresh, lock-screen handling.
- `streamdeck/images.lua`: 96x96 Stream Deck image/canvas helpers.
- `status_callbacks.lua`: dynamic Stream Deck button status overlays.
- `zoom_actions.lua` and `teams_actions.lua`: meeting app controls.
- `rpc.lua`: remote Hammerspoon execution over SSH and `hs.ipc`.
- `windowmanage.lua`: Hyper key window movement helpers.
- `fennel.lua`: vendored Fennel runtime. Avoid editing unless explicitly updating the vendored copy.

## Runtime Assumptions

- This code runs inside Hammerspoon, not plain Lua. Most modules depend on the global `hs` API.
- `init.lua` expects `~/.config/hammerspoon/config.lua` to exist and return at least:
  - `machines.work`
  - `machines.personal`
  - `aws_sso_profile`
- The config uses Hammerspoon modules including `hs.audiodevice`, `hs.application`, `hs.canvas`, `hs.caffeinate`, `hs.eventtap`, `hs.hotkey`, `hs.ipc`, `hs.pathwatcher`, `hs.sound`, `hs.streamdeck`, `hs.task`, and `hs.timer`.
- External command assumptions include `/opt/homebrew/bin/aws`, `/opt/homebrew/bin/saml2aws`, `/opt/homebrew/bin/hs`, `/usr/bin/ssh`, and `/usr/bin/pmset`.
- Stream Deck image assets live in `images/`; PTT sounds live in `sounds/`.

## Conventions

- Keep modules small and callback-oriented. Most public module functions are stored on a module table and returned with `return module`.
- For new or substantially touched non-vendored Lua code, use 2-space indentation.
- Prefer a maximum line length of 79 characters in new or touched code.
- Prefer double-quoted strings in new non-vendored Lua code. Use single quotes only when it materially improves readability by avoiding escapes.
- Prefer `local` variables for new code. Only use globals intentionally when Hammerspoon objects must be retained beyond a module scope, such as timers/watchers that should not be garbage-collected.
- Preserve watcher/timer lifetimes. Existing examples include `pw1`, `garbageTimer`, `audio.muteWatcherTimer`, and `M.enforcePTTTimer`.
- Stream Deck layers are 3 rows by 5 columns and are represented as flat row-major arrays of 15 button tables.
- Empty Stream Deck buttons are `{}`. Use `passthrough = '<layer>'` to reuse a button from another layer.
- Stream Deck buttons commonly use `image`, `press_callback`, `release_callback`, and `update_callback`.
- Status callbacks mutate `button.status_image`; `streamdeck/streamdeck.lua` decides whether to render `status_image`, `image`, or a black button.
- Meeting controls rely on app names and menu items that can change between app versions. When changing Zoom or Teams behavior, include fallbacks for alternate capitalization or menu paths where practical.
- Audio device names are hard-coded and machine-specific. Do not rename devices casually; changes should match actual macOS device names.

## Validation

There is no project test suite or formatter configured.

Basic syntax check for tracked Lua modules:

```sh
find . -path ./.git -prune -o -name '*.lua' -exec luac -p {} +
```

Limitations:

- This only catches Lua syntax errors.
- It does not validate Hammerspoon runtime APIs, `hs.*` behavior, app menu names, audio devices, Stream Deck hardware, private config values, or SSH/RPC behavior.
- Do not use plain `lua` to execute modules that require `hs`; load them in Hammerspoon instead.

Manual validation options:

- Reload Hammerspoon after changes and watch the Hammerspoon Console for errors.
- Exercise affected hotkeys or Stream Deck buttons directly.
- For RPC changes, test both local execution and remote execution paths if machines are available.
- For Stream Deck changes, verify the lock/unlock behavior and status overlays still update.

## Safe Editing Notes

- Do not edit `.codex` unless explicitly asked; it may be local agent metadata.
- Treat `fennel.lua` as vendored code. Do not apply repository style conventions to it, and avoid editing it unless explicitly updating the vendored copy.
- Do not commit private machine names, AWS profiles, or secrets. Keep private values in `~/.config/hammerspoon/config.lua`; use `config.lua.example` only for placeholders.
- Be careful with `actions.get_clipboard` and `actions.send_clipboard`: they construct remote code strings and intentionally encode clipboard text to avoid quoting issues.
- Be careful with `actions.open_url`: it shells out through `open`; preserve URL encoding if changing it.
- If changing `rpc.lua`, keep the timeout behavior in mind; it currently terminates SSH tasks after one second.
- If adding image assets, keep Stream Deck button rendering at 96x96 unless the Stream Deck helper is updated consistently.

## Known Follow-Ups

- `config.lua.example` should be treated as a template for the private config. If editing it, verify the returned table is valid Lua syntax.
- Existing style is mixed. Prefer the repo conventions above for new code; for small edits, follow nearby code unless the touched block is being cleaned up intentionally.
