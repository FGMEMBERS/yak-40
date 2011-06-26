#
# NASAL instruments for TU-154B
# Yurik V. Nikiforoff, yurik@megasignal.com
# Novosibirsk, Russia
# jun 2007
# Rebuild for yak-40 by Mikhail Zuev april 2010
print("Initializing instruments system");

var radar_low_pass = aircraft.lowpass.new(1.5);

init_instruments = func {
	setprop("yak-40/instrumentation/iku/indicated-heading-l",rand()*359);
	setprop("yak-40/instrumentation/iku/indicated-heading-r",rand()*359);
	setprop("/instrumentation/adf/indicated-bearing-deg",getprop("yak-40/instrumentation/iku/indicated-heading-l"));
	setprop("/instrumentation/adf[1]/indicated-bearing-deg",getprop("yak-40/instrumentation/iku/indicated-heading-r"));
	setprop("yak-40/instrumentation/iku/l-mode",0);
	setprop("yak-40/instrumentation/iku/r-mode",0);
	
	setprop("yak-40/instrumentation/gear/knob",0);
	setprop("yak-40/instrumentation/gear/lamp-light",0.5);
	setprop("yak-40/instrumentation/iku/test",0);
	  setprop("yak-40/switches/sw_fuel",0);
	setprop("yak-40/instrumentation/kppm/needle",0);
	setprop("yak-40/instrumentation/kppm[1]/needle",0);
	setprop("yak-40/instrumentation/kppm/kurs",getprop("/orientation/heading-magnetic-deg"));
	setprop("yak-40/instrumentation/kppm[1]/kurs",getprop("/orientation/heading-magnetic-deg"));
setprop("yak-40/switches/sw_fuel_check",0);
  setprop("/instrumentation/airspeed-indicator/serviceable", 1);
	setprop("/instrumentation/altimeter/serviceable", 1);
	setprop("/instrumentation/inst-vertical-speed-indicator/serviceable", 1);
	setprop("/instrumentation/vertical-speed-indicator/serviceable", 1);
	setprop("yak-40/instrumentation/agd-l/serviceable", 1);
	setprop("yak-40/instrumentation/agd-l/flag", 1);
	setprop("yak-40/instrumentation/achs-1/main/h",0.0);
	setprop("yak-40/instrumentation/achs-1/main/m",0.0);
	setprop("yak-40/instrumentation/achs-1/main/s",0.0);
	setprop("yak-40/instrumentation/achs-1/t",0.0);
	setprop("yak-40/instrumentation/achs-1/k1",0);
	setprop("yak-40/instrumentation/achs-1/k2",0);
	setprop("yak-40/instrumentation/vph/serviceable", 1);
	setprop("/yak-40/instrumentation/msrp/serviceable", 1);
	setprop("/instrumentation/ite2t_1/fail",0);
	setprop("/instrumentation/ite2t_2/fail",0);
	setprop("/instrumentation/ite2t_3/fail",0);
#	setprop("/instrumentation/adf[1]/serviceable", 1 );
#	setprop("/instrumentation/adf[0]/serviceable", 1 );
#	setprop("yak-40/instrumentation/ark-15[0]/powered", 1);
#	setprop("yak-40/instrumentation/ark-15[1]/powered", 1);
	setprop("yak-40/instrumentation/npp/left/zpu", 0.0);
	setprop("yak-40/instrumentation/npp/left/mode", 1);
	setprop("yak-40/instrumentation/uvid-15m-l/powered", 1);
	setprop("yak-40/instrumentation/rv-5m/indicated-altitude-m",0);
	setprop("yak-40/instrumentation/ap40/online-btn",0);
#	rv5m_handler();
	rk();
	iku();
	kppm_l();
	kppm_r();
	fuel_meter();
	altimeter_l_handler();
 	altimeter_r_handler();
	altimeter_l_pressure_handler();
 	altimeter_r_pressure_handler();

	setlistener("instrumentation/altimeter/setting-inhg", altimeter_l_pressure_handler);
	setlistener("instrumentation/altimeter[1]/setting-inhg", altimeter_r_pressure_handler);
}

setlistener("/sim/signals/fdm-initialized", init_instruments);

var angular_lowpass = {
        new: func(coeff) {
                var m = { parents: [angular_lowpass] };
                m.sin = aircraft.lowpass.new(coeff);
                m.cos = aircraft.lowpass.new(coeff);
                m.value = nil;
                return m;
        },
        filter: func(v) {
                v *= D2R;
                me.value = math.atan2(me.sin.filter(math.sin(v)), me.cos.filter(math.cos(v))) * R2D;
		print(me.value);
        },
        set: func(v) {
                v *= D2R;
                me.sin.set(math.sin(v));
                me.cos.set(math.cos(v));
        },
        get: func {
                me.value;
        },
};

