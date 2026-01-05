import Toybox.Application;
import Toybox.Lang;

module TimerStorage {
    const STORAGE_KEY = "savedTimers";
    
    function loadTimers() as Array<TimerConfig> {
        var stored = Application.Storage.getValue(STORAGE_KEY);
        var timers = [] as Array<TimerConfig>;
        
        if (stored != null && stored instanceof Array) {
            for (var i = 0; i < stored.size(); i++) {
                var config = new TimerConfig();
                config.fromDictionary(stored[i]);
                timers.add(config);
            }
        }
        
        if (timers.size() == 0) {
            // Create default timer if none exist
            var defaultTimer = new TimerConfig();
            defaultTimer.name = "Default";
            timers.add(defaultTimer);
            saveTimers(timers);
        }
        
        return timers;
    }
    
    function saveTimers(timers as Array<TimerConfig>) {
        var stored = [];
        for (var i = 0; i < timers.size(); i++) {
            stored.add(timers[i].toDictionary());
        }
        Application.Storage.setValue(STORAGE_KEY, stored);
    }
    
    function deleteTimer(timerId, timers as Array<TimerConfig>) {
        for (var i = 0; i < timers.size(); i++) {
            if (timers[i].id == timerId) {
                timers.remove(timers[i]);
                break;
            }
        }
        saveTimers(timers);
        return timers;
    }
}
