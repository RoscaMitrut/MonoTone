import Toybox.Background;
import Toybox.System;

// The Service Delegate is the main entry point for background processes
// our onTemporalEvent() method will get run each time our periodic event
// is triggered by the system.

(:background)
class MonoToneServiceDelegate extends Toybox.System.ServiceDelegate {
	
	function initialize() {
		System.ServiceDelegate.initialize();
	}
	
    function onTemporalEvent() {
    	//var now=System.getClockTime();
        //Background.exit(now.hour+":"+now.min.format("%02d"));
    }
}
