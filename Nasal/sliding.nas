# Draw 3 degree glide slope tunnel for the nearest airport's most suitable runway
# considering wind direction and runway size.
# Activate with  --prop:sim/rendering/glide-slope-tunnel=1 or via Help menu

var INTERVAL = 5;				# check for nearest airport

var runway_id = nil;
var apt = nil;

# Find best runway for current wind direction (or 270), also considering length and width.
#
var near_runway = func(apt) {
	var rwy = nil;
	var min = 10000;
	
	foreach (var r; keys(apt.runways)) {
		var curr = apt.runways[r];
		var m1 = geo.Coord.new().set_latlon(curr.lat, curr.lon);
		m1.apply_course_distance(curr.heading + 180, curr.length / 2 - curr.threshold);
		var m2 = geo.Coord.new().set_latlon(curr.lat, curr.lon);
		m2.apply_course_distance(curr.heading, curr.length / 2 - curr.threshold);
		var plane = geo.aircraft_position();
		# debug.dump(m2.x());
		# debug.dump(m2.y());
		var v = 0;
		var v = ((plane.x()-m2.x())*(m2.y()-m1.y())-(plane.y()-m2.y())*(m2.x()-m1.x()))/curr.length;

		if (v < min) {
			min = v;
			rwy = curr;
		}
	}
	return rwy.id;
}

var loop = func() {
	var apt = airportinfo();
	runway_id = near_runway(apt);
	debug.dump(runway_id);
	settimer(func loop(), INTERVAL);
}


var loopid = 0;

_setlistener("/sim/signals/fdm-initialized", loop);


