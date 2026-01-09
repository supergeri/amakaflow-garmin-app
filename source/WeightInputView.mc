using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;

//! AMA-288: Weight input view for logging set weights on Garmin
class WeightInputView extends WatchUi.View {

    var state;
    var currentWeight = 0.0;
    const BRAND_COLOR = 0x3B82F6;

    function initialize(workoutState) {
        View.initialize();
        state = workoutState;
        // Initialize with suggested weight if available
        if (state.suggestedWeight != null) {
            currentWeight = state.suggestedWeight.toFloat();
        }
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

        drawWeightInput(dc, centerX, centerY, width, height);
    }

    hidden function drawWeightInput(dc, cx, cy, width, height) {
        // Exercise name at top
        var stepNameY = (height * 0.15).toNumber();
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, stepNameY, Graphics.FONT_XTINY, truncateText(state.stepName.toUpper(), 16), Graphics.TEXT_JUSTIFY_CENTER);

        // Set info below exercise name
        var setInfoY = (height * 0.24).toNumber();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, setInfoY, Graphics.FONT_SMALL, "Set " + state.setNumber + "/" + state.totalSets, Graphics.TEXT_JUSTIFY_CENTER);

        // Large weight display in center
        var weightY = cy - (height * 0.08).toNumber();
        dc.setColor(BRAND_COLOR, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, weightY, Graphics.FONT_NUMBER_MILD, formatWeight(currentWeight), Graphics.TEXT_JUSTIFY_CENTER);

        // Unit below weight
        var unitY = cy + (height * 0.10).toNumber();
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, unitY, Graphics.FONT_SMALL, state.weightUnit, Graphics.TEXT_JUSTIFY_CENTER);

        // Last used hint if available
        if (state.suggestedWeight != null && state.suggestedWeight > 0) {
            var hintY = cy + (height * 0.20).toNumber();
            dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, hintY, Graphics.FONT_XTINY, "(last: " + formatWeight(state.suggestedWeight.toFloat()) + ")", Graphics.TEXT_JUSTIFY_CENTER);
        }

        // Button indicators with labels
        drawButtonIndicators(dc, cx, cy, width, height);

        // Instructions at bottom
        var instructY = (height * 0.85).toNumber();
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, instructY, Graphics.FONT_SYSTEM_XTINY, "UP/DOWN adjust | SELECT log", Graphics.TEXT_JUSTIFY_CENTER);
    }

    hidden function drawButtonIndicators(dc, cx, cy, width, height) {
        var radius = (width / 2) - 2;
        var arcWidth = 4;
        dc.setPenWidth(arcWidth);

        // UP button (9 o'clock) - GREEN for + (increase weight)
        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(cx, cy, radius, Graphics.ARC_COUNTER_CLOCKWISE, 170, 190);
        // + label near UP button
        dc.drawText(cx - (width * 0.38).toNumber(), cy - (height * 0.02).toNumber(), Graphics.FONT_SMALL, "+", Graphics.TEXT_JUSTIFY_CENTER);

        // DOWN button (8 o'clock) - YELLOW for - (decrease weight)
        dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(cx, cy, radius, Graphics.ARC_COUNTER_CLOCKWISE, 200, 220);
        // - label near DOWN button
        dc.drawText(cx - (width * 0.32).toNumber(), cy + (height * 0.20).toNumber(), Graphics.FONT_SMALL, "-", Graphics.TEXT_JUSTIFY_CENTER);

        // SELECT button (2 o'clock) - GREEN for LOG
        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(cx, cy, radius, Graphics.ARC_COUNTER_CLOCKWISE, 20, 40);
        // LOG label near SELECT button
        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx + (width * 0.28).toNumber(), cy - (height * 0.22).toNumber(), Graphics.FONT_XTINY, "LOG", Graphics.TEXT_JUSTIFY_CENTER);

        // BACK button (4 o'clock) - ORANGE for SKIP
        dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(cx, cy, radius, Graphics.ARC_COUNTER_CLOCKWISE, 320, 340);
        // SKIP label near BACK button
        dc.drawText(cx + (width * 0.26).toNumber(), cy + (height * 0.22).toNumber(), Graphics.FONT_XTINY, "SKIP", Graphics.TEXT_JUSTIFY_CENTER);

        dc.setPenWidth(1);
    }

    //! Increase weight by increment based on unit
    function increaseWeight() {
        var increment = getIncrement();
        currentWeight = currentWeight + increment;
        WatchUi.requestUpdate();
    }

    //! Decrease weight by increment based on unit
    function decreaseWeight() {
        var increment = getIncrement();
        currentWeight = currentWeight - increment;
        if (currentWeight < 0) {
            currentWeight = 0.0;
        }
        WatchUi.requestUpdate();
    }

    //! Get weight increment based on unit (5 lbs or 2.5 kg)
    hidden function getIncrement() {
        if (state.weightUnit.equals("kg")) {
            return 2.5;
        }
        return 5.0;
    }

    //! Get current weight for logging
    function getCurrentWeight() {
        return currentWeight;
    }

    //! Get weight unit
    function getWeightUnit() {
        return state.weightUnit;
    }

    hidden function formatWeight(weight) {
        if (weight == 0.0) {
            return "0";
        }
        // Check if it's a whole number
        var intWeight = weight.toNumber();
        if (weight == intWeight.toFloat()) {
            return intWeight.toString();
        }
        // Show one decimal place
        return weight.format("%.1f");
    }

    hidden function truncateText(text, maxChars) {
        if (text.length() <= maxChars) {
            return text;
        }
        return text.substring(0, maxChars - 2) + "..";
    }
}
