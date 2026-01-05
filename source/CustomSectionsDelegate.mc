import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Time;

class CustomSectionsDelegate extends WatchUi.Menu2InputDelegate {
    var timerId;
    
    function initialize(id) {
        Menu2InputDelegate.initialize();
        timerId = id;
    }
    
    function onSelect(item) {
        var id = item.getId();
        if (id == :add) {
            // Add new section
            var timers = TimerStorage.loadTimers();
            var config = null;
            for(var i=0; i<timers.size(); i++) {
                if(timers[i].id == timerId) {
                    config = timers[i];
                    break;
                }
            }
            if (config != null) {
                config.customSections.add({"type" => TimerConfig.SECTION_FOCUS, "duration" => 25 * 60});
                TimerStorage.saveTimers(timers);
                var newIndex = config.customSections.size() - 1;
                WatchUi.switchToView(new CustomSectionsMenu(timerId, newIndex), new CustomSectionsDelegate(timerId), WatchUi.SLIDE_IMMEDIATE);
            }
        } else {
            // Edit section (id is index)
            var index = id;
            var timers = TimerStorage.loadTimers();
            var config = null;
            for(var i=0; i<timers.size(); i++) {
                if(timers[i].id == timerId) {
                    config = timers[i];
                    break;
                }
            }
            if (config == null) { return; }
            
            var section = config.customSections[index];
            var typeStr = "Focus";
            if (section["type"] == TimerConfig.SECTION_SHORT_BREAK) { typeStr = "Short Break"; }
            else if (section["type"] == TimerConfig.SECTION_LONG_BREAK) { typeStr = "Long Break"; }
            
            var durationStr = Application.getApp().formatDuration(section["duration"]);
            
            var menu = new WatchUi.Menu2({:title=>"Edit Section"});
            menu.addItem(new WatchUi.MenuItem("Type", typeStr, :type, {:index => index}));
            menu.addItem(new WatchUi.MenuItem("Duration", durationStr, :duration, {:index => index}));
            menu.addItem(new WatchUi.MenuItem("Move Up", null, :moveUp, {:index => index}));
            menu.addItem(new WatchUi.MenuItem("Move Down", null, :moveDown, {:index => index}));
            menu.addItem(new WatchUi.MenuItem("Delete", null, :delete, {:index => index}));
            WatchUi.pushView(menu, new SectionOptionsDelegate(timerId, index), WatchUi.SLIDE_LEFT);
        }
    }
}

class SectionOptionsDelegate extends WatchUi.Menu2InputDelegate {
    var timerId;
    var sectionIndex;
    
    function initialize(id, index) {
        Menu2InputDelegate.initialize();
        timerId = id;
        sectionIndex = index;
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
        
        if (id == :type) {
            // Show Type Selection Menu
            var menu = new WatchUi.Menu2({:title=>"Section Type"});
            menu.addItem(new WatchUi.MenuItem("Focus", null, TimerConfig.SECTION_FOCUS, null));
            menu.addItem(new WatchUi.MenuItem("Short Break", null, TimerConfig.SECTION_SHORT_BREAK, null));
            menu.addItem(new WatchUi.MenuItem("Long Break", null, TimerConfig.SECTION_LONG_BREAK, null));
            WatchUi.pushView(menu, new SectionTypePickerDelegate(timerId, sectionIndex), WatchUi.SLIDE_LEFT);
        } else if (id == :duration) {
            var section = config.customSections[sectionIndex];
            var duration = section["duration"];
            var h = duration / 3600;
            var m = (duration % 3600) / 60;
            var s = duration % 60;
            var values = {:h => h, :m => m, :s => s};
            
            if (WatchUi has :Picker) {
                WatchUi.pushView(
                    new TimePartPicker("Hours", 0, 23, h, "%d"), 
                    new TimePartPickerDelegate(timerId, :customSection, sectionIndex, :hours, values), 
                    WatchUi.SLIDE_LEFT
                );
            }
        } else if (id == :moveUp) {
            if (sectionIndex > 0) {
                var temp = config.customSections[sectionIndex];
                config.customSections[sectionIndex] = config.customSections[sectionIndex-1];
                config.customSections[sectionIndex-1] = temp;
                TimerStorage.saveTimers(timers);
                WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
                WatchUi.switchToView(new CustomSectionsMenu(timerId, null), new CustomSectionsDelegate(timerId), WatchUi.SLIDE_IMMEDIATE);
            }
        } else if (id == :moveDown) {
            if (sectionIndex < config.customSections.size() - 1) {
                var temp = config.customSections[sectionIndex];
                config.customSections[sectionIndex] = config.customSections[sectionIndex+1];
                config.customSections[sectionIndex+1] = temp;
                TimerStorage.saveTimers(timers);
                WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
                WatchUi.switchToView(new CustomSectionsMenu(timerId, null), new CustomSectionsDelegate(timerId), WatchUi.SLIDE_IMMEDIATE);
            }
        } else if (id == :delete) {
            config.customSections.remove(config.customSections[sectionIndex]);
            TimerStorage.saveTimers(timers);
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            WatchUi.switchToView(new CustomSectionsMenu(timerId, null), new CustomSectionsDelegate(timerId), WatchUi.SLIDE_IMMEDIATE);
        }
    }
}

class SectionDurationPickerDelegate extends WatchUi.NumberPickerDelegate {
    var timerId;
    var sectionIndex;
    
    function initialize(id, index) {
        NumberPickerDelegate.initialize();
        timerId = id;
        sectionIndex = index;
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
            var section = config.customSections[sectionIndex];
            section["duration"] = value.value();
            config.customSections[sectionIndex] = section;
            TimerStorage.saveTimers(timers);
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE); // Pop picker
            
            // Rebuild menu to stay on edit page
            var typeStr = "Focus";
            if (section["type"] == TimerConfig.SECTION_SHORT_BREAK) { typeStr = "Short Break"; }
            else if (section["type"] == TimerConfig.SECTION_LONG_BREAK) { typeStr = "Long Break"; }
            
            var durationStr = Application.getApp().formatDuration(section["duration"]);
            
            var menu = new WatchUi.Menu2({:title=>"Edit Section"});
            menu.addItem(new WatchUi.MenuItem("Type", typeStr, :type, {:index => sectionIndex}));
            menu.addItem(new WatchUi.MenuItem("Duration", durationStr, :duration, {:index => sectionIndex}));
            menu.addItem(new WatchUi.MenuItem("Move Up", null, :moveUp, {:index => sectionIndex}));
            menu.addItem(new WatchUi.MenuItem("Move Down", null, :moveDown, {:index => sectionIndex}));
            menu.addItem(new WatchUi.MenuItem("Delete", null, :delete, {:index => sectionIndex}));
            
            WatchUi.switchToView(menu, new SectionOptionsDelegate(timerId, sectionIndex), WatchUi.SLIDE_IMMEDIATE);
        }
        return true;
    }
}
