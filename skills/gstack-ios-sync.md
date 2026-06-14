# Skill: gstack-ios-sync

> Regenerate the iOS debug bridge against the latest upstream gstack templates.

> **Note:** This skill was originally part of **gstack** and depends on gstack infrastructure (binaries, config, conventions, or CLI tools). It may not work outside a gstack environment without adaptation.

## When to invoke this skill

Updates StateServer.swift, DebugOverlay.swift, Package.swift,
and the typed @Observable state accessors. Use after you upgrade gstack
or add new ViewModels/properties that need accessor coverage.
Use when asked to "resync the iOS debug bridge", "regenerate iOS
accessors", or "update the gstack iOS instrumentation".

Voice triggers (speech-to-text aliases): "resync the iOS debug bridge", "regenerate iOS accessors", "update the gstack iOS instrumentation".

## Phase 1: Detect installed version

1. Read `<app>/DebugBridgeGenerated/.gstack-version` (written by /ios-qa
   during install). If missing, treat the install as "unknown old version".
2. Read upstream version from `.gstack/ios-qa/.gstack-version` (or the
   value baked into the installed gstack binary).
3. If versions match AND no new `@Observable` classes were added, exit
   early with "already up to date".

## Phase 2: Regenerate codegen output

Run `gstack-ios-qa-regen` (or the underlying SwiftPM tool directly):

```bash
swift run --package-path ".gstack/ios-qa/scripts/gen-accessors-tool" \
  gen-accessors --input "$APP_SOURCE_DIR" --output "$APP_SOURCE_DIR/DebugBridgeGenerated"
```

The composite-hash cache key handles whether anything actually needs
regenerating; if Swift version, generator git rev, lockfile, source content,
and platform triple all match the cache, this is a ~50ms no-op.

## Phase 3: Update templated Swift files in place

For each file that comes from `ios-qa/templates/*.swift.template`:

1. Read the current installed file at
   `<app>/DebugBridgeGenerated/<Name>.swift`.
2. Read the upstream template at
   `.gstack/ios-qa/templates/<Name>.swift.template`.
3. If the installed file has a `// GSTACK-EDIT-LINE` marker, fold the user's
   edits forward.
4. Otherwise, replace the file outright with the new template (after
   AskUserQuestion if the diff is non-trivial).

## Phase 4: Verify

1. `swift build` succeeds against the app's package.
2. `xcodebuild -scheme <SchemeName>` succeeds.
3. Re-launch the app on the device; daemon connects + rotates token.
4. `GET /state/snapshot` returns the new accessor schema hash.

## Failure modes

| Symptom | Action |
|---|---|
| Swift compile fails after regen | Revert via `git restore` + AskUserQuestion: surface the compile error |
| Schema hash unchanged after adding new @Observable | The new class isn't marked `@Snapshotable` — the codegen excludes it correctly. If the user wanted it snapshotted, add the wrapper. |
| `--input` source dir contains test fixtures | gen-accessors scans the input dir recursively; exclude test/ via `--exclude` |