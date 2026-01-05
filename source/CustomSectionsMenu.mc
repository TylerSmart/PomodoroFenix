import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Application;

class CustomSectionsMenu extends WatchUi.Menu2 {
    var timerId;
    var autoOpenIndex;
    
    function initialize(id, openIndex) {
        Menu2.initialize({:title=>"Sections"});
        timerId = id;
        autoOpenIndex = openIndex;
        
        var timers = TimerStorage.loadTimers();
        var config = null;
        for(var i=0; i<timers.size(); i++) {
            if(timers[i].id == timerId) {
                config = timers[i];
                break;
            }
        }
        
        if (config == null) { return; }
        
        for(var i=0; i<config.customSections.size(); i++) {
            var section = config.customSections[i];
            var typeStr = "Focus";
            if (section["type"] == TimerConfig.SECTION_SHORT_BREAK) { typeStr = "Short Break"; }
            else if (section["type"] == TimerConfig.SECTION_LONG_BREAK) { typeStr = "Long Break"; }
            
            var durationStr = Application.getApp().formatDuration(section["duration"]);
            addItem(new WatchUi.MenuItem(typeStr + " - " + durationStr, null, i, null));
        }
        
        addItem(new WatchUi.MenuItem("Add Section", null, :add, null));
    }
    
    function onShow() {
        Menu2.onShow();
        
        // Refresh the list
        var timers = TimerStorage.loadTimers();
        var config = null;
        for(var i=0; i<timers.size(); i++) {
            if(timers[i].id == timerId) {
                config = timers[i];
                break;
            }
        }
        
        if (config == null) { return; }
        
        // Clear existing items
        // Menu2 doesn't have clear(), so we delete all items
        // We can't use getSize() easily, so we just delete until empty
        // Actually, we can just delete item 0 repeatedly
        // But we need to know how many items to delete?
        // Or just delete until deleteItem returns false.
        
        // Note: deleteItem returns boolean.
        while(deleteItem(0)) {}
        
        for(var i=0; i<config.customSections.size(); i++) {
            var section = config.customSections[i];
            var typeStr = "Focus";
            if (section["type"] == TimerConfig.SECTION_SHORT_BREAK) { typeStr = "Short Break"; }
            else if (section["type"] == TimerConfig.SECTION_LONG_BREAK) { typeStr = "Long Break"; }
            
            var durationStr = Application.getApp().formatDuration(section["duration"]);
            addItem(new WatchUi.MenuItem(typeStr + " - " + durationStr, null, i, null));
        }
        
        addItem(new WatchUi.MenuItem("Add Section", null, :add, null));
        
        if (autoOpenIndex != null) {
            var index = autoOpenIndex;
            autoOpenIndex = null;
            
            // Open editor for this index
            if (index < config.customSections.size()) {
                var section = config.customSections[index];
                var typeStr = "Focus";
                if (section["type"] == TimerConfig.SECTION_FOCUS) { typeStr = "Focus"; }
                else if (section["type"] == TimerConfig.SECTION_SHORT_BREAK) { typeStr = "Short Break"; }
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
}
