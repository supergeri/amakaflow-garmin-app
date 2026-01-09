using Toybox.Lang;
using Toybox.System;

//! Represents the current workout state received from the phone
class WorkoutState {

    var stateVersion = 0;
    var phase = "idle";
    var stepIndex = 0;
    var stepCount = 0;
    var stepName = "";
    var stepType = "reps";
    var remainingMs = 0;
    var roundInfo = "";
    var targetReps = 0;
    var lastUpdateTime = 0;

    // AMA-288: Weight capture fields
    var suggestedWeight = null;  // Suggested weight from phone (last used)
    var weightUnit = "lbs";      // "lbs" or "kg"
    var setNumber = 1;           // Current set number (1-based)
    var totalSets = 1;           // Total sets for this exercise

    function initialize() {
    }

    function update(msg) {
        var version = msg.get("version");
        if (version != null) {
            stateVersion = version;
        }

        var phaseVal = msg.get("phase");
        if (phaseVal != null) {
            phase = phaseVal;
        }

        var stepIndexVal = msg.get("stepIndex");
        if (stepIndexVal != null) {
            stepIndex = stepIndexVal;
        }

        var stepCountVal = msg.get("stepCount");
        if (stepCountVal != null) {
            stepCount = stepCountVal;
        }

        var stepNameVal = msg.get("stepName");
        if (stepNameVal != null) {
            stepName = stepNameVal;
        }

        var stepTypeVal = msg.get("stepType");
        if (stepTypeVal != null) {
            stepType = stepTypeVal;
        }

        var remainingMsVal = msg.get("remainingMs");
        if (remainingMsVal != null) {
            remainingMs = remainingMsVal;
        }

        var roundInfoVal = msg.get("roundInfo");
        if (roundInfoVal != null) {
            roundInfo = roundInfoVal;
        }

        var targetRepsVal = msg.get("targetReps");
        if (targetRepsVal != null) {
            targetReps = targetRepsVal;
        }

        // AMA-288: Parse weight capture fields
        var suggestedWeightVal = msg.get("suggestedWeight");
        if (suggestedWeightVal != null) {
            suggestedWeight = suggestedWeightVal;
        }

        var weightUnitVal = msg.get("weightUnit");
        if (weightUnitVal != null) {
            weightUnit = weightUnitVal;
        }

        var setNumberVal = msg.get("setNumber");
        if (setNumberVal != null) {
            setNumber = setNumberVal;
        }

        var totalSetsVal = msg.get("totalSets");
        if (totalSetsVal != null) {
            totalSets = totalSetsVal;
        }

        lastUpdateTime = System.getTimer();
    }

    function isRunning() {
        return phase.equals("running");
    }

    function isPaused() {
        return phase.equals("paused");
    }

    function isIdle() {
        return phase.equals("idle");
    }

    function isEnded() {
        return phase.equals("ended");
    }

    function isActive() {
        return isRunning() || isPaused();
    }

    function getFormattedTime() {
        if (remainingMs == 0) {
            return "--:--";
        }
        var totalSeconds = remainingMs / 1000;
        var mins = totalSeconds / 60;
        var secs = totalSeconds % 60;
        return mins.format("%d") + ":" + secs.format("%02d");
    }

    function getProgress() {
        if (stepCount == 0) {
            return 0.0;
        }
        return (stepIndex + 1).toFloat() / stepCount.toFloat();
    }

    function getStepProgressText() {
        return (stepIndex + 1).toString() + " of " + stepCount.toString();
    }

    function isTimedStep() {
        return stepType.equals("timed");
    }

    function isStale() {
        if (lastUpdateTime == 0) {
            return true;
        }
        var elapsed = System.getTimer() - lastUpdateTime;
        return elapsed > 30000;
    }

    function reset() {
        stateVersion = 0;
        phase = "idle";
        stepIndex = 0;
        stepCount = 0;
        stepName = "";
        stepType = "reps";
        remainingMs = 0;
        roundInfo = "";
        targetReps = 0;
        lastUpdateTime = 0;
        // AMA-288: Reset weight fields
        suggestedWeight = null;
        weightUnit = "lbs";
        setNumber = 1;
        totalSets = 1;
    }
}
