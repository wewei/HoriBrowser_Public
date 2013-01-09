$H(function (defineClassProc, retrieveClassProc) {
    var hori = this;

    hori.objectManager = hori('/System/ObjectManager');

    hori.webViewController = hori('/Current/WebViewController');

    hori.rootViewController= hori('/System/RootViewController');

    var HBObject = retrieveClassProc('HBObject');

	HBObject.prototype.read = function (callback) {
		hori.objectManager.__call(
			'readObject',
			{
				'path' : this.path,
			},
			callback
		);
	};
    
    HBObject.prototype.write = function (value, callback) {
        hori.objectManager.__call(
			'writeObject',
			{
				'path'  : this.path,
				'value' : value,
			},
			callback
		);
    };

    return hori;    
});
