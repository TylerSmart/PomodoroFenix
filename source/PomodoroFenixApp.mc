import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class PomodoroFenixApp extends Application.AppBase {
    public var pomodoroTimer;

    function initialize() {
        AppBase.initialize();
        pomodoroTimer = new PomodoroTimer();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
        var timer = pomodoroTimer;
        var val;
        val = Application.Storage.getValue("workDuration");
        if (val != null) { timer.workDuration = val; }
        val = Application.Storage.getValue("breakDuration");
        if (val != null) { timer.breakDuration = val; }
        val = Application.Storage.getValue("cycles");
        if (val != null) { timer.cycles = val; }
        val = Application.Storage.getValue("infiniteMode");
        if (val != null) { timer.infiniteMode = val; }
        val = Application.Storage.getValue("vibration");
        if (val != null) { timer.vibration = val; }
        val = Application.Storage.getValue("sound");
        if (val != null) { timer.sound = val; }
        
        // Initialize timeRemaining based on loaded settings if starting fresh
        if (!timer.isRunning && timer.currentPhase == :work) {
            timer.timeRemaining = timer.workDuration;
        }
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
        var timer = pomodoroTimer;
        Application.Storage.setValue("workDuration", timer.workDuration);
        Application.Storage.setValue("breakDuration", timer.breakDuration);
        Application.Storage.setValue("cycles", timer.cycles);
        Application.Storage.setValue("infiniteMode", timer.infiniteMode);
        Application.Storage.setValue("vibration", timer.vibration);
        Application.Storage.setValue("sound", timer.sound);
    }

    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [ new PomodoroFenixView(), new PomodoroFenixDelegate() ];
    }

}

function getApp() as PomodoroFenixApp {
    return Application.getApp() as PomodoroFenixApp;
}