using Toybox.Graphics as G;
import Toybox.Lang;

module UtilsColorCompat {
    const PALETTE8 = [G.COLOR_BLACK, G.COLOR_WHITE, G.COLOR_RED, G.COLOR_GREEN, G.COLOR_BLUE, G.COLOR_YELLOW, 0x00ffff, G.COLOR_PINK];

    var _isLowColor = null;

    function isLowColorDevice() as Boolean {
        if (_isLowColor != null) {
            return _isLowColor;
        }

        if (!(G has :createBufferedBitmap)) {
            _isLowColor = true;
            return _isLowColor;
        }
        try {
            var _ = G.createBufferedBitmap({
                :width => 1,
                :height => 1,
                :palette => [G.COLOR_BLACK, G.COLOR_WHITE, G.COLOR_RED, G.COLOR_GREEN, G.COLOR_BLUE, G.COLOR_YELLOW, 0x00ffff, G.COLOR_PINK, 0x808080],
            });
            _isLowColor = false;
        } catch (e) {
            _isLowColor = true;
        }
        return _isLowColor;
    }

    function to8Color(c as Number) as Number {
        var r = (c >> 16) & 0xff;
        var g = (c >> 8) & 0xff;
        var b = c & 0xff;

        var best = PALETTE8[0];
        var bestD2 = 0x7fffffff;

        for (var i = 0; i < PALETTE8.size(); i += 1) {
            var p = PALETTE8[i];
            var pr = (p >> 16) & 0xff;
            var pg = (p >> 8) & 0xff;
            var pb = p & 0xff;

            var dr = r - pr;
            var dg = g - pg;
            var db = b - pb;
            var d2 = dr * dr + dg * dg + db * db;

            if (d2 < bestD2) {
                bestD2 = d2;
                best = p;
            }
        }
        return best;
    }

    function normalize(c as Number) as Number {
        return isLowColorDevice() ? to8Color(c) : c;
    }
}
