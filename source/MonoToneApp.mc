import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

(:background)
class MonoToneApp extends Application.AppBase {
    var view=null;

    function initialize() {
        AppBase.initialize();
    }

    function onSettingsChanged() as Void {
        if(view!=null) {
            view.mySettings.load();
            WatchUi.requestUpdate();
        }
    }
    
    function onBackgroundData(data) {
        if(view!=null) {
            WatchUi.requestUpdate();
        }
    }

    function onStart(state as Dictionary?) as Void {
    }

    function onStop(state as Dictionary?) as Void {
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        view = new MonoToneView();
        if(view.mySettings.hasProperties){
            return[view, new MonoToneView()] as [Views, InputDelegates];
        }else{
            return[view] as [Views];
        }
    }

    function getSettingsView() {
        var setView=new MonoToneSettingsMenu();
        return [setView,new MonoToneSettingsMenuDelegate(setView)]  as [Views, InputDelegates];
    }

    function getServiceDelegate(){
        return [new MonoToneServiceDelegate()];
    }
}
function getApp() as MonoToneApp {
    return Application.getApp() as MonoToneApp;
}
