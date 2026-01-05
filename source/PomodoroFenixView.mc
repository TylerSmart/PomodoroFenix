import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Application;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;

class PomodoroFenixView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));
    }

    function onShow() as Void {
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var app = Application.getApp();
        var timer = app.pomodoroTimer;
        
        if (timer.config == null) {
             dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
             dc.drawText(dc.getWidth()/2, dc.getHeight()/2, Graphics.FONT_MEDIUM, "No Timer Config", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
             return;
        }

        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;
        var centerY = height / 2;

        // Draw Progress Arc
        var radius = (width < height ? width : height) / 2 - 5;
        var penWidth = 10;
        var totalDuration = 1;
        
        if (timer.config.type == TimerConfig.TYPE_STANDARD) {
            if (timer.currentPhase == :focus) {
                totalDuration = timer.config.focusDuration;
            } else if (timer.currentPhase == :shortBreak) {
                totalDuration = timer.config.shortBreakDuration;
            } else if (timer.currentPhase == :longBreak) {
                totalDuration = timer.config.longBreakDuration;
            }
        } else {
            // Custom
            if (timer.currentSectionIndex < timer.config.customSections.size()) {
                 totalDuration = timer.config.customSections[timer.currentSectionIndex]["duration"];
            }
        }
        
        if (totalDuration == 0) { totalDuration = 1; }
        
        var progress = 0;
        if (totalDuration > 0) {
            progress = timer.timeRemaining.toFloat() / totalDuration.toFloat();
        }
        
        // Draw background circle
        dc.setPenWidth(penWidth);
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(centerX, centerY, radius, Graphics.ARC_CLOCKWISE, 90, 90); // Full circle

        // Draw progress arc
        var phaseColor = (timer.currentPhase == :focus) ? Graphics.COLOR_GREEN : Graphics.COLOR_BLUE;
        dc.setColor(phaseColor, Graphics.COLOR_TRANSPARENT);
        
        if (progress > 0) {
            var angle = 360 * progress;
            dc.drawArc(centerX, centerY, radius, Graphics.ARC_CLOCKWISE, 90, 90 - angle);
        }

        // Draw Phase
        var phaseText = "FOCUS";
        if (timer.currentPhase == :shortBreak) {
            phaseText = "SHORT BREAK";
        } else if (timer.currentPhase == :longBreak) {
            phaseText = "LONG BREAK";
        }
        
        dc.setColor(phaseColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, centerY - 60, Graphics.FONT_MEDIUM, phaseText, Graphics.TEXT_JUSTIFY_CENTER);

        // Draw Current Time if enabled
        if (timer.config.showTime) {
            var clockTime = System.getClockTime();
            var is24Hour = System.getDeviceSettings().is24Hour;
            var timeString = "";
            
            if (is24Hour) {
                timeString = Lang.format("$1$:$2$", [clockTime.hour.format("%02d"), clockTime.min.format("%02d")]);
            } else {
                var hour = clockTime.hour;
                var ampm = "AM";
                if (hour >= 12) {
                    ampm = "PM";
                    if (hour > 12) {
                        hour -= 12;
                    }
                }
                if (hour == 0) {
                    hour = 12;
                }
                timeString = Lang.format("$1$:$2$ $3$", [hour, clockTime.min.format("%02d"), ampm]);
            }
            
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(centerX, centerY - 90, Graphics.FONT_XTINY, timeString, Graphics.TEXT_JUSTIFY_CENTER);
        }

        // Draw Time
        var hours = timer.timeRemaining / 3600;
        var minutes = (timer.timeRemaining % 3600) / 60;
        var seconds = timer.timeRemaining % 60;
        var timeStr;
        
        if (hours > 0) {
            timeStr = Lang.format("$1$:$2$:$3$", [hours.format("%d"), minutes.format("%02d"), seconds.format("%02d")]);
        } else {
            timeStr = Lang.format("$1$:$2$:$3$", [0, minutes.format("%02d"), seconds.format("%02d")]);
        }
        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, centerY, Graphics.FONT_NUMBER_MEDIUM, timeStr, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Draw Cycles
        var cyclesStr = "";
        if (timer.config.type == TimerConfig.TYPE_STANDARD) {
            cyclesStr = (timer.completedCycles + 1) + "/" + timer.config.cycles;
        } else {
            cyclesStr = (timer.currentSectionIndex + 1) + "/" + timer.config.customSections.size();
        }
        dc.drawText(centerX, centerY + 60, Graphics.FONT_SMALL, cyclesStr, Graphics.TEXT_JUSTIFY_CENTER);
        
        // Draw Status (Paused?)
        if (!timer.isRunning) {
             dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
             dc.drawText(centerX, centerY + 90, Graphics.FONT_XTINY, "PAUSED", Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    function onHide() as Void {
    }

}
