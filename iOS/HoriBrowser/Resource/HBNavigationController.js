$H(function (defineClassProc, retrieveClassProc) {
    var hori = this;

	var HBNavigationController = defineClassProc('HBNavigationController');

	HBNavigationController.prototype.pushViewController = function (viewController) {
		var args = { 'viewController' : viewController };
		return this.invoke('pushViewController', args);
	};

    return hori;    
});

