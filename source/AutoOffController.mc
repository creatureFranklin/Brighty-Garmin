using Toybox.Timer as Timer;
using Toybox.Attention as Attention;
using Toybox.Graphics;
import Toybox.Lang;

class AutoOffController {
    private var _timer as Timer.Timer?;
    private var _applyColor as Method; // (Number color) => void
    private var _vibrateOnExp as Boolean;

    function initialize(applyColorFn as Method, vibrateOnExpire as Boolean) {
        _timer = new Timer.Timer();
        _applyColor = applyColorFn;
        _vibrateOnExp = vibrateOnExpire;
    }

    /**
     * Stop current timer
     */
    function cancel() {
        if (_timer != null) {
            _timer.stop();
        }
    }

    /**
     * Rearms the timer according to SettingsService.getAutoOffSeconds();
     * If the currentColor is black, the timer WILL NOT START.
     */
    function rearm(currentColor as Number) {
        cancel();

        // Never count down on black color
        if (currentColor == Graphics.COLOR_BLACK) {
            return;
        }

        var sec = SettingsService.getAutoOffSeconds();
        if (sec <= 0) {
            return; // auto-off disabled
        }

        _timer.start(method(:_onExpire), sec * 1000, false);
    }

    /**
     * Private callback after time expires
     */
    function _onExpire() as Void {
        var colors = SettingsService.getSelectedColors();

        if (_applyColor != null) {
            _applyColor.invoke(colors.size() - 1);
        }

        if (_vibrateOnExp) {
            try {
                Attention.vibrate([new Attention.VibeProfile(50, 1000)]);
            } catch (e) {}
        }
    }
}
