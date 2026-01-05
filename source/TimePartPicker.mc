import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Application;

class TimePartPicker extends WatchUi.Picker {
    function initialize(title, start, stop, initialValue, format) {
        var titleText = new WatchUi.Text({
            :text=>title, 
            :locX=>WatchUi.LAYOUT_HALIGN_CENTER, 
            :locY=>WatchUi.LAYOUT_VALIGN_BOTTOM, 
            :color=>Graphics.COLOR_WHITE
        });
        var factory = new NumberFactory(start, stop, 1, format);
        var index = factory.getIndex(initialValue);
        if (index < 0) { index = 0; }
        if (index >= factory.getSize()) { index = factory.getSize() - 1; }
        
        Picker.initialize({:title=>titleText, :pattern=>[factory], :defaults=>[index]});
    }
}

class NumberFactory extends WatchUi.PickerFactory {
    var start;
    var stop;
    var increment;
    var format;

    function initialize(s, e, i, f) {
        PickerFactory.initialize();
        start = s;
        stop = e;
        increment = i;
        format = f;
    }

    function getIndex(value) {
        return (value - start) / increment;
    }

    function getSize() {
        return (stop - start) / increment + 1;
    }

    function getValue(index) {
        return start + (index * increment);
    }

    function getDrawable(index, selected) {
        var val = getValue(index);
        var text = "";
        if (val instanceof Lang.Number) {
            text = val.format(format);
        } else {
            text = val.toString();
        }
        return new WatchUi.Text({
            :text=>text, 
            :color=>Graphics.COLOR_WHITE, 
            :font=>Graphics.FONT_NUMBER_MEDIUM, 
            :locX=>WatchUi.LAYOUT_HALIGN_CENTER, 
            :locY=>WatchUi.LAYOUT_VALIGN_CENTER
        });
    }
}

class TimePartPickerDelegate extends WatchUi.PickerDelegate {
    var timerId;
    var property; // :focusDuration, :shortBreakDuration, :longBreakDuration, or :customSection
    var sectionIndex; // Only for custom sections
    var part; // :hours, :minutes, :seconds
    var currentValues; // {:h, :m, :s}

    function initialize(id, prop, idx, p, vals) {
        PickerDelegate.initialize();
        timerId = id;
        property = prop;
        sectionIndex = idx;
        part = p;
        currentValues = vals;
    }

    function onCancel() {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }

    function onAccept(values) {
        var val = values[0]; // The value from factory
        
        if (part == :hours) {
            currentValues[:h] = val;
            // Push Minutes
            WatchUi.pushView(
                new TimePartPicker("Minutes", 0, 59, currentValues[:m], "%02d"), 
                new TimePartPickerDelegate(timerId, property, sectionIndex, :minutes, currentValues), 
                WatchUi.SLIDE_LEFT
            );
        } else if (part == :minutes) {
            currentValues[:m] = val;
            // Push Seconds
            WatchUi.pushView(
                new TimePartPicker("Seconds", 0, 59, currentValues[:s], "%02d"), 
                new TimePartPickerDelegate(timerId, property, sectionIndex, :seconds, currentValues), 
                WatchUi.SLIDE_LEFT
            );
        } else if (part == :seconds) {
            currentValues[:s] = val;
            saveAndClose();
        }
        return true;
    }

    function saveAndClose() {
        var totalSeconds = (currentValues[:h] * 3600) + (currentValues[:m] * 60) + currentValues[:s];
        
        var timers = TimerStorage.loadTimers();
        var config = null;
        for(var i=0; i<timers.size(); i++) {
            if(timers[i].id == timerId) {
                config = timers[i];
                break;
            }
        }
        
        if (config != null) {
            if (property == :customSection) {
                var section = config.customSections[sectionIndex];
                section["duration"] = totalSeconds;
                config.customSections[sectionIndex] = section;
                TimerStorage.saveTimers(timers);
                
                // Pop Seconds, Minutes, Hours
                WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
                WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
                WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
                
                // We are now at the Section Options Menu. We should refresh it?
                // The SectionOptionsDelegate doesn't auto-refresh the view below it.
                // But we want to stay on the edit page.
                // The previous view (SectionOptionsDelegate's Menu) has old data in its items?
                // Yes, the menu items are static.
                // We need to replace the menu or update it.
                // Since we can't easily update Menu2 items in place without reference, 
                // we might need to pop the menu too and push a new one?
                // Or just accept that the menu shows old value until we back out?
                // The user asked: "Can we keep the user on the current section they are editing?"
                // In the previous fix, I rebuilt the menu.
                // Here, I am 3 levels deep.
                // If I pop 3 times, I am back at Section Options Menu.
                // I should probably pop 4 times (remove Section Options Menu) and push a new one?
                // Or pop 3 times, then switch view?
                
                // Let's try popping 3 times, then using switchToView to refresh the underlying menu.
                // But switchToView replaces the *top* view.
                // If I pop 3 times, the top view is the old Menu.
                // So I can pop 3 times, then `WatchUi.switchToView(newMenu...)`.
                
                // Rebuild menu logic
                var typeStr = "Focus";
                if (section["type"] == TimerConfig.SECTION_SHORT_BREAK) { typeStr = "Short Break"; }
                else if (section["type"] == TimerConfig.SECTION_LONG_BREAK) { typeStr = "Long Break"; }
                var durationStr = Application.getApp().formatDuration(totalSeconds);
                
                var menu = new WatchUi.Menu2({:title=>"Edit Section"});
                menu.addItem(new WatchUi.MenuItem("Type", typeStr, :type, {:index => sectionIndex}));
                menu.addItem(new WatchUi.MenuItem("Duration", durationStr, :duration, {:index => sectionIndex}));
                menu.addItem(new WatchUi.MenuItem("Move Up", null, :moveUp, {:index => sectionIndex}));
                menu.addItem(new WatchUi.MenuItem("Move Down", null, :moveDown, {:index => sectionIndex}));
                menu.addItem(new WatchUi.MenuItem("Delete", null, :delete, {:index => sectionIndex}));
                
                WatchUi.switchToView(menu, new SectionOptionsDelegate(timerId, sectionIndex), WatchUi.SLIDE_IMMEDIATE);
                
            } else {
                // Standard timer properties
                if (property == :focusDuration) { config.focusDuration = totalSeconds; }
                else if (property == :shortBreakDuration) { config.shortBreakDuration = totalSeconds; }
                else if (property == :longBreakDuration) { config.longBreakDuration = totalSeconds; }
                TimerStorage.saveTimers(timers);
                
                // Pop Seconds, Minutes, Hours
                WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
                WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
                WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
                
                // Refresh TimerEditMenu
                WatchUi.switchToView(new TimerEditMenu(timerId), new TimerEditMenuDelegate(timerId), WatchUi.SLIDE_IMMEDIATE);
            }
        } else {
             // Config not found, just pop
             WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
             WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
             WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        }
    }
}
