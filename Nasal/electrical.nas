# Pilot40&CAXAP
# Yak-40 electrical system.
print("Initializing Electrical System");

var UPDATE_PERIOD = 0.3;

var enode="yak-40/systems/electrical/";
var swnode = "yak-40/switches/";

var battery1 = nil;
var battery2 = nil;

var gen1 = nil;
var gen2 = nil;
var gen3 = nil;

var rap_28 = nil;
var rap_115 = nil;

var po1500_1 = nil;
var po1500_2 = nil;

var po500_1 = nil;
var po500_2 = nil;

var bus27 = nil;
var bus115 = nil;
var bus36 = nil;

var ite2t_1 = nil;
var ite2t_2 = nil;
var ite2t_3 = nil;
var adp = nil;

var beacon = aircraft.light.new( "/sim/model/lights/beacon", [0.05, 0.05] );
beacon.interval = 0;

init_electrical = func {
    
    print("Initializing Nasal Electrical System");

    battery1 = BatteryClass.new( "A20NKBN25-1" );
    battery2 = BatteryClass.new( "A20NKBN25-2" );
    
    gen1 = DCAlternatorClass.new( "gen1" );
    gen1.rpm_source( props.globals.getNode("engines/engine[0]") );
    gen2 = DCAlternatorClass.new( "gen2" );
    gen2.rpm_source( props.globals.getNode("engines/engine[1]") );
    gen3 = DCAlternatorClass.new( "gen3" );
    gen3.rpm_source( props.globals.getNode("engines/engine[2]") );
    
    rap_28 = ExternalClass.new("rap_28");
    rap_115 = ExternalClass.new("rap_115");

    

    po1500_1 = DCACinverterClass.new("PO-1500-1", 1.33 );
    
    po1500_2 = DCACinverterClass.new("PO-1500-2", 1.33 );
    
    po500_1 = DCACinverterClass.new("PT-500-1", 4.26 );
    po500_2 = DCACinverterClass.new("PT-500-2", 4.26 );
        
    bus27 = DCBusClass.new( "bus27");
        
    bus36 = ACBusClass.new( "AC3x36-bus" );
   
    bus115 = ACBusClass.new( "AC1x115-bus" );
    
    bus36.add_input( po1500_1 );

    init_users();
    init_switches();
    

    settimer(update_buses_handler, UPDATE_PERIOD );
    settimer(update_electrical, UPDATE_PERIOD );

}

init_switches = func{
 
  setprop("yak-40/switches/power_sw", 0);
  setprop("yak-40/switches/po1500_1", 0);
  setprop("yak-40/switches/po1500_2", 0);
  setprop("yak-40/switches/az_adp", 0);
  setprop("yak-40/switches/az_agd_r", 0);
  setprop("yak-40/switches/az_ob_eng_1", 0);
  setprop("yak-40/switches/az_ob_eng_2", 0);
  setprop("yak-40/switches/az_ob_eng_3", 0);
}

init_users = func{
    ite2t_1 = UserClass.new("instrumentation", "ite2t_1");
    ite2t_2 = UserClass.new("instrumentation", "ite2t_2");
    ite2t_3 = UserClass.new("instrumentation", "ite2t_3");
    adp = UserClass.new("instrumentation", "adp");

    setlistener("yak-40/switches/po1500_1", PO1500_1_on_bus_handler);
    setlistener("yak-40/switches/az_ob_eng_1", az_ob_eng_1_handler);
    setlistener("yak-40/switches/az_ob_eng_2", az_ob_eng_2_handler);
    setlistener("yak-40/switches/az_ob_eng_3", az_ob_eng_3_handler);
    setlistener("yak-40/switches/power_sw", battery_handler);
    setlistener("yak-40/switches/az_adp", az_adp_handler);

}

