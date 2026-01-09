using Toybox.WatchUi;
using Toybox.System;

//! AMA-288: Delegate for handling button input on weight input view
class WeightInputDelegate extends WatchUi.BehaviorDelegate {

    var weightView;
    var commManager;
    var onComplete;  // Callback when weight input is complete

    function initialize(view, comm, completionCallback) {
        BehaviorDelegate.initialize();
        weightView = view;
        commManager = comm;
        onComplete = completionCallback;
    }

    //! UP button - Increase weight (maps to onPreviousPage)
    function onPreviousPage() {
        System.println("[WEIGHT] UP pressed - increase weight");
        weightView.increaseWeight();
        return true;
    }

    //! DOWN button - Decrease weight (maps to onNextPage)
    function onNextPage() {
        System.println("[WEIGHT] DOWN pressed - decrease weight");
        weightView.decreaseWeight();
        return true;
    }

    //! SELECT/START button - Log set with weight
    function onSelect() {
        System.println("[WEIGHT] SELECT pressed - log set");
        var weight = weightView.getCurrentWeight();
        var unit = weightView.getWeightUnit();

        // Send weight to phone
        if (commManager != null) {
            if (weight > 0) {
                commManager.sendSetLog(weight, unit);
            } else {
                // Weight is 0, send as skip (null weight)
                commManager.sendSetLogSkip();
            }
        }

        // Call completion callback to return to workout view
        if (onComplete != null) {
            onComplete.invoke();
        }
        return true;
    }

    //! BACK button - Skip weight entry
    function onBack() {
        System.println("[WEIGHT] BACK pressed - skip weight");

        // Send skip to phone
        if (commManager != null) {
            commManager.sendSetLogSkip();
        }

        // Call completion callback to return to workout view
        if (onComplete != null) {
            onComplete.invoke();
        }
        return true;
    }
}
