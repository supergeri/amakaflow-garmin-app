using Toybox.WatchUi;
using Toybox.Attention;
using Toybox.System;

//! Input delegate for handling button presses
class WorkoutRemoteDelegate extends WatchUi.BehaviorDelegate {

    var comm;
    var keyPressTime = 0;  // Timestamp for long press detection
    var longPressHandled = false;  // Track if long press was already handled
    const LONG_PRESS_THRESHOLD = 1500;  // 1.5 seconds for long press

    function initialize(commManager) {
        BehaviorDelegate.initialize();
        comm = commManager;
    }

    //! Top right START button - End workout (with confirmation)
    //! Note: This is ONLY for the physical START button, not screen taps
    function onSelect() {
        System.println("[UI] onSelect called (START button)");

        // In demo mode, cycle screens
        if (WorkoutRemoteView.demoMode) {
            WorkoutRemoteView.nextDemoScreen();
            vibrate();
            return true;
        }

        var app = getApp();
        var state = app.getWorkoutState();

        if (state != null && state.isActive()) {
            // Only end workout from physical START button
            var dialog = new WatchUi.Confirmation("End Workout?");
            WatchUi.pushView(dialog, new EndWorkoutConfirmDelegate(comm), WatchUi.SLIDE_UP);
            return true;
        } else if (state == null || state.isIdle()) {
            // When idle, refresh state
            if (comm != null) {
                comm.requestState();
                vibrate();
            }
        }

        return true;
    }

    //! Middle left UP button - Pause/Resume
    function onPreviousPage() {
        var app = getApp();
        var state = app.getWorkoutState();

        if (state != null) {
            if (state.isRunning()) {
                sendCommand("PAUSE");
                vibrate();
            } else if (state.isPaused()) {
                sendCommand("RESUME");
                vibrate();
            }
        }
        return true;
    }

    //! Bottom left DOWN button - Previous step
    function onNextPage() {
        var app = getApp();
        var state = app.getWorkoutState();

        if (state != null && state.isActive()) {
            sendCommand("PREV_STEP");
            vibrate();
        }
        return true;
    }

    //! Bottom right BACK button - Next step
    function onBack() {
        var app = getApp();
        var state = app.getWorkoutState();

        if (state != null && state.isActive()) {
            sendCommand("NEXT_STEP");
            vibrate();
            return true;
        }

        return false;
    }

    //! Menu button (long press LIGHT) - Toggle demo mode or refresh state
    //! In simulator: use Ctrl+M or File > Simulate Key > Menu
    function onMenu() {
        // In demo mode, cycle through screens
        if (WorkoutRemoteView.demoMode) {
            WorkoutRemoteView.nextDemoScreen();
            vibrate();
            return true;
        }

        // Not in demo mode - check if we should enter demo mode or refresh
        var app = getApp();
        var state = app.getWorkoutState();

        // If idle (no active workout), toggle demo mode on
        if (state == null || state.isIdle()) {
            WorkoutRemoteView.toggleDemoMode();
            vibrate();
            System.println("[UI] Demo mode: " + (WorkoutRemoteView.demoMode ? "ON" : "OFF"));
            return true;
        }

        // Active workout - refresh state from iOS
        if (comm != null) {
            comm.requestState();
            vibrate();
        }
        return true;
    }

    //! Track when key is pressed (for long press detection)
    function onKeyPressed(evt) {
        keyPressTime = System.getTimer();
        longPressHandled = false;
        return false;  // Don't consume - let other handlers process
    }

    //! Check for long press on key release
    function onKeyReleased(evt) {
        var elapsed = System.getTimer() - keyPressTime;
        var key = evt.getKey();

        // Long press on SELECT/ENTER toggles demo mode
        if (elapsed >= LONG_PRESS_THRESHOLD && key == WatchUi.KEY_ENTER) {
            WorkoutRemoteView.toggleDemoMode();
            vibrate();
            longPressHandled = true;
            System.println("[UI] Demo mode: " + (WorkoutRemoteView.demoMode ? "ON" : "OFF"));
            return true;
        }

        return false;
    }

    function onKey(evt) {
        // Skip if we just handled a long press
        if (longPressHandled) {
            longPressHandled = false;
            return true;
        }
        var key = evt.getKey();
        if (key == WatchUi.KEY_ENTER) {
            return onSelect();
        }
        return false;
    }

    //! Touch screen hold handler (for touch devices)
    function onHold(evt) {
        WorkoutRemoteView.toggleDemoMode();
        vibrate();
        System.println("[UI] Demo mode: " + (WorkoutRemoteView.demoMode ? "ON" : "OFF"));
        return true;
    }

    function onSwipe(evt) {
        var app = getApp();
        var state = app.getWorkoutState();
        var direction = evt.getDirection();

        if (state != null && state.isActive()) {
            if (direction == WatchUi.SWIPE_UP) {
                // Swipe up = go to next step
                sendCommand("NEXT_STEP");
                vibrate();
                return true;
            } else if (direction == WatchUi.SWIPE_DOWN) {
                // Swipe down = go to previous step
                sendCommand("PREV_STEP");
                vibrate();
                return true;
            }
        }
        return false;
    }

    //! Tap on screen = Pause/Resume
    function onTap(evt) {
        System.println("[UI] onTap called (screen tap)");

        // In demo mode, cycle screens
        if (WorkoutRemoteView.demoMode) {
            WorkoutRemoteView.nextDemoScreen();
            vibrate();
            return true;
        }

        var app = getApp();
        var state = app.getWorkoutState();

        if (state != null) {
            if (state.isRunning()) {
                System.println("[UI] Tap -> PAUSE");
                sendCommand("PAUSE");
                vibrate();
                return true;
            } else if (state.isPaused()) {
                System.println("[UI] Tap -> RESUME");
                sendCommand("RESUME");
                vibrate();
                return true;
            }
        }

        return true;
    }

    hidden function sendCommand(command) {
        if (comm != null) {
            comm.sendCommand(command);
        }
    }

    hidden function vibrate() {
        if (Attention has :vibrate) {
            try {
                var vibeData = [new Attention.VibeProfile(50, 100)];
                Attention.vibrate(vibeData);
            } catch (ex) {
                System.println("Vibration not available");
            }
        }
    }
}

class EndWorkoutConfirmDelegate extends WatchUi.ConfirmationDelegate {

    var comm;

    function initialize(commManager) {
        ConfirmationDelegate.initialize();
        comm = commManager;
    }

    function onResponse(response) {
        if (response == WatchUi.CONFIRM_YES) {
            if (comm != null) {
                comm.sendCommand("END");

                if (Attention has :vibrate) {
                    try {
                        var vibeData = [
                            new Attention.VibeProfile(100, 100),
                            new Attention.VibeProfile(0, 100),
                            new Attention.VibeProfile(100, 100)
                        ];
                        Attention.vibrate(vibeData);
                    } catch (ex) {
                    }
                }
            }
        }
        return true;
    }
}
