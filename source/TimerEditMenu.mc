import Toybox.WatchUi;
import Toybox.Lang;

class TimerEditMenu extends WatchUi.Menu2 {
    var timerId;
    
    function initialize(id) {
        Menu2.initialize({:title=>"Edit Timer"});
        timerId = id;
        
        var timers = TimerStorage.loadTimers();
        var config = null;
        for(var i=0; i<timers.size(); i++) {
            if(timers[i].id == timerId) {
                config = timers[i];
                break;
            }
        }
        
        if (config == null) { return; }
        
        addItem(new WatchUi.MenuItem("Name", config.name, :name, null));
        addItem(new WatchUi.MenuItem("Type", (config.type == TimerConfig.TYPE_STANDARD ? "Standard" : "Custom"), :type, null));
        
        if (config.type == TimerConfig.TYPE_STANDARD) {
            addItem(new WatchUi.MenuItem("Focus Time", formatDuration(config.focusDuration), :focusDuration, null));
            addItem(new WatchUi.MenuItem("Short Break", formatDuration(config.shortBreakDuration), :shortBreakDuration, null));
            addItem(new WatchUi.MenuItem("Long Break", formatDuration(config.longBreakDuration), :longBreakDuration, null));
            addItem(new WatchUi.MenuItem("Cycles", config.cycles.toString(), :cycles, null));
        } else {
            addItem(new WatchUi.MenuItem("Sections", config.customSections.size() + " sections", :customSections, null));
        }
        
        addItem(new WatchUi.ToggleMenuItem("Sound", null, :sound, config.sound, null));
        addItem(new WatchUi.ToggleMenuItem("Vibration", null, :vibration, config.vibration, null));
        addItem(new WatchUi.ToggleMenuItem("Infinite", null, :infiniteMode, config.infiniteMode, null));
        addItem(new WatchUi.ToggleMenuItem("Show Time", null, :showTime, config.showTime, null));
    }
    
    function formatDuration(seconds) {
        return Application.getApp().formatDuration(seconds);
    }
}
