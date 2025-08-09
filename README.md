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

 users and connection status.
![hometab_current](https://github.com/user-attachments/assets/d455caf1-fa54-48f5-854d-824b83a97966)

![Chat](docs/screenshots/chat_thread.png)
Chat thread with faux-glass bubbles and live sent/received messages.
![hometab_history](https://github.com/user-attachments/assets/54d021e7-a40c-4b15-ac5f-f26c9f4ae204)

![Profile](docs/screenshots/profile_screen.png)
Profile screen with username edit and broadcast toggle.
![profile](https://github.com/user-attachments/assets/9c88fc86-9abe-423b-802d-bf032c9478a4)

#### Diagrams
![Workflow](docs/diagrams/workflow.png)
Discovery ↔ Connect ↔ E<img width="1536" height="1024" alt="ChatGPT Image Aug 9, 2025, 05_27_45 AM" src="https://github.com/user-attachments/assets/174623f9-ebfa-419a-b773-195e303d66db" />
xchange messages; profile and messages persisted locally (Hive); broadcast/discovery state cached (SharedPreferences).

For Hardware:

#### Schematic & Circuit
Not applicable.

#### Build Photos
Not applicable.

### Project Demo
#### Video

https://github.com/user-attachments/assets/26ebc032-991c-4e0f-9427-7ee9b66eb439


[Add your demo video link here]
Walkthrough: discovery, con
https://github.com/user-attachments/assets/53a353d9-f173-4b5b-a7e1-c18008a6bc71


nect, send messages, edit profile and toggle broadcasting.

#### Additional Demos

## Team Contributions
- Sourav Sreekumar: Nearby discovery/connection flow, messaging pipeline, state management, build setup, permission handling
- Sreya S: UI/UX design and polish, testing and docs.
