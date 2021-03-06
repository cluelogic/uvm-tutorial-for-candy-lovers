//==============================================================================
// Source code for "UVM Tutorial for Candy Lovers" Post #29
//
// The MIT License (MIT)
//
// Copyright (c) 2015 ClueLogic, LLC
// http://cluelogic.com/
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//==============================================================================

`include "uvm_macros.svh"
`include "jelly_bean_pkg.sv"
`include "jelly_bean_if.sv"

//------------------------------------------------------------------------------
// Module: jelly_bean_partnership
//   This is the DUT.
//------------------------------------------------------------------------------

module jelly_bean_partnership( jelly_bean_if.slave_mp jb_if );
   import jelly_bean_pkg::*;

   jelly_bean_if jb_if0( jb_if.clk );
   jelly_bean_if jb_if1( jb_if.clk );
   
   jelly_bean_taster  taster ( jb_if0 );
   jelly_bean_partner partner( jb_if1 );

   always @* begin
      jb_if0.flavor     = jb_if.flavor;
      jb_if1.flavor     = jb_if.flavor;
      jb_if0.color      = jb_if.color;
      jb_if1.color      = jb_if.color;
      jb_if0.sugar_free = jb_if.sugar_free;
      jb_if1.sugar_free = jb_if.sugar_free;
      jb_if0.sour       = jb_if.sour;
      jb_if1.sour       = jb_if.sour;

      if ( jb_if.taster_id == 0 ) begin
         jb_if0.command = jb_if.command;
         jb_if1.command = NO_OP;
         jb_if.taste    = jb_if0.taste;
      end else begin
         jb_if0.command = NO_OP;
         jb_if1.command = jb_if.command;
         jb_if.taste    = jb_if1.taste;
      end
   end // always @ *

endmodule: jelly_bean_partnership

//------------------------------------------------------------------------------
// Module: jelly_bean_taster
//------------------------------------------------------------------------------

module jelly_bean_taster( jelly_bean_if.slave_mp jb_if );
   import jelly_bean_pkg::*;
   
   reg [1:0] taste;  // TASTE  register
   reg [2:0] flavor; // RECIPE register
   reg [1:0] color;
   reg       sugar_free;
   reg       sour;
   
   reg [1:0] command;

   initial begin
      flavor     = 0;
      color      = 0;
      sugar_free = 0;
      sour       = 0;
      command    = 0;
      taste      = 0;
   end

   always @ ( posedge jb_if.clk ) begin
      command <= jb_if.command;
      if ( jb_if.command == JB_WRITE ) begin
         flavor     <= jb_if.flavor;
         color      <= jb_if.color;
         sugar_free <= jb_if.sugar_free;
         sour       <= jb_if.sour;
      end else if ( jb_if.command == JB_READ ) begin
         jb_if.taste <= #2ns taste;
      end
   end

   always @ ( posedge jb_if.clk ) begin
      if ( jb_if.flavor == CHOCOLATE && jb_if.sour ) taste <= YUCKY;
      else if ( jb_if.flavor != NO_FLAVOR )          taste <= YUMMY;
   end

endmodule: jelly_bean_taster

//------------------------------------------------------------------------------
// Module: jelly_bean_partner
//------------------------------------------------------------------------------

module jelly_bean_partner( jelly_bean_if.slave_mp jb_if );
   import jelly_bean_pkg::*;
   
   reg [1:0] taste;
   reg [4:0] color_and_flavor;
   reg [1:0] command;

   jelly_bean_extra extra();

   initial begin
      color_and_flavor = 0;
      extra.sugar_free = 0;
      extra.sour       = 0;
      command          = 0;
      taste            = 0;
   end

   always @ ( posedge jb_if.clk ) begin
      command <= jb_if.command;
      if ( jb_if.command == JB_WRITE ) begin
         color_and_flavor <= { jb_if.color, jb_if.flavor };
         extra.sugar_free <= jb_if.sugar_free;
         extra.sour       <= jb_if.sour;
      end else if ( jb_if.command == JB_READ ) begin
         jb_if.taste <= #2ns taste;
      end
   end

   always @ ( posedge jb_if.clk ) begin
      if ( jb_if.flavor == CHOCOLATE && jb_if.sour ) taste <= YUCKY;
      else if ( jb_if.flavor != NO_FLAVOR )          taste <= YUMMY;
   end

endmodule: jelly_bean_partner

module jelly_bean_extra;
   reg sugar_free;
   reg sour;
endmodule: jelly_bean_extra

//==============================================================================
// Copyright (c) 2015 ClueLogic, LLC
// http://cluelogic.com/
//==============================================================================