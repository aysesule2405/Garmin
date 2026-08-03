import Toybox.Activity;
import Toybox.ActivityMonitor;
import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;

const STAT_STEPS    = 0;
const STAT_HR       = 1;
const STAT_CALORIES = 2;

const SOURCE_WIDTH  = 263;
const SOURCE_HEIGHT = 438;
const DATA_CELLS = 7;

class HarvestPixelsView extends WatchUi.WatchFace {

    private var _w as Number = 0;
    private var _h as Number = 0;
    private var _statSetting as Number = STAT_STEPS;

    private var _background as Graphics.BitmapReference?;
    private var _fontLarge as WatchUi.FontResource?;
    private var _fontSmall as WatchUi.FontResource?;

    function initialize() {
        WatchFace.initialize();
        loadSettings();

        // The supplied artwork is the face. Nothing in it is redrawn in code.
        _background = WatchUi.loadResource(
            Rez.Drawables.HarvestBackground
        ) as Graphics.BitmapReference;

        // Generated from advanced_pixel-7.ttf.
        _fontLarge = WatchUi.loadResource(
            Rez.Fonts.PixelFontLarge
        ) as WatchUi.FontResource;
        _fontSmall = WatchUi.loadResource(
            Rez.Fonts.PixelFontSmall
        ) as WatchUi.FontResource;
    }

    function onSettingsChanged() as Void {
        loadSettings();
        WatchUi.requestUpdate();
    }

    private function loadSettings() as Void {
        var stat = Application.Properties.getValue("Stat");
        _statSetting = (stat instanceof Number) ? stat : STAT_STEPS;
    }

    function onLayout(dc as Dc) as Void {
        _w = dc.getWidth();
        _h = dc.getHeight();
    }

    function onUpdate(dc as Dc) as Void {
        if (dc has :setAntiAlias) {
            dc.setAntiAlias(false);
        }

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        drawReferenceArtwork(dc);
        drawDay(dc);
        drawSideStats(dc);
        drawTime(dc);
        drawSelectedData(dc);
    }

    private function artWidth() as Number {
        return (_background as Graphics.BitmapReference).getWidth();
    }

    private function artHeight() as Number {
        return (_background as Graphics.BitmapReference).getHeight();
    }

    private function artX() as Number {
        return (_w - artWidth()) / 2;
    }

    private function artY() as Number {
        return (_h - artHeight()) / 2;
    }

    private function sourceX(value as Number) as Number {
        return artX() + ((value * artWidth()) / SOURCE_WIDTH);
    }

    private function sourceY(value as Number) as Number {
        return artY() + ((value * artHeight()) / SOURCE_HEIGHT);
    }

    private function drawReferenceArtwork(dc as Dc) as Void {
        dc.drawBitmap(artX(), artY(), _background);
    }

    private function drawTextAt(
        dc as Dc,
        x as Number,
        y as Number,
        text as String
    ) as Void {
        dc.setColor(0x6A2A12, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            x,
            y,
            _fontLarge,
            text,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    private function drawSmallTextAt(
        dc as Dc,
        x as Number,
        y as Number,
        text as String
    ) as Void {
        dc.setColor(0x6A2A12, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            x,
            y,
            _fontSmall,
            text,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    // First blank board: weekday.
    private function drawDay(dc as Dc) as Void {
        var dayNames = [
            "SUNDAY", "MONDAY", "TUESDAY", "WEDNESDAY",
            "THURSDAY", "FRIDAY", "SATURDAY"
        ];
        var info = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var dayIndex = (info.day_of_week as Number) - 1;
        if (dayIndex < 0 || dayIndex >= dayNames.size()) {
            dayIndex = 0;
        }

        drawTextAt(dc, sourceX(131), sourceY(181), dayNames[dayIndex]);
    }

    // Next large blank board: current time.
    private function drawTime(dc as Dc) as Void {
        var clock = System.getClockTime();
        var hour = clock.hour;
        var is24Hour = System.getDeviceSettings().is24Hour;

        if (!is24Hour) {
            hour = hour % 12;
            if (hour == 0) { hour = 12; }
        }

        var timeString = Lang.format("$1$:$2$", [
            hour.format(is24Hour ? "%02d" : "%d"),
            clock.min.format("%02d")
        ]);

        drawTextAt(dc, sourceX(131), sourceY(316), timeString);
    }

    // The two small boards flanking the center icon: heart rate and battery,
    // always visible regardless of what the user picked for the bottom board.
    private function drawSideStats(dc as Dc) as Void {
        drawSmallTextAt(dc, sourceX(66), sourceY(250), getHeartRateString());

        var battery = System.getSystemStats().battery;
        var batteryPct = (battery != null) ? battery.toNumber() : 0;
        drawSmallTextAt(dc, sourceX(195), sourceY(250), batteryPct.toString());
    }

    // The segmented bottom rectangles are reserved for the selected data.
    private function drawSelectedData(dc as Dc) as Void {
        var activity = ActivityMonitor.getInfo();
        var value = "0";

        if (_statSetting == STAT_HR) {
            value = getHeartRateString();
        } else if (_statSetting == STAT_CALORIES) {
            var calories = (activity.calories != null) ? activity.calories : 0;
            value = calories.toString();
        } else {
            var steps = (activity.steps != null) ? activity.steps : 0;
            value = steps.toString();
        }

        if (value.length() > DATA_CELLS) {
            value = value.substring(
                value.length() - DATA_CELLS,
                value.length()
            );
        }

        var firstCell = DATA_CELLS - value.length();
        for (var i = 0; i < value.length(); i++) {
            var cellCenter = sourceX(45 + ((firstCell + i) * 29));
            var character = value.substring(i, i + 1);
            drawSmallTextAt(dc, cellCenter, sourceY(410), character);
        }
    }

    private function getHeartRateString() as String {
        var activity = Activity.getActivityInfo();
        if (activity != null && activity.currentHeartRate != null) {
            return activity.currentHeartRate.toString();
        }

        var history = ActivityMonitor.getHeartRateHistory(1, true);
        if (history != null) {
            var sample = history.next();
            if (sample != null &&
                sample.heartRate != ActivityMonitor.INVALID_HR_SAMPLE) {
                return sample.heartRate.toString();
            }
        }

        return "NA";
    }
}
