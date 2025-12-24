using Toybox.Communications;
using Toybox.System;
using Toybox.Lang;

//! Manages communication with the AmakaFlow iPhone app
class CommManager {

    var isConnected = false;
    var retryCount = 0;
    var lastTransmitTime = 0;
    var transmitAttempts = 0;
    var lastError = "";
    const MAX_RETRIES = 3;

    function initialize() {
        System.println("[COMM] CommManager initialized");
        logPhoneStatus();
    }

    //! Log detailed phone connectivity status
    function logPhoneStatus() {
        var settings = System.getDeviceSettings();
        var phoneConnected = settings.phoneConnected;
        var connectionAvailable = settings.connectionAvailable;

        System.println("[COMM] ===== Phone Status =====");
        System.println("[COMM] phoneConnected: " + phoneConnected);
        System.println("[COMM] connectionAvailable: " + connectionAvailable);
        System.println("[COMM] ========================");

        return phoneConnected;
    }

    //! Check if phone is connected at system level
    function isPhoneAvailable() {
        var settings = System.getDeviceSettings();
        return settings.phoneConnected;
    }

    function sendCommand(command) {
        System.println("[COMM] sendCommand called: " + command);
        logPhoneStatus();

        var message = {
            "action" => "command",
            "command" => command,
            "commandId" => System.getTimer().toString(),
            "timestamp" => System.getTimer()
        };
        transmitMessage(message);
    }

    function requestState() {
        System.println("[COMM] requestState called");
        logPhoneStatus();

        var message = {
            "action" => "requestState",
            "timestamp" => System.getTimer()
        };
        transmitMessage(message);
    }

    function sendStateAck(stateVersion) {
        System.println("[COMM] sendStateAck called: version=" + stateVersion);

        var message = {
            "action" => "stateAck",
            "version" => stateVersion,
            "timestamp" => System.getTimer()
        };
        transmitMessage(message);
    }

    //! Send pong response to iOS ping
    function sendPong(pingTimestamp) {
        System.println("[COMM] sendPong called");

        var message = {
            "action" => "pong",
            "pingTimestamp" => pingTimestamp,
            "pongTimestamp" => System.getTimer()
        };
        transmitMessage(message);
    }

    hidden function transmitMessage(message) {
        transmitAttempts++;
        lastTransmitTime = System.getTimer();
        var action = message.get("action");

        System.println("[COMM] ===== TRANSMIT #" + transmitAttempts + " =====");
        System.println("[COMM] Action: " + action);
        System.println("[COMM] Phone available: " + isPhoneAvailable());

        if (!isPhoneAvailable()) {
            System.println("[COMM] WARNING: Phone not connected at system level!");
            System.println("[COMM] Make sure Garmin Connect is running and watch is paired");
            lastError = "Phone not connected";
        }

        try {
            System.println("[COMM] Calling Communications.transmit()...");
            Communications.transmit(message, null, new CommListener(self));
            System.println("[COMM] transmit() called successfully, waiting for callback...");
        } catch (ex) {
            System.println("[COMM] EXCEPTION in transmit(): " + ex.getErrorMessage());
            lastError = "Exception: " + ex.getErrorMessage();
            onTransmitError();
        }
    }

    function onTransmitComplete() {
        isConnected = true;
        retryCount = 0;
        lastError = "";
        System.println("[COMM] ===== TRANSMIT SUCCESS =====");
        System.println("[COMM] Message delivered to phone app!");
        System.println("[COMM] Total attempts: " + transmitAttempts);
    }

    function onTransmitError() {
        isConnected = false;
        retryCount++;
        System.println("[COMM] ===== TRANSMIT FAILED =====");
        System.println("[COMM] Retry count: " + retryCount + "/" + MAX_RETRIES);
        System.println("[COMM] Phone available: " + isPhoneAvailable());
        System.println("[COMM] This usually means:");
        System.println("[COMM]   1. AmakaFlow iOS app is not running, OR");
        System.println("[COMM]   2. iOS app hasn't registered for messages, OR");
        System.println("[COMM]   3. Watch app UUID doesn't match iOS app UUID");
        if (lastError.length() > 0) {
            System.println("[COMM] Last error: " + lastError);
        }
    }

    function isPhoneConnected() {
        return isConnected;
    }

    //! Get debug status for display
    function getDebugStatus() {
        var status = "Phone: " + (isPhoneAvailable() ? "YES" : "NO");
        status = status + " | App: " + (isConnected ? "YES" : "NO");
        status = status + " | Attempts: " + transmitAttempts;
        return status;
    }
}

class CommListener extends Communications.ConnectionListener {

    var manager;

    function initialize(commManager) {
        ConnectionListener.initialize();
        manager = commManager;
        System.println("[COMM] CommListener created");
    }

    function onComplete() {
        System.println("[COMM] CommListener.onComplete() - Message delivered!");
        manager.onTransmitComplete();
    }

    function onError() {
        System.println("[COMM] CommListener.onError() - Transmission failed");
        manager.onTransmitError();
    }
}
