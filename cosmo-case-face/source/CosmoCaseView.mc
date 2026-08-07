import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.Timer;
import Toybox.WatchUi;

// ── Palette ──────────────────────────────────────────
const C_BG           = 0x0A0906;  // near-black backdrop
const C_AMBER         = 0xC97B22;  // cabinet body
const C_AMBER_HI      = 0xE0993A;  // cabinet highlight band
const C_AMBER_SHADOW  = 0x8C5416;  // cabinet shadow / recess
const C_CREAM         = 0xF5DFAF;  // plaques and icon buttons
const C_INK           = 0x3A2410;  // outlines and text
const C_INK_MUTED     = 0x8A6B4A;  // secondary text on dark
const C_DAY           = 0x8FD0E8;  // dome day sky
const C_NIGHT         = 0x1B2A4A;  // dome night sky
const C_SUN           = 0xFFD24D;  // sun / accent light
const C_MOON          = 0xE9EDF2;  // moon
const C_STAR          = 0xFFE9A8;  // star
const C_CARD_BG       = 0x1E1712;  // detail card background

const ICON_SLEEP     = 0;
const ICON_GESTURE   = 1;
const ICON_HYDRATION = 2;
const ICON_MUSIC     = 3;
const ICON_COUNT     = 4;

class CosmoCaseView extends WatchUi.WatchFace {

    private var _w as Number = 0;
    private var _h as Number = 0;
    private var _s as Number = 0;
    private var _ox as Number = 0;
    private var _oy as Number = 0;

    private var _iconCx as Array<Number> = [0, 0, 0, 0];
    private var _iconCy as Array<Number> = [0, 0, 0, 0];
    private var _iconSize as Number = 0;

    private var _activeIcon as Number = -1;
    private var _dismissTimer as Timer.Timer?;

