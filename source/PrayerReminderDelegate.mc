import Toybox.WatchUi;
class PrayerReminderDelegate extends WatchUi.BehaviorDelegate {
    function initialize() { BehaviorDelegate.initialize(); }
    function onMenu() {
        WatchUi.pushView(new Rez.Menus.MainMenu(), new PrayerReminderMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }
    function onSelect() { return onMenu(); }
}
