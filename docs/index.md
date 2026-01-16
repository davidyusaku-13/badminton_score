# Badminton Score Keeper - Documentation Index

**Version:** 1.0.0+1
**Last Updated:** 2026-01-16
**Project Type:** Mobile Application (Flutter)

---

## Project Overview

**Badminton Score Keeper** is a professional Flutter mobile application designed for local badminton communities. Features a clean Material Design interface with advanced gesture controls, multiple themes, and community-focused functionality.

- **Architecture:** Single-file component-based architecture
- **Platform Support:** Android, iOS (primary), Web, Desktop (scaffolded)
- **Code Size:** 1,580 lines in lib/main.dart
- **APK Size:** ~19 MB (optimized with shrinking)
- **Dependencies:** 3 runtime packages (minimal footprint)

---

## Quick Reference

### Project Classification

| Attribute | Value |
|-----------|-------|
| **Repository Type** | Monolith (single cohesive codebase) |
| **Primary Language** | Dart |
| **Framework** | Flutter >=3.6.0 |
| **Architecture Pattern** | Single-file component architecture |
| **State Management** | Local setState() with SharedPreferences |
| **Entry Point** | lib/main.dart:198 (main function) |

### Technology Stack

- **Framework:** Flutter >=3.6.0
- **Language:** Dart >=3.6.0
- **UI System:** Material Design 3
- **Audio:** audioplayers ^6.4.0
- **Persistence:** shared_preferences ^2.3.3
- **Screen Management:** wakelock_plus ^1.2.5

### Key Features

- ✅ Score tracking with tap-to-increment
- ✅ 5 customizable themes with swipe navigation
- ✅ Undo system (up to 10 actions)
- ✅ Audio feedback with preloading
- ✅ Configurable target score (default: 21)
- ✅ Win detection with 2-point margin
- ✅ Games won tracking
- ✅ Player name customization
- ✅ Landscape-only orientation
- ✅ Screen always-on during matches

---

## Generated Documentation

### Core Documentation

- **[Project Overview](./project-overview.md)** - Executive summary, features, quick start guide
- **[Architecture](./architecture.md)** - Complete architecture documentation with diagrams and design decisions
- **[Source Tree Analysis](./source-tree-analysis.md)** - Project structure, directory layout, and navigation guide
- **[Development Guide](./development-guide.md)** - Setup, workflow, commands, troubleshooting, and best practices

### Technical Documentation

- **[Data Models](./data-models.md)** - Data structures, state management, persistence, and validation rules
- **[UI Components](./ui-components.md)** - Component inventory, widget hierarchy, design system, and accessibility
- **[Asset Inventory](./asset-inventory.md)** - Fonts, audio, images, optimization recommendations

---

## Existing Documentation

### User Documentation

- **[README.md](../README.md)** - User guide covering features, installation, themes, controls, and technical details
- **[CLAUDE.md](../CLAUDE.md)** - AI assistant instructions with architecture summary and development patterns

### Developer Documentation

- **[.github/copilot-instructions.md](../.github/copilot-instructions.md)** - GitHub Copilot guidance with architecture overview and key patterns

### CI/CD Configuration

- **[.github/workflows/release.yml](../.github/workflows/release.yml)** - Automated build and release pipeline for Android and iOS

---

## Getting Started

### Prerequisites

- Flutter SDK >=3.6.0
- Android Studio or Xcode
- Connected device or emulator

### Quick Start

```bash
# Clone and setup
git clone <repository-url>
cd badminton_score
flutter pub get

# Generate assets
dart run flutter_launcher_icons
flutter pub run flutter_native_splash:create

# Run app
flutter run
```

### Essential Commands

```bash
flutter run                    # Debug mode with hot reload
flutter test                   # Run tests
flutter analyze                # Static analysis
dart format .                  # Format code
flutter build apk --release    # Build Android APK (~19 MB)
```

---

## Documentation Guide

### For New Developers

**Start Here:**
1. [Project Overview](./project-overview.md) - Understand the project
2. [Architecture](./architecture.md) - Learn the architecture
3. [Development Guide](./development-guide.md) - Setup your environment
4. [Source Tree Analysis](./source-tree-analysis.md) - Navigate the codebase

**Then Explore:**
- [Data Models](./data-models.md) - Understand state management
- [UI Components](./ui-components.md) - Learn the component system
- [README.md](../README.md) - User-facing features

### For Feature Development

