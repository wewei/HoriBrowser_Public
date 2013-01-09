$H(function (defineClassProc, retrieveClassProc) {
    var hori = this;

	var HBObject = retrieveClassProc('HBObject');
    var HBClass = defineClassProc('HBClass', null,
        function (path, args) {
            HBObject.call(this, path);
            this.name = args;
        }
    );

    HBClass.prototype.NEW = function (args) {
        return this.GLOBAL_NEW(null, args);
    };

    HBClass.prototype.GLOBAL_NEW = function (path, args) {
		var type = this;
        return this.invoke(
            'new',
            {
                'path' : path,
                'arguments' : args
            }
        ).setReturnValueDecorator(function (returnValue) {
            return hori(returnValue, type.name);
        }).onSuccess(function (returnValue) {
            if (returnValue !== path) {
                console.log('unlink non-referenced object');
                hori(returnValue).unlink();
            }
        });
    };

    function bridgedClass(className) {
        return hori('/Class/' + className, 'HBClass', className);
    }
    hori.bridgedClass = bridgedClass;

    return hori;    
});

