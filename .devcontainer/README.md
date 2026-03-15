# Development Container for Tic-Tac-Toe iOS

## ⚠️ IMPORTANT LIMITATION

**This devcontainer runs on Linux and CANNOT build or run the iOS application.**

This is an iOS project that **requires macOS and Xcode** for building and testing. The devcontainer is provided for:
- ✅ Code review and editing
- ✅ Documentation updates
- ✅ CI/CD workflow modifications
- ✅ Swift syntax learning

**For actual iOS development, you must use macOS with Xcode.**

---

This directory contains the configuration for a development container that can be used with:
- **GitHub Codespaces** - Cloud-based development environment (Linux-based, no iOS build support)
- **VS Code Dev Containers** - Local containerized development (no iOS build support)

## What's Included

### Base Image
- Swift development environment with latest Swift compiler
- macOS-like command-line tools for Swift development

### Extensions
- **Swift Language Support** - Syntax highlighting, IntelliSense, and debugging
- **GitHub Copilot** - AI pair programming
- **GitLens** - Enhanced Git integration
- **Markdown Support** - Documentation editing
- **Code Quality Tools** - Linting and error detection

### Features
- GitHub CLI for repository operations
- Zsh with Oh My Zsh for enhanced terminal experience
- Auto-formatted code on save
- Organized imports
- Spell checking

## Getting Started

### Using GitHub Codespaces

1. Navigate to the repository on GitHub
2. Click the **Code** button
3. Select **Codespaces** tab
4. Click **Create codespace on main** (or your branch)
5. Wait for the container to build (first time only)
6. Start coding in your browser or VS Code!

### Using VS Code Dev Containers (Local)

**Prerequisites:**
- Docker Desktop installed and running
- VS Code with "Dev Containers" extension

**Steps:**
1. Open the repository in VS Code
2. Press `F1` or `Cmd+Shift+P` (Mac) / `Ctrl+Shift+P` (Windows/Linux)
3. Type "Dev Containers: Reopen in Container"
4. Wait for the container to build
5. Start developing!

## Limitations

**Note**: This devcontainer provides a Swift development environment for:
- Editing Swift code with full language support
- Running Swift command-line tools
- Code review and documentation
- Git operations

**However**, building and running the actual iOS app requires:
- macOS with Xcode
- iOS Simulator or physical iOS device

For iOS app development and testing, you'll still need to use Xcode on macOS. This devcontainer is ideal for:
- Code review and documentation updates
- CI/CD workflow modifications
- Non-build-related repository tasks
- Learning Swift syntax and language features

## Building the iOS App

To build and run the iOS application:

1. **On macOS with Xcode:**
   ```bash
   open tictactoe.xcodeproj
   ```
   Then build and run using `Cmd+R`

2. **Command Line (macOS only):**
   ```bash
   xcodebuild -project tictactoe.xcodeproj \
     -scheme "tictactoe iOS" \
     -configuration Debug \
     -sdk iphonesimulator \
     -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
   ```

## Customization

You can customize this devcontainer by editing `.devcontainer/devcontainer.json`:

- **Add Extensions**: Add more VS Code extensions to the `extensions` array
- **Modify Settings**: Update editor settings in the `settings` object
- **Add Features**: Include additional dev container features
- **Change Base Image**: Use a different base image if needed

## Troubleshooting

### Container Won't Build
- Ensure Docker is running
- Check Docker has enough resources allocated
- Try rebuilding: `Dev Containers: Rebuild Container`

### Extensions Not Loading
- Reload the window: `Developer: Reload Window`
- Check extension compatibility with container environment

### Slow Performance
- Increase Docker resource allocation
- Use volume mounts for better I/O performance
- Close unnecessary applications

## Learn More

- [VS Code Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers)
- [GitHub Codespaces](https://github.com/features/codespaces)
- [Swift Docker Images](https://hub.docker.com/_/swift)
