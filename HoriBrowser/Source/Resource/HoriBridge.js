var $H = function () {
    
    var BRIDGE_FRAME_ID = "hori_bridge_frame";
    var BRIDGE_FRAME_SRC = "bridge://localhost/flush";

	var __bridgedObjects = new Object();
    var __activeInvocations = new Object();
    var __invocationQueue = new Array();
    
    var BridgedObject = function (path) {
        this.path = path;
    };
    
    function createBridgeFrame() {
        var frame = document.createElement("iframe");
        frame.style.display = "none";
        frame.id = BRIDGE_FRAME_ID;
        frame.src = BRIDGE_FRAME_SRC;
        document.documentElement.appendChild(frame);
        return frame;
    }
    
    BridgedObject.prototype.constructor = BridgedObject;
    BridgedObject.prototype.call = function (method, arguments, callback) {
        var invocation = new Invocation(this.path, method, arguments, callback);
        __invocationQueue.push(invocation);
		var frame = document.getElementById(BRIDGE_FRAME_ID);
        if (frame == null)
            frame = createBridgeFrame();
        frame.src = BRIDGE_FRAME_SRC;
    };
    
    var __invocationCounter = 0;
    
    var Invocation = function (objectPath, method, arguments, callback) {
        this.__objectPath = objectPath;
        this.__method = method;
        this.__arguments = arguments;
        this.__callback = callback;
        this.__index = ((__invocationCounter ++) & 0x7fffffff);
    };
    
    Invocation.prototype.constructor = Invocation;
    Invocation.prototype.toString = function () {
        var dict = {
            "objectPath" : this.__objectPath,
            "method": this.__method,
            "arguments": this.__arguments,
            "index": this.__index,
        };
        return JSON.stringify(dict);
    };
    
    
    var __bridge = new Object();
    
    __bridge.__test = function () { return 123; };
    
    __bridge.__retrieveInvocation = function () {
        invocation = __invocationQueue.shift();
        if (invocation != undefined) {
            __activeInvocations[invocation.__index] = invocation;
            return invocation.toString();
        } else {
            return null;
        }
    };
    
    __bridge.__completeInvocation = function (completionDict) {
        invocation = __activeInvocations[completionDict.index];
        if (invocation) {
            if (invocation.__callback) {
                var callback = invocation.__callback;
                var routine = function () {
                    callback(completionDict.exception, completionDict.returnValue);
                };
                setTimeout(routine, 1);
            }
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
    
    return hori;    
}();