    private var _iconTitles as Array<String> = [
        "Sleep", "Gestures", "Hydration", "Music"
    ];
    private var _iconLines as Array<Array<String> > = [
        ["Wear your device overnight.",
         "Your sleep score appears each",
         "morning in Garmin Connect."],
        ["Raise your wrist to wake the",
         "display. Turn this off in",
         "Settings, System, Gestures."],
        ["Log water in the Hydration",
         "widget in Garmin Connect to",
         "track your daily intake."],
        ["Add Music to your Controls",
         "menu to play, pause and",
         "skip from your wrist."]
    ];

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Dc) as Void {
        _w = dc.getWidth();
        _h = dc.getHeight();
        _s = (_w < _h) ? _w : _h;
        _ox = (_w - _s) / 2;
        _oy = (_h - _s) / 2;

        _iconSize = vs(0.12);
        var offX = 0.385;
        var topY = 0.425;
        var botY = 0.545;

        _iconCx = [vx(0.5 - offX), vx(0.5 - offX), vx(0.5 + offX), vx(0.5 + offX)];
        _iconCy = [vy(topY), vy(botY), vy(topY), vy(botY)];
    }

    function onUpdate(dc as Dc) as Void {
        if (dc has :setAntiAlias) {
            dc.setAntiAlias(true);
        }

        dc.setColor(C_BG, C_BG);
        dc.clear();

        drawDome(dc);
        drawBody(dc);
        drawBaseStrip(dc);
        drawIcons(dc);

        if (_activeIcon != -1) {
            drawDetailCard(dc);
        }
    }

    // ── Coordinate helpers: everything is laid out as a fraction ──
    // of a virtual square inscribed in the display, so the design
    // stays centered and legible on both round and rectangular watches.
    private function vx(f as Numeric) as Number {
        return (_ox + f * _s).toNumber();
    }

    private function vy(f as Numeric) as Number {
        return (_oy + f * _s).toNumber();
    }

    private function vs(f as Numeric) as Number {
        return (f * _s).toNumber();
    }

    // ── Dome (head): day sky / night sky split, sun and moon ──
    private function drawDome(dc as Dc) as Void {
        var cx = vx(0.5);
        var cy = vy(0.24);
        var r = vs(0.17);

        dc.setColor(C_NIGHT, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(cx, cy, r);

        dc.setClip(cx - r, cy - r, r, r * 2);
        dc.setColor(C_DAY, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(cx, cy, r);
        dc.clearClip();

        dc.setColor(C_SUN, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(cx - r * 45 / 100, cy - r * 10 / 100, r * 20 / 100);

        dc.setColor(C_MOON, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(cx + r * 45 / 100, cy - r * 10 / 100, r * 18 / 100);
        dc.setColor(C_STAR, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(cx + r * 65 / 100, cy + r * 30 / 100, r * 6 / 100);

        dc.setColor(C_INK, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawCircle(cx, cy, r);
        dc.setPenWidth(1);
    }

    // ── Body cabinet: date plaque, drawer pulls, time plaque ──
    private function drawBody(dc as Dc) as Void {
        var x0 = vx(0.22);
        var y0 = vy(0.38);
        var x1 = vx(0.78);
        var y1 = vy(0.84);
        var w = x1 - x0;
        var h = y1 - y0;
        var radius = vs(0.03);

        dc.setColor(C_AMBER_SHADOW, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(x0, y0, w, h, radius);
        dc.setColor(C_AMBER, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(x0, y0 + vs(0.015), w, h - vs(0.015), radius);
        dc.setColor(C_AMBER_HI, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(x0, y0, w, vs(0.03), radius);

        dc.setColor(C_INK, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawRoundedRectangle(x0, y0, w, h, radius);
        dc.setPenWidth(1);

        drawDatePlaque(dc);
        drawDrawerPulls(dc);
        drawTimePlaque(dc);
    }

    private function drawPlaque(dc as Dc, x0 as Number, y0 as Number, x1 as Number, y1 as Number) as Void {
        var radius = vs(0.015);
        dc.setColor(C_CREAM, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(x0, y0, x1 - x0, y1 - y0, radius);
        dc.setColor(C_INK, Graphics.COLOR_TRANSPARENT);
        dc.drawRoundedRectangle(x0, y0, x1 - x0, y1 - y0, radius);
    }

    private function drawDatePlaque(dc as Dc) as Void {
        var x0 = vx(0.26);
        var y0 = vy(0.41);
        var x1 = vx(0.74);
        var y1 = vy(0.485);
        drawPlaque(dc, x0, y0, x1, y1);

        var info = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var dateStr = Lang.format("$1$ $2$", [info.day_of_week, info.day]);

        dc.setColor(C_INK, Graphics.COLOR_TRANSPARENT);
        dc.drawText((x0 + x1) / 2, (y0 + y1) / 2, Graphics.FONT_XTINY, dateStr,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    private function drawDrawerPulls(dc as Dc) as Void {
        var sz = vs(0.075);
        var cy = vy(0.505) + sz / 2;
        var leftCx = vx(0.36);
        var centerCx = vx(0.5);
        var rightCx = vx(0.64);
        var radius = vs(0.01);

        drawSmallSquare(dc, leftCx, cy, sz, radius);
        drawSmallSquare(dc, rightCx, cy, sz, radius);

        dc.setColor(C_AMBER_SHADOW, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(centerCx - sz / 2, cy - sz / 2, sz, sz, radius);
        dc.setColor(C_INK, Graphics.COLOR_TRANSPARENT);
        dc.drawRoundedRectangle(centerCx - sz / 2, cy - sz / 2, sz, sz, radius);
        dc.setColor(C_SUN, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(centerCx, cy, sz * 22 / 100);
    }

    private function drawSmallSquare(dc as Dc, cx as Number, cy as Number, sz as Number, radius as Number) as Void {
        dc.setColor(C_CREAM, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(cx - sz / 2, cy - sz / 2, sz, sz, radius);
        dc.setColor(C_INK, Graphics.COLOR_TRANSPARENT);
        dc.drawRoundedRectangle(cx - sz / 2, cy - sz / 2, sz, sz, radius);
    }

    private function drawTimePlaque(dc as Dc) as Void {
        var x0 = vx(0.24);
        var y0 = vy(0.60);
        var x1 = vx(0.76);
        var y1 = vy(0.80);
        drawPlaque(dc, x0, y0, x1, y1);

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

        dc.setColor(C_INK, Graphics.COLOR_TRANSPARENT);
        dc.drawText((x0 + x1) / 2, (y0 + y1) / 2, Graphics.FONT_NUMBER_MEDIUM, timeStr,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    // ── Base strip: power light plus a battery-level light row ──
    private function drawBaseStrip(dc as Dc) as Void {
        var x0 = vx(0.30);
        var x1 = vx(0.70);
        var y0 = vy(0.845);
        var y1 = vy(0.915);
        var w = x1 - x0;
        var h = y1 - y0;
        var radius = h / 2;

        dc.setColor(C_AMBER_SHADOW, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(x0, y0, w, h, radius);
        dc.setColor(C_INK, Graphics.COLOR_TRANSPARENT);
        dc.drawRoundedRectangle(x0, y0, w, h, radius);

        var lightR = vs(0.014);
        var padding = vs(0.02);
        var lightCy = y0 + h / 2;
        var lightCx = x0 + padding + lightR;

        dc.setColor(C_SUN, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(lightCx, lightCy, lightR);

        var battery = System.getSystemStats().battery;
        var pct = (battery != null) ? battery : 0.0;
        var segCount = 5;
        var lit = ((pct * segCount / 100.0) + 0.5).toNumber();
        if (lit < 0) { lit = 0; }
        if (lit > segCount) { lit = segCount; }

        var segAreaX0 = lightCx + lightR + padding;
        var segGap = vs(0.01);
        var segW = (x1 - padding - segAreaX0 - segGap * (segCount - 1)) / segCount;
        var segH = h * 55 / 100;
        var segY = lightCy - segH / 2;
        var segRadius = vs(0.005);

        for (var i = 0; i < segCount; i++) {
            var sx = segAreaX0 + i * (segW + segGap);
            dc.setColor(i < lit ? C_SUN : C_AMBER, Graphics.COLOR_TRANSPARENT);
            dc.fillRoundedRectangle(sx, segY, segW, segH, segRadius);
        }
    }

    // ── Icon buttons: the four "apps" the user can tap to learn about ──
    private function drawIcons(dc as Dc) as Void {
        for (var i = 0; i < ICON_COUNT; i++) {
            drawIconButton(dc, i);
        }
    }

    private function drawIconButton(dc as Dc, index as Number) as Void {
        var cx = _iconCx[index];
        var cy = _iconCy[index];
        var sz = _iconSize;
        var radius = vs(0.02);

        dc.setColor((_activeIcon == index) ? C_SUN : C_CREAM, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(cx - sz / 2, cy - sz / 2, sz, sz, radius);
        dc.setColor(C_INK, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawRoundedRectangle(cx - sz / 2, cy - sz / 2, sz, sz, radius);
        dc.setPenWidth(1);

        if (index == ICON_SLEEP) {
            drawSleepGlyph(dc, cx, cy, sz);
        } else if (index == ICON_GESTURE) {
            drawHandGlyph(dc, cx, cy, sz);
        } else if (index == ICON_HYDRATION) {
            drawDropGlyph(dc, cx, cy, sz);
        } else {
            drawMusicGlyph(dc, cx, cy, sz);
        }
    }

    private function drawSleepGlyph(dc as Dc, cx as Number, cy as Number, sz as Number) as Void {
        dc.setColor(C_INK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx - sz * 15 / 100, cy + sz * 18 / 100, Graphics.FONT_TINY, "Z",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(cx + sz * 15 / 100, cy - sz * 18 / 100, Graphics.FONT_SMALL, "Z",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    private function drawHandGlyph(dc as Dc, cx as Number, cy as Number, sz as Number) as Void {
        dc.setColor(C_INK, Graphics.COLOR_TRANSPARENT);
        var radius = vs(0.01);
        var palmW = sz * 46 / 100;
        var palmH = sz * 34 / 100;
        var palmY = cy - sz * 2 / 100;
        dc.fillRoundedRectangle(cx - palmW / 2, palmY, palmW, palmH, radius);

        var fingerW = sz * 10 / 100;
        var fingerH = sz * 28 / 100;
        var gap = sz * 4 / 100;
        var startX = cx - palmW / 2 + fingerW / 2;
        for (var i = 0; i < 3; i++) {
            var fx = startX + i * (fingerW + gap);
            dc.fillRoundedRectangle(fx - fingerW / 2, palmY - fingerH + radius, fingerW, fingerH, radius);
        }

        var thumbW = sz * 12 / 100;
        var thumbH = sz * 16 / 100;
        dc.fillRoundedRectangle(cx - palmW / 2 - thumbW * 60 / 100, palmY + palmH * 30 / 100, thumbW, thumbH, radius);
    }

    private function drawDropGlyph(dc as Dc, cx as Number, cy as Number, sz as Number) as Void {
        dc.setColor(C_INK, Graphics.COLOR_TRANSPARENT);
        var r = sz * 22 / 100;
        var tipY = cy - sz * 30 / 100;
        var baseY = cy + sz * 6 / 100;
        var points = [[cx, tipY], [cx - r, baseY], [cx + r, baseY]] as Array<[Numeric, Numeric]>;
        dc.fillPolygon(points);
        dc.fillCircle(cx, baseY, r);
    }

    private function drawMusicGlyph(dc as Dc, cx as Number, cy as Number, sz as Number) as Void {
        dc.setColor(C_INK, Graphics.COLOR_TRANSPARENT);
        var noteR = sz * 14 / 100;
        var stemX = cx + sz * 10 / 100;
        var stemTopY = cy - sz * 28 / 100;
        var stemBottomY = cy + sz * 14 / 100;

        dc.fillCircle(cx - sz * 6 / 100, stemBottomY, noteR);
        dc.setPenWidth(sz * 8 / 100);
        dc.drawLine(stemX, stemTopY, stemX, stemBottomY);
        dc.setPenWidth(1);

        var flagPoints = [
            [stemX, stemTopY],
            [stemX + sz * 16 / 100, stemTopY + sz * 10 / 100],
            [stemX, stemTopY + sz * 20 / 100]
        ] as Array<[Numeric, Numeric]>;
        dc.fillPolygon(flagPoints);
    }

    // ── Detail card: the "learn about it" panel for a tapped icon ──
    private function drawDetailCard(dc as Dc) as Void {
        var x0 = vx(0.14);
        var y0 = vy(0.30);
        var x1 = vx(0.86);
        var y1 = vy(0.72);
        var w = x1 - x0;
        var h = y1 - y0;
        var radius = vs(0.04);

        dc.setColor(C_CARD_BG, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(x0, y0, w, h, radius);
        dc.setColor(C_SUN, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawRoundedRectangle(x0, y0, w, h, radius);
        dc.setPenWidth(1);

        var cx = (x0 + x1) / 2;
        var titleY = y0 + h * 18 / 100;

        dc.setColor(C_SUN, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, titleY, Graphics.FONT_SMALL, _iconTitles[_activeIcon],
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        var lines = _iconLines[_activeIcon];
        var lineY = titleY + h * 20 / 100;
        var lineStep = h * 17 / 100;

        dc.setColor(C_CREAM, Graphics.COLOR_TRANSPARENT);
        for (var i = 0; i < lines.size(); i++) {
            dc.drawText(cx, lineY + i * lineStep, Graphics.FONT_XTINY, lines[i],
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }

        var hintY = y1 - h * 10 / 100;
        dc.setColor(C_INK_MUTED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, hintY, Graphics.FONT_XTINY, "Tap to close",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    // ── Tap handling, called by CosmoCaseDelegate ──
    function handleTap(x as Number, y as Number) as Boolean {
        if (_activeIcon != -1) {
            closeDetail();
            return true;
        }

        for (var i = 0; i < ICON_COUNT; i++) {
            var dx = (x - _iconCx[i]).abs();
            var dy = (y - _iconCy[i]).abs();
            if (dx <= _iconSize / 2 && dy <= _iconSize / 2) {
                openDetail(i);
                return true;
            }
        }

        return false;
    }

    private function openDetail(index as Number) as Void {
        _activeIcon = index;

        if (_dismissTimer != null) {
            (_dismissTimer as Timer.Timer).stop();
        }
        _dismissTimer = new Timer.Timer();
        (_dismissTimer as Timer.Timer).start(method(:onDismissTimer), 4000, false);

        WatchUi.requestUpdate();
    }

    private function closeDetail() as Void {
        _activeIcon = -1;

        if (_dismissTimer != null) {
            (_dismissTimer as Timer.Timer).stop();
            _dismissTimer = null;
        }

        WatchUi.requestUpdate();
    }

    function onDismissTimer() as Void {
        closeDetail();
    }
}
