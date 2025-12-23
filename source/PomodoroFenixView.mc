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

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Clear screen
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var app = Application.getApp();
        var timer = app.pomodoroTimer;

        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;
        var centerY = height / 2;

        // Draw Progress Arc
        var radius = (width < height ? width : height) / 2 - 5;
        var penWidth = 10;
        var totalDuration = timer.workDuration;
        if (timer.currentPhase == :shortBreak) {
            totalDuration = timer.shortBreakDuration;
        } else if (timer.currentPhase == :longBreak) {
            totalDuration = timer.longBreakDuration;
        }
        
        var progress = 0;
        if (totalDuration > 0) {
            progress = timer.timeRemaining.toFloat() / totalDuration.toFloat();
        }
        
        // Draw background circle
        dc.setPenWidth(penWidth);
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(centerX, centerY, radius, Graphics.ARC_CLOCKWISE, 90, 90); // Full circle

        // Draw progress arc
        var phaseColor = (timer.currentPhase == :work) ? Graphics.COLOR_GREEN : Graphics.COLOR_BLUE;
        dc.setColor(phaseColor, Graphics.COLOR_TRANSPARENT);
        
        if (progress > 0) {
            var angle = 360 * progress;
            // Note: drawArc angles are in degrees. 90 is 12 o'clock. 0 is 3 o'clock.
            // Clockwise: 90 -> 0 -> 270 -> 180.
            // So 90 - angle.
            
            dc.drawArc(centerX, centerY, radius, Graphics.ARC_CLOCKWISE, 90, 90 - angle);
        }

        // Draw Phase
        var phaseText = "WORK";
        if (timer.currentPhase == :shortBreak) {
            phaseText = "SHORT BREAK";
        } else if (timer.currentPhase == :longBreak) {
            phaseText = "LONG BREAK";
        }
        
        dc.setColor(phaseColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, centerY - 60, Graphics.FONT_MEDIUM, phaseText, Graphics.TEXT_JUSTIFY_CENTER);

        // Draw Current Time if enabled
        if (timer.showTime) {
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
        // Use a smaller font to fit HH:MM:SS
        dc.drawText(centerX, centerY, Graphics.FONT_NUMBER_MEDIUM, timeStr, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Draw Cycles
        var cyclesStr = (timer.completedCycles + 1) + "/" + timer.cycles;
        dc.drawText(centerX, centerY + 60, Graphics.FONT_SMALL, cyclesStr, Graphics.TEXT_JUSTIFY_CENTER);
        
        // Draw Status (Paused?)
        if (!timer.isRunning) {
             dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
             dc.drawText(centerX, centerY + 90, Graphics.FONT_XTINY, "PAUSED", Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

}
