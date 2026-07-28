import Toybox.Activity;
import Toybox.ActivityMonitor;
import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;

// Season options.
const SEASON_AUTO   = 0;
const SEASON_SPRING = 1;
const SEASON_SUMMER = 2;
const SEASON_AUTUMN = 3;
const SEASON_WINTER = 4;

// User-selectable value shown in the segmented counter.
const STAT_STEPS    = 0;
const STAT_HR       = 1;
const STAT_CALORIES = 2;

// The reference art is rebuilt on this logical grid so its hard pixel edges
// stay crisp on every supported screen size.
const GRID = 48;

class HarvestPixelsView extends WatchUi.WatchFace {

    private var _w as Number = 0;
    private var _h as Number = 0;
    private var _isSleeping as Boolean = false;

    private var _seasonSetting as Number = 0;
    private var _statSetting as Number = 0;
    private var _stepGoal as Number = 10000;

    private var _fontLarge as WatchUi.FontResource?;
    private var _fontSmall as WatchUi.FontResource?;

    function initialize() {
        WatchFace.initialize();
        loadSettings();

        // Both resources are generated from advanced_pixel-7.ttf.
        _fontLarge = WatchUi.loadResource(Rez.Fonts.PixelFontLarge) as WatchUi.FontResource;
        _fontSmall = WatchUi.loadResource(Rez.Fonts.PixelFontSmall) as WatchUi.FontResource;
    }

    function onSettingsChanged() as Void {
        loadSettings();
        WatchUi.requestUpdate();
    }

    private function loadSettings() as Void {
        var season = Application.Properties.getValue("Season");
        _seasonSetting = (season instanceof Number) ? season : SEASON_AUTO;

        var stat = Application.Properties.getValue("Stat");
        _statSetting = (stat instanceof Number) ? stat : STAT_STEPS;

        var goal = Application.Properties.getValue("StepGoal");
        var goalNumber = (goal instanceof Number) ? goal : 10000;
        _stepGoal = (goalNumber > 0) ? goalNumber : 10000;
    }

    function onLayout(dc as Dc) as Void {
        _w = dc.getWidth();
        _h = dc.getHeight();
    }

    function onEnterSleep() as Void {
        _isSleeping = true;
        WatchUi.requestUpdate();
    }

    function onExitSleep() as Void {
        _isSleeping = false;
        WatchUi.requestUpdate();
    }

    function onUpdate(dc as Dc) as Void {
        // Crisp edges are intentional: every shape belongs to the pixel grid.
        if (dc has :setAntiAlias) {
            dc.setAntiAlias(false);
        }

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        drawClockTower(dc);
        drawDay(dc);
        drawTime(dc);
        drawSelectedData(dc);
    }

    // ── Scaled pixel-grid helpers ────────────────────────────────────────

    private function canvasSize() as Number {
        return (_w < _h) ? _w : _h;
    }

    private function gridX(col as Numeric) as Number {
        var size = canvasSize();
        var offset = (_w - size) / 2;
        return (offset + (col * size.toFloat() / GRID)).toNumber();
    }

    private function gridY(row as Numeric) as Number {
        var size = canvasSize();
        var offset = (_h - size) / 2;
        return (offset + (row * size.toFloat() / GRID)).toNumber();
    }

    private function px(
        dc as Dc,
        col as Numeric,
        row as Numeric,
        colSpan as Number,
        rowSpan as Number,
        color as Number
    ) as Void {
        var x = gridX(col);
        var y = gridY(row);
        var x2 = gridX(col + colSpan);
        var y2 = gridY(row + rowSpan);
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(x, y, x2 - x, y2 - y);
    }

    private function drawTextAt(
        dc as Dc,
        col as Numeric,
        row as Numeric,
        font as WatchUi.FontResource?,
        text as String,
        color as Number
    ) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            gridX(col),
            gridY(row),
            font,
            text,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    // Palette order: sky light, sky shade, sun, tile blue, tile pink, leaf.
    private function seasonPalette(season as Number) as Array<Number> {
        switch (season) {
            case SEASON_SPRING:
                return [0xA8ECF3, 0x78C9E6, 0xFFF06A, 0x66E5F1, 0xFF70C8, 0x55C56A];
            case SEASON_SUMMER:
                return [0x74D8F0, 0x4BAED8, 0xFFE65A, 0x35DCEB, 0xF258B7, 0x36A950];
            case SEASON_AUTUMN:
                return [0xF7C77E, 0xE08A4F, 0xFFD65A, 0x75C7D5, 0xE96D78, 0x8AA447];
            case SEASON_WINTER:
                return [0xB7D9EA, 0x738EB8, 0xF1F2E8, 0x89DAE6, 0xC48ED4, 0x7BAE9B];
            default:
                return [0xA8ECF3, 0x78C9E6, 0xFFF06A, 0x66E5F1, 0xFF70C8, 0x55C56A];
        }
    }

