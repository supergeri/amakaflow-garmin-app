using Toybox.Communications;
using Toybox.System;
using Toybox.Lang;

//! Manages communication with the AmakaFlow iPhone app
class CommManager {

    var isConnected = false;
    var retryCount = 0;
    const MAX_RETRIES = 3;

    function initialize() {
    }

    function sendCommand(command) {
        var message = {
            "action" => "command",
            "command" => command,
            "commandId" => System.getTimer().toString(),
            "timestamp" => System.getTimer()
        };
        transmitMessage(message);
    }

    function requestState() {
        var message = {
            "action" => "requestState",
            "timestamp" => System.getTimer()
        };
        transmitMessage(message);
    }

    function sendStateAck(stateVersion) {
        var message = {
            "action" => "stateAck",
            "version" => stateVersion,
            "timestamp" => System.getTimer()
        };
        transmitMessage(message);
    }

    hidden function transmitMessage(message) {
        try {
            Communications.transmit(message, null, new CommListener(self));
            System.println("Transmitting: " + message.get("action"));
        } catch (ex) {
            System.println("Failed to transmit message");
            onTransmitError();
        }
    }

    function onTransmitComplete() {
        isConnected = true;
        retryCount = 0;
        System.println("Message transmitted successfully");
    }

    function onTransmitError() {
        isConnected = false;
        retryCount++;
        System.println("Transmission error, retry count: " + retryCount);
    }

    function isPhoneConnected() {
        return isConnected;
    }
}

class CommListener extends Communications.ConnectionListener {

    var manager;

    function initialize(commManager) {
        ConnectionListener.initialize();
        manager = commManager;
    }

    function onComplete() {
        manager.onTransmitComplete();
    }

    function onError() {
        manager.onTransmitError();
    }
}