var needle_l = aircraft.angular_lowpass.new(0.001);
var needle_r = aircraft.angular_lowpass.new(0.001);
####################
# IKU
####################
iku = func {
   if (getprop("/instrumentation/adf/indicated-bearing-deg")==nil){setprop("/instrumentation/adf/indicated-bearing-deg",0.0);}
   if (getprop("/instrumentation/adf[1]/indicated-bearing-deg")==nil){setprop("/instrumentation/adf[1]/indicated-bearing-deg",0);}
   if (getprop("instrumentation/nav/radials/reciprocal-radial-deg")==nil){setprop("instrumentation/nav/radials/reciprocal-radial-deg",0);}
   if (getprop("instrumentation/nav[1]/radials/reciprocal-radial-deg")==nil){setprop("instrumentation/nav[1]/radials/reciprocal-radial-deg",0);}

   if (getprop("yak-40/instrumentation/iku/l-mode")==0){
    setprop("yak-40/instrumentation/iku/indicated-heading-l",getprop("yak-40/instrumentation/rk/needle1"));
   }

   if (getprop("yak-40/instrumentation/iku/l-mode")==1){
    if (getprop("/instrumentation/nav/nav-id")!=''){
      if (getprop("/instrumentation/nav/radials/reciprocal-radial-deg")>=179 and getprop("/instrumentation/nav/radials/reciprocal-radial-deg")<=181){
	setprop("yak-40/instrumentation/iku/indicated-heading-l",needle_l.filter(getprop("/instrumentation/nav/radials/reciprocal-radial-deg")));
	} else {
	interpolate("yak-40/instrumentation/iku/indicated-heading-l",needle_l.filter(getprop("/instrumentation/nav/radials/reciprocal-radial-deg")),0.05);
	}
      } else {
	if (math.abs(getprop("yak-40/instrumentation/iku/indicated-heading-l") - getprop("/instrumentation/nav/radials/reciprocal-radial-deg"))>3){
	  interpolate("yak-40/instrumentation/iku/indicated-heading-l",getprop("/instrumentation/nav/radials/reciprocal-radial-deg"),1);
	} else {
	  setprop("/instrumentation/nav/radials/reciprocal-radial-deg",rand()*365);
	}
      }
   }

  if (getprop("yak-40/instrumentation/iku/r-mode")==0){
      setprop("yak-40/instrumentation/iku/indicated-heading-r",getprop("yak-40/instrumentation/rk/needle2")); 
   }

   if (getprop("yak-40/instrumentation/iku/r-mode")==1){
    if (getprop("/instrumentation/nav[1]/nav-id")!=''){
      if (getprop("/instrumentation/nav[1]/radials/reciprocal-radial-deg")>=179 and getprop("/instrumentation/nav[1]/radials/reciprocal-radial-deg")<=181){
	setprop("yak-40/instrumentation/iku/indicated-heading-r",needle_r.filter(getprop("/instrumentation/nav[1]/radials/reciprocal-radial-deg")));
	} else {
	interpolate("yak-40/instrumentation/iku/indicated-heading-r",needle_r.filter(getprop("/instrumentation/nav[1]/radials/reciprocal-radial-deg")),0.05);
	}
      } else {
	if (math.abs(getprop("yak-40/instrumentation/iku/indicated-heading-r") - getprop("/instrumentation/nav[1]/radials/reciprocal-radial-deg"))>3){
	  interpolate("yak-40/instrumentation/iku/indicated-heading-r",getprop("/instrumentation/nav[1]/radials/reciprocal-radial-deg"),1);
	} else {
	  setprop("/instrumentation/nav[1]/radials/reciprocal-radial-deg",rand()*365);
	}
      }
   }

   settimer(iku, 0.1); 
}

#############################
# Radio compass
#############################
var needle_1 = aircraft.angular_lowpass.new(0.001);
var needle_2 = aircraft.angular_lowpass.new(0.001);

rk = func {
 
  if (getprop("/instrumentation/adf/ident")!=''){
      if (getprop("/instrumentation/adf/indicated-bearing-deg")>=179 and getprop("/instrumentation/adf/indicated-bearing-deg")<=181){
	setprop("yak-40/instrumentation/rk/needle1",needle_r.filter(getprop("/instrumentation/adf/indicated-bearing-deg")));
	} else {
	interpolate("yak-40/instrumentation/rk/needle1",needle_r.filter(getprop("/instrumentation/adf/indicated-bearing-deg")),0.05);
	}
      } else {
	if (math.abs(getprop("yak-40/instrumentation/rk/needle1") - getprop("/instrumentation/adf/indicated-bearing-deg"))>3){
	  interpolate("yak-40/instrumentation/rk/needle1",getprop("/instrumentation/adf/indicated-bearing-deg"),1);
	} else {
	  setprop("/instrumentation/adf/indicated-bearing-deg",rand()*365);
      }
    }

  if (getprop("/instrumentation/adf[1]/ident")!=''){
      if (getprop("/instrumentation/adf[1]/indicated-bearing-deg")>=179 and getprop("/instrumentation/adf[1]/indicated-bearing-deg")<=181){
	setprop("yak-40/instrumentation/rk/needle2",needle_r.filter(getprop("/instrumentation/adf[1]/indicated-bearing-deg")));
	} else {
	interpolate("yak-40/instrumentation/rk/needle2",needle_r.filter(getprop("/instrumentation/adf[1]/indicated-bearing-deg")),0.05);
	}
      } else {
	if (math.abs(getprop("yak-40/instrumentation/rk/needle2") - getprop("/instrumentation/adf[1]/indicated-bearing-deg"))>3){
	  interpolate("yak-40/instrumentation/rk/needle2",getprop("/instrumentation/adf[1]/indicated-bearing-deg"),1);
	} else {
	  setprop("/instrumentation/adf[1]/indicated-bearing-deg",rand()*365);
      }
    }
  
  settimer(rk, 0.5);
}

#############################
#KPPM left
#############################
kppm_l = func {
  setprop("yak-40/instrumentation/kppm/kurs",getprop("/orientation/heading-magnetic-deg") - getprop("yak-40/instrumentation/kppm/needle"));
  settimer(kppm_l,0);
}

#############################
#KPPM right
#############################
kppm_r = func {
  setprop("yak-40/instrumentation/kppm[1]/needle",getprop("/orientation/heading-magnetic-deg") - getprop("yak-40/instrumentation/kppm[1]/kurs"));
  settimer(kppm_r,0);
}

