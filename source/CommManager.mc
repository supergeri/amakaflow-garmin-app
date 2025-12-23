using Toybox.Communications;
using Toybox.System;
using Toybox.Lang;

//! Manages communication with the AmakaFlow iPhone app
//! Sends commands and receives state updates via Garmin Connect Mobile
class CommManager {

    //! Connection status
    var isConnected as Boolean = false;

    //! Pending command retry count
    var retryCount as Number = 0;

    //! Maximum retry attempts
    const MAX_RETRIES = 3;

    //! Constructor
    function initialize() {
    }

    //! Send a command to the phone
    //! @param command The command string (e.g., "PAUSE", "RESUME", "NEXT_STEP")
    function sendCommand(command as String) as Void {
        var message = {
            "action" => "command",
            "command" => command,
            "commandId" => System.getTimer().toString(),
            "timestamp" => System.getTimer()
        };

        transmitMessage(message);
    }

    //! Request current workout state from phone
    function requestState() as Void {
        var message = {
            "action" => "requestState",
            "timestamp" => System.getTimer()
        };

        transmitMessage(message);
    }

    //! Send acknowledgment for received state
    //! @param stateVersion The version of state being acknowledged
    function sendStateAck(stateVersion as Number) as Void {
        var message = {
            "action" => "stateAck",
            "version" => stateVersion,
            "timestamp" => System.getTimer()
        };

        transmitMessage(message);
    }

    //! Transmit a message to the phone
    //! @param message Dictionary message to send
    private function transmitMessage(message as Dictionary) as Void {
        try {
            Communications.transmit(message, null, new CommListener(self));
            System.println("Transmitting: " + message.get("action"));
        } catch (ex) {
            System.println("Failed to transmit message: " + ex.getErrorMessage());
            onTransmitError();
        }
    }

    //! Called when transmission completes successfully
    function onTransmitComplete() as Void {
        isConnected = true;
        retryCount = 0;
        System.println("Message transmitted successfully");
    }

    //! Called when transmission fails
    function onTransmitError() as Void {
        isConnected = false;
        retryCount++;
        System.println("Transmission error, retry count: " + retryCount);

        // Could implement retry logic here if needed
    }

    //! Check if phone connection is available
    //! @return true if connection appears healthy
    function isPhoneConnected() as Boolean {
        return isConnected;
    }
}

//! Listener for communication transmission results
class CommListener extends Communications.ConnectionListener {

    //! Reference to the CommManager
    var manager as CommManager;

    //! Constructor
    //! @param commManager The CommManager instance
    function initialize(commManager as CommManager) {
        ConnectionListener.initialize();
        manager = commManager;
    }

    //! Called when message is sent successfully
    function onComplete() as Void {
        manager.onTransmitComplete();
    }

    //! Called when message transmission fails
    function onError() as Void {
        manager.onTransmitError();
    }
}
