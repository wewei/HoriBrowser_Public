$H(function (defineClassProc, retrieveClassProc) {
    var hori = this;

    hori.objectManager = hori('/System/objectManager');

    hori.webViewController = hori('/Current/webViewController', 'HBWebViewController');

    hori.rootViewController= hori('/System/rootViewController', 'HBViewController');

    var HBObject = retrieveClassProc('HBObject');

	HBObject.prototype.read = function () {
		return hori.objectManager.invoke(
			'readObject',
			{ 'path' : this.path, }
		);
	};
    
    HBObject.prototype.write = function (value) {
        return hori.objectManager.invoke(
			'writeObject',
			{ 'path'  : this.path, 'value' : value, }
		);
    };

    return hori;    
});