update_buses_handler = func{

    update_users();
    bus36.update_voltage();
#    AC1x115_bus.update_voltage();

    bus27.update_voltage();
#    DC27_bus.update_voltage();
#    Error_bus.update_voltage();
    
#    PO_4500_1.update();
#    PO_4500_2.update();
    
#    0_1_bus.update_voltage();
#    PT_1000_1_bus.update_load();
    
    po1500_1.update();
#    PT_1000_2.update();
    
    bus36.update_load();
#    AC1x115_bus.update_load();
    
    bus27.update_load();
#    DC27_bus.update_load();
#    Error_bus.update_load();
    
    settimer(update_buses_handler, UPDATE_PERIOD );
    settimer(update_users, UPDATE_PERIOD );
    
}

update_users = func{
    adp.update_voltage();
    ite2t_1.update_voltage();
    ite2t_2.update_voltage();
    ite2t_3.update_voltage();
}

setlistener("/sim/signals/fdm-initialized", init_electrical);

battery_handler = func{
    if( getprop("yak-40/switches/power_sw")==1 ){
	bus27.add_input( battery1 );
	battery1.connect_to_bus( bus27 );
	print("Batery 1 On");
	bus27.add_input( battery2 );
	battery2.connect_to_bus( bus27 );
	print("Batery 2 On");
    } 
    if( getprop("yak-40/switches/power_sw")==0 ){
	bus27.rm_input( battery1.name );
	battery1.disconnect_from_bus();
	print("Battery 1 Off");
	bus27.rm_input( battery2.name );
	battery2.disconnect_from_bus();
	print("Battery 2 Off");
    }
}

update_electrical = func {
    settimer(update_electrical, UPDATE_PERIOD);
}

PO1500_1_on_bus_handler = func {
  
  if (getprop("yak-40/switches/po1500_1") == 1) {
      po1500_1.add_input( bus27 );
      print ("PO-1500 on bus");
    } else {
      po1500_1.rm_input( "bus27" );
      print ("PO-1500 out bus");
    }
}

az_ob_eng_1_handler = func {
  if( getprop("yak-40/switches/az_ob_eng_1")==1 ){
	bus27.add_output(ite2t_1, 10);
	ite2t_1.add_input( bus27 );
	print("Engine indicator 1 on");
    } else {
	bus27.rm_output("ite2t_1");
	ite2t_1.rm_input( "bus27");
	print("Engine indicator 1 off");
    }
}

az_ob_eng_2_handler = func {
  if( getprop("yak-40/switches/az_ob_eng_2")==1 ){
	bus27.add_output(ite2t_2, 10);
	ite2t_2.add_input( bus27 );
	print("Engine indicator 2 on");
    } else {
	bus27.rm_output("ite2t_2");
	ite2t_2.rm_input( "bus27");
	print("Engine indicator 2 off");
    }
}

az_ob_eng_3_handler = func {
  if( getprop("yak-40/switches/az_ob_eng_3")==1 ){
	bus27.add_output(ite2t_3, 10);
	ite2t_3.add_input( bus27 );
	print("Engine indicator 3 on");
    } else {
	bus27.rm_output("ite2t_3");
	ite2t_3.rm_input( "bus27");
	print("Engine indicator 3 off");
    }
}
	
az_adp_handler = func {
  if( getprop("yak-40/switches/az_adp")==1 ){
	bus27.add_output(adp, 10);
	adp.add_input( bus27 );
	print("ADP on");
    } else {
	bus27.rm_output("adp");
	adp.rm_input( "bus27");
	print("ADP off");
    }
}


###########################################################

#---- Buses -----

DCBusClass = {};

DCBusClass.new = func( name ) {
    obj = { parents : [DCBusClass],
#	    node :  props.globals.getNode( enode ~ "buses/" ~ name , 1 ),
	    node :  enode ~ "buses/" ~ name ~"/" ,
	    name :  name,
	    volts :  props.globals.getNode( enode ~ "buses/" ~ name ~ "/volts", 1 ),
	    load : props.globals.getNode( enode ~ "buses/" ~ name ~ "/load", 1 ),
	    inputs : props.globals.getNode( enode ~ "buses/" ~ name ~ "/inputs", 1 ),
	    outputs : props.globals.getNode( enode ~ "buses/" ~ name ~ "/ouputs", 1 ) };
    obj.volts.setValue(0.0);
    obj.load.setValue(0.0);
    return obj;
}

