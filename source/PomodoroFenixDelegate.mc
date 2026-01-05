import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application;

class PomodoroFenixDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() as Boolean {
        return true;
    }
    
    function onSelect() as Boolean {
        var app = Application.getApp();
        app.pomodoroTimer.toggle();
        return true;
    }

    function onBack() as Boolean {
        var app = Application.getApp();
        var timer = app.pomodoroTimer;
        
        if (timer.isRunning) {
            // Confirm reset
            var view = new SimpleConfirmationView("Reset Timer?");
            var delegate = new SimpleConfirmationDelegate(method(:onResetConfirm));
            WatchUi.pushView(view, delegate, WatchUi.SLIDE_LEFT);
            return true;
        } else {
            WatchUi.popView(WatchUi.SLIDE_RIGHT);
            return true;
        }
    }
    
    function onResetConfirm(confirmed) {
        if (confirmed) {
            var app = Application.getApp();
            app.pomodoroTimer.reset();
        }
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }
    
    function onKey(keyEvent) {
        var key = keyEvent.getKey();
        var app = Application.getApp();
        var timer = app.pomodoroTimer;

        if (key == WatchUi.KEY_ENTER || key == WatchUi.KEY_START) {
            timer.toggle();
            return true;
        } else if (key == WatchUi.KEY_DOWN) {
            timer.nextSection();
            return true;
        } else if (key == WatchUi.KEY_UP) {
            timer.restartSection();
            return true;
        }
        return false;
    }
}

class TimerResetConfirmationDelegate extends WatchUi.ConfirmationDelegate {
    function initialize() {
        ConfirmationDelegate.initialize();
    }
    
    function onResponse(response) {
        if (response == WatchUi.CONFIRM_YES) {
            var app = Application.getApp();
            app.pomodoroTimer.reset();
        }
        return true;
    }
}