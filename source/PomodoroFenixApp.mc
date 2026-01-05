import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;

class PomodoroFenixApp extends Application.AppBase {
    public var pomodoroTimer;

    function initialize() {
        AppBase.initialize();
        pomodoroTimer = new PomodoroTimer();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
        // No longer loading properties here as we use TimerStorage
    }

    function onSettingsChanged() {
        // No longer needed as phone settings are removed
        WatchUi.requestUpdate();
    }
    
    function formatDuration(seconds) {
        var h = seconds / 3600;
        var m = (seconds % 3600) / 60;
        var s = seconds % 60;
        return Lang.format("$1$:$2$:$3$", [h, m.format("%02d"), s.format("%02d")]);
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
        // No longer saving properties here
    }

    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [ new TimerListMenu(), new TimerListMenuDelegate() ];
    }

}

function getApp() as PomodoroFenixApp {
    return Application.getApp() as PomodoroFenixApp;
}