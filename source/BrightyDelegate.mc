import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.System;
using Toybox.Application as App;

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

    function onTap(clickEvent as WatchUi.ClickEvent) as Boolean {
        return _view.onTap(clickEvent);
    }

    function onBack() as Boolean {
        Utils.turnOnBacklight(1.0, 0);
        System.exit();
    }
}
