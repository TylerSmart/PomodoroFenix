import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application;

class PomodoroFenixDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() as Boolean {
        var app = Application.getApp();
        if (!app.pomodoroTimer.isRunning) {
            var menu = new WatchUi.Menu2({:title=>"Settings"});
            
            menu.addItem(new WatchUi.ToggleMenuItem("Infinite Mode", null, :infiniteMode, app.pomodoroTimer.infiniteMode, null));
            menu.addItem(new WatchUi.MenuItem("Work Time", formatDuration(app.pomodoroTimer.workDuration), :workTime, null));
            menu.addItem(new WatchUi.MenuItem("Break Time", formatDuration(app.pomodoroTimer.breakDuration), :breakTime, null));
            menu.addItem(new WatchUi.MenuItem("Cycles", app.pomodoroTimer.cycles + "", :cycles, null));
            menu.addItem(new WatchUi.ToggleMenuItem("Vibration", null, :vibration, app.pomodoroTimer.vibration, null));
            menu.addItem(new WatchUi.ToggleMenuItem("Sound", null, :sound, app.pomodoroTimer.sound, null));
            menu.addItem(new WatchUi.ToggleMenuItem("Show Time", null, :showTime, app.pomodoroTimer.showTime, null));

            WatchUi.pushView(menu, new PomodoroFenixMenuDelegate(), WatchUi.SLIDE_UP);
            return true;
        }
        return false;
    }

    function formatDuration(seconds) {
        var h = seconds / 3600;
        var m = (seconds % 3600) / 60;
        var s = seconds % 60;
        if (h > 0) {
            return Lang.format("$1$:$2$:$3$", [h, m.format("%02d"), s.format("%02d")]);
        } else {
            return Lang.format("$1$:$2$", [m, s.format("%02d")]);
        }
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