    private function currentSeason() as Number {
        if (_seasonSetting != SEASON_AUTO) {
            return _seasonSetting;
        }

        var now = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var month = now.month;
        if (month == 12 || month == 1 || month == 2) { return SEASON_WINTER; }
        if (month >= 3 && month <= 5) { return SEASON_SPRING; }
        if (month >= 6 && month <= 8) { return SEASON_SUMMER; }
        return SEASON_AUTUMN;
    }

    // ── Clock-tower artwork ──────────────────────────────────────────────

    private function drawClockTower(dc as Dc) as Void {
        var palette = seasonPalette(currentSeason());

        // Fixed wood and parchment colors sampled from the reference mood.
        var outline = 0x4B1D18;
        var shadow = 0x8F3908;
        var wood = 0xD76806;
        var gold = 0xF59A08;
        var highlight = 0xFFC02A;
        var paper = _isSleeping ? 0xD39B50 : 0xFFD27A;
        var paperLight = _isSleeping ? 0xDFB06A : 0xFFE09A;

        // Narrow arched sky window, matching the centered reference artwork.
        px(dc, 21, 4, 6, 1, outline);
        px(dc, 18, 5, 12, 1, outline);
        px(dc, 16, 6, 16, 2, outline);
        px(dc, 15, 8, 18, 9, outline);
        px(dc, 21, 4, 6, 1, wood);
        px(dc, 18, 5, 12, 1, wood);
        px(dc, 17, 6, 14, 2, wood);
        px(dc, 16, 8, 16, 9, wood);
        px(dc, 18, 6, 12, 1, palette[0]);
        px(dc, 17, 7, 14, 9, palette[0]);
        px(dc, 17, 12, 14, 4, palette[1]);

        // Pixel sun and moon, matching the two-tone day/night window.
        px(dc, 19, 9, 3, 3, palette[2]);
        px(dc, 18, 10, 5, 1, palette[2]);
        px(dc, 27, 9, 3, 3, 0xF4F2E7);
        px(dc, 26, 10, 5, 1, 0xF4F2E7);
        px(dc, 30, 12, 1, 1, 0xD8E7ED);
        px(dc, 31, 14, 1, 1, 0xD8E7ED);

        // Golden clock hand and arrow over the window.
        px(dc, 23, 7, 3, 1, outline);
        px(dc, 22, 8, 5, 1, outline);
        px(dc, 23, 6, 3, 1, gold);
        px(dc, 24, 5, 1, 1, highlight);
        px(dc, 24, 8, 1, 7, outline);
        px(dc, 25, 8, 1, 7, highlight);
        px(dc, 23, 15, 4, 1, outline);
        px(dc, 22, 16, 6, 1, shadow);

        // Main wooden cabinet.
        px(dc, 12, 16, 24, 20, outline);
        px(dc, 11, 18, 26, 17, outline);
        px(dc, 13, 16, 22, 20, wood);
        px(dc, 12, 18, 24, 17, wood);
        px(dc, 13, 17, 22, 1, highlight);
        px(dc, 13, 35, 22, 1, shadow);

        // Upper blank board: weekday.
        drawWoodPanel(dc, 13, 18, 22, 6, outline, gold, paper, paperLight);

        // Three decorative tiles copied from the reference's middle row.
        drawWoodPanel(dc, 14, 24, 7, 6, outline, gold, palette[3], palette[0]);
        drawWoodPanel(dc, 21, 24, 6, 6, outline, gold, 0xE87905, 0xF4A20B);
        drawWoodPanel(dc, 27, 24, 7, 6, outline, gold, palette[4], 0xEE8CD0);

        // Sun mosaic in the left tile.
        px(dc, 16, 26, 3, 2, palette[2]);
        px(dc, 17, 25, 1, 4, palette[2]);
        px(dc, 15, 25, 1, 1, 0xFFF8A0);
        px(dc, 19, 28, 1, 1, 0xFFF8A0);

        // Flower/harvest mosaic in the right tile.
        px(dc, 29, 26, 3, 2, 0xFFFFFF);
        px(dc, 30, 25, 1, 4, 0xFFFFFF);
        px(dc, 30, 27, 1, 1, 0xFFD54A);
        px(dc, 28, 28, 2, 1, palette[5]);
        px(dc, 31, 28, 2, 1, palette[5]);

        // Lower blank board: time.
        drawWoodPanel(dc, 13, 30, 22, 6, outline, gold, paper, paperLight);

        // Narrow legs that connect the cabinet to the segmented data counter.
        px(dc, 16, 36, 2, 3, outline);
        px(dc, 17, 36, 1, 3, wood);
        px(dc, 31, 36, 2, 3, outline);
        px(dc, 31, 36, 1, 3, wood);

        drawDataCounter(dc, outline, wood, gold, paper, paperLight);
    }

