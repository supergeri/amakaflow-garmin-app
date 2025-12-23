using Toybox.Application;
using Toybox.System;
using Toybox.WatchUi;

//! Application delegate for handling app-level events
class AmakaFlowDelegate extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) {
        System.println("AmakaFlow app started");
    }

    function onStop(state) {
        System.println("AmakaFlow app stopped");
    }

    function onSettingsChanged() {
        System.println("Settings changed");
        WatchUi.requestUpdate();
    }
}
