//------------------------------------------------------------------------------
// Interface: jelly_bean_if
//------------------------------------------------------------------------------

interface jelly_bean_if( input bit clk );
  logic [2:0] flavor;
  logic [1:0] color;
  logic       sugar_free;
  logic       sour;
  logic [1:0] command;
  logic [1:0] taste;
  
  //----------------------------------------------------------------------------
  // Clocking block: master_cb
  //----------------------------------------------------------------------------

  clocking master_cb @( posedge clk );
    default input #1ns output #1ns;
    output flavor, color, sugar_free, sour, command;
    input  taste;
  endclocking: master_cb

  //----------------------------------------------------------------------------
  // Clocking block: slave_cb
  //----------------------------------------------------------------------------
  
  clocking slave_cb @( posedge clk );
    default input #1ns output #1ns;
    input  flavor, color, sugar_free, sour, command;
    output taste;
  endclocking: slave_cb

  //----------------------------------------------------------------------------
  // Modports
  //----------------------------------------------------------------------------

  modport master_mp( input clk, taste, output flavor, color, sugar_free, sour, command );
  modport slave_mp ( input clk, flavor, color, sugar_free, sour, command, output taste );
  modport master_sync_mp( clocking master_cb );
  modport slave_sync_mp ( clocking slave_cb  );
endinterface: jelly_bean_if

//==============================================================================
// Copyright (c) 2014 ClueLogic, LLC
// http://cluelogic.com/
//==============================================================================