using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;

//! Main view for displaying workout state on the watch
class WorkoutRemoteView extends WatchUi.View {

    var state;
    const BRAND_COLOR = 0x3B82F6;

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

        if (state == null || state.isIdle()) {
            drawIdleState(dc, centerX, centerY);
        } else if (state.isEnded()) {
            drawCompleteState(dc, centerX, centerY);
        } else {
            drawActiveState(dc, centerX, centerY, width, height);
        }

        drawConnectionStatus(dc, width);
    }

    hidden function drawIdleState(dc, cx, cy) {
        dc.setColor(BRAND_COLOR, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy - 40, Graphics.FONT_MEDIUM, "AmakaFlow", Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy, Graphics.FONT_SMALL, "No Active", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(cx, cy + 25, Graphics.FONT_SMALL, "Workout", Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy + 60, Graphics.FONT_XTINY, "Start on iPhone", Graphics.TEXT_JUSTIFY_CENTER);
    }

    hidden function drawCompleteState(dc, cx, cy) {
        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy - 20, Graphics.FONT_LARGE, "Complete!", Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        if (state != null) {
            dc.drawText(cx, cy + 20, Graphics.FONT_SMALL, state.stepName, Graphics.TEXT_JUSTIFY_CENTER);
        }

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy + 50, Graphics.FONT_XTINY, "Great workout!", Graphics.TEXT_JUSTIFY_CENTER);
    }

    hidden function drawActiveState(dc, cx, cy, width, height) {
        if (state == null) {
            return;
        }

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        var stepNameY = 35;
        dc.drawText(cx, stepNameY, Graphics.FONT_SMALL, truncateText(state.stepName, 18), Graphics.TEXT_JUSTIFY_CENTER);

        if (state.roundInfo != null && !state.roundInfo.equals("")) {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, stepNameY + 22, Graphics.FONT_XTINY, state.roundInfo, Graphics.TEXT_JUSTIFY_CENTER);
        }

        if (state.isTimedStep()) {
            drawTimerDisplay(dc, cx, cy);
        } else {
            drawStepCountDisplay(dc, cx, cy);
        }

        drawProgressBar(dc, width, height);

        if (state.isPaused()) {
            drawPausedIndicator(dc, cx, height);
        }

        drawButtonHints(dc, width, height);
    }

    hidden function drawTimerDisplay(dc, cx, cy) {
        if (state == null) {
            return;
        }

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy - 20, Graphics.FONT_NUMBER_HOT, state.getFormattedTime(), Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy + 30, Graphics.FONT_XTINY, state.getStepProgressText(), Graphics.TEXT_JUSTIFY_CENTER);
    }

    hidden function drawStepCountDisplay(dc, cx, cy) {
        if (state == null) {
            return;
        }

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy - 15, Graphics.FONT_NUMBER_MEDIUM, (state.stepIndex + 1).toString(), Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, cy + 25, Graphics.FONT_SMALL, "of " + state.stepCount.toString(), Graphics.TEXT_JUSTIFY_CENTER);
    }

    hidden function drawProgressBar(dc, width, height) {
        if (state == null) {
            return;
        }

        var barWidth = width - 60;
        var barHeight = 6;
        var barX = 30;
        var barY = height - 45;

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

    hidden function drawButtonHints(dc, width, height) {
        if (state == null || (!state.isRunning() && !state.isPaused())) {
            return;
        }

        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width - 8, 50, Graphics.FONT_XTINY, "<", Graphics.TEXT_JUSTIFY_RIGHT);
        dc.drawText(width - 8, height - 60, Graphics.FONT_XTINY, ">", Graphics.TEXT_JUSTIFY_RIGHT);
    }

    hidden function drawConnectionStatus(dc, width) {
        var app = getApp();
        var comm = app.getCommManager();

        if (comm != null && !comm.isPhoneConnected()) {
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(width - 15, 15, 4);
        }
    }

    hidden function truncateText(text, maxChars) {
        if (text.length() <= maxChars) {
            return text;
        }
        return text.substring(0, maxChars - 2) + "..";
    }
}
