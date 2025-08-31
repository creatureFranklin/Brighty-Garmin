import Toybox.Lang;
import Toybox.WatchUi;

class BrightyDelegate extends WatchUi.InputDelegate {
    var _view;

    function initialize(v as WatchUi.View) {
        WatchUi.InputDelegate.initialize();
        _view = v;
    }

    // pass the keys to the View
    function onKey(keyEvent as WatchUi.KeyEvent) as Lang.Boolean {
        return _view.onKey(keyEvent.getKey());
    }
}