# 
# ###########################
# # RV-5M support
# rv5m_handler = func{
# settimer( rv5m_handler, 0.1 );
# # Arretir:
# if( getprop("yak-40/instrumentation/rv-5m/caged-flag" ) != 0 )
# 	{
# 	setprop("yak-40/instrumentation/rv-5m/warn", 0 );
# 	setprop("yak-40/instrumentation/rv-5m/indicated-altitude-m", 0.0 );
# 	return;
# 	}
# if( getprop("yak-40/instrumentation/rv-5m/serviceable" ) != 1 ) 
# 	{
#         setprop("yak-40/instrumentation/rv-5m/warn", 0 );
#         return;
# 	}
# # get altitude and check if device is warmed
# #var alt = getprop("fdm/jsbsim/instrumentation/indicated-altitude-m");
# var altf = getprop("fdm/jsbsim/position/h-agl-ft");
# var hot = getprop("yak-40/instrumentation/rv-5m/hot");
# var alt = altf * 0.3048;	# go to meters
# if( alt == nil ) alt = 0.0;
# if( hot == nil ) hot = 0.0;
# if( alt < hot ) alt = hot;
# interpolate("yak-40/instrumentation/rv-5m/indicated-altitude-m", alt-2, 0.1 );
# # check warning
# var limit = getprop("yak-40/instrumentation/rv-5m/index-m");
# if( limit == nil ) return;
# if( alt < limit ) 
# 	{
# 	setprop("yak-40/instrumentation/rv-5m/warn", 1 );
# #	interpolate("tu154/systems/electrical/indicators/radioaltimeter-limit", 1.0, 0.1);
# 	}
# else { 
# 	setprop("yak-40/instrumentation/rv-5m/warn", 0 );
# #	interpolate("tu154/systems/electrical/indicators/radioaltimeter-limit", 0.0, 0.1);
# 	}
# }
# 
# rv5m_power = func{
# if( getprop( "yak-40/switches/rv-5-1" ) == 1.0 )
# 	{
# 	setprop("yak-40/instrumentation/rv-5m/hot", 5000.0 );
# 	setprop("yak-40/instrumentation/rv-5m/serviceable", true );
# 	
# 	}
# else {
# 	setprop("yak-40/instrumentation/rv-5m/hot", 0 );
# 	setprop("yak-40/instrumentation/rv-5m/serviceable", false );
# 	}
# }
# 
# setlistener("yak-40/switches/rv-5-1", rv5m_power,0,0);
# setlistener("yak-40/instrumentation/rv-5m/serviceable", rv5m_power,0,0);
# 
# 
# rv5m_handler();
###########################

# Air speed indicator US-350
# 1 knots = 1.852 km/h
us = func {
    knots=getprop("/instrumentation/airspeed-indicator/indicated-speed-kt");
	alt = getprop( "/fdm/jsbsim/atmosphere/density-altitude" );
    if( knots != nil ){
    #setprop("yak-40/instrumentation/kus-730/indicated-speed-kmh", knots*1.852-(0.0070*alt) );
    setprop("yak-40/instrumentation/kus-730/indicated-speed-kmh", knots*1.852 );
    }
    settimer(us, 0);	# count speed every frame
   }
us ();

usis = func {
    knots=getprop("/instrumentation/airspeed-indicator/true-speed-kt");
    if( knots != nil ){
    setprop("yak-40/instrumentation/kus-730/true-speed-kmh", knots*1.852 );
    }
    settimer(usis, 0);	# count speed every frame
   }
usis ();
# ###########################
# #AGD_L
# #AGD_L Roll
# kren=func {
# oroll=getprop("/fdm/jsbsim/attitude/roll-rad");
# if( oroll !=nil ){
# setprop("yak-40/instrumentation/agd-l/kren-deg", oroll/0.017444 );
# 	}
# settimer(kren, 0); # count speed every frame
# }
# kren();
# ###########################################
# 
# #AGD_L Pitch
# tang=func {
# opitch=getprop("/fdm/jsbsim/attitude/pitch-rad");
# if( opitch != nil){
# setprop("yak-40/instrumentation/agd-l/tang-deg", opitch/0.017444 );
# 	}
# settimer(tang, 0); # count speed every frame
# }
# tang();
# 
# #AGD_L Pitch_Dir
# pitch_dir=func{
# gliss= getprop("/instrumentation/nav[0]/gs-needle-deflection");
# #if( gliss == nil ) { return; }
# if( gliss != nil ){
# setprop("yak-40/instrumentation/agd-l/tang-dir", gliss*0.8 );
# 	}
# settimer(pitch_dir, 0);
# }
# pitch_dir();
# 
# #AGD_L Roll_Dir
# ###########################################
# 
# #TVG cel eng
# 
# converttemp=func {
# var degf = getprop("engines/engine[0]/egt-degf");
# var degf1 = getprop("engines/engine[1]/egt-degf");
# var degf2= getprop("engines/engine[2]/egt-degf");
# if( degf != nil)
# if( degf1 != nil)
# if( degf2 != nil){
# var degc = (degf - 32) * 5/9;
# var degc1 = (degf1 - 32) * 5/9;
# var degc2 = (degf2 - 32) * 5/9;
# 
# setprop("yak-40/instrumentation/tvg_1/egt-degc", degc);
# setprop("yak-40/instrumentation/tvg_2/egt-degc", degc1);
# setprop("yak-40/instrumentation/tvg_3/egt-degc", degc2);
# 	}
# settimer(converttemp, 0);
# }
# converttemp();
# ###########################################
# #TNV cel
# 
# temptnv=func {
# var degc = getprop("environment/temperature-degc");
# 
# if( degc != nil){
# 
# setprop("yak-40/instrumentation/tnv-15/degc", degc);
# 	}
# settimer(temptnv, 0);
# }
# temptnv();
# 
#############################################
# Fuel meter
#
fuel_meter = func {
  var density = 0;
  var fuel_check = getprop("yak-40/switches/sw_fuel_check");
    if (fuel_check==-1) {
      interpolate("yak-40/instrumentation/fuel/indicated-fuel",0,0.2);
    }
    if (fuel_check==1) {
      interpolate("yak-40/instrumentation/fuel/indicated-fuel",44,0.2);
    }
    if (fuel_check==0) {
        if (getprop("yak-40/switches/sw_fuel")==0){ density = getprop("consumables/fuel/tank[0]/level-lbs") + getprop("consumables/fuel/tank[1]/level-lbs"); }
	if (getprop("yak-40/switches/sw_fuel")==-1){ density = getprop("consumables/fuel/tank[0]/level-lbs")*2;}
        if (getprop("yak-40/switches/sw_fuel")==1){ density = getprop("consumables/fuel/tank[1]/level-lbs")*2;}
	density = density * 0.454;
	interpolate("yak-40/instrumentation/fuel/indicated-fuel",density/100,0.2);
    }
   settimer(fuel_meter,0);
}
# # digit wheels support for UVO-15 SVS altimeter
# # meters
rv5m_l = func(step) {
  var rv_alt = getprop("instrumentation/altimeter/indicated-altitude-ft");
  rv_alt = rv_alt * 0.3048;
  var ind_alt = getprop("yak-40/instrumentation/rv-5m/index-m");
  if ( step < 0) {
    if (ind_alt > 99) {
      ind_alt = ind_alt + 10;
    } else {
      ind_alt = ind_alt + 1;
    }
  } else {
    if (ind_alt > 99) {
      ind_alt = ind_alt - 10;
    } else {
      ind_alt = ind_alt - 1;
    }
  }
  if (ind_alt > 700){ ind_alt = 700;}
  if (ind_alt < 0) { ind_alt = 0;}
  
  setprop("yak-40/instrumentation/rv-5m/index-m",ind_alt);
}
var radar_low_pass = aircraft.lowpass.new(1.5);
var radar_alt = props.globals.getNode("/instrumentation/radar-altimeter/radar-altitude-ft", 1);
var radar_alt_lowpass = props.globals.getNode("/instrumentation/radar-altimeter/radar-altitude-lowpass-ft", 1);