**Planning a Feature:**
1. Review [Architecture](./architecture.md) - Understand design decisions
2. Check [Data Models](./data-models.md) - Plan state changes
3. Review [UI Components](./ui-components.md) - Identify reusable components
4. Follow [Development Guide](./development-guide.md) - Implementation workflow

**Common Tasks:**
- Adding a theme → [Architecture](./architecture.md#theme-system-architecture)
- Modifying game rules → [Data Models](./data-models.md#validation-rules)
- Adding persistence → [Development Guide](./development-guide.md#adding-persistence)
- Modifying UI → [UI Components](./ui-components.md)

### For Code Review

**Review Checklist:**
- Architecture compliance → [Architecture](./architecture.md)
- Code style → [Development Guide](./development-guide.md#code-quality)
- State management → [Data Models](./data-models.md#state-management-architecture)
- UI consistency → [UI Components](./ui-components.md#design-system)
- Asset optimization → [Asset Inventory](./asset-inventory.md#optimization-recommendations)

### For Deployment

**Deployment Process:**
1. [Development Guide](./development-guide.md#deployment) - Build commands
2. [Architecture](./architecture.md#deployment-architecture) - Build configuration
3. [.github/workflows/release.yml](../.github/workflows/release.yml) - CI/CD pipeline

---

## Project Structure

```
badminton_score/
├── lib/
│   └── main.dart              # Complete application (1,580 lines)
├── test/
│   └── widget_test.dart       # Widget tests
├── assets/
│   ├── fonts/                 # Poppins font family
│   ├── beep.mp3              # Score sound effect
│   └── splash.png            # App icon source
├── android/                   # Android platform code
├── ios/                       # iOS platform code
├── docs/                      # Generated documentation (this folder)
│   ├── index.md              # This file
│   ├── project-overview.md
│   ├── architecture.md
│   ├── data-models.md
│   ├── ui-components.md
│   ├── asset-inventory.md
│   ├── source-tree-analysis.md
│   └── development-guide.md
├── pubspec.yaml              # Project configuration
├── README.md                 # User documentation
└── CLAUDE.md                 # AI assistant instructions
```

---

## Key Concepts

### Architecture Pattern

**Single-File Component Architecture:**
- All code in lib/main.dart (1,580 lines)
- Clear class-based separation of concerns
- No external state management libraries
- Offline-first design

**Benefits:**
- Simple and easy to understand
- Fast development iteration
- Clear code organization
- Minimal complexity

**Trade-offs:**
- Large file size (consider splitting at 2,000+ lines)
- Limited parallel development

### State Management

**Two-Tier Approach:**
1. **Global State (Theme)** - Managed in BadmintonScoreApp
2. **Local State (Game)** - Managed in ScoreScreen with setState()

**Persistence:**
- Theme, sound toggle, target score, player names → SharedPreferences
- Scores, games won, undo history → Transient (session-only)

### Component System

**Builder Pattern:**
- `_buildScoreButton()` - Large score display
- `_buildControlButton()` - Outlined action buttons
- `_buildMenuButton()` - Dual-gesture menu access
- `_buildGridItem()` - Consistent padding wrapper

**Responsive Design:**
- FittedBox for all text (prevents overflow)
- Flex-based layout (75% score, 25% controls)
- SafeArea for platform insets

---

## Development Workflow

### Daily Development

1. **Start Development**
   ```bash
   flutter run  # Hot reload enabled
   ```

2. **Make Changes**
   - Edit lib/main.dart
   - Press `r` for hot reload
   - Press `R` for hot restart

3. **Test Changes**
   ```bash
   flutter test
   flutter analyze
   ```

4. **Format Code**
   ```bash
   dart format .
   ```

### Adding Features

**Workflow:**
1. Read relevant documentation
2. Plan changes (use TodoWrite if complex)
3. Implement changes
4. Add tests
5. Run linter and tests
6. Commit with conventional commit message

**Example: Adding a Theme**
```dart
// 1. Define in AppThemes.themes (lib/main.dart:66)
'myTheme': ThemeColors(
  name: 'My Theme',
  background: Color(0xFFFFFFFF),
  primary: Color(0xFF2196F3),
  // ... 6 more colors
),

// 2. Test with swipe or menu
// 3. Verify WCAG AA contrast
```

### Debugging

**Common Issues:**
- Hot reload not working → Press `R` (hot restart)
- Build errors → `flutter clean && flutter pub get`
- Audio not playing → Check sound toggle and asset declaration
- Theme not persisting → Check SharedPreferences permissions

**Debug Tools:**
```bash
flutter run -v              # Verbose logging
flutter run --profile       # Performance profiling
# Press 'w' while running   # Open DevTools
```

---

## Testing

### Test Coverage

**Widget Tests (test/widget_test.dart):**
- Widget rendering
- Win detection logic
- Game state management
- Score increment/decrement

**Run Tests:**
```bash
flutter test                # Run all tests
flutter test --coverage     # Generate coverage report
```

### Manual Testing Checklist

- [ ] Score increment/decrement works
- [ ] Win detection at target score with margin
- [ ] Sudden death at target + 9
- [ ] Undo system (up to 10 actions)
- [ ] Theme switching via swipe
- [ ] Audio feedback plays
- [ ] Sound toggle persists
- [ ] Player names persist
- [ ] Target score persists
- [ ] Landscape orientation locked
- [ ] Screen stays awake

---

## Deployment

### Android

**Build APK:**
```bash
flutter build apk --release --shrink
```

**Output:** build/app/outputs/flutter-apk/app-release.apk (~19 MB)

**Distribution:**
- Direct APK sharing
- Google Play Store (use app bundle)

### iOS

**Build IPA:**
```bash
flutter build ios --release --no-codesign
```

**Requirements:**
- Apple Developer account
- Code signing certificate
- Provisioning profile

### CI/CD

**GitHub Actions:**
- Automated builds for Android and iOS
- Semantic versioning
- Release artifact generation
- Manual trigger via workflow dispatch

---

## Performance Metrics

| Metric | Value |
|--------|-------|
| **APK Size** | ~19 MB (with shrinking) |
| **Audio Latency** | <50ms (preloaded) |
| **Hot Reload** | <1s |
| **Build Time** | ~30s |
| **Lines of Code** | 1,580 |
| **Dependencies** | 3 runtime |

---

## Accessibility

**WCAG AA Compliance:**
- ✅ High contrast themes
- ✅ Large touch targets (75% screen height for scores)
- ✅ Semantics labels for screen readers
- ✅ Haptic feedback for actions
- ✅ Visual + audio feedback (not audio-only)

**Supported Features:**
- Screen reader compatibility
- System font scaling
- High contrast mode
- Reduced motion support

---

## Security & Privacy

**Security:**
- No network communication
- Local-only storage
- No sensitive data collected
- Standard Flutter security model

**Privacy:**
- No analytics or tracking
- No data sharing
- Offline-first operation
- User data stays on device

---

## Contributing

### Commit Conventions

Follow Conventional Commits:

**Types:**
- `feat:` - New feature
- `fix:` - Bug fix
- `refactor:` - Code restructuring
- `docs:` - Documentation
- `test:` - Tests
- `style:` - Formatting

**Examples:**
- `feat(theme): add ocean theme`
- `fix(gesture): prevent accidental theme swap`
- `docs: update architecture documentation`

### Code Style

- Follow analysis_options.yaml rules
- Use `dart format` before committing
- Add tests for new features
- Keep methods focused and small
- Avoid over-engineering

---

## Resources

### Official Documentation

- **Flutter:** https://flutter.dev/docs
- **Dart:** https://dart.dev/guides
- **Material Design:** https://material.io/design

### Package Documentation

- **audioplayers:** https://pub.dev/packages/audioplayers
- **wakelock_plus:** https://pub.dev/packages/wakelock_plus
- **shared_preferences:** https://pub.dev/packages/shared_preferences

### Community

- **Flutter Discord:** https://discord.gg/flutter
- **Stack Overflow:** Tag `flutter`
- **GitHub Issues:** <repository-url>/issues

---

## Support

### Getting Help

1. Check relevant documentation above
2. Search existing GitHub issues
3. Run `flutter doctor -v` for diagnostics
4. Create new issue with:
   - Flutter version
   - Device/emulator details
   - Steps to reproduce
   - Error messages and logs

### Reporting Bugs

Include:
- Flutter version (`flutter --version`)
- Device/emulator details
- Steps to reproduce
- Expected vs actual behavior
- Error messages and stack traces
- Screenshots if applicable

---

## License

[License information to be added]

---

## Acknowledgments

**Built with:**
- Flutter framework by Google
- Poppins font by Google Fonts
- Material Design guidelines
- Community feedback and testing

---

**Documentation Generated:** BMAD document-project workflow
**Workflow Version:** 1.2.0
**Scan Level:** Exhaustive
**Generated:** 2026-01-16
