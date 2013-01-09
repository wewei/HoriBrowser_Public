$H(function (defineClassProc, retrieveClassProc) {
    var hori = this;

    hori.objectManager = hori('/System/objectManager');

    hori.webViewController = hori('/Current/webViewController');

    hori.rootViewController= hori('/System/rootViewController');

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
