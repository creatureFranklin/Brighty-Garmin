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

    public var timeoutLabels = ["Never", "10 s", "30 s", "60 s", "120 s"];
    public var timeoutValues = [0, 10, 30, 60, 120];

    // ---- Colors multiselect ----
    function getSelectedColors() {
        return SettingsService.getSelectedColors();
    }

    function setSelectedColors(list) {
        SettingsService.setSelectedColorsList(list as Array<Number>);
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

    function colorsSummaryLabel() as String {
        var sel = getSelectedColors();
        var names = [] as Array<String>;

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

        var n = names.size();
        if (n == 0) {
            return "—";
        }
        if (n <= 2) {
            return Utils.joinArray(names, ", ");
        }

        return names[0] + ", " + names[1] + " +" + (n - 2).toString();
    }

    function getColor() {
        // returns first color from all selected colors
        var sel = getSelectedColors();
        return sel.size() > 0 ? sel[0] : Graphics.COLOR_WHITE;
    }
    function setColor(c) {
        setSelectedColors([c]);
    }

    function getHints() {
        return SettingsService.getHintsEnabled();
    }

    function setHints(on) {
        SettingsService.setHintsEnabled(on);
    }

    function getAutoOff() {
        return SettingsService.getAutoOffSeconds();
    }

    function setAutoOff(sec) {
        SettingsService.setAutoOffSeconds(sec);
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

    function buildMainMenu() as WatchUi.Menu2 {
        var m = new WatchUi.Menu2({
            :title => Rez.Strings.settings,
        });

        m.addItem(new WatchUi.MenuItem(Rez.Strings.colors, model.colorsSummaryLabel() as String, SettingsIds.ID_COLOR, null));

        var hintsRes = model.getHints() ? "On" : "Off";
        m.addItem(new WatchUi.MenuItem(Rez.Strings.hints, hintsRes, SettingsIds.ID_HINTS, null));

        var tIdx = model.indexOfValue(model.timeoutValues, model.getAutoOff());
        var timeoutLabel = model.timeoutLabels[tIdx];
        m.addItem(new WatchUi.MenuItem(Rez.Strings.autoOff, timeoutLabel, SettingsIds.ID_TIMEOUT, null));

        m.addItem(new WatchUi.MenuItem(Rez.Strings.supportMe, null, SettingsIds.ID_DONATE, null));

        return m;
    }

    function buildColorMenu(currentSel as Array) as WatchUi.Menu2 {
        var m = new WatchUi.Menu2({ :title => Rez.Strings.colorsMultipleSelection });

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

            var mark = picked ? "[x]" : "[ ]";
            m.addItem(new WatchUi.MenuItem(mark + " " + model.colorLabels[i], null, SettingsIds.COLOR_IDS[i], null));
        }

        m.addItem(new WatchUi.MenuItem(Rez.Strings.save, null, SettingsIds.ID_SAVE_COLORS, null));
        m.addItem(new WatchUi.MenuItem(Rez.Strings.back, null, SettingsIds.ID_BACK, null));

        return m;
    }

    function buildTimeoutMenu() as WatchUi.Menu2 {
        var m = new WatchUi.Menu2({ :title => Rez.Strings.autoOff });

        var n = model.timeoutLabels.size();
        if (n > SettingsIds.TIMEOUT_IDS.size()) {
            n = SettingsIds.TIMEOUT_IDS.size();
        }

        var current = model.getAutoOff();
        for (var i = 0; i < n; i += 1) {
            var isCurr = model.timeoutValues[i] == current;
            var mark = isCurr ? "[x]" : "[ ]"; // highlight current choose
            m.addItem(new WatchUi.MenuItem(mark + " " + model.timeoutLabels[i], null, SettingsIds.TIMEOUT_IDS[i], null));
        }

        m.addItem(new WatchUi.MenuItem(Rez.Strings.back, null, SettingsIds.ID_BACK, null));
        return m;
    }

    function refreshMainMenu() {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        var mainView = new FlashlightView();
        var delegate = new BrightyDelegate(mainView);
        WatchUi.switchToView(mainView, delegate, WatchUi.SLIDE_IMMEDIATE);
    }

    function refreshColorsMenu(currentSel as Array) {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        var menu = buildColorMenu(currentSel);
        var dlg = new ColorsMenuDelegate(self, currentSel);
        WatchUi.pushView(menu, dlg, WatchUi.SLIDE_IMMEDIATE);
    }
}

// ---------- Delegates ----------

class SettingsMenuDelegate extends WatchUi.Menu2InputDelegate {
    private var builder;
    private var model;

    function initialize(b) {
        Menu2InputDelegate.initialize();
        builder = b;
        model = new SettingsModel();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId();

        if (id == SettingsIds.ID_COLOR) {
            var startSel = model.getSelectedColors();
            WatchUi.pushView(builder.buildColorMenu(startSel), new ColorsMenuDelegate(builder, startSel), WatchUi.SLIDE_LEFT);
            return;
        }

        if (id == SettingsIds.ID_HINTS) {
            model.setHints(!model.getHints());

            var txt = model.getHints() ? Rez.Strings.on : Rez.Strings.off;
            item.setSubLabel(txt);
            WatchUi.requestUpdate();
            return;
        }

        if (id == SettingsIds.ID_TIMEOUT) {
            WatchUi.pushView(builder.buildTimeoutMenu(), new TimeoutMenuDelegate(builder), WatchUi.SLIDE_LEFT);
            return;
        }

        if (id == SettingsIds.ID_DONATE) {
            (new DonateHelper()).openBuyMeACoffee();
            return;
        }

        if (id == SettingsIds.ID_BACK) {
            WatchUi.popView(WatchUi.SLIDE_DOWN);
            return;
        }
    }

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return;
    }
}

