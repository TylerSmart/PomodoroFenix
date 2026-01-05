import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Application;

class TimerListMenuDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        var id = item.getId();
        if (id == :create_new) {
            createTimer();
        } else {
            // Show options for selected timer
            var optionsMenu = new WatchUi.Menu2({:title=>"Options"});
            optionsMenu.addItem(new WatchUi.MenuItem("Start", null, :start, {:timerId => id}));
            optionsMenu.addItem(new WatchUi.MenuItem("Edit", null, :edit, {:timerId => id}));
            
            var timers = TimerStorage.loadTimers();
            if (timers.size() > 1) {
                optionsMenu.addItem(new WatchUi.MenuItem("Delete", null, :delete, {:timerId => id}));
            }
            
            WatchUi.pushView(optionsMenu, new TimerOptionsDelegate(id), WatchUi.SLIDE_LEFT);
        }
    }
    
    function createTimer() {
        if (WatchUi has :TextPicker) {
            WatchUi.pushView(new WatchUi.TextPicker("New Timer"), new TimerNameDelegate(null), WatchUi.SLIDE_LEFT);
        } else {
            // Fallback if no TextPicker
            var newTimer = new TimerConfig();
            newTimer.name = "New Timer " + newTimer.id;
            var timers = TimerStorage.loadTimers();
            timers.add(newTimer);
            TimerStorage.saveTimers(timers);
            // Go to edit page
            WatchUi.pushView(new TimerEditMenu(newTimer.id), new TimerEditMenuDelegate(newTimer.id), WatchUi.SLIDE_LEFT);
            // For now just refresh list
            // WatchUi.switchToView(new TimerListMenu(), new TimerListMenuDelegate(), WatchUi.SLIDE_IMMEDIATE);
        }
    }
}

class TimerOptionsDelegate extends WatchUi.Menu2InputDelegate {
    var timerId;
    
    function initialize(id) {
        Menu2InputDelegate.initialize();
        timerId = id;
    }
    
    function onSelect(item) {
        var id = item.getId();
        if (id == :start) {
            var timers = TimerStorage.loadTimers();
            var timerConfig = null;
            for(var i=0; i<timers.size(); i++) {
                if(timers[i].id == timerId) {
                    timerConfig = timers[i];
                    break;
                }
            }
            if (timerConfig != null) {
                var app = Application.getApp();
                app.pomodoroTimer.setConfig(timerConfig);
                WatchUi.pushView(new PomodoroFenixView(), new PomodoroFenixDelegate(), WatchUi.SLIDE_LEFT);
            }
        } else if (id == :edit) {
            WatchUi.pushView(new TimerEditMenu(timerId), new TimerEditMenuDelegate(timerId), WatchUi.SLIDE_LEFT);
        } else if (id == :delete) {
             var timers = TimerStorage.loadTimers();
             if (timers.size() <= 1) {
                 // Cannot delete the last timer
                 // Maybe show a toast or just ignore?
                 // For now, just ignore.
             } else {
                 var view = new SimpleConfirmationView("Delete Timer?");
                 WatchUi.pushView(view, new TimerDeleteSimpleDelegate(timerId), WatchUi.SLIDE_LEFT);
             }
        }
    }
}

class TimerDeleteSimpleDelegate extends SimpleConfirmationDelegate {
    var timerId;
    function initialize(id) {
        SimpleConfirmationDelegate.initialize(null); // No callback needed, we override onKey/onBack or handle internally
        timerId = id;
    }
    
    function onKey(keyEvent) {
        var key = keyEvent.getKey();
        if (key == WatchUi.KEY_ENTER || key == WatchUi.KEY_START) {
            var timers = TimerStorage.loadTimers();
            TimerStorage.deleteTimer(timerId, timers);
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE); // Pop confirmation
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE); // Pop options menu
            WatchUi.switchToView(new TimerListMenu(), new TimerListMenuDelegate(), WatchUi.SLIDE_IMMEDIATE);
            return true;
        } else if (key == WatchUi.KEY_ESC || key == WatchUi.KEY_LAP) {
             WatchUi.popView(WatchUi.SLIDE_RIGHT);
             return true;
        }
        return false;
    }
    
    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }
}

class TimerNameDelegate extends WatchUi.TextPickerDelegate {
    var timerId; // If null, creating new. If set, renaming.
    
    function initialize(id) {
        TextPickerDelegate.initialize();
        timerId = id;
    }
    
    function onTextEntered(text, changed) {
        if (timerId == null) {
            // Create new
            var newTimer = new TimerConfig();
            newTimer.name = text;
            var timers = TimerStorage.loadTimers();
            timers.add(newTimer);
            TimerStorage.saveTimers(timers);
            // Go to edit page, replacing the text picker
            WatchUi.switchToView(new TimerEditMenu(newTimer.id), new TimerEditMenuDelegate(newTimer.id), WatchUi.SLIDE_LEFT);
        } else {
            // Rename existing
            var timers = TimerStorage.loadTimers();
            for(var i=0; i<timers.size(); i++) {
                if(timers[i].id == timerId) {
                    timers[i].name = text;
                    break;
                }
            }
            TimerStorage.saveTimers(timers);
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            // Rebuild the edit menu to show new name
            WatchUi.switchToView(new TimerEditMenu(timerId), new TimerEditMenuDelegate(timerId), WatchUi.SLIDE_IMMEDIATE);
        }
        return true;
    }
}
