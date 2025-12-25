using Toybox.WatchUi;
using Toybox.Attention;
using Toybox.System;

//! Input delegate for handling button presses
class WorkoutRemoteDelegate extends WatchUi.BehaviorDelegate {

    var comm;

    function initialize(commManager) {
        BehaviorDelegate.initialize();
        comm = commManager;
    }

    //! Top right START button - End workout (with confirmation)
    function onSelect() {
        var app = getApp();
        var state = app.getWorkoutState();

        if (state != null && state.isActive()) {
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

    function onMenu() {
        if (comm != null) {
            comm.requestState();
            vibrate();
        }
        return true;
    }

    function onKey(evt) {
        var key = evt.getKey();
        if (key == WatchUi.KEY_ENTER) {
            return onSelect();
        }
        return false;
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

    //! Tap on screen = Pause/Resume (same as UP button)
    function onTap(evt) {
        return onPreviousPage();
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
