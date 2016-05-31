//==============================================================================
// Source code for "UVM Tutorial for Candy Lovers" Post #25
//
// The MIT License (MIT)
//
// Copyright (c) 2014, 2015 ClueLogic, LLC
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
// Copyright (c) 2014 ClueLogic, LLC
// http://cluelogic.com/
//==============================================================================