radar_altimeter = func {

  if (radar_alt.getValue() != nil)
    {
      radar_low_pass.filter(radar_alt.getValue());
      radar_alt_lowpass.setValue(radar_low_pass.get());
      setprop("yak-40/instrumentation/rv-5m/indicated-altitude-m",getprop("/instrumentation/radar-altimeter/radar-altitude-lowpass-ft") * 0.3048);
    }
  settimer(radar_altimeter, 0);
}

settimer(radar_altimeter, 0);

rv5m_handler = func {
settimer( rv5m_handler,0);
 var rv_alt = getprop("instrumentation/radar/radar-altitude-ft");
 if (rv_alt == nil ) {return};
  rv_alt = rv_alt * 0.3048;
 setprop("yak-40/instrumentation/rv-5m/indicated-altitude-m",rv_alt); 
}

altimeter_l_handler=func {
settimer( altimeter_l_handler, 0 );
  #if( getprop("tu154/systems/svs/powered") != 1 ) return;
  var alt = getprop("instrumentation/altimeter/indicated-altitude-ft");
  
  if( alt == nil ) { return; }
  alt = alt * 0.3048;	# go to meters
  setprop("yak-40/instrumentation/uvid-15m-l/indicated-wheels_dec_m", (alt/10.0) - int( alt/100.0 )*10.0 );
  setprop("yak-40/instrumentation/uvid-15m-l/indicated-wheels_hund_m", (alt/100.0) - int( alt/1000.0 )*10.0 );
  setprop("yak-40/instrumentation/uvid-15m-l/indicated-wheels_ths_m", (alt/1000.0) - int( alt/10000.0 )*10.0 );
  setprop("yak-40/instrumentation/uvid-15m-l/indicated-wheels_decths_m", (alt/10000.0) - int( alt/100000.0 )*10.0 );

}

altimeter_r_handler=func {
settimer( altimeter_r_handler, 0 );
  #if( getprop("tu154/systems/svs/powered") != 1 ) return;
  var alt = getprop("instrumentation/altimeter[1]/indicated-altitude-ft");
  
  if( alt == nil ) { return; }
  alt = alt * 0.3048;	# go to meters
  setprop("yak-40/instrumentation/uvid-15m-r/indicated-wheels_dec_m", (alt/10.0) - int( alt/100.0 )*10.0 );
  setprop("yak-40/instrumentation/uvid-15m-r/indicated-wheels_hund_m", (alt/100.0) - int( alt/1000.0 )*10.0 );
  setprop("yak-40/instrumentation/uvid-15m-r/indicated-wheels_ths_m", (alt/1000.0) - int( alt/10000.0 )*10.0 );
  setprop("yak-40/instrumentation/uvid-15m-r/indicated-wheels_decths_m", (alt/10000.0) - int( alt/100000.0 )*10.0 );

}
# 
# #svs_power = func{
# #if( getprop( "tu154/switches/SVS-power" ) == 1.0 )
# #	electrical.AC3x200_bus_1L.add_output( "SVS", 10.0);
# #else electrical.AC3x200_bus_1L.rm_output( "SVS" );
# #}
# 
# #setlistener("tu154/switches/SVS-power", svs_power, 0, 0);
# 
# 
# 
# # feet
# altimeter2_handler= func {
# settimer( altimeter2_handler, 0 );
# #if( getprop("yak-40/instrumentation/altimeter[1]/powered") != 1 ) return;
# var alt = getprop("instrumentation/altimeter[1]/indicated-altitude-ft");
# if( alt == nil ) { return; }
# 
# setprop("yak-40/instrumentation/altimeter[1]/indicated-wheels_dec_ft", 
# (alt/10.0) - int( alt/100.0 )*10.0 );
# 
# setprop("yak-40/instrumentation/altimeter[1]/indicated-wheels_hund_ft", 
# (alt/100.0) - int( alt/1000.0 )*10.0 );
# 
# setprop("yak-40/instrumentation/altimeter[1]/indicated-wheels_ths_ft", 
# (alt/1000.0) - int( alt/10000.0 )*10.0 );
# 
# setprop("yak-40/instrumentation/altimeter[1]/indicated-wheels_decths_ft", 
# (alt/10000.0) - int( alt/100000.0 )*10.0 );
# }
# 
# #uvid15_power = func{
# #if( getprop( "tu154/switches/UVID" ) == 1.0 )
# #	electrical.AC3x200_bus_1L.add_output( "UVID-15", 10.0);
# #else electrical.AC3x200_bus_1L.rm_output( "UVID-15" );
# #}
# 
# #setlistener("tu154/switches/UVID", uvid15_power, 0, 0 );
# 
# 
#pressure setting
altimeter_l_pressure_handler=func{
  #print("Open handler");
  var pressure = getprop("instrumentation/altimeter/setting-inhg");
  if( pressure == nil ) { return; }
  pressure = pressure * 25.4;	# go to metrics (mmhg)
  #print (pressure);
  setprop("yak-40/instrumentation/uvid-15m-l/mmhg", pressure );
  setprop("yak-40/instrumentation/uvid-15m-l/mmhg-wheels_dec", (pressure/10.0) - int( pressure/100.0 )*10.0 );
  setprop("yak-40/instrumentation/uvid-15m-l/mmhg-wheels_hund", (pressure/100.0) - int( pressure/1000.0 )*10.0 );

}

