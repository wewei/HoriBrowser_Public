$H(function (defineClassProc, retrieveClassProc) {
	var hori = this;

	var HBViewController = defineClassProc('HBViewController');

	HBViewController.prototype.presentViewController = function (viewController, animated) {
		var args = { 'viewController' : viewController };
		if (animated instanceof Number)
			args['animated'] = animated;
		return this.invoke('presentViewController', args);
	};

	HBViewController.prototype.dismissViewController = function (animated) {
		var args = { };
		if (animated instanceof Number)
			args['animated'] = animated;
		return this.invoke('dismissViewController', args);
	};

	return hori;
});

