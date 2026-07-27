import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.ActivityMonitor;
import Toybox.Activity;
import Toybox.UserProfile;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.Math;

// ── Vaporwave palette ────────────────────────────────
const C_BG        = 0x1A0033;  // deep purple night
const C_BG_LOWER  = 0x2D0A4E;  // horizon glow
const C_GRID      = 0xFF2D95;  // hot magenta grid
const C_SUN_TOP   = 0xFFD319;  // sun gradient top
const C_SUN_MID   = 0xFF901F;
const C_SUN_LOW   = 0xFF2975;
const C_CYAN      = 0x00F0FF;  // neon cyan
const C_PINK      = 0xFF71CE;
const C_LAVENDER  = 0xB967FF;
const C_WHITE     = 0xFFFFFF;

class VaporwaveView extends WatchUi.WatchFace {

    private var _w as Number = 0;
    private var _h as Number = 0;
    private var _isSleeping as Boolean = false;

    function initialize() {
        WatchFace.initialize();
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
        // Anti-aliasing where supported
        if (dc has :setAntiAlias) {
            dc.setAntiAlias(true);
        }

        drawBackground(dc);
        drawSun(dc);
        drawGrid(dc);
        drawTime(dc);
        drawDate(dc);
        drawMetrics(dc);
    }