altimeter_r_pressure_handler=func{
  #print("Open handler");
  var pressure = getprop("instrumentation/altimeter[1]/setting-inhg");
  if( pressure == nil ) { return; }
  pressure = pressure * 25.4;	# go to metrics (mmhg)
  #print (pressure);
  setprop("yak-40/instrumentation/uvid-15m-r/mmhg", pressure );
  setprop("yak-40/instrumentation/uvid-15m-r/mmhg-wheels_dec", (pressure/10.0) - int( pressure/100.0 )*10.0 );
  setprop("yak-40/instrumentation/uvid-15m-r/mmhg-wheels_hund", (pressure/100.0) - int( pressure/1000.0 )*10.0 );

}
# 
# altimeter2_pressure_handler = func{
# var pressure = getprop("instrumentation/altimeter[1]/setting-inhg");
# if( pressure == nil ) { return; }
# pressure = pressure * 100.0;
# setprop("yak-40/instrumentation/altimeter[1]/inhg", pressure );
# 
# setprop("yak-40/instrumentation/altimeter[1]/inhg-wheels_dec", 
# (pressure/10.0) - int( pressure/100.0 )*10.0 );
# 
# setprop("yak-40/instrumentation/altimeter[1]/inhg-wheels_hund", 
# (pressure/100.0) - int( pressure/1000.0 )*10.0 );
# 
# setprop("yak-40/instrumentation/altimeter[1]/inhg-wheels_ths", 
# (pressure/1000.0) - int( pressure/10000.0 )*10.0 );
# }
# 
# 
# setlistener("instrumentation/altimeter[1]/setting-inhg", altimeter2_pressure_handler, 0, 0);
# 
# #####################################################################
# #/fdm/jsbsim/inertia/cg-x-in Центровка в дюймах
# #/fdm/jsbsim/inertia/weight-lbs Вес в фунтах
# #instrumentation/vertical-speed-indicator/indicated-speed-fpm Вертикальная скорость футы в минуту
# #####################################################################
# 
# #CAX ang weight % and kg
# vph=func {
# var cg=getprop("/fdm/jsbsim/inertia/cg-x-in");
# var weight=getprop("/fdm/jsbsim/inertia/weight-lbs");
# if( cg != nil ) {
# setprop("yak-40/instrumentation/vph/cax", ((1040+(cg*25.2))/2970)*100 );
# setprop("yak-40/instrumentation/vph/weight-kg", weight*0.452 );
# 	}
# settimer(vph, 0);
# }
# vph();
# 
# ###################################
# 
# #ACHS-1
# ###################################
# 
# ###########################################
# #MSRP
# msrp=func{
# settimer( msrp, 0 );
# var alt = getprop("instrumentation/altimeter/indicated-altitude-ft");
# var rw_alt = getprop("yak-40/instrumentation/rv-5m/indicated-altitude-m");
# var gear_comp_main = getprop("/gear/gear[1]/compression-norm");
# var kren = getprop("yak-40/instrumentation/agd-l/kren-deg");
# var tang = getprop("yak-40/instrumentation/agd-l/tang-deg");
# var ind_speed = getprop("yak-40/instrumentation/kus-730/indicated-speed-kmh");
# var true_speed = getprop("yak-40/instrumentation/kus-730/true-speed-kmh");
# var weight = getprop("yak-40/instrumentation/vph/weight-kg");
# var cax = getprop("yak-40/instrumentation/vph/cax");
# var tvg = getprop("yak-40/instrumentation/tvg_2/egt-degc");
# var tnv = getprop("yak-40/instrumentation/tnv-15/degc");
# var mkurs = getprop("orientation/heading-magnetic-deg");
# var flaps = getprop("fdm/jsbsim/fcs/flap-pos-deg");
# var gear = getprop("fdm/jsbsim/gear/gear-pos-norm");
# if( alt == nil ) { return; }
# if( rw_alt == nil ) { return; }
# #if( gear_comp_main == nil ) { return; }
# if( kren == nil ) { return; }
# if( tang == nil ) { return; }
# if( ind_speed == nil ) { return; }
# if( true_speed == nil ) { return; }
# if( weight == nil ) { return; }
# if( cax == nil ) { return; }
# if( tvg == nil ) { return; }
# if( tnv == nil ) { return; }
# if( mkurs == nil ) { return; }
# if( flaps == nil ) { return; }
# if( gear == nil ) { return; }
# alt = alt * 0.3048;	# go to meters
#  setprop("yak-40/instrumentation/msrp/alt-m", int(alt));
#  setprop("yak-40/instrumentation/msrp/rv-m", int(rw_alt));
#  setprop("yak-40/instrumentation/msrp/gear_comp_main", int(gear_comp_main));
#  setprop("yak-40/instrumentation/msrp/kren", int(kren));
#  setprop("yak-40/instrumentation/msrp/tang", int(tang));
#  setprop("yak-40/instrumentation/msrp/ind_speed", int(ind_speed));
#  setprop("yak-40/instrumentation/msrp/true_speed", int(true_speed));
#  setprop("yak-40/instrumentation/msrp/weight", int(weight));
#  setprop("yak-40/instrumentation/msrp/cax", int(cax));
#  setprop("yak-40/instrumentation/msrp/tvg", int(tvg));
#  setprop("yak-40/instrumentation/msrp/tnv", int(tnv));
#  setprop("yak-40/instrumentation/msrp/mkurs", int(mkurs));
#  setprop("yak-40/instrumentation/msrp/flaps", int(flaps));
#  setprop("yak-40/instrumentation/msrp/gear", int(gear));
# }
# msrp();
# ############################################################################
# # ARK support
# 
# ark_1_2_handler = func {
# 	var ones = getprop("yak-40/instrumentation/ark-15[0]/digit-2-1");
# 	if( ones == nil ) ones = 0.0;
# 	var dec = getprop("yak-40/instrumentation/ark-15[0]/digit-2-2");
# 	if( dec == nil ) dec = 0.0;
# 	var hund = getprop("yak-40/instrumentation/ark-15[0]/digit-2-3");
# 	if( hund == nil ) hund = 0.0;
# 	var freq = hund * 100 + dec * 10 + ones;
# 	if( getprop("yak-40/switches/adf-1-selector") == 1 )
# 		setprop("/instrumentation/adf[0]/frequencies/selected-khz", freq );
# }
# 
# ark_1_1_handler = func {
# 	var ones = getprop("yak-40/instrumentation/ark-15[0]/digit-1-1");
# 	if( ones == nil ) ones = 0.0;
# 	var dec = getprop("yak-40/instrumentation/ark-15[0]/digit-1-2");
# 	if( dec == nil ) dec = 0.0;
# 	var hund = getprop("yak-40/instrumentation/ark-15[0]/digit-1-3");
# 	if( hund == nil ) hund = 0.0;
# 	var freq = hund * 100 + dec * 10 + ones;
# 	if( getprop("yak-40/switches/adf-1-selector") == 0 )
# 		setprop("/instrumentation/adf[0]/frequencies/selected-khz", freq );
# }
# 
# ark_2_2_handler = func {
# 	var ones = getprop("yak-40/instrumentation/ark-15[1]/digit-2-1");
# 	if( ones == nil ) ones = 0.0;
# 	var dec = getprop("yak-40/instrumentation/ark-15[1]/digit-2-2");
# 	if( dec == nil ) dec = 0.0;
# 	var hund = getprop("yak-40/instrumentation/ark-15[1]/digit-2-3");
# 	if( hund == nil ) hund = 0.0;
# 	var freq = hund * 100 + dec * 10 + ones;
# 	if( getprop("yak-40/switches/adf-2-selector") == 1 )
# 		setprop("/instrumentation/adf[1]/frequencies/selected-khz", freq );
# }
# 
# ark_2_1_handler = func {
# 	var ones = getprop("yak-40/instrumentation/ark-15[1]/digit-1-1");
# 	if( ones == nil ) ones = 0.0;
# 	var dec = getprop("yak-40/instrumentation/ark-15[1]/digit-1-2");
# 	if( dec == nil ) dec = 0.0;
# 	var hund = getprop("yak-40/instrumentation/ark-15[1]/digit-1-3");
# 	if( hund == nil ) hund = 0.0;
# 	var freq = hund * 100 + dec * 10 + ones;
# 	if( getprop("yak-40/switches/adf-2-selector") == 0 )
# 		setprop("/instrumentation/adf[1]/frequencies/selected-khz", freq );
# }
# 
# ark_1_power= func{
#     if( getprop("yak-40/instrumentation/ark-15[0]/powered") == 1 )
# 	{
#     	if( getprop("yak-40/switches/adf-power-1")==1 )
# 		{
# 	     setprop("/instrumentation/adf[0]/serviceable", 1 );
# 		}
#  	else {
# 	     setprop("/instrumentation/adf[0]/serviceable", 1 );
# 	     }
# 	} 
#    else {
# 	setprop("/instrumentation/adf[0]/serviceable", 1 );
# 	}
# }
# 
# ark_2_power= func{
#     if( getprop("yak-40/instrumentation/ark-15[1]/powered") == 1 )
# 	{
#     	if( getprop("yak-40/switches/adf-power-2")==1 )
# 		{
# 	     setprop("/instrumentation/adf[1]/serviceable", 1 );
# 		}
#  	else {
# 	     setprop("/instrumentation/adf[1]/serviceable", 1 );
# 		}
# 	} 
#    else {
# 	setprop("/instrumentation/adf[1]/serviceable", 1 );
# 	}
# }
# 
# 
# # read selected and standby ADF frequencies and copy it to ARK
# ark_init = func{
# var freq = getprop("/instrumentation/adf[0]/frequencies/selected-khz");
# if( freq == nil ) freq = 0.0;
# setprop("yak-40/instrumentation/ark-15[0]/digit-1-3", 
# int( (freq/100.0) - int( freq/1000.0 )*10.0 ) );
# setprop("yak-40/instrumentation/ark-15[0]/digit-1-2", 
# int( (freq/10.0) - int( freq/100.0 )*10.0 ) );
# setprop("yak-40/instrumentation/ark-15[0]/digit-1-1", 
# int( freq - int( freq/10.0 )*10.0 ) );
# 
# freq = getprop("/instrumentation/adf[0]/frequencies/standby-khz");
# if( freq == nil ) freq = 0.0;
# setprop("yak-40/instrumentation/ark-15[0]/digit-2-3", 
# int( (freq/100.0) - int( freq/1000.0 )*10.0 ) );
# setprop("yak-40/instrumentation/ark-15[0]/digit-2-2", 
# int( (freq/10.0) - int( freq/100.0 )*10.0 ) );
# setprop("yak-40/instrumentation/ark-15[0]/digit-2-1", 
# int( freq - int( freq/10.0 )*10.0 ) );
# 
# freq = getprop("/instrumentation/adf[1]/frequencies/selected-khz");
# if( freq == nil ) freq = 0.0;
# setprop("yak-40/instrumentation/ark-15[1]/digit-1-3", 
# int( (freq/100.0) - int( freq/1000.0 )*10.0 ) );
# setprop("yak-40/instrumentation/ark-15[1]/digit-1-2", 
# int( (freq/10.0) - int( freq/100.0 )*10.0 ) );
# setprop("yak-40/instrumentation/ark-15[1]/digit-1-1", 
# int( freq - int( freq/10.0 )*10.0 ) );
# 
# freq = getprop("/instrumentation/adf[1]/frequencies/standby-khz");
# if( freq == nil ) freq = 0.0;
# setprop("yak-40/instrumentation/ark-15[1]/digit-2-3", 
# int( (freq/100.0) - int( freq/1000.0 )*10.0 ) );
# setprop("yak-40/instrumentation/ark-15[1]/digit-2-2", 
# int( (freq/10.0) - int( freq/100.0 )*10.0 ) );
# setprop("yak-40/instrumentation/ark-15[1]/digit-2-1", 
# int( freq - int( freq/10.0 )*10.0 ) );
# 
# }
# 
# ark_init();
# 
# setlistener("yak-40/switches/adf-power-1", ark_1_power ,0,0);
# setlistener("yak-40/switches/adf-power-2", ark_2_power ,0,0);
# #setlistener("yak-40/switchesyak-40/switches/AZ_ARK_1", ark_1_power ,0,0);
# #setlistener("yak-40/switchesyak-40/switches/AZ_ARK_2", ark_2_power ,0,0);
# 
# setlistener( "yak-40/instrumentation/ark-15[0]/powered", ark_1_power ,0,0);
# setlistener( "yak-40/instrumentation/ark-15[1]/powered", ark_2_power ,0,0);
# 
# 
# setlistener( "yak-40/switches/adf-1-selector", ark_1_1_handler ,0,0);
# setlistener( "yak-40/switches/adf-1-selector", ark_1_2_handler ,0,0);
# 
# setlistener( "yak-40/switches/adf-2-selector", ark_2_1_handler ,0,0);
# setlistener( "yak-40/switches/adf-2-selector", ark_2_2_handler ,0,0);
# 
# setlistener( "yak-40/instrumentation/ark-15[0]/digit-1-1", ark_1_1_handler ,0,0);
# setlistener( "yak-40/instrumentation/ark-15[0]/digit-1-2", ark_1_1_handler ,0,0);
# setlistener( "yak-40/instrumentation/ark-15[0]/digit-1-3", ark_1_1_handler ,0,0);
# 
# setlistener( "yak-40/instrumentation/ark-15[0]/digit-2-1", ark_1_2_handler ,0,0);
# setlistener( "yak-40/instrumentation/ark-15[0]/digit-2-2", ark_1_2_handler ,0,0);
# setlistener( "yak-40/instrumentation/ark-15[0]/digit-2-3", ark_1_2_handler ,0,0);
# 
# setlistener( "yak-40/instrumentation/ark-15[1]/digit-1-1", ark_2_1_handler ,0,0);
# setlistener( "yak-40/instrumentation/ark-15[1]/digit-1-2", ark_2_1_handler ,0,0);
# setlistener( "yak-40/instrumentation/ark-15[1]/digit-1-3", ark_2_1_handler ,0,0);
# 
# setlistener( "yak-40/instrumentation/ark-15[1]/digit-2-1", ark_2_2_handler ,0,0);
# setlistener( "yak-40/instrumentation/ark-15[1]/digit-2-2", ark_2_2_handler ,0,0);
# setlistener( "yak-40/instrumentation/ark-15[1]/digit-2-3", ark_2_2_handler ,0,0);
# 
# 
# 
# ############################################################################
# # IKU support
# iku_handler = func {
# settimer( iku_handler, 0.1 );
# 
# 
# #Captain panel
# # yellow needle
# var sel_yellow = getprop("yak-40/instrumentation/iku/l-mode");
# if( sel_yellow == nil ) sel_yellow = 0.0;
# var param_yellow = getprop("instrumentation/nav[0]/radials/reciprocal-radial-deg");
# if( param_yellow == nil ) param_yellow = 0.0;
# var compass = getprop("/orientation/heading-magnetic-deg");
# if( compass == nil ) compass = 0.0;
# if( sel_yellow == 0.0 ) # ADF
# 	param_yellow = getprop("instrumentation/adf[0]/indicated-bearing-deg");
# else param_yellow -= compass;
# if( param_yellow == nil ) param_yellow = 0.0;
# setprop("yak-40/instrumentation/iku/indicated-heading-l", param_yellow );
# # White needle
# var sel_white = getprop("yak-40/instrumentation/iku/r-mode");
# if( sel_white == nil ) sel_white = 0.0;
# var param_white = getprop("instrumentation/nav[1]/radials/reciprocal-radial-deg");
# if( param_white == nil ) param_white = 0.0;
# if( sel_white == 0.0 ) # ADF
# 	param_white = getprop("instrumentation/adf[1]/indicated-bearing-deg");
# else param_white -= compass;
# if( param_white == nil ) param_white = 0.0;
# setprop("yak-40/instrumentation/iku/indicated-heading-r", param_white );
# }
# 
# iku_handler();
# 
# # Heading (yellow index, left handle)
# 
# compass_adjust_hdg = func {
# var prop = "yak-40/instrumentation/iku/heading-deg";
# if( arg[0] == 1 ) prop = "yak-40/instrumentation/iku/heading-deg";
# 
# var delta = arg[1];
# var heading = getprop( prop );
# if( heading == nil ) return;
# 
# heading = heading + delta;
# if( heading >= 360.0 ) heading = heading - 360.0;
# if( 0 > heading ) heading = heading + 360.0; 
# setprop( prop, heading );
# # proceed delayed property for smooth digit wheel animation
# prop = sprintf("%s-delayed", prop);
# interpolate( prop, heading, 0.2 );
# 
# }
# 
# # "Plane" (white needle, right handle with plane symbol)
# 
# compass_adjust_plane = func {
# var prop = "yak-40/instrumentation/iku/plane-deg";
# if( arg[0] == 1 ) prop = "yak-40/instrumentation/iku/plane-deg";
# 
# var delta = arg[1];
# # proceed delayed property for smooth digit wheel animation
# var delayed_prop = sprintf("%s-delayed", prop);
# var local_prop = sprintf("%s-local", prop);
# 
# var heading = getprop( local_prop );
# if( heading == nil ) return;
# heading = heading + delta;
# if( heading >= 360.0 ) heading = heading - 360.0;
# if( 0 > heading ) heading = heading + 360.0; 
# 
# setprop( local_prop, heading );
# interpolate( delayed_prop, heading, 0.2 );
# # proceed white needle
# 
#       setprop( "yak-40/instrumentation/iku/plane-deg", heading );
#       setprop( "yak-40/instrumentation/iku/plane-deg", heading );
#       
# }
# #########################################################################
# #NPP
# 
#     npp1= func {
#  
# #  s1 = getprop("/controls/electric/battery-switch");
#  
# #  s3 = getprop("/controls/switches/master-avionics");  
#  
#   
# #if( s1 == nil ){
# #    return ( settimer(npp1, 2) );  
# #    }
# 
# #if( s3 == nil ){
# #    return ( settimer(npp1, 2) );  
# #   }
#     
#     
#     d1 = getprop("/orientation/heading-magnetic-deg");
#     d2 = getprop("yak-40/instrumentation/iku/indicated-heading-l");
# #    d3 = getprop("IL-76/systems/tks/id3_1/indicated-heading-deg");
# #    d4 = getprop("yak-40/instrumentation/npp/left/mode");
#     d5 = getprop("yak-40/instrumentation/npp/left/zpu");
#     if( d1 == nil ) d1 = 0.0;
#     if( d2 == nil ) d2 = 0.0;
#  #   if( d3 == nil ) d3 = 0.0;
#     if( d5 == nil ) d5 = 0.0;
#     
# #   if( d4 == 0 ){ setprop("yak-40/instrumentation/npp/left/indicated-heading-deg", d1);}else{
#    setprop("yak-40/instrumentation/npp/left/indicated-heading-deg", d1);
#    
#   
#    
#    z1 = d1 + d5;
#    if( z1 >= 360.0 ) z1 = z1 - 360.0;
#    #if( z1 < 0.0 ) z1 = z1 + 360.0;
#    
#    
#    d2 = d2 + 180;
#    if( 0 > d2  ) d2 = d2 + 360.0;
#    
# 
#   setprop("yak-40/instrumentation/npp/left/indicated-angle", d2);
#   setprop("yak-40/instrumentation/npp/left/indicated-zpu", z1);
#     
#   settimer(npp1, 0);
#   }
#   npp1 ();
# #########################################################################
# #KPP
# 
# #########################################################################
# #AP-40
# #Power
# 
# appower= func{
# vk_ap = getprop("yak-40/switches/vk_ap");
# t_ap = getprop("yak-40/switches/t_ap");
# 
# 
# 
# if( vk_ap == nil ) return;
# if( t_ap == nil ) return;
# 
# 
# 
# if( vk_ap == 1 ){
# setprop("yak-40/instrumentation/ap40/serviceable", 1 );
# }else{
# setprop("yak-40/instrumentation/ap40/serviceable", 0);
# }
# if(( vk_ap == 1 ) and ( t_ap == 1)){
#  setprop("yak-40/instrumentation/ap40/tangag", 1);
#  }else
#  if(( vk_ap == 1 ) and ( t_ap == 0))
#  {
# setprop("yak-40/instrumentation/ap40/tangag", 0);
# }
# 
# settimer(appower, 0);
# }
# appower ();
# #####################################################
# 
# ################################
# #On
 var ap_online = func{
	print("AP Online");
# 	var  power = getprop("yak-40/instrumentation/ap40/serviceable");
# 	var  tangag = getprop("yak-40/instrumentation/ap40/tangag");
# 	var  ap_but = getprop("yak-40/switches/vkl_ap");
# 
# 	if( power == nil ) return;
# 	if( tangag == nil ) return;
# 	if( ap_but == nil ) return;
# 	
# 	if(( power == 1 ) and ( tangag == 1 ) and ( ap_but == 1 ))
# 	{
# 	setprop("/autopilot/internal/target-roll-deg", 0.0 );
# 	setprop("/autopilot/settings/target-pitch-deg", int(getprop("yak-40/instrumentation/agd-l/tang-deg")) );
# 	setprop("/autopilot/locks/altitude", "pitch-hold" );
# 	setprop("/autopilot/settings/heading-bug-deg", getprop("yak-40/instrumentation/npp/left/indicated-heading-deg") );
# 	setprop("/autopilot/locks/heading", "dg-heading-hold" );
# 	setprop("yak-40/instrumentation/ap40/ap_on", 1 );
# 	setprop("input/joysticks/js/axis[0])/binding/factor", 0.00001);
# 	setprop("input/joysticks/js/axis[1])/binding/factor", -0.00001);
# 	setprop("input/joysticks/js/axis[2])/binding/factor", 0.00001);
# 	help.messenger("Autopilot ON: Heading lock , pitch lock");
# 	}
# 	else
# 	if(( power == 1 ) and ( tangag == 1 ) and ( ap_but == 0 ))
# 	{
# 	help.messenger("Autopilot OFF");
# 	setprop("/autopilot/internal/target-roll-deg", 0.0 );
# 	setprop("/autopilot/locks/altitude", "" );
# 	setprop("yak-40/instrumentation/ap40/althold", 0 );
# 	setprop("yak-40/instrumentation/ap40/ap_on", 0 );
# 	setprop("/autopilot/locks/heading", "" );
# 	setprop("input/joysticks/js/axis[0])/binding/factor", 1);
# 	setprop("input/joysticks/js/axis[1])/binding/factor", -1);
# 	setprop("input/joysticks/js/axis[2])/binding/factor", 1);
# 	}
 }
 
 var ap_alt = func{
	print("ALT on");
 }
