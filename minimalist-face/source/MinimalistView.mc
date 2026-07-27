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
import Toybox.Application;

class MinimalistView extends WatchUi.WatchFace {

    private var _w   as Number  = 0;
    private var _h   as Number  = 0;
    private var _cx  as Number  = 0;
    private var _cy  as Number  = 0;
    private var _r   as Number  = 0;
    private var _isSleeping as Boolean = false;

    // ── Accent palettes [primary, dim track] ─────────────────────────────────
    // 0=Gold  1=Ocean  2=Rose  3=Sage  4=Lavender
    private var _accentPrimary as Number = 0xC9A84C;
    private var _accentDim     as Number = 0x4A3A18;

    // ── Background ────────────────────────────────────────────────────────────
    // 0=Obsidian  1=Midnight  2=Slate  3=Charcoal
    private var _bgColor as Number = 0x060608;

    // ── Complication metric IDs ───────────────────────────────────────────────
    // 0=HR  1=Steps  2=Calories  3=Distance  4=Floors  5=Battery
    private var _leftMetric  as Number  = 0;
    private var _rightMetric as Number  = 1;

    private var _showSeconds as Boolean = true;
    private var _stepGoal    as Number  = 10000;

    function initialize() {
        WatchFace.initialize();
        loadSettings();
    }

    function onSettingsChanged() as Void {
        loadSettings();
        WatchUi.requestUpdate();
    }

    private function loadSettings() as Void {
        // Accent color
        var accentIdx = Application.Properties.getValue("AccentColor");
        var accentPalettes = [
            [0xC9A84C, 0x4A3A18],  // Gold
            [0x4BAEC9, 0x193D47],  // Ocean
            [0xC95E7B, 0x47192A],  // Rose
            [0x5BB88A, 0x1A4231],  // Sage
            [0x8B72C9, 0x2E1F4A],  // Lavender
        ];
        var ai = (accentIdx instanceof Number) ? (accentIdx as Number) : 0;
        if (ai < 0 || ai >= 5) { ai = 0; }
        var palette = accentPalettes[ai] as Array<Number>;
        _accentPrimary = palette[0];
        _accentDim     = palette[1];

        // Background
        var bgIdx = Application.Properties.getValue("BgColor");
        var bgColors = [0x060608, 0x0A0D14, 0x141926, 0x161618];
        var bi = (bgIdx instanceof Number) ? (bgIdx as Number) : 0;
        if (bi < 0 || bi >= 4) { bi = 0; }
        _bgColor = bgColors[bi];

        // Metrics
        var lm = Application.Properties.getValue("LeftMetric");
        _leftMetric = (lm instanceof Number) ? (lm as Number) : 0;

        var rm = Application.Properties.getValue("RightMetric");
        _rightMetric = (rm instanceof Number) ? (rm as Number) : 1;

        // Show seconds
        var ss = Application.Properties.getValue("ShowSeconds");
        _showSeconds = (ss instanceof Number) ? ((ss as Number) != 0) : true;

        // Step goal
        var sg = Application.Properties.getValue("StepGoal");
        var sgNum = (sg instanceof Number) ? (sg as Number) : 10000;
        _stepGoal = (sgNum > 0) ? sgNum : 10000;
    }

    function onLayout(dc as Dc) as Void {
        _w  = dc.getWidth();
        _h  = dc.getHeight();
        _cx = _w / 2;
        _cy = _h / 2;
        _r  = (_w < _h ? _w : _h) / 2 - 2;
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
        if (dc has :setAntiAlias) {
            dc.setAntiAlias(true);
        }
        var clock = System.getClockTime();

        drawBackground(dc);
        drawStepArc(dc);
        drawHourMarkers(dc);
        drawComplications(dc);
        drawDate(dc);
        drawHands(dc, clock);
    }

    // ── Background ────────────────────────────────────────────────────────────

    private function drawBackground(dc as Dc) as Void {
        dc.setColor(_bgColor, _bgColor);
        dc.clear();
    }

    // ── Step progress arc at outer edge ──────────────────────────────────────

