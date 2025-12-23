using Toybox.Application;
using Toybox.System;
using Toybox.Lang;

//! Application delegate for handling app-level events
//! Manages lifecycle callbacks and system events
class AmakaFlowDelegate extends Application.AppBase {

    //! Constructor
    function initialize() {
        AppBase.initialize();
    }

    //! Called on app start
    //! @param state Saved state dictionary
    function onStart(state as Dictionary?) as Void {
        System.println("AmakaFlow app started");
    }

    //! Called on app stop
    //! @param state Dictionary to save state
    function onStop(state as Dictionary?) as Void {
        System.println("AmakaFlow app stopped");
    }

    //! Called when settings change
    function onSettingsChanged() as Void {
        System.println("Settings changed");
        WatchUi.requestUpdate();
    }

    //! Called on low memory condition
    function onLowMemory() as Void {
        System.println("Low memory warning");
    }
}
