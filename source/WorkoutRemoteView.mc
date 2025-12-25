using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;

//! Main view for displaying workout state on the watch
class WorkoutRemoteView extends WatchUi.View {

    var state;
    const BRAND_COLOR = 0x3B82F6;

    // Demo mode for simulator testing
    static var demoMode = false;
    static var demoScreen = 0; // 0=idle, 1=running, 2=paused, 3=complete

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

        // Demo mode for simulator testing
        if (demoMode) {
            drawDemoScreen(dc, centerX, centerY, width, height);
            return;
        }

        if (state == null || state.isIdle()) {
            drawIdleState(dc, centerX, centerY, width, height);
        } else if (state.isEnded()) {
            drawCompleteState(dc, centerX, centerY, width, height);
        } else {
            drawActiveState(dc, centerX, centerY, width, height);
        }

        drawConnectionStatus(dc, width, height);
    }

    //! Draw demo screens for simulator testing without connection
    hidden function drawDemoScreen(dc, cx, cy, width, height) {
        if (demoScreen == 0) {
            // Idle screen demo
            drawIdleState(dc, cx, cy, width, height);
        } else if (demoScreen == 1) {
            // Running workout demo (rep-based step)
            drawDemoActiveState(dc, cx, cy, width, height, false);
        } else if (demoScreen == 2) {
            // Timed step demo (Warm Up)
            drawDemoTimedState(dc, cx, cy, width, height);
        } else if (demoScreen == 3) {
            // Paused workout demo
            drawDemoActiveState(dc, cx, cy, width, height, true);
        } else if (demoScreen == 4) {
            // Complete screen demo
            drawDemoCompleteState(dc, cx, cy, width, height);
        }

        // Demo mode indicator
        dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, 12, Graphics.FONT_XTINY, "DEMO " + (demoScreen + 1) + "/5", Graphics.TEXT_JUSTIFY_CENTER);
    }

    hidden function drawDemoActiveState(dc, cx, cy, width, height, isPaused) {
        // Step name at top
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, 50, Graphics.FONT_SMALL, "Jumping Jacks", Graphics.TEXT_JUSTIFY_CENTER);

        // Round info (with more spacing from step name)
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, 82, Graphics.FONT_XTINY, "Round 2 of 3", Graphics.TEXT_JUSTIFY_CENTER);

        // Step count - use smaller font to avoid overlap
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy - 10, Graphics.FONT_NUMBER_MILD, "2", Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy + 45, Graphics.FONT_SMALL, "of 7", Graphics.TEXT_JUSTIFY_CENTER);

        // Progress bar
        var barWidth = width - 80;
        var barX = 40;
        var barY = height - 50;
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(barX, barY, barWidth, 6, 3);
        dc.setColor(BRAND_COLOR, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(barX, barY, (barWidth * 0.3).toNumber(), 6, 3);

        // Paused indicator
        if (isPaused) {
            dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, height - 70, Graphics.FONT_XTINY, "PAUSED", Graphics.TEXT_JUSTIFY_CENTER);
        }

        // Button hints
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width - 12, cy - 50, Graphics.FONT_XTINY, "END", Graphics.TEXT_JUSTIFY_RIGHT);
        dc.drawText(width - 12, cy + 40, Graphics.FONT_XTINY, "NEXT", Graphics.TEXT_JUSTIFY_RIGHT);
        dc.drawText(12, cy + 40, Graphics.FONT_XTINY, "PREV", Graphics.TEXT_JUSTIFY_LEFT);
        if (isPaused) {
            dc.drawText(12, cy - 10, Graphics.FONT_XTINY, "PLAY", Graphics.TEXT_JUSTIFY_LEFT);
        } else {
            dc.drawText(12, cy - 10, Graphics.FONT_XTINY, "PAUSE", Graphics.TEXT_JUSTIFY_LEFT);
        }
    }

    hidden function drawDemoTimedState(dc, cx, cy, width, height) {
        // Step name at top
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, 50, Graphics.FONT_SMALL, "Warm Up", Graphics.TEXT_JUSTIFY_CENTER);

        // Timer display (like the real watch shows)
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy - 10, Graphics.FONT_NUMBER_HOT, "4:55", Graphics.TEXT_JUSTIFY_CENTER);

        // Progress bar
        var barWidth = width - 80;
        var barX = 40;
        var barY = height - 50;
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(barX, barY, barWidth, 6, 3);
        dc.setColor(BRAND_COLOR, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(barX, barY, (barWidth * 0.17).toNumber(), 6, 3);  // ~1 min of 6 min

        // Button hints
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width - 12, cy - 50, Graphics.FONT_XTINY, "END", Graphics.TEXT_JUSTIFY_RIGHT);
        dc.drawText(width - 12, cy + 40, Graphics.FONT_XTINY, "NEXT", Graphics.TEXT_JUSTIFY_RIGHT);
        dc.drawText(12, cy + 40, Graphics.FONT_XTINY, "PREV", Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(12, cy - 10, Graphics.FONT_XTINY, "PAUSE", Graphics.TEXT_JUSTIFY_LEFT);
    }

    hidden function drawDemoCompleteState(dc, cx, cy, width, height) {
        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy - 50, Graphics.FONT_MEDIUM, "Complete!", Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy + 5, Graphics.FONT_SMALL, "Cool Down", Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy + 45, Graphics.FONT_XTINY, "Great workout!", Graphics.TEXT_JUSTIFY_CENTER);
    }

    hidden function drawIdleState(dc, cx, cy, width, height) {
        // Title - positioned higher for round display
        dc.setColor(BRAND_COLOR, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy - 60, Graphics.FONT_MEDIUM, "AmakaFlow", Graphics.TEXT_JUSTIFY_CENTER);

        // Status message
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy - 10, Graphics.FONT_SMALL, "No Active", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(cx, cy + 18, Graphics.FONT_SMALL, "Workout", Graphics.TEXT_JUSTIFY_CENTER);

        // Instruction
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy + 50, Graphics.FONT_XTINY, "Start on iPhone", Graphics.TEXT_JUSTIFY_CENTER);

        // Version and connection status - keep within safe area for round display
        var app = getApp();
        var comm = app.getCommManager();
        if (comm != null) {
            var ph = comm.isPhoneAvailable() ? "Y" : "N";
            var ap = comm.isPhoneConnected() ? "Y" : "N";
            dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, cy + 75, Graphics.FONT_XTINY, "v" + APP_VERSION + "  Ph:" + ph + "  App:" + ap, Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    hidden function drawCompleteState(dc, cx, cy, width, height) {
        // "Complete!" - use MEDIUM font to avoid overlap, positioned higher
        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy - 50, Graphics.FONT_MEDIUM, "Complete!", Graphics.TEXT_JUSTIFY_CENTER);

        // Step name - well below Complete
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        if (state != null) {
            dc.drawText(cx, cy + 5, Graphics.FONT_SMALL, truncateText(state.stepName, 14), Graphics.TEXT_JUSTIFY_CENTER);
        }

        // "Great workout!" - well below step name
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy + 45, Graphics.FONT_XTINY, "Great workout!", Graphics.TEXT_JUSTIFY_CENTER);
    }

    hidden function drawActiveState(dc, cx, cy, width, height) {
        if (state == null) {
            return;
        }

        // Step name at top - safe area for round displays
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, 50, Graphics.FONT_SMALL, truncateText(state.stepName, 14), Graphics.TEXT_JUSTIFY_CENTER);

        // Round info below step name
        if (state.roundInfo != null && !state.roundInfo.equals("")) {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, 75, Graphics.FONT_XTINY, state.roundInfo, Graphics.TEXT_JUSTIFY_CENTER);
        }

        // Main display (timer or step count) - centered
        if (state.isTimedStep()) {
            drawTimerDisplay(dc, cx, cy, width, height);
        } else {
            drawStepCountDisplay(dc, cx, cy, width, height);
        }

        // Progress bar
        drawProgressBar(dc, width, height);

        // Paused indicator
        if (state.isPaused()) {
            drawPausedIndicator(dc, cx, height);
        }

        // Button hints
        drawButtonHints(dc, cx, cy, width, height);
    }

    hidden function drawTimerDisplay(dc, cx, cy, width, height) {
        if (state == null) {
            return;
        }

        // Timer - use MILD font which is smaller than HOT to avoid overlap
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy - 15, Graphics.FONT_NUMBER_MILD, state.getFormattedTime(), Graphics.TEXT_JUSTIFY_CENTER);

        // Step progress text below timer
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy + 45, Graphics.FONT_XTINY, state.getStepProgressText(), Graphics.TEXT_JUSTIFY_CENTER);
    }

    hidden function drawStepCountDisplay(dc, cx, cy, width, height) {
        if (state == null) {
            return;
        }

        // Step number - use MILD font which is more manageable
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy - 10, Graphics.FONT_NUMBER_MILD, (state.stepIndex + 1).toString(), Graphics.TEXT_JUSTIFY_CENTER);

        // "of X" - well below the number
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy + 45, Graphics.FONT_SMALL, "of " + state.stepCount.toString(), Graphics.TEXT_JUSTIFY_CENTER);
    }

    hidden function drawProgressBar(dc, width, height) {
        if (state == null) {
            return;
        }

        // Progress bar - keep within round display safe area
        var barWidth = width - 80;
        var barHeight = 6;
        var barX = 40;
        var barY = height - 50;

        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(barX, barY, barWidth, barHeight, 3);

        var progressWidth = (barWidth * state.getProgress()).toNumber();
        if (progressWidth > 0) {
            dc.setColor(BRAND_COLOR, Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(barX, barY, progressWidth, barHeight, 3);
        }
    }

    hidden function drawPausedIndicator(dc, cx, height) {
        dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, height - 70, Graphics.FONT_XTINY, "PAUSED", Graphics.TEXT_JUSTIFY_CENTER);
    }

    hidden function drawButtonHints(dc, cx, cy, width, height) {
        if (state == null || (!state.isRunning() && !state.isPaused())) {
            return;
        }

        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);

        // Top right = END (near the START button)
        dc.drawText(width - 12, cy - 50, Graphics.FONT_XTINY, "END", Graphics.TEXT_JUSTIFY_RIGHT);

        // Bottom right = NEXT
        dc.drawText(width - 12, cy + 40, Graphics.FONT_XTINY, "NEXT", Graphics.TEXT_JUSTIFY_RIGHT);

        // Bottom left = PREV
        dc.drawText(12, cy + 40, Graphics.FONT_XTINY, "PREV", Graphics.TEXT_JUSTIFY_LEFT);

        // Middle left = PAUSE/PLAY
        if (state.isRunning()) {
            dc.drawText(12, cy - 10, Graphics.FONT_XTINY, "PAUSE", Graphics.TEXT_JUSTIFY_LEFT);
        } else if (state.isPaused()) {
            dc.drawText(12, cy - 10, Graphics.FONT_XTINY, "PLAY", Graphics.TEXT_JUSTIFY_LEFT);
        }
    }

    hidden function drawConnectionStatus(dc, width, height) {
        var app = getApp();
        var comm = app.getCommManager();

        if (comm != null) {
            var phoneAvailable = comm.isPhoneAvailable();
            var appConnected = comm.isPhoneConnected();

            // Phone status indicator (top right)
            if (phoneAvailable) {
                dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
            } else {
                dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            }
            dc.fillCircle(width - 18, 18, 5);

            // App connection status (below phone indicator)
            if (appConnected) {
                dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
            } else {
                dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
            }
            dc.fillCircle(width - 18, 33, 4);
        } else {
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(width - 18, 18, 5);
        }
    }

    hidden function truncateText(text, maxChars) {
        if (text.length() <= maxChars) {
            return text;
        }
        return text.substring(0, maxChars - 2) + "..";
    }

    //! Toggle demo mode - call from menu or button
    static function toggleDemoMode() {
        demoMode = !demoMode;
        demoScreen = 0;
        WatchUi.requestUpdate();
    }

    //! Cycle to next demo screen
    static function nextDemoScreen() {
        if (demoMode) {
            demoScreen = (demoScreen + 1) % 5;
            WatchUi.requestUpdate();
        }
    }
}
