import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Application;
import Toybox.Graphics;



class BlackPicker extends WatchUi.Picker {
    function initialize(options) {
        Picker.initialize(options);
    }
    
    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        Picker.onUpdate(dc);
    }
}

class PomodoroFenixMenuDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as MenuItem) as Void {
        var id = item.getId();
        var app = Application.getApp();
        var timer = app.pomodoroTimer;

        if (id == :infiniteMode) {
            timer.infiniteMode = (item as ToggleMenuItem).isEnabled();
        } else if (id == :vibration) {
            timer.vibration = (item as ToggleMenuItem).isEnabled();
        } else if (id == :sound) {
            timer.sound = (item as ToggleMenuItem).isEnabled();
        } else if (id == :workTime) {
             var initialValue = timer.workDuration;
             var h = initialValue / 3600;
             var m = (initialValue % 3600) / 60;
             var s = initialValue % 60;
             
             var factories = [new TimeFactory(0, 23, 1, :hours), new TimeFactory(0, 59, 1, :minutes), new TimeFactory(0, 59, 1, :seconds)];
             var defaults = [h, m, s];
             
             WatchUi.pushView(new BlackPicker({
                 :title=>new WatchUi.Text({:text=>"Work Time", :locX=>WatchUi.LAYOUT_HALIGN_CENTER, :locY=>WatchUi.LAYOUT_VALIGN_BOTTOM, :color=>Graphics.COLOR_WHITE}),
                 :pattern=>factories,
                 :defaults=>defaults
             }), new TimePickerDelegate(method(:onWorkTimePicked), item), WatchUi.SLIDE_IMMEDIATE);
        } else if (id == :breakTime) {
             var initialValue = timer.breakDuration;
             var h = initialValue / 3600;
             var m = (initialValue % 3600) / 60;
             var s = initialValue % 60;
             
             var factories = [new TimeFactory(0, 23, 1, :hours), new TimeFactory(0, 59, 1, :minutes), new TimeFactory(0, 59, 1, :seconds)];
             var defaults = [h, m, s];

             WatchUi.pushView(new BlackPicker({
                 :title=>new WatchUi.Text({:text=>"Break Time", :locX=>WatchUi.LAYOUT_HALIGN_CENTER, :locY=>WatchUi.LAYOUT_VALIGN_BOTTOM, :color=>Graphics.COLOR_WHITE}),
                 :pattern=>factories,
                 :defaults=>defaults
             }), new TimePickerDelegate(method(:onBreakTimePicked), item), WatchUi.SLIDE_IMMEDIATE);
        } else if (id == :cycles) {
             var initialValue = timer.cycles;
             var factory = new NumberFactory(1, 20, 1);
             var index = factory.getIndex(initialValue);
             WatchUi.pushView(new BlackPicker({
                 :title=>new WatchUi.Text({:text=>"Cycles", :locX=>WatchUi.LAYOUT_HALIGN_CENTER, :locY=>WatchUi.LAYOUT_VALIGN_BOTTOM, :color=>Graphics.COLOR_WHITE}),
                 :pattern=>[factory],
                 :defaults=>[index]
             }), new NumberPickerDelegate(method(:onCyclesPicked), item), WatchUi.SLIDE_IMMEDIATE);
        }
    }

    function onWorkTimePicked(values, item) {
        var app = Application.getApp();
        var seconds = (values[0] as Number) * 3600 + (values[1] as Number) * 60 + (values[2] as Number);
        app.pomodoroTimer.setWorkDuration(seconds);
        item.setSubLabel(formatDuration(seconds));
    }

    function onBreakTimePicked(values, item) {
        var app = Application.getApp();
        var seconds = (values[0] as Number) * 3600 + (values[1] as Number) * 60 + (values[2] as Number);
        app.pomodoroTimer.setBreakDuration(seconds);
        item.setSubLabel(formatDuration(seconds));
    }

    function formatDuration(seconds) {
        var h = seconds / 3600;
        var m = (seconds % 3600) / 60;
        var s = seconds % 60;
        if (h > 0) {
            return Lang.format("$1$:$2$:$3$", [h, m.format("%02d"), s.format("%02d")]);
        } else {
            return Lang.format("$1$:$2$", [m, s.format("%02d")]);
        }
    }

    function onCyclesPicked(value, item) {
        var app = Application.getApp();
        app.pomodoroTimer.cycles = value;
        item.setSubLabel(value + "");
    }

}

class TimePickerDelegate extends WatchUi.PickerDelegate {
    var _callback;
    var _item;
    function initialize(callback, item) {
        PickerDelegate.initialize();
        _callback = callback;
        _item = item;
    }
    function onCancel() {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        return true;
    }
    function onAccept(values) {
        _callback.invoke(values, _item);
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        return true;
    }
}

class LabeledTimeItem extends WatchUi.Drawable {
    var _number;
    var _label;

    function initialize(number, label) {
        Drawable.initialize({});
        _number = number;
        _label = label;
    }

    function draw(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;
        var centerY = height / 2;

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        
        // Draw number right-aligned to center minus a small padding
        dc.drawText(centerX - 2, centerY, Graphics.FONT_NUMBER_MEDIUM, _number, Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
        
        // Draw label left-aligned to center plus a small padding
        dc.drawText(centerX + 2, centerY, Graphics.FONT_SMALL, _label, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
    }
}

class TimeFactory extends WatchUi.PickerFactory {
    var _start;
    var _stop;
    var _increment;
    var _type;

    function initialize(start, stop, increment, type) {
        PickerFactory.initialize();
        _start = start;
        _stop = stop;
        _increment = increment;
        _type = type;
    }

    function getIndex(value) {
        return (value - _start) / _increment;
    }

    function getSize() {
        return (_stop - _start) / _increment + 1;
    }

    function getValue(index) {
        return _start + (index * _increment);
    }

    function getDrawable(index, selected) {
        var val = getValue(index);
        var str = (val as Number).format("%02d");
        var label = "s";
        if (_type == :hours) { 
            str = (val as Number).format("%d"); 
            label = "h";
        } else if (_type == :minutes) {
            label = "m";
        }
        
        return new LabeledTimeItem(str, label);
    }
}



class NumberPickerDelegate extends WatchUi.PickerDelegate {
    var _callback;
    var _item;
    function initialize(callback, item) {
        PickerDelegate.initialize();
        _callback = callback;
        _item = item;
    }
    function onCancel() {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        return true;
    }
    function onAccept(values) {
        _callback.invoke(values[0], _item);
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        return true;
    }
}

class NumberFactory extends WatchUi.PickerFactory {
    var _start;
    var _stop;
    var _increment;

    function initialize(start, stop, increment) {
        PickerFactory.initialize();
        _start = start;
        _stop = stop;
        _increment = increment;
    }

    function getIndex(value) {
        return (value - _start) / _increment;
    }

    function getSize() {
        return (_stop - _start) / _increment + 1;
    }

    function getValue(index) {
        return _start + (index * _increment);
    }

    function getDrawable(index, selected) {
        return new WatchUi.Text({
            :text=>(getValue(index) as Number).format("%d"),
            :color=>Graphics.COLOR_WHITE,
            :font=>Graphics.FONT_NUMBER_MEDIUM,
            :locX=>WatchUi.LAYOUT_HALIGN_CENTER,
            :locY=>WatchUi.LAYOUT_VALIGN_CENTER
        });
    }
}