DCBusClass.add_input = func( obj ) {
    me.inputs.getNode( obj.name, 1).setValue( obj.node );
}

DCBusClass.add_output = func( obj, load ) {
    me.outputs.getNode( obj.name, 1).setValues({ "load" : load});
}

DCBusClass.rm_input = func( name ) {
    me.inputs.removeChild( name,0 );
}

DCBusClass.rm_output = func( name ) {
    me.outputs.removeChild( name,0 );
}

DCBusClass.voltage = func {
    return me.volts.getValue();
}

DCBusClass.update_input = func( name, volts ) {
    me.inputs.getNode( name ).setValues( { "volts" : volts } );
}

DCBusClass.update_output = func( name, load ) {
    me.ouputs.getNode( name ).setValues( { name : load } );
}

DCBusClass.update_load = func {
    load = 0.0;
    outputs =  me.outputs.getChildren();
    if(outputs == nil) return;
    foreach( output; outputs ){
	load += output.getNode("load").getValue();
    }
    me.load.setValue( load );
}

DCBusClass.update_voltage = func {
    volts = 0.0;
    foreach( input; me.inputs.getChildren() ){
	ivolts = props.globals.getNode( input.getValue() ~ "volts" ).getValue();
	volts = volts < ivolts ? ivolts : volts;
    }
    me.volts.setValue( volts );
}


ACBusClass = {};

ACBusClass.new = func( name ) {
    obj = { parents : [ACBusClass],
#	    node :  props.globals.getNode( enode ~ "buses/" ~ name , 1 ),
	    node :  enode ~ "buses/" ~ name ~ "/",
	    name :  name,
	    volts :  props.globals.getNode( enode ~ "buses/" ~ name ~ "/volts", 1 ),
	    load : props.globals.getNode( enode ~ "buses/" ~ name ~ "/load", 1 ),
	    frequency: props.globals.getNode( enode ~ "buses/" ~ name ~ "/frequency", 1 ),
	    inputs : props.globals.getNode( enode ~ "buses/" ~ name ~ "/inputs", 1 ),
	    outputs : props.globals.getNode( enode ~ "buses/" ~ name ~ "/ouputs", 1 ) };
    obj.volts.setValue(0.0);
    obj.load.setValue(0.0);
    obj.frequency.setValue(0.0);
    return obj;
}

ACBusClass.add_input = func( obj  ) {
    me.inputs.getNode( obj.name, 1).setValue( obj.node );
}

ACBusClass.add_output = func( name, load ) {
    me.outputs.getNode( name, 1).setValues({ "load" : load});
}

ACBusClass.rm_input = func( name ) {
    me.inputs.removeChild( name,0 );
}

ACBusClass.rm_output = func( name ) {
    me.outputs.removeChild( name,0 );
}

ACBusClass.voltage = func {
    return me.volts.getValue();
}

ACBusClass.update_intput = func( name, volts, freq ) {
    me.inputs.getNode( name ).setValues( { "volts" : volts, "frequency": freq } );
}

ACBusClass.update_output = func( name, load ) {
    me.ouputs.getNode( name ).setValues( { "load" : load } );
}

ACBusClass.update_load = func {
    load = 0.0;
    outputs = me.outputs.getChildren();
    if(outputs == nil) return;
    foreach( output;  outputs ){
	load += output.getNode("load").getValue();
    }
    me.load.setValue( load );
}

ACBusClass.update_voltage = func {
    volts = 0.0;
    freq = 0.0;
    foreach( input; me.inputs.getChildren() ){
	ivolts = getprop( input.getValue() ~ "/volts" );
	ifreq  = getprop( input.getValue() ~ "/frequency" );
       	freq   = volts < ivolts ? ifreq : me.frequency.getValue();
	volts  = volts < ivolts ? ivolts : volts;
    }
    me.volts.setValue( volts );
    me.frequency.setValue( freq );
}

#---- Batterys ------

