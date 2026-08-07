import Toybox.Lang;
import Toybox.WatchUi;

class CosmoCaseDelegate extends WatchUi.InputDelegate {
    private var _view as CosmoCaseView;

    function initialize(view as CosmoCaseView) {
        InputDelegate.initialize();
        _view = view;
    }

    function onTap(clickEvent as WatchUi.ClickEvent) as Boolean {
        var coords = clickEvent.getCoordinates();
        return _view.handleTap(coords[0], coords[1]);
    }
}
