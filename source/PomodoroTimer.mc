import Toybox.Lang;
import Toybox.System;
import Toybox.Timer;
import Toybox.Attention;
import Toybox.WatchUi;

class PomodoroTimer {
    // Config
    public var config as TimerConfig?;

    // State
    public var isRunning = false;
    public var currentPhase = :focus; // :focus, :shortBreak, :longBreak
    public var timeRemaining = 0;
    public var completedCycles = 0;
    public var currentSectionIndex = 0; // For custom timers

    private var _timer;
    private var _notifyTimer;

    function initialize() {
        _timer = new Timer.Timer();
        _notifyTimer = new Timer.Timer();
        // Default config will be loaded by App or View
    }

    function setConfig(newConfig as TimerConfig) {
        config = newConfig;
        reset();
    }

    function start() {
        if (config == null) { return; }
        if (!isRunning) {
            isRunning = true;
            _timer.start(method(:onTimerTick), 1000, true);
            WatchUi.requestUpdate();

            if (config.vibration) {
                if (Attention has :vibrate) {
                    var vibeData = [new Attention.VibeProfile(100, 500)];
                    Attention.vibrate(vibeData);
                }
            }
            if (config.sound) {
                if (Attention has :playTone) {
                    Attention.playTone(Attention.TONE_START);
                }
            }
        }
    }

    function stop() {
        if (config == null) { return; }
        if (isRunning) {
            isRunning = false;
            _timer.stop();
            WatchUi.requestUpdate();

            if (config.vibration) {
                if (Attention has :vibrate) {
                    var vibeData = [new Attention.VibeProfile(100, 1500)];
                    Attention.vibrate(vibeData);
                }
            }
            if (config.sound) {
                if (Attention has :playTone) {
                    Attention.playTone(Attention.TONE_STOP);
                }
            }
        }
    }

    function toggle() {
        if (isRunning) {
            stop();
        } else {
            start();
        }
    }

    function restartSection() {
        var wasRunning = isRunning;
        stop();
        if (config != null) {
            if (config.type == TimerConfig.TYPE_STANDARD) {
                if (currentPhase == :focus) {
                    timeRemaining = config.focusDuration;
                } else if (currentPhase == :shortBreak) {
                    timeRemaining = config.shortBreakDuration;
                } else if (currentPhase == :longBreak) {
                    timeRemaining = config.longBreakDuration;
                }
            } else {
                loadCustomSection(currentSectionIndex);
            }
        }
        if (wasRunning) {
            start();
        }
        WatchUi.requestUpdate();
    }

    function nextSection() {
        var wasRunning = isRunning;
        stop();
        var shouldResume = true;
        if (config != null) {
            if (config.type == TimerConfig.TYPE_STANDARD) {
                shouldResume = switchPhaseStandard();
            } else {
                shouldResume = switchPhaseCustom();
            }
        }
        if (wasRunning && shouldResume) {
            start();
        }
        WatchUi.requestUpdate();
    }

    function reset() {
        isRunning = false;
        _timer.stop();
        completedCycles = 0;
        currentSectionIndex = 0;
        
        if (config != null) {
            if (config.type == TimerConfig.TYPE_STANDARD) {
                currentPhase = :focus;
                timeRemaining = config.focusDuration;
            } else {
                loadCustomSection(0);
            }
        }
        WatchUi.requestUpdate();
    }

    function loadCustomSection(index) {
        if (config == null || config.customSections.size() == 0) { return false; }
        
        if (index >= config.customSections.size()) {
            // End of custom sections
            if (config.infiniteMode) {
                index = 0;
            } else {
                stop();
                // Reset to start
                currentSectionIndex = 0;
                loadCustomSection(0);
                return false;
            }
        }
        
        currentSectionIndex = index;
        var section = config.customSections[index];
        var type = section["type"];
        var duration = section["duration"];
        
        if (type == TimerConfig.SECTION_FOCUS) {
            currentPhase = :focus;
        } else if (type == TimerConfig.SECTION_SHORT_BREAK) {
            currentPhase = :shortBreak;
        } else {
            currentPhase = :longBreak;
        }
        timeRemaining = duration;
        return true;
    }

    function onTimerTick() {
        if (timeRemaining > 0) {
            timeRemaining--;
        } else {
            // Section complete
            var nextIsFocus = false;
            
            if (config.type == TimerConfig.TYPE_STANDARD) {
                nextIsFocus = (currentPhase == :shortBreak || currentPhase == :longBreak);
                switchPhaseStandard();
            } else {
                // Custom
                var nextIndex = currentSectionIndex + 1;
                if (nextIndex >= config.customSections.size() && config.infiniteMode) {
                    nextIndex = 0;
                }
                
                if (nextIndex < config.customSections.size()) {
                    var nextSection = config.customSections[nextIndex];
                    nextIsFocus = (nextSection["type"] == TimerConfig.SECTION_FOCUS);
                }
                
                switchPhaseCustom();
            }
            
            notify(nextIsFocus);
            
            // If we stopped (cycles done), don't restart timer
            if (!isRunning) {
                _timer.stop();
            }
        }
        WatchUi.requestUpdate();
    }

    function switchPhaseStandard() {
        if (currentPhase == :focus) {
            if (completedCycles + 1 >= config.cycles) {
                currentPhase = :longBreak;
                timeRemaining = config.longBreakDuration;
            } else {
                currentPhase = :shortBreak;
                timeRemaining = config.shortBreakDuration;
            }
        } else {
            if (currentPhase == :longBreak) {
                completedCycles = 0;
                if (!config.infiniteMode) {
                    stop();
                    currentPhase = :focus;
                    timeRemaining = config.focusDuration;
                    return false;
                }
            } else {
                completedCycles++;
            }
            currentPhase = :focus;
            timeRemaining = config.focusDuration;
        }
        return true;
    }
    
    function switchPhaseCustom() {
        return loadCustomSection(currentSectionIndex + 1);
    }

    function notify(nextIsFocus) {
        if (config.vibration) {
            if (Attention has :vibrate) {
                var vibeData;
                if (nextIsFocus) {
                    vibeData = [new Attention.VibeProfile(50, 500)];
                } else {
                    vibeData = [new Attention.VibeProfile(50, 1500)];
                }
                Attention.vibrate(vibeData);
            }
        }
        if (config.sound) {
            if (Attention has :playTone) {
                if (nextIsFocus) {
                    Attention.playTone(Attention.TONE_LAP);
                } else {
                    Attention.playTone(Attention.TONE_LAP);
                    if (_notifyTimer != null) {
                        _notifyTimer.start(method(:playSecondChime), 500, false);
                    }
                }
            }
        }
    }

    function playSecondChime() {
        if (config.sound && Attention has :playTone) {
            Attention.playTone(Attention.TONE_LAP);
        }
    }
}
