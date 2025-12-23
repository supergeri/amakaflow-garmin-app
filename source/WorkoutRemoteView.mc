using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;

//! Main view for displaying workout state on the watch
//! Renders current exercise, timer, progress, and status
class WorkoutRemoteView extends WatchUi.View {

    //! Reference to workout state
    var state as WorkoutState?;

    //! Brand color (AmakaFlow blue)
    const BRAND_COLOR = 0x3B82F6;

    //! Constructor
    //! @param workoutState The workout state to display
    function initialize(workoutState as WorkoutState?) {
        View.initialize();
        state = workoutState;
    }

    //! Called when the view layout is needed
    //! @param dc The device context
    function onLayout(dc as Graphics.Dc) as Void {
        // Layout is handled dynamically in onUpdate
    }

    //! Called when the view needs to be updated
    //! @param dc The device context
    function onUpdate(dc as Graphics.Dc) as Void {
        // Clear screen with black background
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;
        var centerY = height / 2;

        if (state == null || state.isIdle()) {
            drawIdleState(dc, centerX, centerY);
        } else if (state.isEnded()) {
            drawCompleteState(dc, centerX, centerY);
        } else {
            drawActiveState(dc, centerX, centerY, width, height);
        }

        // Draw connection indicator
        drawConnectionStatus(dc, width);
    }

