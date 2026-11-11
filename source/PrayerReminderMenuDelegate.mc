import Toybox.Application;
import Toybox.Attention;
import Toybox.WatchUi;
class PrayerReminderMenuDelegate extends WatchUi.MenuInputDelegate {
    function initialize() { MenuInputDelegate.initialize(); }
    function onMenuItem(item) {
        if (item == :toggle) {
            Application.Properties.setValue("reminders", !PrayerSchedule.enabled());
        } else if (item == :plus || item == :minus) {
            var correction = PrayerSchedule.correction() + (item == :plus ? 1 : -1);
            if (correction >= -15 && correction <= 15) {
                Application.Properties.setValue("correction", correction);
            }
        } else if (item == :test) {
            if (Attention has :vibrate) {
                Attention.vibrate([new Attention.VibeProfile(70, 500),
                    new Attention.VibeProfile(0, 200), new Attention.VibeProfile(70, 500)]);
            }
        }
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        WatchUi.requestUpdate();
    }
}
