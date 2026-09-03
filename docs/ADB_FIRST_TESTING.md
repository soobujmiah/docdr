# ADB-first device testing

This repository is Android/Android-adjacent, so real-device testing follows the canonical
control hierarchy defined in `soobujmiah/skb` → `standards/agent-device-testing.md`
(the "Agent Device Testing Standard"):

1. **ADB-first.** Work against the real, directly connected device through `adb`, not an
   emulator or UI-driven simulation.
2. **Application-native control.** Prefer whatever this app exposes — an exported
   Activity/Intent, a service, a broadcast receiver, a debug/test interface — over raw input.
3. **Raw `adb shell input`** for deterministic taps/text/keys when no better interface exists.
4. **UIAutomator** only as a last resort, for interactions with genuinely no other control path.

Performance principles (from the same standard): batch independent ADB commands, wait on an
observable readiness condition (`pidof`, `am start -W`, a specific logcat pattern, a `dumpsys`
state) instead of an arbitrary `sleep`, filter logs to this app's own tags, and prefer
programmatic state checks over screenshots wherever the same fact is available without one.

**Reference implementation:** `soobujmiah/lai`'s `docs/TESTING.md` ("ADB-first device testing" /
"Backend qualification") and `scripts/device/lai_adb.sh` are the worked example — a small,
reusable ADB helper (install/reset/launch/wait-process/wait-log/logs/state/qualify) plus an
app-native qualification path added directly to the app (intent extras on its existing exported
launcher Activity, gated behind an existing build-time evidence flag) for the one interaction
ADB and raw input alone couldn't reach deterministically. Reuse that shape rather than
re-deriving it — implement only the subset this repository's own testing gaps actually need.

## Starting point

No existing testing documentation or ADB tooling was found in this repository at time of
writing — this is a clean instantiation of the standard with nothing to reconcile against.
`android/app/src/{main,debug,profile}/AndroidManifest.xml` confirm a real Flutter Android shell
exists; verify current exported-component surface before assuming parity with any other
repository's pattern.
