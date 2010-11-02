#
#
#
# Project Tupolev for FlightGear
#
# Yurik V. Nikiforoff, yurik@megasignal.com
# Novosibirsk, Russia
# mar 2008
#
# Custom views 
#
###########################
var forceView = func{
	var n = arg[0];
	# Hide levers on navigator view

	# Hide right yoke
	if( n == 1 ) setprop("/yak-40/mod-views/copilot-view", 1);
	else setprop("/yak-40/mod-views/copilot-view", 0);
	if( n == 2 ) setprop("/yak-40/mod-views/bm-view", 1);
	else setprop("/yak-40/mod-views/bm-view", 0);
	if( n == 3 ) setprop("/yak-40/mod-views/leftazs-view", 1);
	else setprop("/yak-40/mod-views/leftazs-view", 0);
	if( n == 3 ) setprop("/yak-40/mod-views/rightazs-view", 1);
	else setprop("/yak-40/mod-views/rightazs-view", 0);

	var offset = getprop("/yak-40/mod-views/view-offset");
	if( n > 0 ) n = n + offset;
	setprop("sim/current-view/view-number", n);
	gui.popupTip(views[n].getNode("name").getValue());
};
######################################
var modView  = func{
	var n = getprop("sim/current-view/view-number");
	var offset = getprop("/yak-40/mod-views/view-offset");
	if( n == nil ) n = 0;
	if( n > 0 ) n = n - offset;
	if( n < 0 ) return;
	var mode = arg[0];
	if( mode == nil ) mode = 0;
	# get mod view coordinates	
	var mv = props.globals.getNode("yak-40/mod-views").getChildren("mod-view");
	if( mode == 1 )
	{
	setprop("yak-40/mod-views/mod", 1 );
	
# save current position
	setprop("yak-40/var/save-x", getprop("sim/current-view/x-offset-m") );
	setprop("yak-40/var/save-y", getprop("sim/current-view/y-offset-m") );
	setprop("yak-40/var/save-z", getprop("sim/current-view/z-offset-m") );
	setprop("yak-40/var/save-fov", getprop("sim/current-view/field-of-view") );
	setprop("yak-40/var/save-pitch", getprop("sim/current-view/pitch-offset-deg") );
	setprop("yak-40/var/save-heading",getprop("sim/current-view/heading-offset-deg"));
	setprop("yak-40/var/save-roll",getprop("sim/current-view/roll-offset-deg"));
# set modified view	
	setprop("sim/current-view/x-offset-m", mv[n].getNode("x-offset-m").getValue() );
	setprop("sim/current-view/y-offset-m", mv[n].getNode("y-offset-m").getValue() );
	setprop("sim/current-view/z-offset-m", mv[n].getNode("z-offset-m").getValue() );
	setprop("sim/current-view/field-of-view",
		mv[n].getNode("field-of-view").getValue() );
	setprop("sim/current-view/pitch-offset-deg", 
		mv[n].getNode("pitch-offset-deg").getValue() );
	setprop("sim/current-view/heading-offset-deg", 
		mv[n].getNode("heading-offset-deg").getValue() );
	setprop("sim/current-view/roll-offset-deg", 
		mv[n].getNode("roll-offset-deg").getValue() );

	return;
	}
	else
	{
	setprop("yak-40/mod-views/mod", 0 );
	
# save modified view	

#	mv[n].getNode("x-offset-m").setValue(getprop("sim/current-view/x-offset-m"));
#	mv[n].getNode("y-offset-m").setValue(getprop("sim/current-view/y-offset-m"));
#	mv[n].getNode("z-offset-m").setValue(getprop("sim/current-view/z-offset-m"));
# 	mv[n].getNode("field-of-view").setValue(
# 		getprop("sim/current-view/field-of-view"));
# 	mv[n].getNode("pitch-offset-deg").setValue(
# 		getprop("sim/current-view/pitch-offset-deg"));
# 	mv[n].getNode("heading-offset-deg").setValue(
# 		getprop("sim/current-view/heading-offset-deg"));
# 	mv[n].getNode("roll-offset-deg").setValue(
# 		getprop("sim/current-view/roll-offset-deg"));
				
	setprop("sim/current-view/x-offset-m", getprop("yak-40/var/save-x") );
	setprop("sim/current-view/y-offset-m", getprop("yak-40/var/save-y") );
	setprop("sim/current-view/z-offset-m", getprop("yak-40/var/save-z") );
	setprop("sim/current-view/field-of-view", getprop("yak-40/var/save-fov") );
	setprop("sim/current-view/pitch-offset-deg", getprop("yak-40/var/save-pitch") );
	setprop("sim/current-view/heading-offset-deg",getprop("yak-40/var/save-heading"));
	setprop("sim/current-view/roll-offset-deg",getprop("yak-40/var/save-roll"));
	}
};
#######################################################
# BM View

var fe_view = {
	start: func {
		setprop("sim/current-view/config/heading-offset-deg", 
			getprop("sim/view[102]/config/heading-offset-deg"));
		},
};


var init_offset = func{
setprop("/yak-40/mod-views/bm-view", 0);
setprop("/yak-40/mod-views/copilot-view", 0);
# Do we have Model View?
if( props.globals.getNode("/sim/view[9]") != nil )
  setprop("/yak-40/mod-views/view-offset", 8 );
else setprop("/yak-40/mod-views/view-offset", 7 );
}

init_offset();

setlistener("/sim/signals/fdm-initialized", func {
view.manager.register("BM View", fe_view );
});


print("View registered");
