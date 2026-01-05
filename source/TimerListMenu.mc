import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Graphics;

class TimerListMenu extends WatchUi.Menu2 {
    function initialize() {
        Menu2.initialize({:title=>"Timers"});
        var timers = TimerStorage.loadTimers();
        for (var i = 0; i < timers.size(); i++) {
            var timer = timers[i];
            addItem(new WatchUi.MenuItem(timer.name, null, timer.id, null));
        }
        addItem(new WatchUi.MenuItem("Create Timer", null, :create_new, null));
    }
    
    function onShow() {
        Menu2.onShow();
        // Refresh list
        var timers = TimerStorage.loadTimers();
        
        while(deleteItem(0)) {}
        
        for (var i = 0; i < timers.size(); i++) {
            var timer = timers[i];
            addItem(new WatchUi.MenuItem(timer.name, null, timer.id, null));
        }
        addItem(new WatchUi.MenuItem("Create Timer", null, :create_new, null));
    }
}