# 
# #####################################################
# #Ap-job
# 
# #######################################################
# #Alt-hold
# var ap_althold = func{
# 	var  power = getprop("yak-40/instrumentation/ap40/serviceable");
# 	var  tangag = getprop("yak-40/instrumentation/ap40/tangag");
# 	var  ap_but = getprop("yak-40/switches/vkl_ap");
# 	var	h_ap = getprop("yak-40/switches/h_ap");
# 
# 	if( power == nil ) return;
# 	if( tangag == nil ) return;
# 	if( ap_but == nil ) return;
# 	if( h_ap == nil ) return;
# 	
# 	if(( power == 1 ) and ( tangag == 1 ) and ( ap_but == 1 ) and ( h_ap == 1 ))
# 	{
# 	setprop("/autopilot/settings/target-altitude-ft", int(getprop("instrumentation/altimeter/indicated-altitude-ft")) );
# 	setprop("/autopilot/locks/altitude", "altitude-hold" );
# 	setprop("yak-40/instrumentation/ap40/althold", 1 );
# 	help.messenger("Autopilot ON: Heading lock , Alt-hold");
# 	}
# 	else
# 	if(( power == 1 ) and ( tangag == 1 ) and ( ap_but == 1 ) and ( h_ap == 0 ))
# 	{
# 	help.messenger("Autopilot ON: Heading lock , pitch lock");
# 	setprop("/autopilot/locks/altitude", "pitch-hold" );
# # setprop("yak-40/instrumentation/ap40/althold", 0 );
# 	}
# }
# 
# 
# #########################################################
# #Wing-level
# 
# #Pitch up
# #Pitch down
# #Left kren
# #Right kren
# 
# 
