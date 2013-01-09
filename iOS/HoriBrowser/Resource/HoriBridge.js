var $H = function () {
    
    var hori = function (path, typeName, args) {
        if (!__bridgedObjects[path]) {
            var constructor = BridgedObject;
            if (__types[typeName] instanceof Function) {
                constructor = __types[typeName];
            }
            __bridgedObjects[path] = new constructor(path, args);
        }
        return __bridgedObjects[path];
    };

    // Debug
    hori.__debug = new Object();
    
    // Utilities

    function createDummyFrame(frameID, frameSrc) {
        var frame = document.createElement('iframe');
        frame.style.display = 'none';
        frame.id = frameID;
        frame.src = frameSrc;
        document.documentElement.appendChild(frame);
        return frame;
    }

    function reloadDummyFrame(protocol) {
        frameID = 'hori_dummy_frame_' + protocol; 
        frameSrc = protocol + '://localhost/';
        var frame = document.getElementById(frameID);
        if (frame == null)
            frame = createDummyFrame(frameID, frameSrc);
        else
            frame.src = frameSrc;
    }

    function stringForObject(type, dataString) {
        return '{"type":"' + type + '","data":' + dataString + '}';
    }

    function stringifyJSON(obj, callbacks) {
		if (obj == null) {
			return null;
        } if (obj instanceof BridgedObject) {
            return stringForObject('bridged', '"' + obj.path + '"');
        } else if (typeof obj === 'object') {
            var pares = new Array();
            for (var key in obj) {
                var keyStr = stringifyJSON(key, callbacks);
                var valueStr = stringifyJSON(obj[key], callbacks);
                pares.push(keyStr + ':' + valueStr);
            }
            return stringForObject('object', '{' + pares.join(',') + '}');
        } else if (typeof obj === 'function') {
            var callbackIndex = callbacks.length;
            callbacks.push(obj);
            return stringForObject('function', callbackIndex);
        }
        return JSON.stringify(obj);
    }

    // Async call

    function asyncCall(func, args) {
        if (typeof func === 'function') {
            var routine = function () { func(args); };
            setTimeout(routine, 1);
        }
    }

    hori.__asyncCall = asyncCall;

    // Log

    var LOG_PROTOCOL = 'log';

    var __logQueue = new Array();

    window.console = new Object();

    function horiLog(log) {
        if (typeof log === 'string')
            __logQueue.push(log);
        else
            __logQueue.push(JSON.stringify(log));
        reloadDummyFrame(LOG_PROTOCOL);
    };

    window.console.log = horiLog;
    window.console.debug = horiLog;
    window.console.info = horiLog;
    window.console.warn = horiLog;
    window.console.error = horiLog;

    hori.__log = new Object();
    hori.__log.__retrieveLogs = function () {
        var result = JSON.stringify(__logQueue);
        __logQueue.splice(0, __logQueue.length);
        return result;
    };

    // Bridge

    var BRIDGE_PROTOCOL = 'bridge';

    var __bridgedObjects = new Object();
    var __invocationQueue = new Array();
    
    var BridgedObject = function (path, args) {
        this.path = path;
    };

    BridgedObject.prototype.constructor = BridgedObject;
    BridgedObject.prototype.__call = function (method, args, callback) {
        var invocation = new Invocation(this.path, method, args, callback);
        __invocationQueue.push(invocation);
        reloadDummyFrame(BRIDGE_PROTOCOL);
    };
    
    BridgedObject.prototype.setProperty = function (property, value, callback) {
        this.__call(
            'setProperty',
            {
                'property' : property,
                'value' : value,
            },
            callback
        );
    };
    
    BridgedObject.prototype.getProperty = function (property, callback) {
        this.__call(
            'getProperty',
            { 'property' : property },
            callback
        );
    };

    BridgedObject.prototype.unlink = function (callback) {
        this.__call('unlink', null, callback);
    };
    
    BridgedObject.prototype.move = function (path, callback) {
        this.__call('moveToPath', { 'path' : path }, callback);
    };

	BridgedObject.prototype.read = function (callback) {
		objectManager().__call(
			'readObject',
			{
				'path' : this.path,
			},
			callback
		);
	};
    
    BridgedObject.prototype.write = function (value, callback) {
        objectManager().__call(
			'writeObject',
			{
				'path'  : this.path,
				'value' : value,
			},
			callback
		);
    };

    function defaultReturnValueDecorator(returnValue) { return returnValue; }

	var PublicInvocation = function (obj, method, args) {
		this.__ready = false;
		this.__returnArgs = null;
		this.__onSuccess = null;
		this.__onFailure = null;
        this.__returnValueDecorator = defaultReturnValueDecorator;
		var pubInvoc =  this;
		obj.__call(method, args, function (_args) {
			pubInvoc.__returnArgs = _args;
			pubInvoc.__ready = true;
			if (_args.exception === null) {
				if (pubInvoc.__onSuccess instanceof Function) {
					pubInvoc.__onSuccess(
                        pubInvoc.__returnValueDecorator(_args.returnValue)
                    );
				}
			} else {
				if (pubInvoc.__onFailure instanceof Function) {
					pubInvoc.__onFailure(_args.exception);
				}
			}
		});
	};

	PublicInvocation.prototype.constructor = PublicInvocation;

	PublicInvocation.prototype.onSuccess = function (routine) {
		if (routine instanceof Function) {
			if (!this.__ready) {
				this.__onSuccess = routine;
			} else if (this.__onSuccess === null && this.__returnArgs.exception === null) {
				this.__onSuccess = routine;
				this.__onSuccess(
                    this.__returnValueDecorator(this.__returnArgs.returnValue)
                );
			}
		}
		return this;
	};

	PublicInvocation.prototype.onFailure = function (routine) {
		if (routine instanceof Function) {
			if (!this.__ready) {
				this.__onFailure = routine;
			} else if (this.__onFailure === null && this.__returnArgs.exception !== null) {
				this.__onFailure = routine;
				this.__onFailure(this.__returnArgs.exception);
			}
		}
		return this;
	};

    PublicInvocation.prototype.setReturnValueDecorator = function (decorator) {
        if (decorator instanceof Function)
            this.__returnValueDecorator = decorator;
        return this;
    };

	BridgedObject.prototype.invoke = function (method, args) {
		return new PublicInvocation(this, method, args);
	};

    var __activeInvocations = new Object();
    var __invocationCounter = 0;
    
    var Invocation = function (objectPath, method, args, callback) {
        this.__objectPath = objectPath;
        this.__method = method;
        this.__arguments = args;
        this.__index = ((__invocationCounter ++) & 0x7fffffff);

        this.__callbacks = [];
        if (callback)
            this.__callbacks.push(callback);
    };
    
    Invocation.prototype.constructor = Invocation;
    Invocation.prototype.toString = function () {
        return stringifyJSON({
            'objectPath' : this.__objectPath,
            'method': this.__method,
            'arguments': this.__arguments,
            'index': this.__index,
        }, this.__callbacks);
    };

    Invocation.prototype.triggerCallback = function (index, args) {
        var callback = this.__callbacks[index];
        var result = null;
        if (typeof callback === 'function')
            result = callback(args);
        return stringifyJSON(result, this.__callbacks);
    };

    Invocation.prototype.triggerCallbackAsync = function (index, args) {
        var callback = this.__callbacks[index];
        asyncCall(callback, args);
    };
    
    var __bridge = new Object();

    __bridge.__retrieveInvocation = function () {
        var invocation = __invocationQueue.shift();
        if (invocation) {
            __activeInvocations[invocation.__index] = invocation;
            return invocation.toString();
        } else {
            return null;
        }
    };
    
    __bridge.__triggerCallback = function (invocationIndex, callbackIndex, args) {
        var invocation = __activeInvocations[invocationIndex];
        if (invocation) {
            return invocation.triggerCallback(callbackIndex, args);
        }
        return null;
    };

    __bridge.__triggerCallbackAsync = function (invocationIndex, callbackIndex, args) {
        var invocation = __activeInvocations[invocationIndex];
        if (invocation)
            return invocation.triggerCallbackAsync(callbackIndex, args);
    };
    
    var __persistedCallbacks = new Object();
    var __persistedCallbackCounter = 0;
    
    __bridge.__persistCallback = function (invocationIndex, callbackIndex) {
        var invocation = __activeInvocations[invocationIndex];
        if (invocation) {
            var callback = invocation.__callbacks[callbackIndex];
            if (typeof callback === 'function') {
                var persistedCallbackIndex = ((__persistedCallbackCounter ++) & 0x7fffffff);
                __persistedCallbacks[persistedCallbackIndex] = callback;
                return persistedCallbackIndex;
            }
        }
        return null;
    };

    __bridge.__unlinkCallback = function (persistedCallbackIndex) {
        delete __persistedCallbacks[persistedCallbackIndex];
    };

    __bridge.__triggerPersistedCallback = function (persistedCallbackIndex, args) {
        var callback = __persistedCallbacks[persistedCallbackIndex];
        var result = null;
        if (typeof callback === 'function')
            result = callback(args);
        return stringifyJSON(result, []); // TODO, store the persisted callback function return values
    };
    
    __bridge.__triggerPersistedCallbackAsync = function (persistedCallbackIndex, args) {
        var callback = __persistedCallbacks[persistedCallbackIndex];
        asyncCall(callback, args);
    };

    __bridge.__completeInvocation = function (completionDict) {
        var invocation = __activeInvocations[completionDict.index];
        if (invocation) {
            invocation.triggerCallbackAsync(0, {
                'returnValue' : completionDict.returnValue,
                'exception'   : completionDict.exception,
            });
            delete __activeInvocations[completionDict.index];
        }
    };

    hori.__bridge = __bridge;

    // Classes
    var __types = new Object();

    function defineClass(className, superclassName, constructor) {
        var superclass = __types[superclassName];
        if (!(superclass instanceof Function))
            superclass = BridgedObject;
        if (!constructor)
            constructor = function (args) { this.superclass(args); };
        if (constructor instanceof Function) {
            constructor.prototype = new superclass();
            constructor.prototype.superclass = superclass;
            constructor.prototype.constructor = constructor;
            __types[className] = constructor;
            return constructor;
        }
        return null;
    };
    hori.defineClass = defineClass;

    var HBClass = defineClass('HBClass', null,
        function (path, args) {
            this.superclass(path);
            this.name = args;
        }
    );

    HBClass.prototype.NEW = function (args) {
        return this.GLOBAL_NEW(null, args);
    };

    HBClass.prototype.GLOBAL_NEW = function (path, args) {
        console.log(this.name);
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

    // Short cuts

    function objectManager() {
        return hori('/System/ObjectManager');
    }
    hori.objectManager = objectManager;

    function webViewController() {
        return hori('/Current/WebViewController');
    }
    hori.webViewController = webViewController;

    function rootViewController() {
        return hori('/System/RootViewController');
    }
    hori.rootViewController= rootViewController;

    function bridgedClass(className) {
        return hori('/Class/' + className, 'HBClass', className);
    }
    hori.bridgedClass = bridgedClass;

    return hori;    
}();

$H.defineClass('NavigationController');

$H.__asyncCall($H_main, null);

