# Cross-Platform Runner Cleanup Action

![GitHub release (latest by date)](https://img.shields.io/github/v/release/Keshav-writes-code/runner-cleaner)
![GitHub marketplace](https://img.shields.io/badge/marketplace-runner--cleaner-blue?logo=github)
![License](https://img.shields.io/github/license/Keshav-writes-code/runner-cleaner)

Aggressively reclaim disk space on GitHub-hosted runners (**Linux**, **macOS**, and **Windows**) by removing large, unnecessary SDKs, tools, and caches.

GitHub-hosted runners often come pre-installed with a vast amount of software (Android SDKs, .NET, Haskell, Docker images, etc.) that you might not need for your specific workflow. This action helps you delete those unused items to prevent "No space left on device" errors and speed up your builds.

## Features

- 🗑️ **Cross-Platform:** Works on Ubuntu, macOS, and Windows runners.
- 🔧 **Customizable:** Choose exactly what to remove via inputs.
- 🧪 **Dry Run Mode:** Test what would be deleted without actually removing anything.
- ⚡ **Fast:** Runs native shell scripts (Bash/PowerShell) for maximum performance.

## Usage

### Basic Usage (Defaults)

Simply add this step **before** your build steps. By default, it removes most large unused tools.

```yaml
steps:
  - name: Free up disk space
    uses: Keshav-writes-code/runner-cleaner@v1
```

### Advanced Usage (Custom Configuration)

Customize what gets removed. For example, if you need .NET but don't need Android or Docker:

```yaml
steps:
  - name: Free up disk space
    uses: Keshav-writes-code/runner-cleaner@v1
    with:
      remove-android: 'true'
      remove-dotnet: 'false'  # Keep .NET
      remove-haskell: 'true'
      remove-codeql: 'true'
      remove-docker-images: 'true'
```

### Dry Run (Testing)

Check what would be deleted without taking action:

```yaml
steps:
  - name: Test Cleanup
    uses: Keshav-writes-code/runner-cleaner@v1
    with:
      dry-run: 'true'
```

## Inputs (Specs)

| Input | Description | Default |
| :--- | :--- | :--- |
| `dry-run` | If `true`, only logs what would be removed without deleting it. | `false` |
| `remove-android` | Removes Android SDKs and NDKs. | `true` |
| `remove-dotnet` | Removes .NET SDKs and runtimes. | `true` |
| `remove-haskell` | Removes GHC, Cabal, and Stack. | `true` |
| `remove-codeql` | Removes the CodeQL Action cache. | `true` |
| `remove-docker-images` | Prunes unused Docker images and build cache. | `true` |
| `remove-browsers` | Removes pre-installed browsers (Chrome, Firefox, Edge). | `true` |
| `remove-xcode` | **(macOS only)** Removes unused Xcode versions, keeping the currently selected one. | `true` |
| `remove-swap` | **(Linux only)** Disables and removes the swap file. | `true` |

## Supported Platforms

| Platform | Script | Notes |
| :--- | :--- | :--- |
| **Linux** (Ubuntu) | `src/cleanup-linux.sh` | Most effective. Can free up 20GB+. |
| **macOS** | `src/cleanup-macos.sh` | Cleans Android, Haskell, browsers, and unused Xcode versions. |
| **Windows** | `src/cleanup-windows.ps1` | Cleans Android, .NET, Haskell, and Docker. |

## License

MIT © [Keshav-writes-code](https://github.com/Keshav-writes-code)
