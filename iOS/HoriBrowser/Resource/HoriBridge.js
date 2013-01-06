var $H = function () {
    
    var BRIDGE_FRAME_ID = "hori_bridge_frame";
    var BRIDGE_FRAME_SRC = "bridge://localhost/flush";

    var __bridgedObjects = new Object();
    var __invocationQueue = new Array();
    
    function createBridgeFrame() {
        var frame = document.createElement("iframe");
        frame.style.display = "none";
        frame.id = BRIDGE_FRAME_ID;
        frame.src = BRIDGE_FRAME_SRC;
        document.documentElement.appendChild(frame);
        return frame;
    }

    function asyncCall(func, args) {
        if (typeof func === 'function') {
            var routine = function () { func(args); };
            setTimeout(routine, 1);
        }
    }

    var BridgedObject = function (path) {
        this.path = path;
    };

    BridgedObject.prototype.constructor = BridgedObject;
    BridgedObject.prototype.call = function (method, args, callback) {
        var invocation = new Invocation(this.path, method, args, callback);
        __invocationQueue.push(invocation);
        var frame = document.getElementById(BRIDGE_FRAME_ID);
        if (frame == null)
            frame = createBridgeFrame();
        frame.src = BRIDGE_FRAME_SRC;
    };
    
    BridgedObject.prototype.setProperty = function (property, value, callback) {
        this.call(
            "setProperty",
            {
                "property" : property,
                "value" : value,
            },
            callback
        );
    };
    
    BridgedObject.prototype.getProperty = function (property, callback) {
        this.call(
            "getProperty",
            { "property" : property },
            callback
        );
    };

    BridgedObject.prototype.unlink = function (callback) {
        this.call("unlink", null, callback);
    };
    
    BridgedObject.prototype.move = function (path, callback) {
        this.call("moveToPath", { "path" : path }, callback);
    };

	BridgedObject.prototype.read = function (callback) {
		$H("/System/ObjectManager").call(
			"readObject",
			{
				"path" : this.path,
			},
			callback
		);
	};
    
    BridgedObject.prototype.write = function (value, callback) {
        $H("/System/ObjectManager").call(
			"writeObject",
			{
				"path"  : this.path,
				"value" : value,
			},
			callback
		);
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
        return this.stringifyJSON({
            "objectPath" : this.__objectPath,
            "method": this.__method,
            "arguments": this.__arguments,
            "index": this.__index,
        });
    };

    Invocation.prototype.stringifyJSON = function(json) {
        var invocation = this;
        return JSON.stringify(json, function(key, value) {
            if (typeof value === 'function') {
                var callbackIndex = invocation.__callbacks.length;
                invocation.__callbacks.push(value);
                return callbackIndex;
            }
            return value;
        });
    };

    Invocation.prototype.triggerCallback = function (index, args) {
        var callback = this.__callbacks[index];
        var result = null;
        if (typeof callback === 'function')
            result = callback(args);
        return this.stringifyJSON(result);
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
        return JSON.stringify(result);
    };
    
    __bridge.__triggerPersistedCallbackAsync = function (persistedCallbackIndex, args) {
        var callback = __persistedCallbacks[persistedCallbackIndex];
        asyncCall(callback, args);
    };

    __bridge.__completeInvocation = function (completionDict) {
        var invocation = __activeInvocations[completionDict.index];
        if (invocation) {
            invocation.triggerCallbackAsync(0, {
                "returnValue" : completionDict.returnValue,
                "exception"   : completionDict.exception,
            });
            delete __activeInvocations[completionDict.index];
        }
    };

    var hori = function (path) {
        if (!__bridgedObjects[path]) {
            __bridgedObjects[path] = new BridgedObject(path);
        }
        return __bridgedObjects[path];
    };
    
    hori.__bridge = __bridge;
    hori.__asyncCall = asyncCall;
    
    return hori;    
}();

$H.__asyncCall($H_main, null);
    
