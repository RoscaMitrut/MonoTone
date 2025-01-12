import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class MonoToneApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [ new MonoToneView() ];
    }

    // New app settings have been received so trigger a UI update
    function onSettingsChanged() as Void {
        WatchUi.requestUpdate();
    }

}

function getApp() as MonoToneApp {
    return Application.getApp() as MonoToneApp;
}

////////////////////////////////////////////
    var view=null;

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

    function getInitialView() as Array<Views or InputDelegates>? {
        view = new MonoToneView();
        if(view.mySettings.hasProperties){
            return[view, new MonoToneView()] as Array<Views or InputDelegates>;
        }else{
            return[view] as Array<Views or InputDelegates>;
        }
    }

    function getSettingsView() {
        var setView=new MonoToneSettingsMenu();
        return [setView,new MonoToneSettingsMenuDelegate(setView)]  as Array<Views or InputDelegates>;
    }  