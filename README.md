# AmakaFlow Workout Remote

A Garmin Connect IQ app that acts as a remote control for AmakaFlow workouts on iPhone. Control your workouts from your Garmin watch without touching your phone.

## Features

- **View Workout State**: See current exercise name, timer, and progress
- **Play/Pause**: Toggle workout pause state with SELECT button
- **Navigate Steps**: Skip to next or previous exercise
- **End Workout**: End workout with confirmation dialog
- **Haptic Feedback**: Feel confirmation on button presses

## Button Mapping

| Button | Action | Command |
|--------|--------|---------|
| **SELECT** (middle) | Play/Pause | `PAUSE` / `RESUME` |
| **UP** | Previous step | `PREV_STEP` |
| **DOWN** | Next step | `NEXT_STEP` |
| **BACK** (long) | End workout | `END` (with confirmation) |
| **MENU** | Refresh state | Request state update |

Touch-enabled devices also support:
- **Tap**: Toggle play/pause
- **Swipe Up**: Next step
- **Swipe Down**: Previous step

## Supported Devices

### Fenix Series
- Fenix 7 / 7S / 7X / 7 Pro / 7S Pro / 7X Pro
- Fenix 8 (43mm / 47mm / 51mm / Solar)

### Forerunner Series
- Forerunner 165 / 165 Music
- Forerunner 255 / 255 Music / 255S / 255S Music
- Forerunner 265 / 265S
- Forerunner 955 / 965

### Venu Series
- Venu 2 / 2S / 2 Plus
- Venu 3 / 3S
- Venu Sq 2 / Sq 2 Music

### Other
- Vivoactive 5
- Epix 2 / Epix 2 Pro (42mm / 47mm / 51mm)
- Enduro 2 / Enduro 3

## Development Setup

### Prerequisites

1. **Garmin Connect IQ SDK**
   - Download from [developer.garmin.com](https://developer.garmin.com/connect-iq/sdk/)
   - Install the SDK Manager

2. **Visual Studio Code** with Connect IQ extension
   - Install the "Monkey C" extension from the VS Code marketplace

3. **Developer Key**
   - Generate a developer key for signing apps
   - Store as `developer_key.der` in the project root (do not commit!)

### Building

```bash
# Build for all devices
monkeyc -f monkey.jungle -o bin/AmakaFlow.prg -y developer_key.der

# Build for specific device (e.g., Fenix 7)
monkeyc -d fenix7 -f monkey.jungle -o bin/AmakaFlow-fenix7.prg -y developer_key.der
```

### Simulator Testing

```bash
# Launch the Connect IQ simulator
connectiq

# Side-load the app to simulator
monkeydo bin/AmakaFlow.prg fenix7
```

### Real Device Testing

1. Connect your Garmin device via USB
2. Copy the `.prg` file to `GARMIN/APPS/` on the device
3. Disconnect and launch the app from the watch menu

## Project Structure

```
amakaflow-garmin-app/
├── source/
│   ├── AmakaFlowApp.mc           # Main app entry point
│   ├── AmakaFlowDelegate.mc      # App lifecycle handling
│   ├── WorkoutRemoteView.mc      # Main workout UI
│   ├── WorkoutRemoteDelegate.mc  # Button/input handling
│   ├── CommManager.mc            # Phone communication
│   └── WorkoutState.mc           # Workout state model
├── resources/
│   ├── drawables/                # Icons and graphics
│   ├── layouts/                  # UI layouts
│   ├── settings/                 # App settings definitions
│   ├── strings.xml               # Localized strings
│   └── properties.xml            # Default property values
├── manifest.xml                  # App manifest
├── monkey.jungle                 # Build configuration
└── README.md
```

## Communication Protocol

The app communicates with the AmakaFlow iOS app via Garmin Connect Mobile SDK.

### Messages from Phone → Watch

```json
{
  "action": "stateUpdate",
  "version": 1,
  "phase": "running",
  "stepIndex": 2,
  "stepCount": 10,
  "stepName": "Push-ups",
  "stepType": "reps",
  "remainingMs": 30000,
  "roundInfo": "Round 2 of 3"
}
```

### Messages from Watch → Phone

```json
{
  "action": "command",
  "command": "PAUSE",
  "commandId": "12345678",
  "timestamp": 12345678
}
```

### Commands

| Command | Description |
|---------|-------------|
| `PAUSE` | Pause the current workout |
| `RESUME` | Resume a paused workout |
| `NEXT_STEP` | Skip to next exercise |
| `PREV_STEP` | Go to previous exercise |
| `END` | End the workout |

## iOS Integration

The iOS app needs to integrate the Garmin Connect Mobile SDK and implement `GarminConnectManager.swift` to:

1. Discover and pair with Garmin devices
2. Register for app messages
3. Send state updates to the watch
4. Receive and handle commands from the watch

See the Linear issue AMA-125 for detailed iOS integration code.

## TODO Before Release

- [ ] Add launcher icon (60x60 PNG)
- [ ] Generate unique app UUID in manifest.xml
- [ ] Test on physical devices
- [ ] Implement iOS GarminConnectManager
- [ ] Submit to Connect IQ Store

## Resources

- [Connect IQ SDK Documentation](https://developer.garmin.com/connect-iq/sdk/)
- [Connect IQ Programmer's Guide](https://developer.garmin.com/connect-iq/programmers-guide/)
- [Monkey C Language Reference](https://developer.garmin.com/connect-iq/api-docs/)
- [Garmin Connect Mobile SDK for iOS](https://developer.garmin.com/connect-iq/core-topics/mobile-sdk-for-ios/)

## License

Proprietary - AmakaFlow
