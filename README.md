# SafePaste - Privacy-Focused Clipboard Sanitizer for macOS

SafePaste is a macOS menu bar application that intercepts paste operations with a customizable keyboard shortcut and automatically sanitizes clipboard content to remove sensitive information while preserving context.

## Features

- **Custom Keyboard Shortcut**: Configure any combination of Control, Option, Command, and Shift with a key to trigger safe paste
- **Comprehensive Rule System**: Built-in rules for GDPR compliance and confidential information protection
- **Context Preservation**: Replaces sensitive data with meaningful placeholders (e.g., [EMAIL], [PHONE], [COMPANY])
- **Customizable Rules**: Add, edit, enable/disable rules through the settings panel
- **Real-time Testing**: Test rules before applying them
- **Menu Bar Integration**: Runs in the background, accessible from the menu bar

## Built-in Rules

SafePaste includes default rules for:

### Personal Information
- Email addresses → [EMAIL]
- Phone numbers (US and French formats) → [PHONE]
- Social Security Numbers (US) → [SSN]
- French SIRET/SIREN numbers → [SIRET]/[SIREN]
- Street addresses → [ADDRESS]
- Dates → [DATE]

### Company Information
- Company name patterns → [COMPANY]
- Project names → [PROJECT]

### Technical Information
- Web URLs → [URL]
- IP addresses → [IP]
- Long number sequences (IDs) → [ID]

### Names
- Common first names → [FIRSTNAME]
- Common last names → [LASTNAME]
- Proper nouns → [NAME]

## Installation

### Prerequisites
- macOS 13.0 (Ventura) or later
- Xcode 15.0 or later

### Build from Source

1. Clone the repository:
```bash
cd /workspace/elieauvray__mistral1
```

2. Open the project in Xcode:
```bash
open SafePaste/SafePaste.xcodeproj
```

3. Build and run the project (⌘+R)

4. The application will appear in your menu bar

### Manual Installation

1. Build the application in Xcode (Product → Archive)
2. Export as a macOS Application
3. Copy SafePaste.app to your Applications folder
4. Run the application

## Usage

1. **First Run**: The settings panel will appear automatically
2. **Configure Shortcut**: Set your preferred keyboard shortcut (default: Control+Option+Command+V)
3. **Customize Rules**: Enable/disable built-in rules or add your own
4. **Test Rules**: Use the test feature in the rule editor to verify patterns
5. **Use SafePaste**: Copy text as usual, then use your custom shortcut to paste sanitized content

## Accessibility Permissions

SafePaste requires accessibility permissions to monitor keyboard events and simulate paste operations.

1. When first launched, macOS will prompt you to grant accessibility permissions
2. Go to System Settings → Privacy & Security → Accessibility
3. Add SafePaste to the list of allowed applications
4. Restart SafePaste

## Configuration

### Settings Panel
- **Enable/Disable**: Toggle SafePaste on/off
- **Paste Shortcut**: Configure your custom keyboard shortcut
- **Rules Management**: View, edit, enable/disable, and reorder sanitization rules

### Adding Custom Rules
1. Click the "+" button in the Rules section
2. Enter a name for your rule
3. Specify the pattern to match (use regular expressions for complex patterns)
4. Set the replacement text
5. Toggle "Use Regular Expression" for regex patterns
6. Test the rule with sample text
7. Save the rule

### Rule Examples

**Simple Text Replacement:**
- Pattern: `Confidential`
- Replacement: `[REDACTED]`
- Use Regex: No

**Email Addresses:**
- Pattern: `\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b`
- Replacement: `[EMAIL]`
- Use Regex: Yes

**Custom Project Codes:**
- Pattern: `PROJ-[A-Z0-9]{4,}`
- Replacement: `[PROJECT]`
- Use Regex: Yes

## Security & Privacy

- SafePaste only processes text that you explicitly paste using the custom shortcut
- Original clipboard content is restored immediately after pasting
- All processing happens locally on your machine
- No data is sent to external servers
- Rules are stored locally in your user preferences

## Use Cases

### LLM Interaction
SafePaste is particularly useful when pasting content into Large Language Models (LLMs) or AI assistants:
- Remove personal information from code snippets
- Anonymize user data in support tickets
- Sanitize confidential business information in documents
- Protect sensitive data in chat conversations

### Development & Debugging
- Share code snippets without exposing API keys or credentials
- Post error logs without user-specific information
- Share database queries without sensitive data

### Business Communication
- Paste customer information with identifiers removed
- Share project details without confidential names
- Forward emails with personal data redacted

## Troubleshooting

### Shortcut Not Working
1. Verify the shortcut is configured correctly in Settings
2. Check that SafePaste has accessibility permissions
3. Ensure no other application is using the same shortcut
4. Try a different shortcut combination

### Rules Not Applying
1. Check that the rule is enabled
2. Verify the pattern matches your text
3. Test the rule using the test feature in the rule editor
4. Check the order of rules - they are applied sequentially

### Application Not Appearing
1. Check that the application is running (look for the clipboard icon in menu bar)
2. Try quitting and reopening the application
3. Check Activity Monitor for any crashed instances

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## License

This project is open source and available under the MIT License.

## Acknowledgments

- Inspired by the need for privacy-focused tools in the age of AI
- Built with SwiftUI and AppKit for native macOS integration
- Designed for GDPR compliance and data protection
