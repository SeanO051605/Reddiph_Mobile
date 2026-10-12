# Reddiph - Original UI + Emergency Flow

This version keeps the original Reddiph interface and adds the emergency flow without replacing the original dashboard design.

## Original UI preserved
- Portal role selection
- Resident login
- Resident dashboard and SOS circle
- Responder dashboard
- Doctor dashboard
- Nurse dashboard
- Volunteer dashboard
- Original colors, spacing, cards, typography and navigation

## Resident emergency flow
Resident Dashboard
-> hold SOS
-> responder map with responder name and ETA
-> Responder Arrived
-> Rate responder and close report

The flow is currently simulated locally. The PHP endpoint is included separately for the next backend integration step.

## Run
flutter pub get
flutter run

If Flutter says Android is not a supported platform in this project, run this once inside the project folder:
flutter create .

Then:
flutter pub get
flutter run -d emulator-5554

## PHP API
Keep `sos_api` separate from the Flutter project under XAMPP htdocs.

## Maps
Map screens use interactive Leaflet maps in the shared mobile WebView widget in
`lib/views/widgets/open_street_map.dart`. Tile endpoint, Leaflet CDN URLs,
user-agent, attribution, and demo coordinates are kept separately in
`lib/services/open_street_map_api.dart`. Internet access is required to load
Leaflet and map tiles, and © OpenStreetMap contributors attribution is
displayed on maps. The current markers are demo coordinates near Alfonso,
Cavite; replace them with verified GPS coordinates when connecting live
emergency locations.

## Updated Resident Flow

The resident flow has been updated to match the supplied Resident App Flow reference:

Resident Home -> hold SOS -> responder map with name and ETA -> Responder Arrived -> Rating/Close Report.

Resident bottom navigation is Home / Status / Profile. The Profile tab includes the SOS button. The resident SOS action opens the live-status map directly, with the demo responder name and ETA shown alongside it. Map coordinates and responder information are demo data until live GPS and dispatch integration is available.

The Sending screen remains available to the other roles that use it, with its existing 3-second countdown, cancel, and continue behavior. The resident SOS flow goes directly to tracking.

## Performance & animation pass

**Transitions**
- `core/theme.dart` defines a themed page transition (fade + short slide, light parallax on the page underneath; Cupertino swipe-back kept on iOS). All `MaterialPageRoute` pushes inherit it.
- `core/nav.dart` (`Nav.push / replace / resetTo`) is the single navigation entry point. Stack resets (login, logout, bottom-bar jumps in the SOS flow) cross-fade.
- The logo is a `Hero` between the portal and login screens.
- Tab changes in the shell cross-fade; the SOS FAB scales in/out instead of popping.

**Buttons**
- `Pressable` (in `views/widgets/common.dart`) gives every button a quick press-down scale. It uses a raw `Listener`, so it never interferes with taps, long-press or scrolling.
- The SOS circle pulses while idle, squishes while held and gives a haptic bump when the hold completes. The pulse stops if the OS "remove animations" setting is on.
- The portal role tiles now show their ripple (the old coloured `Container` was painting over the `InkWell`).

**Efficiency**
- One shared `ResidentBottomBar` replaces four copy-pasted bars; one SOS FAB replaces two.
- Screens only rebuild what changed: the SOS countdown uses a `ValueNotifier`, Home / Tracking / Status listen to `SosController` only in the section that needs it, star rating owns its own state.
- Static content is `const`, blurred shadows and the pulse live in `RepaintBoundary`s, `ThemeData` is built once, deprecated `withOpacity` calls removed.
- Fixed: `TrackingScreen` notified listeners during `initState` (setState-during-build); double-tapping CONTINUE/CANCEL could push two routes; the bottom bar ignored the system gesture inset.
