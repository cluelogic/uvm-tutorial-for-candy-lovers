`include "uvm_macros.svh"
`include "jelly_bean_pkg.sv"
`include "jelly_bean_if.sv"

//------------------------------------------------------------------------------
// Module: jelly_bean_taster
//   This is the DUT.
//------------------------------------------------------------------------------

module jelly_bean_taster( jelly_bean_if.slave_mp jb_if );
  import jelly_bean_pkg::*;
  
  always @ ( posedge jb_if.clk ) begin
    if ( jb_if.flavor == CHOCOLATE && jb_if.sour )
      jb_if.taste <= #2ns YUCKY;
    else
      jb_if.taste <= #2ns YUMMY;
  end
endmodule: jelly_bean_taster

//==============================================================================
// Copyright (c) 2015 ClueLogic, LLC
// http://cluelogic.com/
//==============================================================================