class BacklightKeepAlive {
    var _timer;
    private const BACKLIGHT_KEEPALIVE_MS = 4000;

    function start() as Void {
        stop();
        if (!SettingsService.getAllowBacklight()) {
            return;
        }
        if (!SettingsService.getBacklightKeepAlive()) {
            return;
        }

        turnOnBacklightRespectingSettings();
        _timer = new Toybox.Timer.Timer();
        _timer.start(method(:_tick), BACKLIGHT_KEEPALIVE_MS, true);
    }

    function stop() as Void {
        if (_timer != null) {
            _timer.stop();
            _timer = null;
        }
    }

    function _tick() as Void {
        turnOnBacklightRespectingSettings();
    }

    public static function turnOnBacklightRespectingSettings() as Void {
        if (SettingsService.getAllowBacklight()) {
            Utils.turnOnBacklight(1.0, 2);
        }
    }
}
