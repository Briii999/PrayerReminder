import Toybox.Application;
import Toybox.Background;
import Toybox.Math;
import Toybox.Lang;
import Toybox.Time;

// Fixed location: central Banjarmasin, UTC+8. No GPS or phone required.
(:background)
module PrayerSchedule {
    const OFFSET = 28800;
    const LAT = -3.3194;
    const LON = 114.5908;
    const RAD = 0.017453292519943295;
    var names as Array<String> = ["Subuh", "Zuhur", "Asar", "Magrib", "Isya"];

    function dayStart(epoch) {
        return ((epoch + OFFSET) / 86400).toNumber() * 86400 - OFFSET;
    }
    function enabled() {
        return Application.Properties.getValue("reminders") == true;
    }
    function correction() {
        var value = Application.Properties.getValue("correction");
        if (value == null || value < -15 || value > 15) { return 2; }
        return value;
    }
    function normalize(degrees) {
        return degrees - Math.floor(degrees / 360.0) * 360.0;
    }
    function sin(degrees) { return Math.sin(degrees * RAD); }
    function cos(degrees) { return Math.cos(degrees * RAD); }
    function hourAngle(altitude, declination) {
        var v = (sin(altitude) - sin(LAT) * sin(declination)) /
            (cos(LAT) * cos(declination));
        return Math.acos(v) / RAD / 15.0;
    }
    function times(start) as Array<Number> {
        // Solar coordinates at local noon; days from J2000 noon UTC.
        // Work directly with epoch days to avoid Julian-date Float precision loss.
        var d = (start.toDouble() + 43200.0d - 946728000.0d) / 86400.0d;
        var g = normalize(357.529 + 0.98560028 * d);
        var q = normalize(280.459 + 0.98564736 * d);
        var l = normalize(q + 1.915 * sin(g) + 0.020 * sin(2 * g));
        var e = 23.439 - 0.00000036 * d;
        var ra = normalize(Math.atan2(cos(e) * sin(l), cos(l)) / RAD) / 15.0;
        var eq = q / 15.0 - ra;
        if (eq > 12) { eq -= 24; }
        if (eq < -12) { eq += 24; }
        var dec = Math.asin(sin(e) * sin(l)) / RAD;
        var noon = 12.0 + 8.0 - LON / 15.0 - eq;
        // Subuh -20 degrees, Isya -18 degrees; Asar shadow factor 1.
        var asar = Math.atan(1.0 / (1.0 + Math.tan((LAT - dec).abs() * RAD))) / RAD;
        var hours = [noon - hourAngle(-20.0, dec), noon,
            noon + hourAngle(asar, dec), noon + hourAngle(-0.833, dec),
            noon + hourAngle(-18.0, dec)];
        var result = [] as Array<Number>;
        for (var i = 0; i < 5; i++) {
            result.add(start + (Math.ceil(hours[i] * 60).toNumber() + correction()) * 60);
        }
        return result;
    }
    function nextPrayer(now) as Array<Number> {
        var start = dayStart(now);
        var today = times(start);
        for (var i = 0; i < 5; i++) {
            if (today[i] > now) { return [i, today[i]]; }
        }
        return [0, times(start + 86400)[0]];
    }
    function clockText(epoch) {
        var minutes = ((epoch + OFFSET) % 86400) / 60;
        return (minutes / 60).toNumber().format("%02d") + ":" +
            (minutes % 60).toNumber().format("%02d");
    }
    function due(now) as Array<Number>? {
        var today = times(dayStart(now));
        for (var i = 0; i < 5; i++) {
            // Late delivery grace: do not show stale reminders after a long delay.
            if (now >= today[i] && now - today[i] < 300 &&
                Application.Storage.getValue("lastAlert") != today[i]) {
                return [i, today[i]];
            }
        }
        return null;
    }
    function schedule() {
        if (!enabled()) { Background.deleteTemporalEvent(); return; }
        var next = nextPrayer(Time.now().value());
        var eventTime = next[1];
        var last = Background.getLastTemporalEventTime();
        if (last != null && eventTime < last.value() + 300) {
            eventTime = last.value() + 300;
        }
        Background.registerForTemporalEvent(new Time.Moment(eventTime));
    }
}