    //! Draw the idle state (no active workout)
    //! @param dc Device context
    //! @param cx Center X coordinate
    //! @param cy Center Y coordinate
    private function drawIdleState(dc as Graphics.Dc, cx as Number, cy as Number) as Void {
        // App name
        dc.setColor(BRAND_COLOR, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy - 40, Graphics.FONT_MEDIUM, "AmakaFlow", Graphics.TEXT_JUSTIFY_CENTER);

        // Status message
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy, Graphics.FONT_SMALL, "No Active", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(cx, cy + 25, Graphics.FONT_SMALL, "Workout", Graphics.TEXT_JUSTIFY_CENTER);

        // Instruction
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy + 60, Graphics.FONT_XTINY, "Start on iPhone", Graphics.TEXT_JUSTIFY_CENTER);
    }

    //! Draw the workout complete state
    //! @param dc Device context
    //! @param cx Center X coordinate
    //! @param cy Center Y coordinate
    private function drawCompleteState(dc as Graphics.Dc, cx as Number, cy as Number) as Void {
        // Checkmark or completion indicator
        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy - 20, Graphics.FONT_LARGE, "Complete!", Graphics.TEXT_JUSTIFY_CENTER);

        // Workout name
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        if (state != null) {
            dc.drawText(cx, cy + 20, Graphics.FONT_SMALL, state.stepName, Graphics.TEXT_JUSTIFY_CENTER);
        }

        // Great job message
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy + 50, Graphics.FONT_XTINY, "Great workout!", Graphics.TEXT_JUSTIFY_CENTER);
    }

    //! Draw the active workout state
    //! @param dc Device context
    //! @param cx Center X coordinate
    //! @param cy Center Y coordinate
    //! @param width Screen width
    //! @param height Screen height
    private function drawActiveState(dc as Graphics.Dc, cx as Number, cy as Number, width as Number, height as Number) as Void {
        if (state == null) {
            return;
        }

        // Step name at top
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        var stepNameY = 35;
        dc.drawText(cx, stepNameY, Graphics.FONT_SMALL, truncateText(state.stepName, 18), Graphics.TEXT_JUSTIFY_CENTER);

        // Round info below step name
        if (state.roundInfo != null && !state.roundInfo.equals("")) {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, stepNameY + 22, Graphics.FONT_XTINY, state.roundInfo, Graphics.TEXT_JUSTIFY_CENTER);
        }

        // Main content area - timer or step count
        if (state.isTimedStep()) {
            drawTimerDisplay(dc, cx, cy);
        } else {
            drawStepCountDisplay(dc, cx, cy);
        }

        // Progress bar
        drawProgressBar(dc, width, height);

        // Pause indicator
        if (state.isPaused()) {
            drawPausedIndicator(dc, cx, height);
        }

        // Button hints
        drawButtonHints(dc, width, height);
    }

    //! Draw the timer display for timed steps
    //! @param dc Device context
    //! @param cx Center X coordinate
    //! @param cy Center Y coordinate
    private function drawTimerDisplay(dc as Graphics.Dc, cx as Number, cy as Number) as Void {
        if (state == null) {
            return;
        }

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        // Use a large number font for the timer
        dc.drawText(cx, cy - 20, Graphics.FONT_NUMBER_HOT, state.getFormattedTime(), Graphics.TEXT_JUSTIFY_CENTER);

        // Step progress below
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy + 30, Graphics.FONT_XTINY, state.getStepProgressText(), Graphics.TEXT_JUSTIFY_CENTER);
    }

    //! Draw the step count display for rep-based steps
    //! @param dc Device context
    //! @param cx Center X coordinate
    //! @param cy Center Y coordinate
    private function drawStepCountDisplay(dc as Graphics.Dc, cx as Number, cy as Number) as Void {
        if (state == null) {
            return;
        }

        // Current step number large
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy - 15, Graphics.FONT_NUMBER_MEDIUM, (state.stepIndex + 1).toString(), Graphics.TEXT_JUSTIFY_CENTER);

        // "of X" below
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy + 25, Graphics.FONT_SMALL, "of " + state.stepCount.toString(), Graphics.TEXT_JUSTIFY_CENTER);
    }

    //! Draw the progress bar at bottom of screen
    //! @param dc Device context
    //! @param width Screen width
    //! @param height Screen height
    private function drawProgressBar(dc as Graphics.Dc, width as Number, height as Number) as Void {
        if (state == null) {
            return;
        }

        var barWidth = width - 60;
        var barHeight = 6;
        var barX = 30;
        var barY = height - 45;

        // Background track
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(barX, barY, barWidth, barHeight, 3);

        // Progress fill
        var progressWidth = (barWidth * state.getProgress()).toNumber();
        if (progressWidth > 0) {
            dc.setColor(BRAND_COLOR, Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(barX, barY, progressWidth, barHeight, 3);
        }
    }

    //! Draw the paused indicator
    //! @param dc Device context
    //! @param cx Center X coordinate
    //! @param height Screen height
    private function drawPausedIndicator(dc as Graphics.Dc, cx as Number, height as Number) as Void {
        dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, height - 70, Graphics.FONT_XTINY, "PAUSED", Graphics.TEXT_JUSTIFY_CENTER);
    }

    //! Draw button hints on screen edges
    //! @param dc Device context
    //! @param width Screen width
    //! @param height Screen height
    private function drawButtonHints(dc as Graphics.Dc, width as Number, height as Number) as Void {
        // Only show hints in running/paused state
        if (state == null || (!state.isRunning() && !state.isPaused())) {
            return;
        }

        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);

        // Up arrow hint (previous)
        dc.drawText(width - 8, 50, Graphics.FONT_XTINY, "<", Graphics.TEXT_JUSTIFY_RIGHT);

        // Down arrow hint (next)
        dc.drawText(width - 8, height - 60, Graphics.FONT_XTINY, ">", Graphics.TEXT_JUSTIFY_RIGHT);
    }

    //! Draw connection status indicator
    //! @param dc Device context
    //! @param width Screen width
    private function drawConnectionStatus(dc as Graphics.Dc, width as Number) as Void {
        var app = getApp();
        var comm = app.getCommManager();

        if (comm != null && !comm.isPhoneConnected()) {
            // Show disconnected indicator
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(width - 15, 15, 4);
        }
    }

    //! Truncate text to fit within character limit
    //! @param text The text to truncate
    //! @param maxChars Maximum characters
    //! @return Truncated text
    private function truncateText(text as String, maxChars as Number) as String {
        if (text.length() <= maxChars) {
            return text;
        }
        return text.substring(0, maxChars - 2) + "..";
    }
}
