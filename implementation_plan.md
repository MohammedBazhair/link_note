# Bluetooth Chat Logic and UX Improvements

The current Bluetooth chat implementation uses the user's default username for discovery. To improve UX, we will allow users to set a custom "Nearby Name" and enhance the device discovery interface.

## User Review Required

> [!IMPORTANT]
> - Users will now need to set a "Nearby Display Name" if they want to be identified differently during discovery.
> - Advertising and Discovery will be active simultaneously by default when the screen is open.

## Proposed Changes

### [Nearby Service & Providers]

#### [MODIFY] [nearby_service.dart](file:///e:/Projects/Link%20Note/link_note/lib/features/bluetooth_chat/data/datasource/nearby_service.dart)
- Enable updating the local user name without recreating the manager.

#### [MODIFY] [chat_providers.dart](file:///e:/Projects/Link%20Note/link_note/lib/features/bluetooth_chat/presentation/controllers/chat_providers.dart)
- Add `nearbyDisplayNameProvider` to manage the custom name.
- Update `connectionManagerProvider` to use this custom name.

### [UI/UX Enhancements]

#### [MODIFY] [nearby_devices_screen.dart](file:///e:/Projects/Link%20Note/link_note/lib/features/bluetooth_chat/presentation/screens/nearby_devices_screen.dart)
- Add a text field or dialog to set the "Nearby Display Name".
- Improve the device list with better status indicators (e.g., "Connecting...", "Handshaking...").
- Add a toggle for "Visible to others" (Advertising).

## Verification Plan

### Manual Verification
1. Open the "Nearby Devices" screen on two Android devices.
2. Change the "Nearby Name" on Device A.
3. Observe if Device B sees the updated name in its discovery list.
4. Initiate a connection from Device A to Device B.
5. Verify that the chat opens and messages can be sent/received.
