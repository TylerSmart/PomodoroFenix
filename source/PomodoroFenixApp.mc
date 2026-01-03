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
        loadProperties();
        
        var timer = pomodoroTimer;
        // Initialize timeRemaining based on loaded settings if starting fresh
        if (!timer.isRunning && timer.currentPhase == :work) {
            timer.timeRemaining = timer.workDuration;
        }
    }

    function onSettingsChanged() {
        loadProperties();
        WatchUi.requestUpdate();
    }

    function loadProperties() {
        var timer = pomodoroTimer;
        var val;
        
        try {
            val = Application.Properties.getValue("workDuration");
            if (val != null) { timer.workDuration = val; }
            
            val = Application.Properties.getValue("shortBreakDuration");
            if (val != null) { timer.shortBreakDuration = val; }

            val = Application.Properties.getValue("longBreakDuration");
            if (val != null) { timer.longBreakDuration = val; }

            val = Application.Properties.getValue("cycles");
            if (val != null) { timer.cycles = val; }
            
            val = Application.Properties.getValue("infiniteMode");
            if (val != null) { timer.infiniteMode = val; }
            
            val = Application.Properties.getValue("vibration");
            if (val != null) { timer.vibration = val; }
            
            val = Application.Properties.getValue("sound");
            if (val != null) { timer.sound = val; }
            
            val = Application.Properties.getValue("showTime");
            if (val != null) { timer.showTime = val; }
        } catch (e) {
            // Fallback or handle error if Properties not available
            System.println("Error loading properties: " + e.getErrorMessage());
        }
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
        var timer = pomodoroTimer;
        try {
            Application.Properties.setValue("workDuration", timer.workDuration);
            Application.Properties.setValue("shortBreakDuration", timer.shortBreakDuration);
            Application.Properties.setValue("longBreakDuration", timer.longBreakDuration);
            Application.Properties.setValue("cycles", timer.cycles);
            Application.Properties.setValue("infiniteMode", timer.infiniteMode);
            Application.Properties.setValue("vibration", timer.vibration);
            Application.Properties.setValue("sound", timer.sound);
            Application.Properties.setValue("showTime", timer.showTime);
        } catch (e) {
            System.println("Error saving properties: " + e.getErrorMessage());
        }
    }

    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [ new PomodoroFenixView(), new PomodoroFenixDelegate() ];
    }

}

function getApp() as PomodoroFenixApp {
    return Application.getApp() as PomodoroFenixApp;
}