using Toybox.Sensor;
using Toybox.System;
using Toybox.Timer;

//! Manages heart rate sensor and streaming to iOS
class HeartRateManager {

    var currentHR = null;       // null = not available
    var hrAvailable = false;
    var isStreaming = false;
    var commManager;
    var sendTimer;
    var hrReason = "";          // Reason for unavailability

    const HR_SEND_INTERVAL_MS = 2000; // 2 seconds

    function initialize(comm) {
        commManager = comm;
        System.println("[HR] HeartRateManager initialized");
    }

    //! Start HR streaming - called when workout becomes active
    function startStreaming() {
        if (isStreaming) {
            System.println("[HR] Already streaming");
            return;
        }

        System.println("[HR] Starting HR streaming...");

        // Enable HR sensor and register for events
        try {
            var options = {
                :period => 1,  // 1 second updates
                :heartBeatIntervals => {
                    :enabled => false
                },
                :accelerometer => {
                    :enabled => false
                }
            };
            Sensor.setEnabledSensors([Sensor.SENSOR_HEARTRATE]);
            Sensor.enableSensorEvents(method(:onSensorData));
            System.println("[HR] HR sensor enabled");
        } catch (ex) {
            System.println("[HR] Failed to enable HR sensor: " + ex.getErrorMessage());
            hrReason = "sensor_error";
            return;
        }

        // Start send timer
        sendTimer = new Timer.Timer();
        sendTimer.start(method(:sendHRToPhone), HR_SEND_INTERVAL_MS, true);

        isStreaming = true;
        hrReason = "";
        System.println("[HR] Streaming started, interval: " + HR_SEND_INTERVAL_MS + "ms");
    }

    //! Stop HR streaming - called when workout ends or app exits
    function stopStreaming() {
        if (!isStreaming) {
            System.println("[HR] Not streaming, nothing to stop");
            return;
        }

        System.println("[HR] Stopping HR streaming...");

        // Stop timer first
        if (sendTimer != null) {
            sendTimer.stop();
            sendTimer = null;
            System.println("[HR] Send timer stopped");
        }

        // Disable sensor events and sensors
        try {
            Sensor.enableSensorEvents(null);
            Sensor.setEnabledSensors([]);
            System.println("[HR] Sensors disabled");
        } catch (ex) {
            System.println("[HR] Error disabling sensors: " + ex.getErrorMessage());
        }

        currentHR = null;
        hrAvailable = false;
        isStreaming = false;
        hrReason = "stopped";
        System.println("[HR] Streaming stopped");
    }

    //! Sensor data callback - called by the system when new sensor data is available
    function onSensorData(sensorInfo as Sensor.Info) as Void {
        if (sensorInfo == null) {
            hrAvailable = false;
            hrReason = "no_data";
            return;
        }

        if (sensorInfo.heartRate != null && sensorInfo.heartRate > 0) {
            currentHR = sensorInfo.heartRate;
            hrAvailable = true;
            hrReason = "";
        } else {
            // HR temporarily unavailable (e.g., poor wrist contact)
            hrAvailable = false;
            hrReason = "no_signal";
        }
    }

    //! Timer callback - send HR to phone
    function sendHRToPhone() as Void {
        if (commManager == null) {
            System.println("[HR] No commManager, can't send HR");
            return;
        }

        if (hrAvailable && currentHR != null) {
            commManager.sendHeartRate(currentHR);
        } else {
            commManager.sendHeartRateUnavailable(hrReason);
        }
    }

    //! Get current heart rate (may be null)
    function getCurrentHR() {
        return currentHR;
    }

    //! Check if HR is currently available
    function isAvailable() {
        return hrAvailable;
    }

    //! Check if currently streaming
    function isCurrentlyStreaming() {
        return isStreaming;
    }

    //! Get reason for unavailability
    function getUnavailableReason() {
        return hrReason;
    }
}
