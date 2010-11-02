    #############################################################################
    #    Copyright 								#

    #############################################################################

print("Warn subsystem started");

#MTSH
mtsh=func{
#akrit = getprop("fdm/jsbsim/aero/alpha-deg");

#if( akrit == nil ) return;

#if( akrit > 15 ){
#setprop("controls/flight/elevator", 1.0 );
#setprop("controls/flight/elevator", -1.0 );
#}
settimer(mtsh, 0);
}
mtsh ();
