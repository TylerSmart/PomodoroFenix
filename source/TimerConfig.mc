import Toybox.Lang;
import Toybox.System;

class TimerConfig {
    enum TimerType {
        TYPE_STANDARD = 0,
        TYPE_CUSTOM = 1
    }

    enum SectionType {
        SECTION_FOCUS = 0,
        SECTION_SHORT_BREAK = 1,
        SECTION_LONG_BREAK = 2
    }

    var id; // Unique ID
    var name;
    var type; // TimerType
    
    // Standard Settings
    var focusDuration;
    var shortBreakDuration;
    var longBreakDuration;
    var cycles;

    // Custom Settings
    var customSections; // Array of Dictionaries { "type" => SectionType, "duration" => Number }

    // Common Settings
    var sound;
    var vibration;
    var infiniteMode;
    var showTime;

    function initialize() {
        id = System.getTimer(); // Simple ID generation
        name = "New Timer";
        type = TYPE_STANDARD;
        focusDuration = 25 * 60;
        shortBreakDuration = 5 * 60;
        longBreakDuration = 15 * 60;
        cycles = 4;
        customSections = [];
        sound = true;
        vibration = true;
        infiniteMode = false;
        showTime = true;
    }
    
    // Serialization for Storage
    function toDictionary() {
        return {
            "id" => id,
            "name" => name,
            "type" => type,
            "focusDuration" => focusDuration,
            "shortBreakDuration" => shortBreakDuration,
            "longBreakDuration" => longBreakDuration,
            "cycles" => cycles,
            "customSections" => customSections,
            "sound" => sound,
            "vibration" => vibration,
            "infiniteMode" => infiniteMode,
            "showTime" => showTime
        };
    }

    function fromDictionary(dict as Dictionary) {
        id = dict["id"];
        name = dict["name"];
        type = dict["type"];
        focusDuration = dict["focusDuration"];
        shortBreakDuration = dict["shortBreakDuration"];
        longBreakDuration = dict["longBreakDuration"];
        cycles = dict["cycles"];
        customSections = dict["customSections"];
        sound = dict["sound"];
        vibration = dict["vibration"];
        infiniteMode = dict["infiniteMode"];
        showTime = dict["showTime"];
    }
}
