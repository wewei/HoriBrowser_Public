$H(function (defineClassProc, retrieveClassProc) {
	var hori = this;

	var HBWebViewController = defineClassProc('HBWebViewController', 'HBViewController');

	HBWebViewController.prototype.loadURL = function(url, onStartLoading) {
		var args = { 'url' : url };
		if (onStartLoading instanceof Function)
			args['onStartLoading'] = onStartLoading;
		return this.invoke('loadURL', args);
	};

	return hori;
});

