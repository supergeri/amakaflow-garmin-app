using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;

//! Main view for displaying workout state on the watch
class WorkoutRemoteView extends WatchUi.View {

    var state;
    const BRAND_COLOR = 0x3B82F6;

    // Demo mode for simulator testing
    static var demoMode = false;
    static var demoScreen = 0; // 0=idle, 1-5=various exercises, 6=paused, 7=complete

    function initialize(workoutState) {
        View.initialize();
        state = workoutState;
    }

    function onLayout(dc) {
    }

    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;
        var centerY = height / 2;

        // Get the state to display (real or demo)
        var displayState = getDisplayState();

        if (displayState == null || displayState.get("phase").equals("idle")) {
            drawIdleState(dc, centerX, centerY, width, height);
        } else if (displayState.get("phase").equals("guide")) {
            drawButtonGuide(dc, centerX, centerY, width, height);
        } else if (displayState.get("phase").equals("ended")) {
            drawCompleteState(dc, centerX, centerY, width, height, displayState);
        } else {
            drawActiveState(dc, centerX, centerY, width, height, displayState);
        }

        // Connection status (only show in non-demo mode)
        if (!demoMode) {
            drawConnectionStatus(dc, width, height);
        }

        // Demo mode indicator
        if (demoMode) {
            var demoY = (height * 0.05).toNumber();
            if (demoY < 12) { demoY = 12; }
            dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
            dc.drawText(centerX, demoY, Graphics.FONT_XTINY, "DEMO " + (demoScreen + 1) + "/9", Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    //! Get the state to display - either real state or demo state
    hidden function getDisplayState() {
        if (demoMode) {
            return getDemoState();
        }

        // Convert real state to dictionary format
        if (state == null) {
            return null;
        }

        var dict = {};
        dict.put("phase", state.phase);
        dict.put("stepName", state.stepName);
        dict.put("stepType", state.stepType);
        dict.put("stepIndex", state.stepIndex);
        dict.put("stepCount", state.stepCount);
        dict.put("remainingMs", state.remainingMs);
        dict.put("roundInfo", state.roundInfo);
        dict.put("targetReps", state.targetReps);
        dict.put("formattedTime", state.getFormattedTime());
        dict.put("progress", state.getProgress());
        dict.put("stepProgressText", state.getStepProgressText());
        return dict;
    }

    //! Get demo state based on current demo screen
    hidden function getDemoState() {
        var dict = {};

        if (demoScreen == 0) {
            // Button guide screen
            dict.put("phase", "guide");
            return dict;
        } else if (demoScreen == 1) {
            // Idle
            dict.put("phase", "idle");
            return dict;
        } else if (demoScreen == 2) {
            // Rep-based step (Jumping Jacks) - Round 2
            dict.put("phase", "running");
            dict.put("stepName", "Jumping Jacks");
            dict.put("stepType", "reps");
            dict.put("stepIndex", 1);
            dict.put("stepCount", 8);
            dict.put("targetReps", 20);
            dict.put("roundInfo", "Round 2 of 3");
            dict.put("formattedTime", "--:--");
            dict.put("progress", 0.25);
            dict.put("stepProgressText", "2 of 8");
            return dict;
        } else if (demoScreen == 3) {
            // Timed step (Warm Up)
            dict.put("phase", "running");
            dict.put("stepName", "Warm Up");
            dict.put("stepType", "timed");
            dict.put("stepIndex", 0);
            dict.put("stepCount", 8);
            dict.put("targetReps", 0);
            dict.put("roundInfo", "");
            dict.put("formattedTime", "4:55");
            dict.put("progress", 0.125);
            dict.put("stepProgressText", "1 of 8");
            return dict;
        } else if (demoScreen == 4) {
            // Rep-based step (Push Ups)
            dict.put("phase", "running");
            dict.put("stepName", "Push Ups");
            dict.put("stepType", "reps");
            dict.put("stepIndex", 2);
            dict.put("stepCount", 8);
            dict.put("targetReps", 15);
            dict.put("roundInfo", "Round 1 of 3");
            dict.put("formattedTime", "--:--");
            dict.put("progress", 0.375);
            dict.put("stepProgressText", "3 of 8");
            return dict;
        } else if (demoScreen == 5) {
            // Timed step (Rest)
            dict.put("phase", "running");
            dict.put("stepName", "Rest");
            dict.put("stepType", "timed");
            dict.put("stepIndex", 3);
            dict.put("stepCount", 8);
            dict.put("targetReps", 0);
            dict.put("roundInfo", "");
            dict.put("formattedTime", "0:30");
            dict.put("progress", 0.5);
            dict.put("stepProgressText", "4 of 8");
            return dict;
        } else if (demoScreen == 6) {
            // Rep-based step (Squats)
            dict.put("phase", "running");
            dict.put("stepName", "Squats");
            dict.put("stepType", "reps");
            dict.put("stepIndex", 4);
            dict.put("stepCount", 8);
            dict.put("targetReps", 25);
            dict.put("roundInfo", "Round 3 of 3");
            dict.put("formattedTime", "--:--");
            dict.put("progress", 0.625);
            dict.put("stepProgressText", "5 of 8");
            return dict;
        } else if (demoScreen == 7) {
            // Paused state
            dict.put("phase", "paused");
            dict.put("stepName", "Burpees");
            dict.put("stepType", "reps");
            dict.put("stepIndex", 5);
            dict.put("stepCount", 8);
            dict.put("targetReps", 10);
            dict.put("roundInfo", "Round 2 of 3");
            dict.put("formattedTime", "--:--");
            dict.put("progress", 0.75);
            dict.put("stepProgressText", "6 of 8");
            return dict;
        } else if (demoScreen == 8) {
            // Complete
            dict.put("phase", "ended");
            dict.put("stepName", "Cool Down");
            dict.put("stepType", "reps");
            dict.put("stepIndex", 7);
            dict.put("stepCount", 8);
            dict.put("targetReps", 0);
            dict.put("roundInfo", "");
            dict.put("formattedTime", "--:--");
            dict.put("progress", 1.0);
            dict.put("stepProgressText", "8 of 8");
            return dict;
        }

        return null;
    }

    //! Draw active workout state - UNIFIED for both real and demo
    hidden function drawActiveState(dc, cx, cy, width, height, displayState) {
        var stepNameY = (height * 0.15).toNumber();
        var roundInfoY = (height * 0.26).toNumber();

        // Step name at top
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        var stepName = displayState.get("stepName");
        dc.drawText(cx, stepNameY, Graphics.FONT_SMALL, truncateText(stepName, 14), Graphics.TEXT_JUSTIFY_CENTER);

        // Round info below step name (if available) - only shown here, not in center
        var roundInfo = displayState.get("roundInfo");
        if (roundInfo != null && !roundInfo.equals("")) {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, roundInfoY, Graphics.FONT_XTINY, roundInfo, Graphics.TEXT_JUSTIFY_CENTER);
        }

        // Main display based on step type
        var stepType = displayState.get("stepType");
        var isPaused = displayState.get("phase").equals("paused");

        if (stepType.equals("timed")) {
            // Timer display - large centered timer
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, cy - (height * 0.06).toNumber(), Graphics.FONT_NUMBER_MILD, displayState.get("formattedTime"), Graphics.TEXT_JUSTIFY_CENTER);

            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, cy + (height * 0.12).toNumber(), Graphics.FONT_SMALL, "remaining", Graphics.TEXT_JUSTIFY_CENTER);
        } else {
            // Rep-based display - show target reps as the big number
            var targetReps = displayState.get("targetReps");
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            if (targetReps != null && targetReps > 0) {
                dc.drawText(cx, cy - (height * 0.06).toNumber(), Graphics.FONT_NUMBER_MILD, targetReps.toString(), Graphics.TEXT_JUSTIFY_CENTER);
                dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
                dc.drawText(cx, cy + (height * 0.12).toNumber(), Graphics.FONT_SMALL, "reps", Graphics.TEXT_JUSTIFY_CENTER);
            } else {
                // No rep count - just show REPS indicator
                dc.drawText(cx, cy - (height * 0.06).toNumber(), Graphics.FONT_MEDIUM, "REPS", Graphics.TEXT_JUSTIFY_CENTER);
            }
        }

