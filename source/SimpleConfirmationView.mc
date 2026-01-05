import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Lang;

class SimpleConfirmationView extends WatchUi.View {
    var message;
    
    function initialize(msg) {
        View.initialize();
        message = msg;
    }
    
    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        
        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;
        var centerY = height / 2;
        
        // Draw Message
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX, centerY, Graphics.FONT_MEDIUM, message, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        
        // Draw Confirm Hint (Green Check at 2 o'clock / Start button)
        // 2 o'clock is -30 degrees from 3 o'clock (0).
        // Using polar coordinates or just approximate placement.
        // Fenix 8 is round.
        
        // Confirm (Start Button - Top Right)
        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        // Draw a small arc or circle segment
        // dc.drawArc(centerX, centerY, width/2 - 2, Graphics.ARC_CLOCKWISE, 45, 15);
        
        // Draw Checkmark icon or text
        // Using simple text for now as drawing icons requires coordinates
        // Start button is usually around 30-45 degrees (1-2 o'clock)
        var startX = centerX + (width/2 * 0.85 * Math.cos(Math.toRadians(-30))); // -30 for 2 o'clock
        var startY = centerY + (height/2 * 0.85 * Math.sin(Math.toRadians(-30)));
        
        dc.drawText(startX, startY, Graphics.FONT_SMALL, "Confirm", Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
        
        // Cancel (Back Button - Bottom Right or Bottom Left depending on device)
        // Fenix 8 Back is usually Bottom Right (4-5 o'clock) or Bottom Left (8 o'clock)?
        // Standard 5-button layout:
        // Light (Top Left), Up (Mid Left), Down (Bot Left), Start (Top Right), Back (Bot Right)
        // So Back is Bottom Right (~4-5 o'clock).
        
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        var backX = centerX + (width/2 * 0.85 * Math.cos(Math.toRadians(30))); // 30 for 4 o'clock
        var backY = centerY + (height/2 * 0.85 * Math.sin(Math.toRadians(30)));
        
        dc.drawText(backX, backY, Graphics.FONT_SMALL, "Cancel", Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
    }
}

class SimpleConfirmationDelegate extends WatchUi.BehaviorDelegate {
    var callback;
    
    function initialize(cb) {
        BehaviorDelegate.initialize();
        callback = cb;
    }
    
    function onKey(keyEvent) {
        var key = keyEvent.getKey();
        if (key == WatchUi.KEY_ENTER || key == WatchUi.KEY_START) {
            callback.invoke(true);
            return true;
        } else if (key == WatchUi.KEY_ESC || key == WatchUi.KEY_LAP) { // Back button often maps to ESC or LAP
             callback.invoke(false);
             return true;
        }
        return false;
    }
    
    function onBack() {
        callback.invoke(false);
        return true;
    }
}
