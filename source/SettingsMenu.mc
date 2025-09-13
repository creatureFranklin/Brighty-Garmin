using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Application;
import Toybox.Lang;
using Toybox.System;

// ---------- Fixed item IDs (Symbol) ----------
class SettingsIds {
    public static const COLOR_IDS = [:color0, :color1, :color2, :color3, :color4, :color5];
    public static const TIMEOUT_IDS = [:timeout0, :timeout1, :timeout2, :timeout3, :timeout4, :timeout5, :timeout6];

    public static const ID_COLOR = :color; // main menu → color submenu (multiselect)
    public static const ID_SAVE_COLORS = :save; // main menu → color submenu "Save"
    public static const ID_HINTS = :hints; // main menu toggle
    public static const ID_TIMEOUT = :timeout; // main menu → timeout submenu
    public static const ID_BACK = :back; // universal "Back"

    public static const ID_DONATE = :donate;
}

class SettingsModel {
    public var colorLabels = ["White", "Green", "Red"];
    public var colorValues = [Graphics.COLOR_WHITE, Graphics.COLOR_GREEN, Graphics.COLOR_RED];

    public var timeoutLabels = ["Never", "5 s", "10 s", "30 s", "60 s"];
    public var timeoutValues = [0, 5, 10, 30, 60];

    // ---- Colors multiselect ----
    function getSelectedColors() {
        var arr = Application.getApp().getProperty("mainColors");
        if (arr == null) {
            arr = [Graphics.COLOR_WHITE]; // Default color
        }
        return arr;
    }

    function setSelectedColors(list) {
        Application.getApp().setProperty("mainColors", list);
    }

    function isColorSelected(val as Number) {
        var sel = getSelectedColors();
        for (var i = 0; i < sel.size(); i += 1) {
            if (sel[i] == val) {
                return true;
            }
        }
        return false;
    }

    function toggleColor(val as Number) {
        var sel = getSelectedColors();

        if (isColorSelected(val)) {
            sel.remove(val);
        } else {
            sel.add(val);
        }

        // Check if atleast one color
        if (sel.size() == 0) {
            sel.add(Graphics.COLOR_WHITE);
        }

        setSelectedColors(sel);
    }

    function colorsSummaryLabel() {
        var sel = getSelectedColors();
        var names = [];
        for (var i = 0; i < colorValues.size(); i += 1) {
            var cv = colorValues[i];
            var picked = false;
            for (var j = 0; j < sel.size(); j += 1) {
                if (sel[j] == cv) {
                    picked = true;
                    break;
                }
            }
            if (picked) {
                names.add(colorLabels[i]);
            }
        }
        if (names.size() == 0) {
            return "—";
        }
        if (names.size() <= 2) {
            return Utils.joinArray(names, ", ");
        }

        return names.size() + " " + Rez.Strings.selected;
    }

    /**
     * Kompatibilita se single-select
     */
    function getColor() {
        // returns first color from all selected colors
        var sel = getSelectedColors();
        return sel.size() > 0 ? sel[0] : Graphics.COLOR_WHITE;
    }
    function setColor(c) {
        setSelectedColors([c]);
    }

    function getHints() {
        var v = Application.getApp().getProperty("showHints");
        if (v == null) {
            v = true;
        }
        return v;
    }
    function setHints(on) {
        Application.getApp().setProperty("showHints", on);
    }

    function getAutoOff() {
        var v = Application.getApp().getProperty("autoOffSec");
        if (v == null) {
            v = 0;
        }
        return v;
    }

    function setAutoOff(sec) {
        Application.getApp().setProperty("autoOffSec", sec);
    }

    function indexOfValue(arr, value) {
        for (var i = 0; i < arr.size(); i += 1) {
            if (arr[i] == value) {
                return i;
            }
        }
        return 0;
    }
}

// ---------- Builder menu ----------
class SettingsMenuBuilder {
    private var model;

    function initialize() {
        model = new SettingsModel();
    }

    function buildMainMenu() {
        var m = new WatchUi.Menu();
        m.setTitle(Rez.Strings.settings);

        // Colors (multiselect) – show summary
        m.addItem(Rez.Strings.colors + ": " + model.colorsSummaryLabel(), SettingsIds.ID_COLOR);

        // Hints
        var hintsTxt = model.getHints() ? Rez.Strings.on : Rez.Strings.off;
        m.addItem(Rez.Strings.hints + ": " + hintsTxt, SettingsIds.ID_HINTS);

        // Auto-off
        var tIdx = model.indexOfValue(model.timeoutValues, model.getAutoOff());
        m.addItem(Rez.Strings.autoOff + ": " + model.timeoutLabels[tIdx], SettingsIds.ID_TIMEOUT);

        m.addItem(Rez.Strings.supportMe, SettingsIds.ID_DONATE);

        // m.addItem("Zpět", SettingsIds.ID_BACK);
        return m;
    }

