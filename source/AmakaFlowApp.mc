using Toybox.Application;
using Toybox.WatchUi;
using Toybox.Communications;
using Toybox.System;
using Toybox.Lang;

//! Main application class for AmakaFlow Workout Remote
class AmakaFlowApp extends Application.AppBase {

    var commManager;
    var workoutState;

    function initialize() {
        AppBase.initialize();
        commManager = new CommManager();
        workoutState = new WorkoutState();
    }

    function onStart(state) {
        Communications.registerForPhoneAppMessages(method(:onMessage));
        if (commManager != null) {
            commManager.requestState();
        }
    }

    function onStop(state) {
    }

    function getInitialView() {
        return [new WorkoutRemoteView(workoutState), new WorkoutRemoteDelegate(commManager)];
    }

    function onMessage(msg as Communications.PhoneAppMessage) as Void {
        var data = msg.data;
        if (data instanceof Lang.Dictionary) {
            var action = data.get("action");
            if (action != null && action.equals("stateUpdate")) {
                if (workoutState != null) {
                    workoutState.update(data);
                    WatchUi.requestUpdate();
                }
            }
        }
    }

    function getWorkoutState() {
        return workoutState;
    }

    function getCommManager() {
        return commManager;
    }
}

function getApp() {
    return Application.getApp();
}
