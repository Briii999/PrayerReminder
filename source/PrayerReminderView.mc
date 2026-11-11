import Toybox.Application;
import Toybox.Attention;
import Toybox.Graphics;
import Toybox.Time;
import Toybox.Timer;
import Toybox.WatchUi;

class PrayerReminderView extends WatchUi.View {
    var _timer;
    var _alert = null;
    var _alertUntil = 0;
    var _alertTime = 0;
    function initialize() { View.initialize(); }
    function onShow() {
        if (_timer == null) {
            _timer = new Timer.Timer();
            _timer.start(method(:tick), 1000, true);
        }
        tick();
    }
    // Keep checking while the menu is shown; app shutdown owns timer cleanup.
    function onHide() { }
    function stopTimer() {
        if (_timer != null) { _timer.stop(); _timer = null; }
    }
    function tick() as Void {
        var now = Time.now().value();
        if (PrayerSchedule.enabled()) {
            var due = PrayerSchedule.due(now);
            if (due != null) {
                Application.Storage.setValue("lastAlert", due[1]);
                _alert = "Waktu " + PrayerSchedule.names[due[0]];
                _alertUntil = now + 60;
                _alertTime = due[1];
                vibrate();
            }
        }
        WatchUi.requestUpdate();
    }
    function vibrate() {
        if (Attention has :vibrate) {
            Attention.vibrate([new Attention.VibeProfile(70, 500),
                new Attention.VibeProfile(0, 200), new Attention.VibeProfile(70, 500)]);
        }
    }
    // Center every label within its own band, using actual device font metrics.
    function centeredText(dc, x, y, font, text, color) {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y - dc.getFontHeight(font) / 2, font, text,
            Graphics.TEXT_JUSTIFY_CENTER);
    }

    function onUpdate(dc) {
        var w = dc.getWidth();
        var h = dc.getHeight();
        var now = Time.now().value();
        var next = PrayerSchedule.nextPrayer(now);
        var schedule = PrayerSchedule.times(PrayerSchedule.dayStart(now));
        var alerting = _alert != null && now < _alertUntil;
        var accent = 0x83D9C3;
        var muted = 0x929D9A;
        var white = 0xF2F5F4;
        dc.setColor(white, Graphics.COLOR_BLACK);
        dc.clear();

        // The current WITA clock is the primary information, including during alerts.
        centeredText(dc, w/2, h*0.115, Graphics.FONT_XTINY, "BANJARMASIN", muted);
        var name = alerting ? _alert : PrayerSchedule.names[next[0]];
        if (!alerting && next[1] >= PrayerSchedule.dayStart(now) + 86400) {
            name += " besok";
        }
        centeredText(dc, w/2, h*0.26, Graphics.FONT_NUMBER_MEDIUM,
            PrayerSchedule.clockText(now), white);
        centeredText(dc, w/2, h*0.375, Graphics.FONT_SMALL,
            alerting ? name : "Menuju " + name, accent);

        var remaining = next[1] - now;
        var hours = (remaining / 3600).toNumber();
        var minutes = ((remaining % 3600) / 60).toNumber();
        var countdown = hours > 0 ? hours.toString() + " jam " + minutes.toString() + " menit lagi" :
            (minutes > 0 ? minutes.toString() + " menit lagi" : "Kurang dari 1 menit");
        centeredText(dc, w/2, h*0.445, Graphics.FONT_XTINY,
            alerting ? "Telah masuk waktu salat" : countdown, muted);

        dc.setColor(0x273532, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(w*0.28, h*0.505, w*0.72, h*0.505);

        var rowHeight = h*0.065;
        var font = Graphics.FONT_XTINY;
        for (var i=0; i<5; i++) {
            var selected = alerting ? schedule[i] == _alertTime : schedule[i] == next[1];
            var centerY = h*0.555 + i*rowHeight;
            if (selected) {
                dc.setColor(0x142B25, Graphics.COLOR_TRANSPARENT);
                dc.fillRoundedRectangle(w*0.22, centerY-rowHeight/2,
                    w*0.56, rowHeight, 6);
                dc.setColor(accent, Graphics.COLOR_TRANSPARENT);
                dc.fillCircle(w*0.25, centerY, 2);
            }
            dc.setColor(selected ? accent : (schedule[i] < now ? muted : white),
                Graphics.COLOR_TRANSPARENT);
            var y = centerY - dc.getFontHeight(font)/2;
            dc.drawText(w*0.285, y, font, PrayerSchedule.names[i], Graphics.TEXT_JUSTIFY_LEFT);
            dc.drawText(w*0.74, y, font, PrayerSchedule.clockText(schedule[i]), Graphics.TEXT_JUSTIFY_RIGHT);
        }
        var status = PrayerSchedule.enabled() ? "Aktif" : "Mati";
        centeredText(dc, w/2, h*0.895, Graphics.FONT_XTINY,
            status + " | WITA | " + PrayerSchedule.correction().format("%+d") + "m", muted);
    }
}
