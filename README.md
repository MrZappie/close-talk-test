## Close Talk 🎯

## Basic Details
### Team Name: MitsFits

### Team Members
- Team Lead: Sourav Sreekumar - [College]
- Member 2: Sreya S - [College]

### Project Description
Close Talk is a peer-to-peer, internet-free chat app that discovers nearby devices and lets you exchange messages directly over local connections. Profiles and conversations  are stored locally.

### The Problem (that doesn't exist)
The Wi-Fi’s down, the data’s slow, and now you have to actually… talk? In person? Yikes.

### The Solution (that nobody asked for)
We let your phones gossip without the internet. They find each other and chat behind your back—delivering your words without leaving the room.

## Technical Details
### Technologies/Components Used
For Software:
- Languages used: Dart
- Frameworks used: Flutter
- Libraries used: nearby_connections, hive, hive_flutter, shared_preferences, permission_handler, location, device_info_plus,uuid.
- Tools used: Flutter SDK,VS Code,Cursor.ai,

For Hardware:
- Not applicable

### Implementation
For Software:

#### Installation
bash
# Prerequisites: Flutter SDK installed and set up
flutter --version

# Get dependencies
flutter pub get


#### Run
bash
# Run on a connected Android device or emulator
flutter run


Notes:
- The app uses Nearby Connections; testing requires at least two Android devices/emulators with location and Bluetooth/Wi‑Fi Direct enabled.
- On first launch, the app requests required permissions and creates a local profile via Hive.

### Project Documentation
For Software:

#### Screenshots (Add at least 3)
![Home/Discovery](docs/screenshots/home_discovery.png)
Shows discovered nearby users and connection status.

![Chat](docs/screenshots/chat_thread.png)
Chat thread with faux-glass bubbles and live sent/received messages.

![Profile](docs/screenshots/profile_screen.png)
Profile screen with username edit and broadcast toggle.

#### Diagrams
![Workflow](docs/diagrams/workflow.png)
Discovery ↔ Connect ↔ Exchange messages; profile and messages persisted locally (Hive); broadcast/discovery state cached (SharedPreferences).

For Hardware:

#### Schematic & Circuit
Not applicable.

#### Build Photos
Not applicable.

### Project Demo
#### Video
[Add your demo video link here]
Walkthrough: discovery, connect, send messages, edit profile and toggle broadcasting.

#### Additional Demos
[Add any extra demo materials/links]

## Team Contributions
- Sourav Sreekumar: Nearby discovery/connection flow, messaging pipeline, state management, build setup, permission handling
- Sreya S: UI/UX design and polish, testing and docs.
