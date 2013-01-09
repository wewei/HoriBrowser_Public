$H(function (defineClassProc, retrieveClassProc, DummyInvocation) {
    var hori = this;

	var HBNavigationController = defineClassProc('HBNavigationController');

	HBNavigationController.prototype.pushViewController = function (viewController) {
		var args = { 'viewController' : viewController };
		return this.invoke('pushViewController', args);
	};

	HBNavigationController.prototype.pushWebViewController = function (url, stopOnFailure) {
		var navCtrl = this;
		var invoc = new DummyInvocation();

		var webViewCtrlClass = hori.bridgedClass('HBWebViewController');
		if (!webViewCtrlClass) {
			invoc.fail({
				'name' : 'NavigationControllerException',
				'reason' : 'Class HBWebViewController not defined',
				'userInfo' : null,
			});
		}

		var webViewCtrl = null;

		function pushControler() {
			navCtrl.pushViewController(webViewCtrl)
				.onSuccess(function () {
					webViewCtrl.unlink();
					invoc.success();
				})
				.onFailure(function (exception) {
					webViewCtrl.unlink();
					invoc.fail(exception);
				});
		}

		function loadPage() {
			webViewCtrl.loadURL(url)
				.onSuccess(pushControler)
				.onFailure(function (exception) {
					webViewCtrl.unlink();
					invoc.fail(exception);
				});
		}

		webViewCtrlClass.NEW()
			.onSuccess(function (_webViewCtrl) {
				webViewCtrl = _webViewCtrl;
				loadPage();
			})
			.onFailure(function (exception) {
				invoc.fail(exception);
			});

		return invoc;
	};

    return hori;    
});

