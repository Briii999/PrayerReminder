import Toybox.Application;
import Toybox.Background;
import Toybox.WatchUi;

(:background)
class PrayerReminderApp extends Application.AppBase {
    var _view = null;
    function initialize() { AppBase.initialize(); }
    function onStart(state) { Background.deleteTemporalEvent(); }
    function onStop(state) {
        if (_view != null) { _view.stopTimer(); }
        PrayerSchedule.schedule();
    }
    function getInitialView() {
        _view = new PrayerReminderView();
        return [_view, new PrayerReminderDelegate()];
    }
    function getServiceDelegate() { return [new PrayerReminderService()]; }
    function onSettingsChanged() {
        // Foreground timer handles reminders while app is running.
        Background.deleteTemporalEvent();
        WatchUi.requestUpdate();
    }
}