    private function drawWoodPanel(
        dc as Dc,
        col as Number,
        row as Number,
        width as Number,
        height as Number,
        outline as Number,
        border as Number,
        fill as Number,
        fillLight as Number
    ) as Void {
        px(dc, col, row, width, height, outline);
        px(dc, col + 1, row + 1, width - 2, height - 2, border);
        px(dc, col + 2, row + 2, width - 4, height - 4, fill);
        px(dc, col + 2, row + 2, width - 4, 1, fillLight);
    }

    private function drawDataCounter(
        dc as Dc,
        outline as Number,
        wood as Number,
        gold as Number,
        paper as Number,
        paperLight as Number
    ) as Void {
        // Rounded-by-pixels ornamental end caps.
        px(dc, 12, 38, 24, 5, outline);
        px(dc, 11, 39, 26, 3, outline);
        px(dc, 13, 38, 22, 5, wood);
        px(dc, 12, 39, 24, 3, gold);

        // Seven light cells form one continuous selectable-data counter.
        for (var i = 0; i < 7; i++) {
            var cellX = 14 + (i * 3);
            px(dc, cellX, 38, 3, 5, outline);
            px(dc, cellX + 1, 39, 2, 4, paper);
            px(dc, cellX + 1, 39, 2, 1, paperLight);
        }
    }

    // ── Live content ─────────────────────────────────────────────────────

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

        drawTextAt(dc, 24, 21.0, _fontLarge, dayNames[dayIndex], 0x6A2A12);
    }

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

        drawTextAt(dc, 24, 33.0, _fontLarge, timeString, 0x6A2A12);
    }

    private function drawSelectedData(dc as Dc) as Void {
        var activity = ActivityMonitor.getInfo();
        var label = "STP";
        var value = "0";

        if (_statSetting == STAT_HR) {
            label = "BPM";
            value = getHeartRateString();
        } else if (_statSetting == STAT_CALORIES) {
            label = "CAL";
            var calories = (activity.calories != null) ? activity.calories : 0;
            value = calories.toString();
        } else {
            var steps = (activity.steps != null) ? activity.steps : 0;
            value = steps.toString();
        }

        // The center tile identifies the user's selected metric; its value is
        // reserved for the seven-cell counter at the very bottom.
        drawTextAt(dc, 24, 27.0, _fontSmall, label, 0x6A2A12);
        drawCounterValue(dc, value);
    }

    private function drawCounterValue(dc as Dc, value as String) as Void {
        var visible = value;
        if (visible.length() > 7) {
            visible = visible.substring(visible.length() - 7, visible.length());
        }

        var firstCell = 7 - visible.length();
        for (var i = 0; i < visible.length(); i++) {
            var cellCenter = 15.5 + ((firstCell + i) * 3);
            var character = visible.substring(i, i + 1);
            drawTextAt(dc, cellCenter, 40.5, _fontLarge, character, 0x6A2A12);
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
            if (sample != null && sample.heartRate != ActivityMonitor.INVALID_HR_SAMPLE) {
                return sample.heartRate.toString();
            }
        }

        return "NA";
    }
}
