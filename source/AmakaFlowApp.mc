using Toybox.Application;
using Toybox.WatchUi;
using Toybox.Communications;
using Toybox.System;

//! Main application class for AmakaFlow Workout Remote
//! Handles app lifecycle and phone message routing
class AmakaFlowApp extends Application.AppBase {

    var commManager as CommManager?;
    var workoutState as WorkoutState?;

    //! Constructor
    function initialize() {
        AppBase.initialize();
        commManager = new CommManager();
        workoutState = new WorkoutState();
    }

    //! Called when the app starts
    //! @param state Dictionary of app state (unused)
    function onStart(state as Dictionary?) as Void {
        // Register for phone app messages
        Communications.registerForPhoneAppMessages(method(:onMessage));

        // Request current state from phone
        if (commManager != null) {
            commManager.requestState();
        }
    }

    //! Called when the app stops
    //! @param state Dictionary to save state (unused)
    function onStop(state as Dictionary?) as Void {
        // Cleanup if needed
    }

    //! Returns the initial view for the app
    //! @return Array containing the view and input delegate
    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [new WorkoutRemoteView(workoutState), new WorkoutRemoteDelegate(commManager)];
    }

    //! Handles incoming messages from the phone
    //! @param msg The message received from the phone
    function onMessage(msg as Communications.PhoneAppMessage) as Void {
        var data = msg.data;
        if (data instanceof Dictionary) {
            var action = data.get("action");

            if (action != null && action.equals("stateUpdate")) {
                if (workoutState != null) {
                    workoutState.update(data);
                    WatchUi.requestUpdate();
                }
            } else if (action != null && action.equals("commandAck")) {
                // Command acknowledged by phone
                var commandId = data.get("commandId");
                System.println("Command acknowledged: " + commandId);
            }
        }
    }

    //! Get the workout state
    //! @return The current workout state
    function getWorkoutState() as WorkoutState? {
        return workoutState;
    }

    //! Get the communication manager
    //! @return The communication manager instance
    function getCommManager() as CommManager? {
        return commManager;
    }
}

//! Get the application instance
//! @return The AmakaFlowApp instance
function getApp() as AmakaFlowApp {
    return Application.getApp() as AmakaFlowApp;
}