BatteryClass = {};
BatteryClass.new = func ( name ) {
    obj = { parents : [BatteryClass],
	    name : name,
	    node :   enode ~ "suppliers/" ~ name ~ "/",
	    volts :  props.globals.getNode( enode ~ "suppliers/" ~ name ~ "/volts", 1 ),
            bus :  nil,
            ideal_volts : 27.0,
            ideal_amps : 30.0,
            amp_hours : 25.0,
            charge_percent : 1.0,
            charge_amps : 7.0 };
    obj.volts.setValue(27.0);
    return obj;
}
BatteryClass.apply_load = func( amps, dt ) {
    amphrs_used = amps * dt / 3600.0;
    percent_used = amphrs_used / me.amp_hours;
    me.charge_percent -= percent_used;
    if ( me.charge_percent < 0.0 ) {
        me.charge_percent = 0.0;
    } elsif ( me.charge_percent > 1.0 ) {
        me.charge_percent = 1.0;
    }
    return me.amp_hours * me.charge_percent;
}
BatteryClass.get_output_volts = func {
    x = 1.0 - me.charge_percent;
    factor = x / 10;
    return me.ideal_volts - factor;
}
BatteryClass.get_output_amps = func {
    x = 1.0 - me.charge_percent;
    tmp = -(3.0 * x - 1.0);
    factor = (tmp*tmp*tmp*tmp*tmp + 32) / 32;
    return me.ideal_amps * factor;
}

BatteryClass.connect_to_bus = func( _bus ){
    me.bus = _bus;
}

BatteryClass.disconnect_from_bus = func{
    me.bus = nil;
}

#---- Alernators

DCAlternatorClass = {};
DCAlternatorClass.new = func( name ) {
    obj = { parents : [DCAlternatorClass],
	    name : name,
	    node :  enode ~ "suppliers/" ~ name ~ "/",
	    volts :   props.globals.getNode( enode ~ "suppliers/" ~ name ~ "/volts", 1 ),
	    engine : nil,
	    bus : nil,
            ideal_volts : 28.5,
	    ideal_amps : 600.0 };
    props.globals.getNode(obj.node,1).setValues({ "volts": 0.0} );
    return obj;
}


DCAlternatorClass.apply_load = func( amps, dt ) {
    rpm = me.engine.getNode("rpm").getValue();
    available_amps = me.ideal_amps * math.ln(rpm)/9;
    return available_amps - amps;
}

DCAlternatorClass.rpm_handler = func {
    rpm = me.engine.getNode("rpm").getValue();
    if( rpm < 1000.0 ) volts = 0.0;
    else volts = me.ideal_volts*math.ln(rpm)/9;
    me.volts.setValue( volts );
    if( me.bus != nil ) setprop(me.bus.volts, volts );
}

DCAlternatorClass.get_output_amps = func(src ){
    rpm = getprop( src );
    if( rpm == nil ) rpm = 0;
    # APU can have 0 rpm
    if (rpm < 1000.0 ) {
        factor = 0;
    } else {
        factor = math.ln(rpm)/4;
    }
    return me.ideal_amps * factor;
}

DCAlternatorClass.connect_to_bus = func( _bus ){
    me.bus = _bus;
}

DCAlternatorClass.disconnect_from_bus = func{
    me.bus = nil;
}

DCAlternatorClass.rpm_source = func( eng ){
    me.engine = eng;
}

DCAlternatorClass.voltage = func( eng ){
    return me.volts.getValue();
}

TransformerClass = {};

TransformerClass.new = func( name, coeff ) {
    obj = { parents : [TransformerClass],
	    name : name,
	    node :  enode ~ "suppliers/" ~ name ~ "/",
	    volts :   props.globals.getNode( enode ~ "suppliers/" ~ name ~ "/volts", 1 ),
	    frequency :  props.globals.getNode( enode ~ "suppliers/" ~ name ~ "/frequency", 1 ),
	    input : nil,
	    output : nil,
	    trans_coeff : coeff };
    props.globals.getNode(obj.node,1).setValues({ "volts": 0.0, "frequency" : 400.0} );
    return obj;
}

TransformerClass.add_input = func( obj ){
    me.input = obj;
}

TransformerClass.output = func( obj ){
    me.output = obj;
}

