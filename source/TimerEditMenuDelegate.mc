import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Time;

class TimerEditMenuDelegate extends WatchUi.Menu2InputDelegate {
    var timerId;
    
    function initialize(id) {
        Menu2InputDelegate.initialize();
        timerId = id;
    }
    
    function onSelect(item) {
        var id = item.getId();
        var timers = TimerStorage.loadTimers();
        var config = null;
        for(var i=0; i<timers.size(); i++) {
            if(timers[i].id == timerId) {
                config = timers[i];
                break;
            }
        }
        if (config == null) { return; }
        
        if (id == :name) {
            if (WatchUi has :TextPicker) {
                WatchUi.pushView(new WatchUi.TextPicker(config.name), new TimerNameDelegate(timerId), WatchUi.SLIDE_LEFT);
            }
        } else if (id == :type) {
            var menu = new WatchUi.Menu2({:title=>"Timer Type"});
            menu.addItem(new WatchUi.MenuItem("Standard", null, TimerConfig.TYPE_STANDARD, null));
            menu.addItem(new WatchUi.MenuItem("Custom", null, TimerConfig.TYPE_CUSTOM, null));
            WatchUi.pushView(menu, new TimerTypePickerDelegate(timerId), WatchUi.SLIDE_LEFT);
        } else if (id == :focusDuration || id == :shortBreakDuration || id == :longBreakDuration) {
            var initialVal = 25 * 60;
            if (id == :focusDuration) { initialVal = config.focusDuration; }
            else if (id == :shortBreakDuration) { initialVal = config.shortBreakDuration; }
            else if (id == :longBreakDuration) { initialVal = config.longBreakDuration; }
            
            var h = initialVal / 3600;
            var m = (initialVal % 3600) / 60;
            var s = initialVal % 60;
            var values = {:h => h, :m => m, :s => s};
            
            if (WatchUi has :Picker) {
                WatchUi.pushView(
                    new TimePartPicker("Hours", 0, 23, h, "%d"), 
                    new TimePartPickerDelegate(timerId, id, null, :hours, values), 
                    WatchUi.SLIDE_LEFT
                );
            } else {
                // Fallback: Simple Duration Menu
                var menu = new WatchUi.Menu2({:title=>"Select Duration"});
                var durations = [5, 10, 15, 20, 25, 30, 45, 60, 90, 120];
                for(var i=0; i<durations.size(); i++) {
                    var min = durations[i];
                    menu.addItem(new WatchUi.MenuItem(min + " min", null, min * 60, null));
                }
                WatchUi.pushView(menu, new SimpleDurationPickerDelegate(timerId, id), WatchUi.SLIDE_LEFT);
            }
        } else if (id == :cycles) {
             var menu = new WatchUi.Menu2({:title=>"Cycles"});
             for(var i=1; i<=10; i++) {
                 menu.addItem(new WatchUi.MenuItem(i.toString(), null, i, null));
             }
             WatchUi.pushView(menu, new CyclesPickerDelegate(timerId), WatchUi.SLIDE_LEFT);
        } else if (id == :customSections) {
            WatchUi.pushView(new CustomSectionsMenu(timerId, null), new CustomSectionsDelegate(timerId), WatchUi.SLIDE_LEFT);
        } else if (item instanceof WatchUi.ToggleMenuItem) {
            if (id == :sound) { config.sound = item.isEnabled(); }
            else if (id == :vibration) { config.vibration = item.isEnabled(); }
            else if (id == :infiniteMode) { config.infiniteMode = item.isEnabled(); }
            else if (id == :showTime) { config.showTime = item.isEnabled(); }
            TimerStorage.saveTimers(timers);
        }
    }
}

class SimpleDurationPickerDelegate extends WatchUi.Menu2InputDelegate {
    var timerId;
    var property;
    
    function initialize(id, prop) {
        Menu2InputDelegate.initialize();
        timerId = id;
        property = prop;
    }
    
    function onSelect(item) {
        var seconds = item.getId();
        var timers = TimerStorage.loadTimers();
        var config = null;
        for(var i=0; i<timers.size(); i++) {
            if(timers[i].id == timerId) {
                config = timers[i];
                break;
            }
        }
        if (config != null) {
            if (property == :focusDuration) { config.focusDuration = seconds; }
            else if (property == :shortBreakDuration) { config.shortBreakDuration = seconds; }
            else if (property == :longBreakDuration) { config.longBreakDuration = seconds; }
            TimerStorage.saveTimers(timers);
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            WatchUi.switchToView(new TimerEditMenu(timerId), new TimerEditMenuDelegate(timerId), WatchUi.SLIDE_IMMEDIATE);
        }
    }
}

class DurationPickerDelegate extends WatchUi.NumberPickerDelegate {
    var timerId;
    var property;
    
    function initialize(id, prop) {
        NumberPickerDelegate.initialize();
        timerId = id;
        property = prop;
    }
    
    function onNumberPicked(value) {
        var timers = TimerStorage.loadTimers();
        var config = null;
        for(var i=0; i<timers.size(); i++) {
            if(timers[i].id == timerId) {
                config = timers[i];
                break;
            }
        }
        if (config != null) {
            var seconds = value.value();
            if (property == :focusDuration) { config.focusDuration = seconds; }
            else if (property == :shortBreakDuration) { config.shortBreakDuration = seconds; }
            else if (property == :longBreakDuration) { config.longBreakDuration = seconds; }
            TimerStorage.saveTimers(timers);
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            WatchUi.switchToView(new TimerEditMenu(timerId), new TimerEditMenuDelegate(timerId), WatchUi.SLIDE_IMMEDIATE);
        }
        return true;
    }
}

class CyclesPickerDelegate extends WatchUi.Menu2InputDelegate {
    var timerId;
    function initialize(id) {
        Menu2InputDelegate.initialize();
        timerId = id;
    }
    function onSelect(item) {
        var cycles = item.getId();
        var timers = TimerStorage.loadTimers();
        var config = null;
        for(var i=0; i<timers.size(); i++) {
            if(timers[i].id == timerId) {
                config = timers[i];
                break;
            }
        }
        if (config != null) {
            config.cycles = cycles;
            TimerStorage.saveTimers(timers);
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            WatchUi.switchToView(new TimerEditMenu(timerId), new TimerEditMenuDelegate(timerId), WatchUi.SLIDE_IMMEDIATE);
        }
    }
}
