import Toybox.WatchUi;
import Toybox.Lang;

class TimerTypePickerDelegate extends WatchUi.Menu2InputDelegate {
    var timerId;
    
    function initialize(id) {
        Menu2InputDelegate.initialize();
        timerId = id;
    }
    
    function onSelect(item) {
        var type = item.getId();
        var timers = TimerStorage.loadTimers();
        var config = null;
        for(var i=0; i<timers.size(); i++) {
            if(timers[i].id == timerId) {
                config = timers[i];
                break;
            }
        }
        if (config != null) {
            config.type = type;
            TimerStorage.saveTimers(timers);
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            WatchUi.switchToView(new TimerEditMenu(timerId), new TimerEditMenuDelegate(timerId), WatchUi.SLIDE_IMMEDIATE);
        }
    }
}
