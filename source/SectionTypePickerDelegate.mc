import Toybox.WatchUi;
import Toybox.Lang;

class SectionTypePickerDelegate extends WatchUi.Menu2InputDelegate {
    var timerId;
    var sectionIndex;
    
    function initialize(id, index) {
        Menu2InputDelegate.initialize();
        timerId = id;
        sectionIndex = index;
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
            var section = config.customSections[sectionIndex];
            section["type"] = type;
            config.customSections[sectionIndex] = section;
            TimerStorage.saveTimers(timers);
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE); // Pop type picker
            
            // Rebuild menu to stay on edit page
            var typeStr = "Focus";
            if (type == TimerConfig.SECTION_SHORT_BREAK) { typeStr = "Short Break"; }
            else if (type == TimerConfig.SECTION_LONG_BREAK) { typeStr = "Long Break"; }
            
            var durationStr = Application.getApp().formatDuration(section["duration"]);
            
            var menu = new WatchUi.Menu2({:title=>"Edit Section"});
            menu.addItem(new WatchUi.MenuItem("Type", typeStr, :type, {:index => sectionIndex}));
            menu.addItem(new WatchUi.MenuItem("Duration", durationStr, :duration, {:index => sectionIndex}));
            menu.addItem(new WatchUi.MenuItem("Move Up", null, :moveUp, {:index => sectionIndex}));
            menu.addItem(new WatchUi.MenuItem("Move Down", null, :moveDown, {:index => sectionIndex}));
            menu.addItem(new WatchUi.MenuItem("Delete", null, :delete, {:index => sectionIndex}));
            
            WatchUi.switchToView(menu, new SectionOptionsDelegate(timerId, sectionIndex), WatchUi.SLIDE_IMMEDIATE);
        }
    }
}