TransformerClass.update = func{
    volts = me.input == nil ? 0.0 : me.input.volts.getValue()*me.trans_coeff ;
    me.volts.setValue(volts);
}

ACDCconverterClass = {};

ACDCconverterClass.new = func( name, coeff ) {
    obj = { parents : [ACDCconverterClass],
	    name : name,
	    node :  enode ~ "suppliers/" ~ name ~ "/",
	    volts :   props.globals.getNode( enode ~ "suppliers/" ~ name ~ "/volts", 1 ),
	    frequency :  props.globals.getNode( enode ~ "suppliers/" ~ name ~ "/frequency", 1 ),
	    input : nil,
	    output : nil,
	    conv_coeff : coeff };
    props.globals.getNode(obj.node,1).setValues({ "volts": 0.0, "frequency" : 400.0} );
    return obj;
}

ACDCconverterClass.add_input = func( obj ){
    me.input = obj;
}

ACDCconverterClass.output = func( obj ){
    me.output = obj;
}

ACDCconverterClass.update = func{
    volts = me.input == nil ? 0.0 : me.input.volts.getValue()*me.conv_coeff ;
    me.volts.setValue(volts);
}

DCACinverterClass = {};

DCACinverterClass.new = func( name, coeff ) {
    obj = { parents : [DCACinverterClass],
	    name : name,
	    node :  enode ~ "suppliers/" ~ name ~ "/",
	    volts :   props.globals.getNode( enode ~ "suppliers/" ~ name ~ "/volts", 1 ),
	    frequency :  props.globals.getNode( enode ~ "suppliers/" ~ name ~ "/frequency", 1 ),
	    input : nil,
	    output : nil,
	    conv_coeff : coeff };
    props.globals.getNode(obj.node,1).setValues({ "volts": 0.0, "frequency" : 400.0} );
    return obj;
}

DCACinverterClass.add_input = func( obj ){
    me.input = obj;
}

DCACinverterClass.rm_input = func( obj ){
    me.input = nil;
}

DCACinverterClass.output = func( obj ){
    me.output = obj;
}

DCACinverterClass.disconnect_from_bus = func{
    me.bus = nil;
}

DCACinverterClass.update = func{
    volts = me.input == nil ? 0.0 : me.input.volts.getValue()*me.conv_coeff;
    me.volts.setValue(volts);
}

ExternalClass = {};

ExternalClass.new = func( name ) {
    obj = { parents : [ExternalClass],
	    name : name,
	    node :  enode ~ "suppliers/" ~ name ~ "/",
	    volts :   props.globals.getNode( enode ~ "suppliers/" ~ name ~ "/volts", 1 ),
	    bus : nil,
            ideal_volts : 28.5,
            ideal_amps : 110.0 };
    props.globals.getNode(obj.node,1).setValues({ "volts": 28.5} );
    return obj;
}

ExternalClass.connect_to_bus = func( _bus ){
    me.bus = _bus;
}

ExternalClass.disconnect_from_bus = func{
    me.bus = nil;
}

UserClass = {};

UserClass.new = func( node, name ) {
    obj = { parents : [UserClass],
	    node : node,
	    name :  name,
	    volts :  props.globals.getNode( node ~ "/" ~ name ~ "/volts", 1 ),
	    inputs : props.globals.getNode( node ~ "/" ~ name ~ "/inputs", 1 ) };
    obj.volts.setValue(0.0);
    return obj;
}

UserClass.add_input = func( obj ) {
    me.inputs.getNode( obj.name, 1).setValue( obj.node );
}

UserClass.rm_input = func( name ) {
    me.inputs.removeChild( name,0 );
}

UserClass.voltage = func {
    return me.volts.getValue();
}

UserClass.update_input = func( name, volts ) {
    me.inputs.getNode( name ).setValues( { "volts" : volts } );
}

UserClass.update_voltage = func {
    volts = 0.0;
    foreach( input; me.inputs.getChildren() ){
	ivolts = props.globals.getNode( input.getValue() ~ "volts" ).getValue();
	volts = volts < ivolts ? ivolts : volts;
    }
    me.volts.setValue( volts );
}