//------------------------------------------------------------------------------
// Module: top
//------------------------------------------------------------------------------

module top;
  import uvm_pkg::*;
  
  reg clk;
  jelly_bean_if     jb_if( clk );
  jelly_bean_taster dut( jb_if ); // DUT
  
  initial begin // clock
    clk = 1;
    forever #5ns clk = ! clk;
  end
  
  initial begin // waveform
    $dumpfile( "dump.vcd" );
    $dumpvars( 0, top );
  end
  
  initial begin
    uvm_config_db#( virtual jelly_bean_if )::set( .cntxt( null ),
                                                  .inst_name( "uvm_test_top*" ),
                                                  .field_name( "jb_if" ),
                                                  .value( jb_if ) );
    run_test();
  end
endmodule: top
  
//==============================================================================
// Copyright (c) 2014 ClueLogic, LLC
// http://cluelogic.com/
//==============================================================================