using Toybox.Lang;

//! Represents the current workout state received from the phone
//! Mirrors the state broadcast from WorkoutEngine on iOS
class WorkoutState {

    //! State version for change detection
    var stateVersion as Number = 0;

    //! Current workout phase: "idle", "running", "paused", "ended"
    var phase as String = "idle";

    //! Current step index (0-based)
    var stepIndex as Number = 0;

    //! Total number of steps in the workout
    var stepCount as Number = 0;

    //! Display name of the current step/exercise
    var stepName as String = "";

    //! Type of step: "timed", "reps", "distance"
    var stepType as String = "reps";

    //! Remaining time in milliseconds (for timed steps)
    var remainingMs as Number = 0;

    //! Round information display string (e.g., "Round 2 of 5")
    var roundInfo as String = "";

    //! Last update timestamp for timeout detection
    var lastUpdateTime as Number = 0;

    //! Constructor
    function initialize() {
    }

    //! Update state from a phone message
    //! @param msg Dictionary containing state data
    function update(msg as Dictionary) as Void {
        var version = msg.get("version");
        if (version != null && version instanceof Number) {
            stateVersion = version;
        }

        var phaseVal = msg.get("phase");
        if (phaseVal != null && phaseVal instanceof String) {
            phase = phaseVal;
        }

        var stepIndexVal = msg.get("stepIndex");
        if (stepIndexVal != null && stepIndexVal instanceof Number) {
            stepIndex = stepIndexVal;
        }

        var stepCountVal = msg.get("stepCount");
        if (stepCountVal != null && stepCountVal instanceof Number) {
            stepCount = stepCountVal;
        }

        var stepNameVal = msg.get("stepName");
        if (stepNameVal != null && stepNameVal instanceof String) {
            stepName = stepNameVal;
        }

        var stepTypeVal = msg.get("stepType");
        if (stepTypeVal != null && stepTypeVal instanceof String) {
            stepType = stepTypeVal;
        }

        var remainingMsVal = msg.get("remainingMs");
        if (remainingMsVal != null && remainingMsVal instanceof Number) {
            remainingMs = remainingMsVal;
        }

        var roundInfoVal = msg.get("roundInfo");
        if (roundInfoVal != null && roundInfoVal instanceof String) {
            roundInfo = roundInfoVal;
        }

        lastUpdateTime = System.getTimer();
    }

    //! Check if workout is currently running
    //! @return true if phase is "running"
    function isRunning() as Boolean {
        return phase.equals("running");
    }

    //! Check if workout is paused
    //! @return true if phase is "paused"
    function isPaused() as Boolean {
        return phase.equals("paused");
    }

    //! Check if no workout is active
    //! @return true if phase is "idle"
    function isIdle() as Boolean {
        return phase.equals("idle");
    }

    //! Check if workout has ended
    //! @return true if phase is "ended"
    function isEnded() as Boolean {
        return phase.equals("ended");
    }

    //! Check if workout is active (running or paused)
    //! @return true if workout is in progress
    function isActive() as Boolean {
        return isRunning() || isPaused();
    }

    //! Format remaining time as MM:SS string
    //! @return Formatted time string
    function getFormattedTime() as String {
        if (remainingMs == 0) {
            return "--:--";
        }
        var totalSeconds = remainingMs / 1000;
        var mins = totalSeconds / 60;
        var secs = totalSeconds % 60;
        return mins.format("%d") + ":" + secs.format("%02d");
    }

    //! Get progress as a float from 0.0 to 1.0
    //! @return Progress ratio
    function getProgress() as Float {
        if (stepCount == 0) {
            return 0.0f;
        }
        return (stepIndex + 1).toFloat() / stepCount.toFloat();
    }

    //! Get current step as "X of Y" string
    //! @return Step progress string
    function getStepProgressText() as String {
        return (stepIndex + 1).toString() + " of " + stepCount.toString();
    }

    //! Check if this is a timed step
    //! @return true if step type is "timed"
    function isTimedStep() as Boolean {
        return stepType.equals("timed");
    }

    //! Check if state is stale (no update in 30 seconds)
    //! @return true if state might be stale
    function isStale() as Boolean {
        if (lastUpdateTime == 0) {
            return true;
        }
        var elapsed = System.getTimer() - lastUpdateTime;
        return elapsed > 30000; // 30 seconds
    }

    //! Reset state to idle
    function reset() as Void {
        stateVersion = 0;
        phase = "idle";
        stepIndex = 0;
        stepCount = 0;
        stepName = "";
        stepType = "reps";
        remainingMs = 0;
        roundInfo = "";
        lastUpdateTime = 0;
    }
}
