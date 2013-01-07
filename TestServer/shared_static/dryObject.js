function testDryObject()
{
    var object = new Object();

    object.obj = new Object();
    object.integer = 1;
    object.string = "hello";
    object.func = function () {
        alert("hello");
    };

    console.log("get here");
    var str = $H.__debug.stringifyJSON(object, []);
    console.log(str);
    console.log(JSON.parse(str));
//    console.log(JSON.parse(str));
}

