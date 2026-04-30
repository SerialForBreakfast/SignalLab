# Memory Graph Malloc Stack Logging Scheme Configuration

Date: 2026-04-29

## Context

Memory Graph Lab needs allocation backtraces so learners can select `MemoryGraphCheckoutSession` and use the right inspector Backtrace section to navigate to the allocation source line.

The first manual attempt added raw Run environment variables:

- `MallocStackLogging=1`
- `MallocStackLoggingNoCompact=1`

That did not make Xcode's scheme editor show **Run > Diagnostics > Memory Management > Malloc Stack Logging** as enabled, and Memory Graph still reported:

> Malloc stack logging is not enabled for this process.

## Verified Xcode Setting

The correct user-visible setting is:

**Edit Scheme > Run > Diagnostics > Memory Management > Malloc Stack Logging**

Leave the existing SignalLab diagnostics unchanged unless a specific lab requires otherwise:

- Main Thread Checker: enabled
- Thread Performance Checker: enabled
- API Validation: enabled
- Zombie Objects: disabled for Memory Graph Lab
- Malloc Scribble: disabled
- Malloc Guard Edges: disabled

## Canonical `.xcscheme` XML

After enabling the checkbox in Xcode and closing the scheme editor, Xcode writes this under `LaunchAction`:

```xml
<AdditionalOptions>
   <AdditionalOption
      key = "PrefersMallocStackLoggingLite"
      value = ""
      isEnabled = "YES">
   </AdditionalOption>
   <AdditionalOption
      key = "MallocStackLogging"
      value = ""
      isEnabled = "YES">
   </AdditionalOption>
</AdditionalOptions>
```

Use this Xcode-written format as the source of truth. Do not rely on only `EnvironmentVariables` entries for this checkbox.

## Verification Rule

To verify the setting:

1. Open **Edit Scheme > Run > Diagnostics**.
2. Confirm **Malloc Stack Logging** is checked.
3. Stop the app and launch again from the shared `SignalLab` scheme.
4. Capture Memory Graph and select the retained app object.
5. The right inspector Backtrace section should no longer say malloc stack logging is disabled for this process.