        // Step progress - FIXED at 73%
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        if (isPaused) {
            dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, (height * 0.73).toNumber(), Graphics.FONT_XTINY, "PAUSED", Graphics.TEXT_JUSTIFY_CENTER);
        } else {
            dc.drawText(cx, (height * 0.73).toNumber(), Graphics.FONT_XTINY, "Step " + displayState.get("stepProgressText"), Graphics.TEXT_JUSTIFY_CENTER);
        }

        // Progress bar - FIXED at 82%
        var barMargin = (width * 0.15).toNumber();
        var barWidth = width - (barMargin * 2);
        var barY = (height * 0.82).toNumber();
        var barHeight = (height * 0.025).toNumber();
        if (barHeight < 4) { barHeight = 4; }

        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(barMargin, barY, barWidth, barHeight, barHeight / 2);

        var progress = displayState.get("progress");
        var progressWidth = (barWidth * progress).toNumber();
        if (progressWidth > 0) {
            dc.setColor(BRAND_COLOR, Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(barMargin, barY, progressWidth, barHeight, barHeight / 2);
        }

        // Button indicators - colored arcs at bezel edge, centered on physical buttons
        // All arcs are 20 degrees, centered on button position
        // Garmin angles: 0=3 o'clock, 90=12 o'clock, 180=9 o'clock, 270=6 o'clock
        var radius = (width / 2) - 2;
        var arcWidth = 4;
        dc.setPenWidth(arcWidth);

        // END - RED arc centered at ~2:00 (START button) = 30°, span 20-40
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(cx, cy, radius, Graphics.ARC_COUNTER_CLOCKWISE, 20, 40);

        // NEXT - GREEN arc centered at ~4:00 (BACK button) = 330°, span 320-340
        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(cx, cy, radius, Graphics.ARC_COUNTER_CLOCKWISE, 320, 340);

        // PAUSE - YELLOW/GREEN arc centered at ~9:00 (UP button) = 180°, span 170-190
        if (isPaused) {
            dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        } else {
            dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        }
        dc.drawArc(cx, cy, radius, Graphics.ARC_COUNTER_CLOCKWISE, 170, 190);

        // PREV - BLUE arc centered at ~8:00 (DOWN button) = 210°, span 200-220
        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(cx, cy, radius, Graphics.ARC_COUNTER_CLOCKWISE, 200, 220);

        dc.setPenWidth(1);
    }

    hidden function drawIdleState(dc, cx, cy, width, height) {
        dc.setColor(BRAND_COLOR, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy - (height * 0.18).toNumber(), Graphics.FONT_MEDIUM, "AmakaFlow", Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy - (height * 0.02).toNumber(), Graphics.FONT_SMALL, "No Active", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(cx, cy + (height * 0.08).toNumber(), Graphics.FONT_SMALL, "Workout", Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy + (height * 0.20).toNumber(), Graphics.FONT_XTINY, "Start workout on iPhone", Graphics.TEXT_JUSTIFY_CENTER);

        // Version and connection status
        var app = getApp();
        var comm = app.getCommManager();
        if (comm != null) {
            var ph = comm.isPhoneAvailable() ? "Y" : "N";
            var ap = comm.isPhoneConnected() ? "Y" : "N";
            dc.drawText(cx, cy + (height * 0.30).toNumber(), Graphics.FONT_XTINY, "v" + APP_VERSION + "  Ph:" + ph + "  App:" + ap, Graphics.TEXT_JUSTIFY_CENTER);
        } else {
            dc.drawText(cx, cy + (height * 0.30).toNumber(), Graphics.FONT_XTINY, "v" + APP_VERSION, Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    //! Draw button guide screen with curved arcs at bezel edge, centered on buttons
    hidden function drawButtonGuide(dc, cx, cy, width, height) {
        var radius = (width / 2) - 2;  // At the edge of bezel
        var arcWidth = 4;

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy - (height * 0.08).toNumber(), Graphics.FONT_SMALL, "Button", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(cx, cy + (height * 0.02).toNumber(), Graphics.FONT_SMALL, "Guide", Graphics.TEXT_JUSTIFY_CENTER);

        // All arcs are 20 degrees, centered on button position
        // Garmin angles: 0=3 o'clock, 90=12 o'clock, 180=9 o'clock, 270=6 o'clock
        dc.setPenWidth(arcWidth);

        // END - RED arc centered at ~2:00 (START button) = 30°, span 20-40
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(cx, cy, radius, Graphics.ARC_COUNTER_CLOCKWISE, 20, 40);
        dc.drawText(cx + (width * 0.30).toNumber(), cy - (height * 0.22).toNumber(), Graphics.FONT_XTINY, "END", Graphics.TEXT_JUSTIFY_CENTER);

        // NEXT - GREEN arc centered at ~4:00 (BACK button) = 330°, span 320-340
        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(cx, cy, radius, Graphics.ARC_COUNTER_CLOCKWISE, 320, 340);
        dc.drawText(cx + (width * 0.28).toNumber(), cy + (height * 0.22).toNumber(), Graphics.FONT_XTINY, "NEXT", Graphics.TEXT_JUSTIFY_CENTER);

        // PAUSE - YELLOW arc centered at ~9:00 (UP button) = 180°, span 170-190
        dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(cx, cy, radius, Graphics.ARC_COUNTER_CLOCKWISE, 170, 190);
        dc.drawText(cx - (width * 0.34).toNumber(), cy - (height * 0.02).toNumber(), Graphics.FONT_XTINY, "PAUSE", Graphics.TEXT_JUSTIFY_CENTER);

        // PREV - BLUE arc centered at ~8:00 (DOWN button) = 210°, span 200-220
        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(cx, cy, radius, Graphics.ARC_COUNTER_CLOCKWISE, 200, 220);
        dc.drawText(cx - (width * 0.28).toNumber(), cy + (height * 0.22).toNumber(), Graphics.FONT_XTINY, "PREV", Graphics.TEXT_JUSTIFY_CENTER);

        dc.setPenWidth(1);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy + (height * 0.32).toNumber(), Graphics.FONT_SYSTEM_XTINY, "NEXT to continue", Graphics.TEXT_JUSTIFY_CENTER);
    }

    hidden function drawCompleteState(dc, cx, cy, width, height, displayState) {
        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy - (height * 0.15).toNumber(), Graphics.FONT_MEDIUM, "Complete!", Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        var stepName = displayState.get("stepName");
        dc.drawText(cx, cy + (height * 0.02).toNumber(), Graphics.FONT_SMALL, truncateText(stepName, 14), Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy + (height * 0.15).toNumber(), Graphics.FONT_XTINY, "Great workout!", Graphics.TEXT_JUSTIFY_CENTER);
    }

    hidden function drawConnectionStatus(dc, width, height) {
        var app = getApp();
        var comm = app.getCommManager();

        var statusX = width - (width * 0.07).toNumber();
        var phoneStatusY = (height * 0.07).toNumber();
        var appStatusY = (height * 0.12).toNumber();
        var phoneRadius = (width * 0.02).toNumber();
        if (phoneRadius < 4) { phoneRadius = 4; }
        var appRadius = (width * 0.015).toNumber();
        if (appRadius < 3) { appRadius = 3; }

        if (comm != null) {
            var phoneAvailable = comm.isPhoneAvailable();
            var appConnected = comm.isPhoneConnected();

            if (phoneAvailable) {
                dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
            } else {
                dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            }
            dc.fillCircle(statusX, phoneStatusY, phoneRadius);

            if (appConnected) {
                dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
            } else {
                dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
            }
            dc.fillCircle(statusX, appStatusY, appRadius);
        } else {
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(statusX, phoneStatusY, phoneRadius);
        }
    }

    hidden function truncateText(text, maxChars) {
        if (text.length() <= maxChars) {
            return text;
        }
        return text.substring(0, maxChars - 2) + "..";
    }

    static function toggleDemoMode() {
        demoMode = !demoMode;
        demoScreen = 0;
        WatchUi.requestUpdate();
    }

    static function nextDemoScreen() {
        if (demoMode) {
            demoScreen = (demoScreen + 1) % 9;
            WatchUi.requestUpdate();
        }
    }
}