class ColorsMenuDelegate extends WatchUi.Menu2InputDelegate {
    private var builder;
    private var model;
    private var tempSel;

    function initialize(b, initialSel as Array) {
        Menu2InputDelegate.initialize();
        builder = b;
        model = new SettingsModel();

        tempSel = [];
        for (var i = 0; i < initialSel.size(); i += 1) {
            tempSel.add(initialSel[i]);
        }
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId();

        // Save
        if (id == SettingsIds.ID_SAVE_COLORS) {
            if (tempSel.size() == 0) {
                tempSel.add(Graphics.COLOR_WHITE);
            }
            model.setSelectedColors(tempSel);
            builder.refreshMainMenu();
            return;
        }

        // Back
        if (id == SettingsIds.ID_BACK) {
            builder.refreshMainMenu();
            return;
        }

        // Change
        var ids = SettingsIds.COLOR_IDS;
        var n = model.colorValues.size();
        if (n > ids.size()) {
            n = ids.size();
        }

        for (var i = 0; i < n; i += 1) {
            if (id == ids[i]) {
                var val = model.colorValues[i];

                // toggle in tempSel
                var idx = Utils.indexOfArray(tempSel, val);
                if (idx >= 0) {
                    // remove
                    var tmp = [] as Array<Number>;
                    for (var k = 0; k < tempSel.size(); k += 1) {
                        if (k != idx) {
                            tmp.add(tempSel[k]);
                        }
                    }
                    tempSel = tmp;
                } else {
                    tempSel.add(val);
                }

                var picked = Utils.indexOfArray(tempSel, val) >= 0;
                var mark = picked ? "[x]" : "[ ]";
                item.setLabel(mark + " " + model.colorLabels[i]);
                WatchUi.requestUpdate();
                return;
            }
        }
    }

    function onBack() {
        builder.refreshMainMenu();
        return;
    }
}

class TimeoutMenuDelegate extends WatchUi.Menu2InputDelegate {
    private var builder;
    private var model;

    function initialize(b) {
        Menu2InputDelegate.initialize();
        builder = b;
        model = new SettingsModel();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId();

        if (id == SettingsIds.ID_BACK) {
            builder.refreshMainMenu();
            return;
        }

        var ids = SettingsIds.TIMEOUT_IDS;
        var n = model.timeoutValues.size();
        if (n > ids.size()) {
            n = ids.size();
        }

        for (var i = 0; i < n; i += 1) {
            if (id == ids[i]) {
                model.setAutoOff(model.timeoutValues[i]);
                builder.refreshMainMenu();
                return;
            }
        }
    }

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
        return;
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

    static function _composeSelectedColors() as Array<Number> {
        var options = [
            { :key => "colorWhite", :def => true, :color => Graphics.COLOR_WHITE },
            { :key => "colorGreen", :def => false, :color => Graphics.COLOR_GREEN },
            { :key => "colorRed", :def => false, :color => Graphics.COLOR_RED },
        ];

        var baseColors = [] as Array<Number>;

        for (var i = 0; i < options.size(); i += 1) {
            var opt = options[i];
            if (_getBool(opt[:key], opt[:def])) {
                baseColors.add(opt[:color]);
            }
        }

        if (baseColors.size() == 0) {
            baseColors.add(Graphics.COLOR_WHITE);
        }

        var result = [] as Array<Number>;
        var whiteShades = [0xbfbfbf, 0x808080];

        for (var i = 0; i < baseColors.size(); i += 1) {
            var col = baseColors[i];
            result.add(col);
            if (col == Graphics.COLOR_WHITE) {
                for (var j = 0; j < whiteShades.size(); j += 1) {
                    result.add(whiteShades[j]);
                }
            }
        }

        result.add(Graphics.COLOR_BLACK);

        return result;
    }

    static function getSelectedColors() as Array {
        return _composeSelectedColors();
    }

    static function setSelectedColorsList(list as Array<Number>) {
        var hasW = false,
            hasG = false,
            hasR = false;
        if (list != null) {
            var n = list.size();
            for (var i = 0; i < n; i += 1) {
                var c = list[i];
                if (c == Graphics.COLOR_WHITE) {
                    hasW = true;
                    continue;
                }
                if (c == Graphics.COLOR_GREEN) {
                    hasG = true;
                    continue;
                }
                if (c == Graphics.COLOR_RED) {
                    hasR = true;
                }
            }
        }

        if (!hasW && !hasG && !hasR) {
            hasW = true;
        }

        var curW = _getBool("colorWhite", true);
        var curG = _getBool("colorGreen", false);
        var curR = _getBool("colorRed", false);

        if (curW != hasW) {
            _set("colorWhite", hasW);
        }
        if (curG != hasG) {
            _set("colorGreen", hasG);
        }
        if (curR != hasR) {
            _set("colorRed", hasR);
        }
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
