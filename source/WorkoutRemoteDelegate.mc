using Toybox.WatchUi;
using Toybox.Attention;
using Toybox.System;

//! Input delegate for handling button presses on the workout remote view
//! Maps physical buttons to workout commands
class WorkoutRemoteDelegate extends WatchUi.BehaviorDelegate {

    //! Reference to communication manager
    var comm as CommManager?;

    //! Constructor
    //! @param commManager The communication manager instance
    function initialize(commManager as CommManager?) {
        BehaviorDelegate.initialize();
        comm = commManager;
    }

    //! Handle SELECT button press (Play/Pause toggle)
    //! @return true if handled
    function onSelect() as Boolean {
        var app = getApp();
        var state = app.getWorkoutState();

        if (state != null) {
            if (state.isRunning()) {
                sendCommand("PAUSE");
            } else if (state.isPaused()) {
                sendCommand("RESUME");
            } else if (state.isIdle()) {
                // Request state refresh when idle
                if (comm != null) {
                    comm.requestState();
                }
            }
        }

        vibrate();
        return true;
    }

    //! Handle UP button / Previous page (Previous step)
    //! @return true if handled
    function onPreviousPage() as Boolean {
        var app = getApp();
        var state = app.getWorkoutState();

        if (state != null && state.isActive()) {
            sendCommand("PREV_STEP");
            vibrate();
        }
        return true;
    }

    //! Handle DOWN button / Next page (Next step)
    //! @return true if handled
    function onNextPage() as Boolean {
        var app = getApp();
        var state = app.getWorkoutState();

        if (state != null && state.isActive()) {
            sendCommand("NEXT_STEP");
            vibrate();
        }
        return true;
    }

    //! Handle BACK button press (End workout with confirmation)
    //! @return true if handled
    function onBack() as Boolean {
        var app = getApp();
        var state = app.getWorkoutState();

        if (state != null && state.isActive()) {
            // Show confirmation dialog before ending workout
            var dialog = new WatchUi.Confirmation("End Workout?");
            WatchUi.pushView(dialog, new EndWorkoutConfirmDelegate(comm), WatchUi.SLIDE_UP);
            return true;
        }

        // Allow back button to exit app when idle
        return false;
    }

    //! Handle menu button press
    //! @return true if handled
    function onMenu() as Boolean {
        // Could show a menu with additional options
        // For now, refresh state
        if (comm != null) {
            comm.requestState();
            vibrate();
        }
        return true;
    }

    //! Handle key press events
    //! @param evt The key event
    //! @return true if handled
    function onKey(evt as WatchUi.KeyEvent) as Boolean {
        var key = evt.getKey();

        // Handle specific key events if needed
        if (key == WatchUi.KEY_ENTER) {
            return onSelect();
        }

        return false;
    }

    //! Handle swipe gestures (for touch-enabled devices)
    //! @param evt The swipe event
    //! @return true if handled
    function onSwipe(evt as WatchUi.SwipeEvent) as Boolean {
        var direction = evt.getDirection();

        if (direction == WatchUi.SWIPE_UP) {
            return onNextPage();
        } else if (direction == WatchUi.SWIPE_DOWN) {
            return onPreviousPage();
        }

        return false;
    }

    //! Handle tap on touchscreen
    //! @param evt The click event
    //! @return true if handled
    function onTap(evt as WatchUi.ClickEvent) as Boolean {
        // Tap anywhere to toggle play/pause
        return onSelect();
    }

    //! Send a command to the phone
    //! @param command The command string
    private function sendCommand(command as String) as Void {
        if (comm != null) {
            comm.sendCommand(command);
        }
    }

    //! Trigger haptic feedback
    private function vibrate() as Void {
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

//! Confirmation delegate for ending workout
class EndWorkoutConfirmDelegate extends WatchUi.ConfirmationDelegate {

    //! Reference to communication manager
    var comm as CommManager?;

    //! Constructor
    //! @param commManager The communication manager instance
    function initialize(commManager as CommManager?) {
        ConfirmationDelegate.initialize();
        comm = commManager;
    }

    //! Handle confirmation response
    //! @param response The user's response
    //! @return true
    function onResponse(response as WatchUi.Confirm) as Boolean {
        if (response == WatchUi.CONFIRM_YES) {
            if (comm != null) {
                comm.sendCommand("END");

                // Vibrate to confirm
                if (Attention has :vibrate) {
                    try {
                        var vibeData = [
                            new Attention.VibeProfile(100, 100),
                            new Attention.VibeProfile(0, 100),
                            new Attention.VibeProfile(100, 100)
                        ];
                        Attention.vibrate(vibeData);
                    } catch (ex) {
                        // Ignore vibration errors
                    }
                }
            }
        }
        return true;
    }
}
