import Toybox.Lang;
import Toybox.WatchUi;

class PomodoroFenixDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() as Boolean {
        WatchUi.pushView(new Rez.Menus.MainMenu(), new PomodoroFenixMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

}