    function buildColorMenu(currentSel as Array) {
        var m = new WatchUi.Menu();
        m.setTitle(Rez.Strings.colorsMultipleSelection);

        var n = model.colorLabels.size();
        if (n > SettingsIds.COLOR_IDS.size()) {
            n = SettingsIds.COLOR_IDS.size();
        }

        for (var i = 0; i < n; i += 1) {
            var val = model.colorValues[i];
            var picked = false;

            for (var j = 0; j < currentSel.size(); j += 1) {
                if (currentSel[j] == val) {
                    picked = true;
                    break;
                }
            }
            var mark = picked ? "[x] " : "[ ] ";
            m.addItem(mark + model.colorLabels[i], SettingsIds.COLOR_IDS[i]);
        }

        m.addItem(Rez.Strings.save, SettingsIds.ID_SAVE_COLORS);
        m.addItem(Rez.Strings.back, SettingsIds.ID_BACK);
        return m;
    }

    function buildTimeoutMenu() {
        var m = new WatchUi.Menu();
        m.setTitle(Rez.Strings.autoOff);

        var n = model.timeoutLabels.size();
        if (n > SettingsIds.TIMEOUT_IDS.size()) {
            n = SettingsIds.TIMEOUT_IDS.size();
        }

        for (var i = 0; i < n; i += 1) {
            m.addItem(model.timeoutLabels[i], SettingsIds.TIMEOUT_IDS[i]);
        }
        m.addItem(Rez.Strings.back, SettingsIds.ID_BACK);
        return m;
    }

    function refreshMainMenu() {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        var menu = buildMainMenu();
        var dlg = new SettingsMenuDelegate(self);
        WatchUi.pushView(menu, dlg, WatchUi.SLIDE_IMMEDIATE);
    }

    function refreshColorsMenu(currentSel as Array) {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        var menu = buildColorMenu(currentSel);
        var dlg = new ColorsMenuDelegate(self, currentSel);
        WatchUi.pushView(menu, dlg, WatchUi.SLIDE_IMMEDIATE);
    }
}

// ---------- Delegates ----------
class SettingsMenuDelegate extends WatchUi.MenuInputDelegate {
    private var builder;
    private var model;

    function initialize(b) {
        MenuInputDelegate.initialize();
        builder = b;
        model = new SettingsModel();
    }

    function onMenuItem(item) {
        var startSel = model.getSelectedColors();
        if (item == SettingsIds.ID_COLOR) {
            WatchUi.pushView(builder.buildColorMenu(startSel), new ColorsMenuDelegate(builder, startSel), WatchUi.SLIDE_LEFT);
            return;
        }
        if (item == SettingsIds.ID_SAVE_COLORS) {
            WatchUi.pushView(builder.buildColorMenu(startSel), new ColorsMenuDelegate(builder, startSel), WatchUi.SLIDE_LEFT);
            return;
        }
        if (item == SettingsIds.ID_HINTS) {
            model.setHints(!model.getHints());
            builder.refreshMainMenu();
            return;
        }
        if (item == SettingsIds.ID_TIMEOUT) {
            WatchUi.pushView(builder.buildTimeoutMenu(), new TimeoutMenuDelegate(builder), WatchUi.SLIDE_LEFT);
            return;
        }
        if (item == SettingsIds.ID_DONATE) {
            (new DonateHelper()).openBuyMeACoffee();
            return;
        }
        if (item == SettingsIds.ID_BACK) {
            WatchUi.popView(WatchUi.SLIDE_DOWN);
            return;
        }
    }

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }
}

class ColorsMenuDelegate extends WatchUi.MenuInputDelegate {
    private var builder;
    private var model;
    private var tempSel;

    function initialize(b, initialSel as Array) {
        MenuInputDelegate.initialize();
        builder = b;
        model = new SettingsModel();
        // Create a copy so that changes can be clicked/selected without being saved immediately
        tempSel = [];
        for (var i = 0; i < initialSel.size(); i += 1) {
            tempSel.add(initialSel[i]);
        }
    }

    function toggleInTemp(val as Number) {
        var idx = Utils.indexOfArray(tempSel, val);
        if (idx >= 0) {
            // remove
            var newArr = [];
            for (var i = 0; i < tempSel.size(); i += 1) {
                if (i != idx) {
                    newArr.add(tempSel[i]);
                }
            }
            tempSel = newArr;
        } else {
            // add
            tempSel.add(val);
        }
    }

