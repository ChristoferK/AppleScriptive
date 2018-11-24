ObjC.import('CoreWLAN');
nil = $();

(() => {
    	
	const defaultInterface = $.CWWiFiClient.sharedWiFiClient.interface;
	
	if (!defaultInterface.powerOn) return false;
	
	const networks = defaultInterface
			.scanForNetworksWithNameError(nil,nil)
			.allObjects;
	
	const SSIDs = ObjC.deepUnwrap(networks.valueForKey('ssid'));
	const RSSIValues = ObjC.deepUnwrap(networks.valueForKey('rssiValue'));
	
	const WiFi = SSIDs.reduce((ξ, item, i)=>{ 
					ξ[item] = RSSIValues[i];
					return ξ;
				  }, {})
				  
	var WiFiByStrength = {};
	Object.keys(WiFi).sort((i,j)=>{ return WiFi[j] - WiFi[i]; })
			 .map(key=>WiFiByStrength[key] = WiFi[key]);
	
	return WiFiByStrength;

})();