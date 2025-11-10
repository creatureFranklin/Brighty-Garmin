using Toybox.Application;
using Toybox.Graphics;
using Toybox.WatchUi;
using Toybox.System;

class BrightyApp extends Application.AppBase {
    public var activeView as FlashlightView?;

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) {}

    function getInitialView() {
        var activeView = new FlashlightView();
        var d = new BrightyDelegate(activeView);
        return [activeView, d];
    }

    function onSettingsChanged() {
        // Recalculate local cache of settings (if you keep any)
        SettingsService.refreshCacheFromProperties();

        if (activeView != null) {
            activeView.resyncBacklightKA();
        }

        // If you are in settings on the watch or in the main view, refresh the UI
        WatchUi.requestUpdate();
    }
}
