using Toybox.Application;
using Toybox.WatchUi;
using Toybox.Communications;
using Toybox.System;
using Toybox.Lang;
using Toybox.Attention;

//! App version - update here and in manifest.xml
const APP_VERSION = "1.0.14";

//! Main application class for AmakaFlow Workout Remote
class AmakaFlowApp extends Application.AppBase {

    var commManager;
    var workoutState;
    var messageCount = 0;

    function initialize() {
        AppBase.initialize();
        System.println("[APP] ===== AmakaFlow Initializing =====");
        System.println("[APP] App UUID: 90ABF0DE-493E-47B7-B0A2-16A4D685D02A");
        commManager = new CommManager();
        workoutState = new WorkoutState();
        System.println("[APP] Initialization complete");
    }

    function onStart(state) {
        System.println("[APP] ===== onStart called =====");

        // Log device info
        var deviceSettings = System.getDeviceSettings();
        System.println("[APP] Phone connected: " + deviceSettings.phoneConnected);
        System.println("[APP] Connection available: " + deviceSettings.connectionAvailable);

        // Register for messages from iOS app
        System.println("[APP] Registering for phone app messages...");
        Communications.registerForPhoneAppMessages(method(:onMessage));
        System.println("[APP] Message registration complete");

        // Give haptic feedback to confirm app started
        if (Attention has :vibrate) {
            System.println("[APP] Sending startup vibration");
            Attention.vibrate([new Attention.VibeProfile(50, 200)]);
        }

        // Request current state from iOS app
        if (commManager != null) {
            System.println("[APP] Requesting initial state from iOS app...");
            commManager.requestState();
        }
    }

    function onStop(state) {
        System.println("[APP] ===== onStop called =====");
        System.println("[APP] Messages received this session: " + messageCount);
    }

    function getInitialView() {
        System.println("[APP] getInitialView called");
        return [new WorkoutRemoteView(workoutState), new WorkoutRemoteDelegate(commManager)];
    }

    function onMessage(msg as Communications.PhoneAppMessage) as Void {
        messageCount++;
        System.println("[APP] ===== MESSAGE RECEIVED #" + messageCount + " =====");

        var data = msg.data;
        System.println("[APP] Raw message type: " + data);

        if (data instanceof Lang.Dictionary) {
            var action = data.get("action");
            System.println("[APP] Message action: " + action);

            // Vibrate to indicate message received
            if (Attention has :vibrate) {
                Attention.vibrate([new Attention.VibeProfile(25, 100)]);
            }

            if (action != null && action.equals("stateUpdate")) {
                System.println("[APP] Processing stateUpdate...");
                if (workoutState != null) {
                    workoutState.update(data);
                    WatchUi.requestUpdate();
                    System.println("[APP] UI updated with new state");
                }
            } else if (action != null && action.equals("commandAck")) {
                System.println("[APP] Received command acknowledgment");
                var commandId = data.get("commandId");
                var status = data.get("status");
                System.println("[APP] Command " + commandId + " status: " + status);
            } else if (action != null && action.equals("ping")) {
                System.println("[APP] ===== PING RECEIVED! =====");
                var timestamp = data.get("timestamp");
                System.println("[APP] Ping timestamp: " + timestamp);
                // Send pong response back to iOS
                if (commManager != null) {
                    commManager.sendPong(timestamp);
                }
                // Extra vibration to confirm ping
                if (Attention has :vibrate) {
                    Attention.vibrate([new Attention.VibeProfile(100, 300)]);
                }
            } else {
                System.println("[APP] Unknown action: " + action);
            }
        } else {
            System.println("[APP] WARNING: Message is not a Dictionary!");
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
