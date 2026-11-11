import Toybox.Test;
import Toybox.Application;

(:test)
function witaAndRollover(logger) {
    Application.Properties.setValue("correction", 2);
    // 2026-09-25 00:00 WITA = 2026-09-24 16:00 UTC.
    var start = 1790265600;
    Test.assertEqual(PrayerSchedule.dayStart(start), start);
    Test.assertEqual(PrayerSchedule.dayStart(start-1), start-86400);
    Test.assertEqual(PrayerSchedule.clockText(start), "00:00");
    var today = PrayerSchedule.times(start);
    var next = PrayerSchedule.nextPrayer(today[4]);
    Test.assertEqual(next[0], 0);
    Test.assertEqual(next[1], PrayerSchedule.times(start+86400)[0]);
    Test.assertEqual(PrayerSchedule.nextPrayer(today[0]-1)[0], 0);
    Test.assertEqual(PrayerSchedule.nextPrayer(today[0])[0], 1);
    return true;
}

(:test)
function yearlySchedule(logger) {
    Application.Properties.setValue("correction", 2);
    // Cover an entire leap year, including year rollover.
    var start = 1830268800;
    for (var day=0; day<367; day++) {
        var midnight = start + day*86400;
        var times = PrayerSchedule.times(midnight);
        Test.assertEqual(times.size(), 5);
        Test.assert(times[0] > midnight+4*3600 && times[0] < midnight+6*3600);
        Test.assert(times[4] > midnight+18*3600 && times[4] < midnight+21*3600);
        for (var i=1; i<5; i++) { Test.assert(times[i]-times[i-1] > 300); }
    }
    return true;
}

(:test)
function correctionAndDeduplication(logger) {
    var savedCorrection = Application.Properties.getValue("correction");
    var savedAlert = Application.Storage.getValue("lastAlert");
    Application.Properties.setValue("correction", 0);
    var baseline = PrayerSchedule.times(1790265600);
    Application.Properties.setValue("correction", 5);
    var adjusted = PrayerSchedule.times(1790265600);
    for (var i=0; i<5; i++) { Test.assertEqual(adjusted[i]-baseline[i], 300); }
    Application.Storage.deleteValue("lastAlert");
    Test.assert(PrayerSchedule.due(adjusted[0]-1) == null);
    Test.assert(PrayerSchedule.due(adjusted[0]) != null);
    Test.assert(PrayerSchedule.due(adjusted[0]+299) != null);
    Test.assert(PrayerSchedule.due(adjusted[0]+300) == null);
    Application.Storage.setValue("lastAlert", adjusted[0]);
    Test.assert(PrayerSchedule.due(adjusted[0]) == null);
    Application.Properties.setValue("correction", savedCorrection);
    if (savedAlert == null) { Application.Storage.deleteValue("lastAlert"); }
    else { Application.Storage.setValue("lastAlert", savedAlert); }
    return true;
}
