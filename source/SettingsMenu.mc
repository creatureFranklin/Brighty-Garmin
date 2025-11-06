using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Application;
import Toybox.Lang;
using Toybox.System;

// ---------- Fixed item IDs (Symbol) ----------
class SettingsIds {
    public static const COLOR_IDS = [:color0, :color1, :color2, :color3, :color4, :color5, :color6, :color7];
    public static const TIMEOUT_IDS = [:timeout0, :timeout1, :timeout2, :timeout3, :timeout4, :timeout5, :timeout6];

    public static const ID_COLOR = :color; // main menu → color submenu (multiselect)
    public static const ID_SAVE_COLORS = :save; // main menu → color submenu "Save"
    public static const ID_HINTS = :hints; // main menu toggle
    public static const ID_TIMEOUT = :timeout; // main menu → timeout submenu
    public static const ID_BACK = :back; // universal "Back"

    public static const ID_DONATE = :donate;
}

class SettingsModel {
    public var colorLabels as Array<String> =
        [Utils._t(Rez.Strings.white), Utils._t(Rez.Strings.green), Utils._t(Rez.Strings.red), Utils._t(Rez.Strings.orange), Utils._t(Rez.Strings.yellow)] as Array<String>;
    public var colorValues as Array<Number> = [Graphics.COLOR_WHITE, Graphics.COLOR_GREEN, Graphics.COLOR_RED, Graphics.COLOR_ORANGE, Graphics.COLOR_YELLOW] as Array<Number>;

    public var timeoutLabels as Array<String> =
        [Utils._t(Rez.Strings.autoOffNever), Utils._t(Rez.Strings.autoOff10), Utils._t(Rez.Strings.autoOff30), Utils._t(Rez.Strings.autoOff60), Utils._t(Rez.Strings.autoOff120)] as Array<String>;
    public var timeoutValues as Array<Number> = [0, 10, 30, 60, 120] as Array<Number>;

    // ---- Colors multiselect ----
    function getSelectedColors() {
        return SettingsService.getSelectedColors();
    }

    function setSelectedColors(list) {
        SettingsService.setSelectedColorsList(list as Array<Number>);
    }

    function isColorSelected(val as Number) {
        var sel = getSelectedColors() as Array<Number>;
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
        var sel = getSelectedColors() as Array<Number>;
        var names = [] as Array<String>;
        for (var i = 0; i < colorValues.size(); i += 1) {
            var cv = colorValues[i] as Number;

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
            return Utils.joinArray(names as Array, ", ");
        }

        return names[0] + ", " + names[1] + " +" + (n - 2).toString();
    }

    function getColor() {
        // returns first color from all selected colors
        var sel = getSelectedColors() as Array<Number>;
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

        var tIdx = Utils.indexOfArray(model.timeoutValues, model.getAutoOff());
        if (tIdx < 0) {
            tIdx = 0;
        }
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
            if (UtilsColorCompat.isLowColorDevice() && val != Graphics.COLOR_ORANGE) {
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

    // Helper: add only unique color
    static function _addMapped(result as Array<Number>, c as Number, isLow as Boolean) as Void {
        var mapped = isLow ? UtilsColorCompat.to8Color(c) : c;
        if (!Utils.containsArray(result as Array, mapped)) {
            result.add(mapped);
        }
    }

    static function _composeSelectedColors() as Array<Number> {
        var options = [
            { :key => "colorWhite", :def => true, :color => Graphics.COLOR_WHITE },
            { :key => "colorGreen", :def => false, :color => Graphics.COLOR_GREEN },
            { :key => "colorRed", :def => false, :color => Graphics.COLOR_RED },
            { :key => "colorOrange", :def => false, :color => Graphics.COLOR_ORANGE },
            { :key => "colorYellow", :def => false, :color => Graphics.COLOR_YELLOW },
        ];

        // 1) Load selected baseColors in defined order
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

        var isLow = UtilsColorCompat.isLowColorDevice();
        var result = [] as Array<Number>;

        // 2) White -> and after that whiteShades
        var idxWhite = -1;
        for (var i = 0; i < baseColors.size(); i += 1) {
            if (baseColors[i] == Graphics.COLOR_WHITE) {
                idxWhite = i;
                break;
            }
        }

        if (idxWhite >= 0) {
            _addMapped(result, Graphics.COLOR_WHITE, isLow);

            // whiteShades after white
            if (!isLow) {
                var whiteShades = [0xbfbfbf, 0x808080] as Array<Number>;
                for (var ws = 0; ws < whiteShades.size(); ws += 1) {
                    _addMapped(result, whiteShades[ws], isLow);
                }
            }
        }

        // 3) Other baseColors
        for (var j = 0; j < baseColors.size(); j += 1) {
            if (j == idxWhite) {
                continue;
            }
            _addMapped(result, baseColors[j], isLow); // ORANGE→YELLOW on FR55
        }

        // 4) Black as last color in order
        _addMapped(result, Graphics.COLOR_BLACK, isLow);

        return result;
    }

    static function getSelectedColors() as Array<Number> {
        return _composeSelectedColors();
    }

    static function setSelectedColorsList(list as Array<Number>?) {
        var hasW = false,
            hasG = false,
            hasR = false,
            hasO = false,
            hasY = false;
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
                    continue;
                }
                if (c == Graphics.COLOR_ORANGE) {
                    hasO = true;
                    continue;
                }
                if (c == Graphics.COLOR_YELLOW) {
                    hasY = true;
                }
            }
        }

        if (!hasW && !hasG && !hasR && !hasO && !hasY) {
            hasW = true;
        }

        var curW = _getBool("colorWhite", true);
        var curG = _getBool("colorGreen", false);
        var curR = _getBool("colorRed", false);
        var curO = _getBool("colorOrange", false);
        var curY = _getBool("colorYellow", false);

        if (curW != hasW) {
            _set("colorWhite", hasW);
        }
        if (curG != hasG) {
            _set("colorGreen", hasG);
        }
        if (curR != hasR) {
            _set("colorRed", hasR);
        }
        if (curO != hasO) {
            _set("colorOrange", hasO);
        }
        if (curY != hasY) {
            _set("colorYellow", hasY);
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
        } else if (color == Graphics.COLOR_ORANGE) {
            _set("colorOrange", !_getBool("colorOrange", false));
        } else if (color == Graphics.COLOR_YELLOW) {
            _set("colorYellow", !_getBool("colorYellow", false));
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
