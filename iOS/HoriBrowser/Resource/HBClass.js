$H(function (defineClassProc, retrieveClassProc) {
    var hori = this;

    var HBClass = defineClassProc('HBClass', null,
        function (path, args) {
            this.superclass(path);
            this.name = args;
        }
    );

    HBClass.prototype.NEW = function (args) {
        return this.GLOBAL_NEW(null, args);
    };

    HBClass.prototype.GLOBAL_NEW = function (path, args) {
        return this.invoke(
            'new',
            {
                'path' : path,
                'arguments' : args
            }
        ).setReturnValueDecorator(function (returnValue) {
            return hori(returnValue, this.name);
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

