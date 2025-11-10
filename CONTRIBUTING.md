# Contributing to Tic-Tac-Toe iOS

Thank you for your interest in contributing to this project! 🎉

## How to Contribute

### Reporting Bugs

If you find a bug, please open an issue with:
- A clear description of the problem
- Steps to reproduce
- Expected vs actual behavior
- Screenshots (if applicable)
- iOS version and device information

### Suggesting Enhancements

Enhancement suggestions are welcome! Please open an issue with:
- A clear description of the enhancement
- Use cases and benefits
- Any implementation ideas you have

### Pull Requests

1. **Fork the Repository**
   ```bash
   git clone https://github.com/KevinTCoughlin/tictactoe.git
   cd tictactoe
   ```

2. **Create a Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make Your Changes**
   - Follow the existing code style
   - Add comments for complex logic
   - Update documentation if needed

4. **Test Your Changes**
   - Build the project successfully
   - Test on iOS Simulator
   - Verify no regressions

5. **Commit Your Changes**
   ```bash
   git add .
   git commit -m "Add feature: your feature description"
   ```

6. **Push and Create PR**
   ```bash
   git push origin feature/your-feature-name
   ```
   Then open a Pull Request on GitHub

## Code Style Guidelines

- Use Swift naming conventions (camelCase for variables, PascalCase for types)
- Add documentation comments for public APIs
- Keep functions focused and single-purpose
- Use meaningful variable names
- Follow Apple's Swift API Design Guidelines

## Swift Code Quality

All contributions must pass:
- ✅ SwiftLint checks
- ✅ Build validation
- ✅ Swift syntax validation

These are automatically checked by our CI pipeline.

## Project Structure

- `tictactoe Shared/` - Shared game logic (SpriteKit scenes, Game Center)
- `tictactoe iOS/` - iOS-specific code (App lifecycle, view controllers)
- `.github/workflows/` - CI/CD workflows

## Questions?

Feel free to open an issue for any questions about contributing!

## Code of Conduct

Be respectful, constructive, and professional in all interactions.

---

Thank you for contributing! 🚀
