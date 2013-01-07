var DryObject = function (type, value) {
    this.type = type;
    this.value = value;
};

DryObject.prototype.constructor = DryObject;
DryObject.prototype.hello = function () { alert("Hello"); };

function replacer(key, value) {
    if (typeof value === "object") {
//        var driedObject = 
        return new DryObject("object", value);
    }
    return value;
}

function testDryObject()
{
    var object = new Object();

    object.obj = new Object();
    object.integer = 1;
    object.string = "hello";

    console.log(Object.keys(object));
    console.log(Object.keys(new DryObject("object", object)));
    // console.log(JSON.stringify(object, replacer));
}