    private function drawStepArc(dc as Dc) as Void {
        var info = ActivityMonitor.getInfo();
        var steps = (info.steps != null) ? info.steps as Number : 0;
        var frac = steps.toFloat() / _stepGoal.toFloat();
        if (frac > 1.0) { frac = 1.0; }
        var sweepDeg = (frac * 360.0).toNumber();

        var arcR = _r - 7;
        dc.setPenWidth(3);

        // Dim background track
        dc.setColor(_accentDim, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(_cx, _cy, arcR, Graphics.ARC_CLOCKWISE, 90, 90 - 359);

        // Filled progress (clockwise from 12 o'clock)
        if (sweepDeg > 0) {
            dc.setColor(_accentPrimary, Graphics.COLOR_TRANSPARENT);
            dc.drawArc(_cx, _cy, arcR, Graphics.ARC_CLOCKWISE, 90, 90 - sweepDeg);
        }

        // Small start-marker dot at 12 o'clock
        dc.setPenWidth(1);
        dc.setColor(_accentPrimary, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(_cx, _cy - arcR, 3);
    }

    // ── Hour markers ─────────────────────────────────────────────────────────

    private function drawHourMarkers(dc as Dc) as Void {
        for (var i = 0; i < 12; i++) {
            var angleRad = (i * 30 - 90) * Math.PI / 180.0;
            var isCardinal = (i % 3 == 0);

            var outerR  = _r - 13;
            var innerR  = isCardinal ? _r - 26 : _r - 18;
            var penW    = isCardinal ? 3 : 1;
            var color   = isCardinal ? _accentPrimary : 0x303034;

            dc.setColor(color, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(penW);
            dc.drawLine(
                (_cx + innerR * Math.cos(angleRad)).toNumber(),
                (_cy + innerR * Math.sin(angleRad)).toNumber(),
                (_cx + outerR * Math.cos(angleRad)).toNumber(),
                (_cy + outerR * Math.sin(angleRad)).toNumber()
            );
        }
        dc.setPenWidth(1);
    }

    // ── Clock hands ───────────────────────────────────────────────────────────

    private function drawHands(dc as Dc, clock as System.ClockTime) as Void {
        var hours   = clock.hour % 12;
        var minutes = clock.min;
        var seconds = clock.sec;

        var hourAngle = (hours * 30.0 + minutes * 0.5 - 90.0) * Math.PI / 180.0;
        var minAngle  = (minutes * 6.0 - 90.0) * Math.PI / 180.0;
        var secAngle  = (seconds * 6.0 - 90.0) * Math.PI / 180.0;

        var hourLen = (_r * 48 / 100).toNumber();
        var minLen  = (_r * 70 / 100).toNumber();
        var secLen  = (_r * 80 / 100).toNumber();
        var secTail = (_r * 20 / 100).toNumber();

        // ── Minute hand ──────────────────────────────────────────────────────
        dc.setPenWidth(2);
        dc.setColor(0xCCCCCC, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(
            (_cx - minLen * 0.10 * Math.cos(minAngle)).toNumber(),
            (_cy - minLen * 0.10 * Math.sin(minAngle)).toNumber(),
            (_cx + minLen * Math.cos(minAngle)).toNumber(),
            (_cy + minLen * Math.sin(minAngle)).toNumber()
        );

        // ── Hour hand: gray base + accent tip ────────────────────────────────
        dc.setPenWidth(4);
        dc.setColor(0xCCCCCC, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(
            (_cx - hourLen * 0.12 * Math.cos(hourAngle)).toNumber(),
            (_cy - hourLen * 0.12 * Math.sin(hourAngle)).toNumber(),
            (_cx + hourLen * Math.cos(hourAngle)).toNumber(),
            (_cy + hourLen * Math.sin(hourAngle)).toNumber()
        );
        // Accent covers outer 38%
        var tipStart = hourLen * 62 / 100;
        dc.setColor(_accentPrimary, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(4);
        dc.drawLine(
            (_cx + tipStart * Math.cos(hourAngle)).toNumber(),
            (_cy + tipStart * Math.sin(hourAngle)).toNumber(),
            (_cx + hourLen * Math.cos(hourAngle)).toNumber(),
            (_cy + hourLen * Math.sin(hourAngle)).toNumber()
        );

        // ── Second hand ──────────────────────────────────────────────────────
        if (!_isSleeping && _showSeconds) {
            dc.setPenWidth(1);
            dc.setColor(_accentPrimary, Graphics.COLOR_TRANSPARENT);
            // Tail with small counterbalance circle
            var txEnd = (_cx - secTail * Math.cos(secAngle)).toNumber();
            var tyEnd = (_cy - secTail * Math.sin(secAngle)).toNumber();
            dc.drawLine(
                txEnd, tyEnd,
                (_cx + secLen * Math.cos(secAngle)).toNumber(),
                (_cy + secLen * Math.sin(secAngle)).toNumber()
            );
            dc.fillCircle(txEnd, tyEnd, 3);
        }

        // ── Center cap ───────────────────────────────────────────────────────
        dc.setColor(_bgColor, _bgColor);
        dc.fillCircle(_cx, _cy, 7);
        dc.setColor(0xC0C0C0, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(_cx, _cy, 5);
        if (!_isSleeping && _showSeconds) {
            dc.setColor(_accentPrimary, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(_cx, _cy, 3);
        }
    }

    // ── Date label ───────────────────────────────────────────────────────────

    private function drawDate(dc as Dc) as Void {
        var now = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var months = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
                      "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];
        var mon = months[now.month - 1] as String;
        var dateStr = Lang.format("$1$ $2$", [mon, now.day]);

        dc.setColor(0x686870, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            _cx, _cy + _r * 53 / 100,
            Graphics.FONT_XTINY, dateStr,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    // ── Data complications at 9 & 3 o'clock ─────────────────────────────────

    private function drawComplications(dc as Dc) as Void {
        var compOffset = _r * 50 / 100;
        drawMetricAt(dc, _cx - compOffset, _cy, _leftMetric);
        drawMetricAt(dc, _cx + compOffset, _cy, _rightMetric);
    }

    // Metric IDs: 0=HR  1=Steps  2=Calories  3=Distance  4=Floors  5=Battery
    private function drawMetricAt(dc as Dc, x as Number, y as Number, id as Number) as Void {
        var label = "--";
        var value = "--";
        var info = ActivityMonitor.getInfo();

        if (id == 0) {
            label = "HR";
            value = getHeartRateStr();
        } else if (id == 1) {
            label = "STP";
            var s = (info.steps != null) ? info.steps as Number : 0;
            value = formatK(s);
        } else if (id == 2) {
            label = "CAL";
            var c = (info.calories != null) ? info.calories as Number : 0;
            value = c.toString();
        } else if (id == 3) {
            label = "KM";
            var d = (info.distance != null) ? info.distance as Number : 0;
            value = (d / 100000.0).format("%.1f");
        } else if (id == 4) {
            label = "FLR";
            var f = (info.floorsClimbed != null) ? info.floorsClimbed as Number : 0;
            value = f.toString();
        } else {
            label = "BAT";
            value = System.getSystemStats().battery.format("%d") + "%";
        }

        // Thin separator
        dc.setColor(0x252528, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawLine(x - 16, y, x + 16, y);

        // Label above line (accent, small)
        dc.setColor(_accentPrimary, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y - 10, Graphics.FONT_XTINY, label,
                    Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Value below line (light)
        dc.setColor(0xC0C0C0, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y + 10, Graphics.FONT_XTINY, value,
                    Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    private function getHeartRateStr() as String {
        var actInfo = Activity.getActivityInfo();
        if (actInfo != null && actInfo.currentHeartRate != null) {
            return actInfo.currentHeartRate.toString();
        }
        var it = ActivityMonitor.getHeartRateHistory(1, true);
        if (it != null) {
            var sample = it.next();
            if (sample != null && sample.heartRate != ActivityMonitor.INVALID_HR_SAMPLE) {
                return sample.heartRate.toString();
            }
        }
        return "--";
    }

    private function formatK(n as Number) as String {
        if (n >= 10000) {
            return (n / 1000.0).format("%.1f") + "k";
        }
        return n.toString();
    }
}