    function onMenuItem(item) {
        // Save: confirm selections and return to the main menu
        if (item == SettingsIds.ID_SAVE_COLORS) {
            if (tempSel.size() == 0) {
                // always at least one color, default is white
                tempSel.add(Graphics.COLOR_WHITE);
            }
            model.setSelectedColors(tempSel);
            builder.refreshMainMenu();
            return;
        }

        // Back: discard changes (do not save) and return
        if (item == SettingsIds.ID_BACK) {
            builder.refreshMainMenu();
            return;
        }

        // Click on a color → toggle in tempSel and refresh THIS submenu
        var ids = SettingsIds.COLOR_IDS;
        var n = model.colorValues.size();
        if (n > ids.size()) {
            n = ids.size();
        }

        for (var i = 0; i < n; i += 1) {
            if (item == ids[i]) {
                toggleInTemp(model.colorValues[i]);
                builder.refreshColorsMenu(tempSel); // stay in the submenu, but redraw
                return;
            }
        }
    }

    function onBack() {
        builder.refreshMainMenu();
        return true;
    }
}

class TimeoutMenuDelegate extends WatchUi.MenuInputDelegate {
    private var builder;
    private var model;

    function initialize(b) {
        MenuInputDelegate.initialize();
        builder = b;
        model = new SettingsModel();
    }

    function onMenuItem(item) {
        if (item == SettingsIds.ID_BACK) {
            builder.refreshMainMenu();
            return;
        }

        var ids = SettingsIds.TIMEOUT_IDS;
        var n = model.timeoutValues.size();
        if (n > ids.size()) {
            n = ids.size();
        }

        for (var i = 0; i < n; i += 1) {
            if (item == ids[i]) {
                model.setAutoOff(model.timeoutValues[i]);
                builder.refreshMainMenu();
                return;
            }
        }
    }

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return true;
    }
}

class SettingsMenu {
    static function open() {
        var builder = new SettingsMenuBuilder();
        var menu = builder.buildMainMenu();
        var dlg = new SettingsMenuDelegate(builder);
        WatchUi.pushView(menu, dlg, WatchUi.SLIDE_UP);
    }
}

class SettingsService {
    static function _getBool(key as String, def as Boolean) as Boolean {
        try {
            return Application.Properties.getValue(key);
        } catch (e) {
            return def;
        }
    }

    static function _getNum(key as String, def as Number) as Number {
        try {
            return Application.Properties.getValue(key);
        } catch (e) {
            return def;
        }
    }

    static function _set(key as String, val) {
        try {
            Application.Properties.setValue(key, val);
        } catch (e) {
            // ignore on very old firmwares or background process
        }
    }

    // --- Bridge: booleans -> array of colors ---
    static function _composeSelectedColors() as Array {
        var res = [];
        if (_getBool("colorWhite", true)) {
            res.add(Graphics.COLOR_WHITE);
        }
        if (_getBool("colorGreen", false)) {
            res.add(Graphics.COLOR_GREEN);
        }
        if (_getBool("colorRed", false)) {
            res.add(Graphics.COLOR_RED);
        }
        if (res.size() == 0) {
            res.add(Graphics.COLOR_WHITE);
        }
        return res;
    }

    static function getSelectedColors() as Array {
        return _composeSelectedColors();
    }

    static function getPrimaryColor() {
        var arr = getSelectedColors();
        return arr[0];
    }

    static function getHintsEnabled() as Boolean {
        return _getBool("showHints", true);
    }

    static function getAutoOffSeconds() as Number {
        return _getNum("autoOffSec", 0);
    }

    static function toggleColor(color as Number) {
        if (color == Graphics.COLOR_WHITE) {
            _set("colorWhite", !_getBool("colorWhite", true));
        } else if (color == Graphics.COLOR_GREEN) {
            _set("colorGreen", !_getBool("colorGreen", false));
        } else if (color == Graphics.COLOR_RED) {
            _set("colorRed", !_getBool("colorRed", false));
        }

        var arr = _composeSelectedColors();
        if (arr.size() == 0) {
            _set("colorWhite", true);
        }
    }

    static function setHintsEnabled(on as Boolean) {
        _set("showHints", on);
    }

    static function setAutoOffSeconds(sec as Number) {
        _set("autoOffSec", sec);
    }

    // If you want to keep anything in cache, put it here and call it from onSettingsChanged()
    static function refreshCacheFromProperties() {
        // for simplicity we do nothing – always read directly from Properties
    }
}
