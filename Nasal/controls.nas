var axisHandler = func(pre, post) {
    func(invert = 0) {
        var val = cmdarg().getNode("setting").getValue();
        if(invert) val = -val;
        foreach(var e; engines)
            if(e.selected.getValue())
                setprop(pre ~ e.index ~ post, (1 - val) / 2);
    }
}
var throttleLeftAxis = axisHandler("/controls/engines/engine["0"]/throttle");
var throttleCenterAxis = axisHandler("/controls/engines/engine["1"]/throttle");
var throttleRightAxis = axisHandler("/controls/engines/engine["2"]/throttle");

