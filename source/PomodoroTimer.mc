import Toybox.Lang;
import Toybox.System;
import Toybox.Timer;
import Toybox.Attention;
import Toybox.WatchUi;

class PomodoroTimer {
    // Settings
    public var workDuration = 25 * 60;
    public var shortBreakDuration = 5 * 60;
    public var longBreakDuration = 15 * 60;
    public var cycles = 4;
    public var infiniteMode = false;
    public var vibration = true;
    public var sound = true;
    public var showTime = true;

    // State
    public var isRunning = false;
    public var currentPhase = :work; // :work, :shortBreak, :longBreak
    public var timeRemaining = 25 * 60;
    public var completedCycles = 0;

    private var _timer;
    private var _notifyTimer;

    function initialize() {
        _timer = new Timer.Timer();
        _notifyTimer = new Timer.Timer();
    }

    function start() {
        if (!isRunning) {
            isRunning = true;
            _timer.start(method(:onTimerTick), 1000, true);
            WatchUi.requestUpdate();

            if (vibration) {
                if (Attention has :vibrate) {
                    var vibeData = [new Attention.VibeProfile(100, 500)];
                    Attention.vibrate(vibeData);
                }
            }
            if (sound) {
                if (Attention has :playTone) {
                    Attention.playTone(Attention.TONE_START);
                }
            }
        }
    }

    function stop() {
        if (isRunning) {
            isRunning = false;
            _timer.stop();
            WatchUi.requestUpdate();

            if (vibration) {
                if (Attention has :vibrate) {
                    var vibeData = [new Attention.VibeProfile(100, 1500)];
                    Attention.vibrate(vibeData);
                }
            }
            if (sound) {
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
        if (currentPhase == :work) {
            timeRemaining = workDuration;
        } else if (currentPhase == :shortBreak) {
            timeRemaining = shortBreakDuration;
        } else if (currentPhase == :longBreak) {
            timeRemaining = longBreakDuration;
        }
        if (wasRunning) {
            start();
        }
        WatchUi.requestUpdate();
    }

    function nextSection() {
        var wasRunning = isRunning;
        stop();
        switchPhase();
        if (wasRunning) {
            start();
        }
        WatchUi.requestUpdate();
    }

    function onTimerTick() {
        if (timeRemaining > 0) {
            timeRemaining--;
        } else {
            // Section complete
            // Determine next phase to decide on notification sound
            var nextIsWork = (currentPhase == :shortBreak || currentPhase == :longBreak);
            notify(nextIsWork);
            
            switchPhase();
            
            // If we stopped (cycles done), don't restart timer
            if (!isRunning) {
                _timer.stop();
            }
        }
        WatchUi.requestUpdate();
    }

    function switchPhase() {
        if (currentPhase == :work) {
            // Work finished. Check if we should take a long break.
            // If we just finished the last cycle (e.g. 4th work session), go to long break.
            // completedCycles starts at 0. So if cycles=4, we want to go to long break after work #4.
            // At this point completedCycles is 3 (0, 1, 2 done, just finished 3rd index which is 4th item).
            // Wait, let's trace:
            // Start: cycles=0. Work.
            // Work finishes. switchPhase.
            // If completedCycles + 1 >= cycles (0+1 >= 4? No).
            // Go to short break.
            // Short break finishes. switchPhase. completedCycles becomes 1. Back to Work.
            // ...
            // Work #4 finishes. completedCycles is 3.
            // If completedCycles + 1 >= cycles (3+1 >= 4? Yes).
            // Go to long break.
            
            if (completedCycles + 1 >= cycles) {
                currentPhase = :longBreak;
                timeRemaining = longBreakDuration;
            } else {
                currentPhase = :shortBreak;
                timeRemaining = shortBreakDuration;
            }
        } else {
            // Break finished (Short or Long).
            if (currentPhase == :longBreak) {
                completedCycles = 0; // Reset cycle count
                if (!infiniteMode) {
                    stop();
                    currentPhase = :work;
                    timeRemaining = workDuration;
                    return; // Don't start work if stopped
                }
            } else {
                // Short break finished
                completedCycles++;
            }
            
            // Back to work
            currentPhase = :work;
            timeRemaining = workDuration;
        }
    }

    function notify(nextIsWork) {
        if (vibration) {
            if (Attention has :vibrate) {
                var vibeData;
                if (nextIsWork) {
                    // Short vibration for work start
                    vibeData = [new Attention.VibeProfile(50, 500)];
                } else {
                    // Long vibration for break start
                    vibeData = [new Attention.VibeProfile(50, 1500)];
                }
                Attention.vibrate(vibeData);
            }
        }
        if (sound) {
            if (Attention has :playTone) {
                if (nextIsWork) {
                    // Single chime for work start
                    Attention.playTone(Attention.TONE_LAP);
                } else {
                    // Double chime for break start
                    Attention.playTone(Attention.TONE_LAP);
                    if (_notifyTimer != null) {
                        _notifyTimer.start(method(:playSecondChime), 500, false);
                    }
                }
            }
        }
    }

    function playSecondChime() {
        if (sound && Attention has :playTone) {
            Attention.playTone(Attention.TONE_LAP);
        }
    }
    
    function setWorkDuration(seconds) {
        workDuration = seconds;
        if (!isRunning && currentPhase == :work) {
            timeRemaining = workDuration;
        }
    }

    function setBreakDuration(seconds) {
        shortBreakDuration = seconds;
        if (!isRunning && currentPhase == :shortBreak) {
            timeRemaining = shortBreakDuration;
        }
    }

    function setLongBreakDuration(seconds) {
        longBreakDuration = seconds;
        if (!isRunning && currentPhase == :longBreak) {
            timeRemaining = longBreakDuration;
        }
    }
}
