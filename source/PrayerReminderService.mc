import Toybox.Application;
import Toybox.Background;
import Toybox.System;
import Toybox.Time;

(:background)
class PrayerReminderService extends System.ServiceDelegate {
    function initialize() { ServiceDelegate.initialize(); }
    function onTemporalEvent() {
        if (PrayerSchedule.enabled()) {
            var prayer = PrayerSchedule.due(Time.now().value());
            if (prayer != null) {
                Background.requestApplicationWake("Waktu " + PrayerSchedule.names[prayer[0]] +
                    " - " + PrayerSchedule.clockText(prayer[1]) + " WITA");
                Application.Storage.setValue("lastAlert", prayer[1]);
            }
        }
        PrayerSchedule.schedule();
        Background.exit(null);
    }
}
