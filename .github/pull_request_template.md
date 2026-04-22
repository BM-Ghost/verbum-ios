## Description
<!-- Required: Explain the context and motivation for this change. -->



## Type of Change
<!-- Check all that apply. -->
- [ ] Bug fix (non-breaking change that fixes an issue)
- [ ] New feature (non-breaking change that adds functionality)
- [ ] Breaking change (fix or feature that alters existing behaviour)
- [ ] Refactor (code restructure with no behaviour change)
- [ ] Performance improvement
- [ ] UI / Preview update
- [ ] Documentation / README update
- [ ] CI/CD / DevOps change (requires owner approval)
- [ ] Dependency update

---

## Contributor Checklist

### Code Quality
- [ ] bash Scripts/Verification/verify_verbum_guidelines.sh passes locally with no violations
- [ ] xcodebuild build passes locally
- [ ] No TODO or FIXME left in changed files

### Architecture
- [ ] New code follows App -> Features/Core and Features -> Core dependency direction
- [ ] No direct SwiftData/CoreData access in Views/ViewModels
- [ ] No direct URLSession calls in Views/ViewModels
- [ ] No feature-to-feature compile-time dependency introduced

### UI / Previews
- [ ] Every new screen has a SwiftUI preview
- [ ] Previews render correctly in Xcode
- [ ] Theme tokens are used for colors and typography (no hardcoded color literals)

### Tests
- [ ] Unit tests added or updated for new logic
- [ ] xcodebuild test passes locally

### Security
- [ ] No secrets, API keys, or credentials added to source files
- [ ] All network calls use HTTPS
- [ ] Input from external sources is validated before use

---

## Screenshots / Screen Recordings
<!-- If UI changes are included, add before/after screenshots for at least one key flow. -->

| Before | After |
|--------|-------|
|        |       |

---

## Related Issues
<!-- Link related issues using "Closes #123" or "Relates to #456" syntax. -->
