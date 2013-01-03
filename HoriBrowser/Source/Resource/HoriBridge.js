
// alert("hello world");

var $H = function () {
    var __bridgedObjects = new Object();
    var __activeInvocations = new Object();
    var __invocationQueue = new Array();
    
    var BridgedObject = function (path) {
        this.path = path;
    };
    
    BridgedObject.prototype.constructor = BridgedObject;
    BridgedObject.prototype.call = function (method, arguments, callback) {
        var invocation = new Invocation(this.path, method, arguments, callback);
        __invocationQueue.push(invocation);
		var frame = document.getElementById("hori_bridge_frame");
        if (frame)
            frame.contentDocument.location.reload();
    };
    
    var __invocationCounter = 0;
    
    var Invocation = function (objectPath, method, arguments, callback) {
        this.__objectPath = objectPath;
        this.__method = method;
        this.__arguments = arguments;
        this.__callback = callback;
        this.__index = (__invocationCounter ++);
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
        alert(completionDict.index);
        alert(invocation);
        if (invocation) {
            if (invocation.__callback) {
                invocation.__callback(completionDict.status, completionDict.returnValue);
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