    // ── Background ───────────────────────────────────
    private function drawBackground(dc as Dc) as Void {
        dc.setColor(C_BG, C_BG);
        dc.clear();
        // lower half slightly lighter for horizon glow
        dc.setColor(C_BG_LOWER, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(0, _h * 55 / 100, _w, _h);
    }

    // ── Retro sun with scanline slats ────────────────
    private function drawSun(dc as Dc) as Void {
        var cx = _w / 2;
        var cy = _h * 56 / 100;          // sun sits on the horizon
        var r  = _w * 22 / 100;

        // banded gradient: draw shrinking circles
        dc.setColor(C_SUN_LOW, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(cx, cy, r);
        dc.setColor(C_SUN_MID, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(cx, cy, r * 3 / 4);
        dc.setColor(C_SUN_TOP, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(cx, cy, r / 2);

        // horizontal slats cut into the lower half of the sun
        dc.setColor(C_BG_LOWER, Graphics.COLOR_TRANSPARENT);
        var slatY = cy;
        var slatH = 2;
        var gap = 4;
        while (slatY < cy + r) {
            dc.fillRectangle(cx - r, slatY, r * 2, slatH);
            slatY += gap;
            gap += 2;      // slats spread apart toward the bottom
            slatH += 1;
        }

        // clip everything below the horizon line
        dc.setColor(C_BG_LOWER, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(0, cy + (r * 55 / 100), _w, r);
    }

    // ── Perspective grid ─────────────────────────────
    private function drawGrid(dc as Dc) as Void {
        var horizonY = _h * 62 / 100;
        var vpX = _w / 2;                // vanishing point x

        dc.setPenWidth(1);
        dc.setColor(C_GRID, Graphics.COLOR_TRANSPARENT);

        // horizontal lines, spacing widens toward bottom
        var y = horizonY;
        var step = 4;
        while (y < _h) {
            dc.drawLine(0, y, _w, y);
            y += step;
            step += 3;
        }

        // radiating vertical lines from vanishing point
        var n = 9;
        for (var i = 0; i <= n; i++) {
            var xBottom = (_w * i / n) * 15 / 10 - (_w / 4);
            dc.drawLine(vpX, horizonY, xBottom, _h);
        }

        // horizon line, brighter
        dc.setPenWidth(2);
        dc.setColor(C_CYAN, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(0, horizonY, _w, horizonY);
        dc.setPenWidth(1);
    }

    // ── Time ─────────────────────────────────────────
    private function drawTime(dc as Dc) as Void {
        var clock = System.getClockTime();
        var hour = clock.hour;
        var is24 = System.getDeviceSettings().is24Hour;
        if (!is24) {
            hour = hour % 12;
            if (hour == 0) { hour = 12; }
        }
        var timeStr = Lang.format("$1$:$2$", [
            hour.format(is24 ? "%02d" : "%d"),
            clock.min.format("%02d")
        ]);

        var y = _h * 26 / 100;

        // neon glow: pink offset shadow behind cyan text (chromatic aberration vibe)
        dc.setColor(C_PINK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_w / 2 + 2, y + 2, Graphics.FONT_NUMBER_THAI_HOT,
                    timeStr, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(C_CYAN, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_w / 2, y, Graphics.FONT_NUMBER_THAI_HOT,
                    timeStr, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    private function drawDate(dc as Dc) as Void {
        var now = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var dateStr = Lang.format("$1$ $2$ $3$", [now.day_of_week, now.month, now.day]);
        dc.setColor(C_LAVENDER, Graphics.COLOR_TRANSPARENT);
        dc.drawText(_w / 2, _h * 9 / 100, Graphics.FONT_XTINY,
                    dateStr, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    // ── Metrics: HR, steps, active/passive cals, VO2max ──
    private function drawMetrics(dc as Dc) as Void {
        var info = ActivityMonitor.getInfo();
        var profile = UserProfile.getProfile();

        // Heart rate
        var hr = getHeartRate();
        var hrStr = (hr != null) ? hr.toString() : "--";

        // Steps
        var steps = (info.steps != null) ? info.steps : 0;

        // Calories: total from Garmin, split into passive (BMR-based) + active
        var totalCal = (info.calories != null) ? info.calories : 0;
        var passiveCal = estimatePassiveCalories(profile);
        var activeCal = totalCal - passiveCal;
        if (activeCal < 0) { activeCal = 0; }

        // VO2max
        var vo2 = null;
        if (profile has :vo2maxRunning) {
            vo2 = profile.vo2maxRunning;
        }
        var vo2Str = (vo2 != null) ? vo2.toString() : "--";

        var font = Graphics.FONT_XTINY;

        // Row above the sun: HR (left) and steps (right)
        var rowY = _h * 44 / 100;
        drawLabeledValue(dc, _w * 22 / 100, rowY, "HR", hrStr, C_PINK, font);
        drawLabeledValue(dc, _w * 78 / 100, rowY, "STEPS", formatK(steps), C_CYAN, font);

        // Bottom rows over the grid
        var botY1 = _h * 74 / 100;
        var botY2 = _h * 86 / 100;
        drawLabeledValue(dc, _w * 32 / 100, botY1, "ACT", activeCal.toString(), C_SUN_TOP, font);
        drawLabeledValue(dc, _w * 68 / 100, botY1, "PAS", passiveCal.toString(), C_LAVENDER, font);
        drawLabeledValue(dc, _w / 2, botY2, "VO2", vo2Str, C_WHITE, font);
    }

    private function drawLabeledValue(dc as Dc, x as Number, y as Number,
                                      label as String, value as String,
                                      color as Number, font as FontDefinition) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y - 10, font, label, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(C_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y + 10, font, value, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    private function getHeartRate() as Number? {
        var actInfo = Activity.getActivityInfo();
        if (actInfo != null && actInfo.currentHeartRate != null) {
            return actInfo.currentHeartRate;
        }
        // fall back to most recent HR sample
        var it = ActivityMonitor.getHeartRateHistory(1, true);
        if (it != null) {
            var sample = it.next();
            if (sample != null && sample.heartRate != ActivityMonitor.INVALID_HR_SAMPLE) {
                return sample.heartRate;
            }
        }
        return null;
    }

    // Garmin only exposes total daily calories in the watchface API.
    // Passive (resting) is estimated via Mifflin-St Jeor BMR prorated
    // over the elapsed part of the day; active = total - passive.
    // This mirrors what most third-party faces do.
    private function estimatePassiveCalories(profile as UserProfile.Profile) as Number {
        var weightKg = 75.0;
        var heightCm = 175.0;
        var age = 30;
        var isMale = true;

        if (profile.weight != null) { weightKg = profile.weight / 1000.0; }  // grams → kg
        if (profile.height != null) { heightCm = profile.height.toFloat(); } // cm
        if (profile.birthYear != null) {
            var year = Gregorian.info(Time.now(), Time.FORMAT_SHORT).year;
            age = year - profile.birthYear;
        }
        if (profile.gender != null) {
            isMale = (profile.gender == UserProfile.GENDER_MALE);
        }

        var bmr = 10.0 * weightKg + 6.25 * heightCm - 5.0 * age + (isMale ? 5.0 : -161.0);

        var clock = System.getClockTime();
        var secToday = clock.hour * 3600 + clock.min * 60 + clock.sec;
        return (bmr * secToday / 86400.0).toNumber();
    }

    private function formatK(n as Number) as String {
        if (n >= 10000) {
            return (n / 1000.0).format("%.1f") + "k";
        }
        return n.toString();
    }
}
