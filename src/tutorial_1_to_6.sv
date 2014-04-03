//==============================================================================
// tutorial_1_to_6.sv (v0.1.0) - Source code for "UVM Tutorial for Candy Lovers"
//                               Posts #1 to #6.
//
// The MIT License (MIT)
//
// Copyright (c) 2011-2014 ClueLogic, LLC
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

//------------------------------------------------------------------------------
// Interface: jelly_bean_if
//------------------------------------------------------------------------------

interface jelly_bean_if( input bit clk );
   logic [2:0] flavor;
   logic [1:0] color;
   logic       sugar_free;
   logic       sour;
   logic [1:0] taste;

   clocking master_cb @ ( posedge clk );
      default input #1step output #1ns;
      output flavor, color, sugar_free, sour;
      input  taste;
   endclocking: master_cb

   clocking slave_cb @ ( posedge clk );
      default input #1step output #1ns;
      input  flavor, color, sugar_free, sour;
      output taste;
   endclocking: slave_cb

   modport master_mp( input clk, taste, output flavor, color, sugar_free, sour );
   modport slave_mp ( input clk, flavor, color, sugar_free, sour, output taste );
   modport master_sync_mp( clocking master_cb );
   modport slave_sync_mp ( clocking slave_cb  );
endinterface: jelly_bean_if

//------------------------------------------------------------------------------
// Package: jelly_bean_pkg
//------------------------------------------------------------------------------

package jelly_bean_pkg;
   import uvm_pkg::*;

   //---------------------------------------------------------------------------
   // Class: jelly_bean_configuration
   //---------------------------------------------------------------------------

class jelly_bean_configuration extends uvm_object;
   `uvm_object_utils( jelly_bean_configuration )

   function new( string name = "" );
      super.new( name );
   endfunction: new
endclass: jelly_bean_configuration

   //---------------------------------------------------------------------------
   // Class: jelly_bean_transaction
   //---------------------------------------------------------------------------

class jelly_bean_transaction extends uvm_sequence_item;
   typedef enum bit[2:0] { NO_FLAVOR, APPLE, BLUEBERRY, BUBBLE_GUM, CHOCOLATE } flavor_e;
   typedef enum bit[1:0] { RED, GREEN, BLUE } color_e;
   typedef enum bit[1:0] { UNKNOWN, YUMMY, YUCKY } taste_e;

   rand flavor_e flavor;
   rand color_e  color;
   rand bit      sugar_free;
   rand bit      sour;
   taste_e       taste;

   constraint flavor_color_con {
      flavor != NO_FLAVOR;
      flavor == APPLE     -> color != BLUE;
      flavor == BLUEBERRY -> color == BLUE;
   }

   function new( string name = "" );
      super.new( name );
   endfunction: new

   `uvm_object_utils_begin( jelly_bean_transaction )
      `uvm_field_enum( flavor_e, flavor, UVM_ALL_ON )
      `uvm_field_enum( color_e,  color,  UVM_ALL_ON )
      `uvm_field_int ( sugar_free,       UVM_ALL_ON )
      `uvm_field_int ( sour,             UVM_ALL_ON )
      `uvm_field_enum( taste_e,  taste,  UVM_ALL_ON )
   `uvm_object_utils_end
endclass: jelly_bean_transaction

   //---------------------------------------------------------------------------
   // Class: sugar_free_jelly_bean_transaction
   //---------------------------------------------------------------------------
   
class sugar_free_jelly_bean_transaction extends jelly_bean_transaction;
   `uvm_object_utils( sugar_free_jelly_bean_transaction )

   constraint sugar_free_con {
      sugar_free == 1;
   }

   function new( string name = "" );
      super.new( name );
   endfunction: new
endclass: sugar_free_jelly_bean_transaction

   //---------------------------------------------------------------------------
   // Class: one_jelly_bean_sequence
   //---------------------------------------------------------------------------
   
class one_jelly_bean_sequence extends uvm_sequence#( jelly_bean_transaction );
   `uvm_object_utils( one_jelly_bean_sequence )

   function new( string name = "" );
      super.new( name );
   endfunction: new

   task body();
      jelly_bean_transaction jb_tx;
      jb_tx = jelly_bean_transaction::type_id::create( .name( "jb_tx" ) );
      start_item( jb_tx );
`ifndef CL_USE_MODELSIM
      assert( jb_tx.randomize() );
`endif
      finish_item( jb_tx );
   endtask: body
endclass: one_jelly_bean_sequence

   //---------------------------------------------------------------------------
   // Class: same_flavored_jelly_beans_sequence
   //   Sequence of transactions.
   //---------------------------------------------------------------------------

class same_flavored_jelly_beans_sequence extends uvm_sequence#( jelly_bean_transaction );
   rand int unsigned num_jelly_beans; // knob

   constraint num_jelly_beans_con { num_jelly_beans inside { [2:4] }; }

   function new( string name = "" );
      super.new( name );
   endfunction: new

   task body();
      jelly_bean_transaction           jb_tx;
      jelly_bean_transaction::flavor_e jb_flavor;

      jb_tx = jelly_bean_transaction::type_id::create( .name( "jb_tx" ) );
`ifndef CL_USE_MODELSIM
      assert( jb_tx.randomize() );
`endif
      jb_flavor = jb_tx.flavor;

      repeat ( num_jelly_beans ) begin
	 jb_tx = jelly_bean_transaction::type_id::create( .name( "jb_tx" ) );
	 start_item( jb_tx );
`ifndef CL_USE_MODELSIM
	 assert( jb_tx.randomize() with { jb_tx.flavor == jb_flavor; } );
`endif
	 finish_item( jb_tx );
      end
   endtask: body

   `uvm_object_utils_begin( same_flavored_jelly_beans_sequence )
      `uvm_field_int( num_jelly_beans, UVM_ALL_ON )
   `uvm_object_utils_end
endclass: same_flavored_jelly_beans_sequence

   //---------------------------------------------------------------------------
   // Class: gift_boxed_jelly_beans_sequence
   //   Sequence of sequences.
   //---------------------------------------------------------------------------

class gift_boxed_jelly_beans_sequence extends uvm_sequence#( jelly_bean_transaction );
   rand int unsigned num_jelly_bean_flavors; // knob

   constraint num_jelly_bean_flavors_con { num_jelly_bean_flavors inside { [2:3] }; }

   function new( string name = "" );
      super.new( name );
   endfunction: new

   task body();
      same_flavored_jelly_beans_sequence jb_seq;
      repeat ( num_jelly_bean_flavors ) begin
	 jb_seq = same_flavored_jelly_beans_sequence::type_id::create( .name( "jb_seq" ) );
`ifndef CL_USE_MODELSIM
	 assert( jb_seq.randomize() );
`endif
	 jb_seq.start( m_sequencer );
      end
   endtask: body

   `uvm_object_utils_begin( gift_boxed_jelly_beans_sequence )
      `uvm_field_int( num_jelly_bean_flavors, UVM_ALL_ON )
   `uvm_object_utils_end
endclass: gift_boxed_jelly_beans_sequence

   //---------------------------------------------------------------------------
   // Typedef: jelly_bean_sequencer
   //---------------------------------------------------------------------------

   typedef uvm_sequencer#(jelly_bean_transaction) jelly_bean_sequencer;

   //---------------------------------------------------------------------------
   // Class: jelly_bean_driver
   //---------------------------------------------------------------------------

class jelly_bean_driver extends uvm_driver#( jelly_bean_transaction );
   `uvm_component_utils( jelly_bean_driver )

   virtual jelly_bean_if jb_vi;

   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new

   function void build_phase( uvm_phase phase );
      super.build_phase( phase );
      void'( uvm_resource_db#( virtual jelly_bean_if )::read_by_name
	     ( .scope( "ifs" ), .name( "jelly_bean_if" ), .val( jb_vi ) ) );
   endfunction: build_phase

   task run_phase( uvm_phase phase );
      jelly_bean_transaction jb_tx;

      forever begin
	 @jb_vi.master_cb;
	 jb_vi.master_cb.flavor <= jelly_bean_transaction::NO_FLAVOR;
	 seq_item_port.get_next_item( jb_tx );
	 @jb_vi.master_cb;
	 jb_vi.master_cb.flavor     <= jb_tx.flavor;
	 jb_vi.master_cb.color      <= jb_tx.color;
	 jb_vi.master_cb.sugar_free <= jb_tx.sugar_free;
	 jb_vi.master_cb.sour       <= jb_tx.sour;
	 seq_item_port.item_done();
      end
   endtask: run_phase
endclass: jelly_bean_driver

   //---------------------------------------------------------------------------
   // Class: jelly_bean_monitor
   //---------------------------------------------------------------------------

class jelly_bean_monitor extends uvm_monitor;
   `uvm_component_utils( jelly_bean_monitor )

   uvm_analysis_port#( jelly_bean_transaction ) jb_ap;

   virtual jelly_bean_if jb_vi;

   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new

   function void build_phase( uvm_phase phase );
      super.build_phase( phase );
      void'( uvm_resource_db#( virtual jelly_bean_if )::read_by_name
	     ( .scope( "ifs" ), .name( "jelly_bean_if" ), .val( jb_vi ) ) );
      jb_ap = new( .name( "jb_ap" ), .parent( this ) );
   endfunction: build_phase

   task run_phase( uvm_phase phase );
      forever begin
	 jelly_bean_transaction jb_tx;
	 @jb_vi.slave_cb;
	 if ( jb_vi.slave_cb.flavor != jelly_bean_transaction::NO_FLAVOR ) begin
	    jb_tx = jelly_bean_transaction::type_id::create( .name( "jb_tx" ) );
	    jb_tx.flavor     = jelly_bean_transaction::flavor_e'( jb_vi.slave_cb.flavor );
	    jb_tx.color      = jelly_bean_transaction::color_e' ( jb_vi.slave_cb.color  );
	    jb_tx.sugar_free = jb_vi.slave_cb.sugar_free;
	    jb_tx.sour       = jb_vi.slave_cb.sour;
	    @jb_vi.master_cb;
	    jb_tx.taste = jelly_bean_transaction::taste_e'( jb_vi.master_cb.taste );
	    jb_ap.write( jb_tx );
	 end
      end
   endtask: run_phase
endclass: jelly_bean_monitor

   //---------------------------------------------------------------------------
   // Class: jelly_bean_agent
   //---------------------------------------------------------------------------

class jelly_bean_agent extends uvm_agent;
   `uvm_component_utils( jelly_bean_agent )

   uvm_analysis_port#( jelly_bean_transaction ) jb_ap;
     
   jelly_bean_sequencer jb_seqr;
   jelly_bean_driver    jb_drvr;
   jelly_bean_monitor   jb_mon;

   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new

   function void build_phase( uvm_phase phase );
      super.build_phase( phase );

      jb_ap = new( .name( "jb_ap" ), .parent( this ) );
      jb_seqr = jelly_bean_sequencer::type_id::create( .name( "jb_seqr" ), .parent( this ) );
      jb_drvr = jelly_bean_driver   ::type_id::create( .name( "jb_drvr" ), .parent( this ) );
      jb_mon  = jelly_bean_monitor  ::type_id::create( .name( "jb_mon"  ), .parent( this ) );
   endfunction: build_phase

   function void connect_phase( uvm_phase phase );
      super.connect_phase( phase );
      jb_drvr.seq_item_port.connect( jb_seqr.seq_item_export );
      jb_mon.jb_ap.connect( jb_ap );
   endfunction: connect_phase
endclass: jelly_bean_agent

   //---------------------------------------------------------------------------
   // Class: jelly_bean_fc_subscriber
   //---------------------------------------------------------------------------

class jelly_bean_fc_subscriber extends uvm_subscriber#( jelly_bean_transaction );
   `uvm_component_utils( jelly_bean_fc_subscriber )

   jelly_bean_transaction jb_tx;

`ifndef CL_USE_MODELSIM
   covergroup jelly_bean_cg;
      flavor_cp:     coverpoint jb_tx.flavor;
      color_cp:      coverpoint jb_tx.color;
      sugar_free_cp: coverpoint jb_tx.sugar_free;
      sour_cp:       coverpoint jb_tx.sour;
      cross flavor_cp, color_cp, sugar_free_cp, sour_cp;
   endgroup: jelly_bean_cg
`endif

   function new( string name, uvm_component parent );
      super.new( name, parent );
`ifndef CL_USE_MODELSIM
      jelly_bean_cg = new;
`endif
   endfunction: new

   function void write( jelly_bean_transaction t );
      jb_tx = t;
`ifndef CL_USE_MODELSIM
      jelly_bean_cg.sample();
`endif
   endfunction: write
endclass: jelly_bean_fc_subscriber

   //---------------------------------------------------------------------------
   // Class: jelly_bean_sb_subscriber
   //---------------------------------------------------------------------------

typedef class jelly_bean_scoreboard;
   
class jelly_bean_sb_subscriber extends uvm_subscriber#( jelly_bean_transaction );
   `uvm_component_utils( jelly_bean_sb_subscriber )

   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new

   function void write( jelly_bean_transaction t );
      jelly_bean_scoreboard jb_sb;
      
      $cast( jb_sb, m_parent );
      jb_sb.check_jelly_bean_taste( t );
   endfunction: write
endclass: jelly_bean_sb_subscriber

   //---------------------------------------------------------------------------
   // Class: jelly_bean_scoreboard
   //---------------------------------------------------------------------------

class jelly_bean_scoreboard extends uvm_scoreboard;
   `uvm_component_utils( jelly_bean_scoreboard )

   uvm_analysis_export#( jelly_bean_transaction ) jb_analysis_export;
   local jelly_bean_sb_subscriber jb_sb_sub;
   
   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new

   function void build_phase( uvm_phase phase );
      super.build_phase( phase );
      jb_analysis_export = new( .name( "jb_analysis_export" ), .parent( this ) );
      jb_sb_sub = jelly_bean_sb_subscriber::type_id::create( .name( "jb_sb_sub" ), .parent( this ) );
   endfunction: build_phase

   function void connect_phase( uvm_phase phase );
      super.connect_phase( phase );
      jb_analysis_export.connect( jb_sb_sub.analysis_export );
   endfunction: connect_phase

   virtual function void check_jelly_bean_taste( jelly_bean_transaction jb_tx );
      uvm_table_printer p = new;
      if ( jb_tx.flavor == jelly_bean_transaction::CHOCOLATE && jb_tx.sour &&
	   jb_tx.taste  == jelly_bean_transaction::YUMMY ) begin
	 `uvm_error( "jelly_bean_scoreboard", 
		     { "You lost sense of taste!\n", jb_tx.sprint( p ) } );
      end else begin
	 `uvm_info( "jelly_bean_scoreboard",
		    { "You have a good sense of taste.\n", jb_tx.sprint( p ) },
		    UVM_LOW );
      end
   endfunction: check_jelly_bean_taste
endclass: jelly_bean_scoreboard

   //---------------------------------------------------------------------------
   // Class: jelly_bean_env
   //---------------------------------------------------------------------------

class jelly_bean_env extends uvm_env;
   `uvm_component_utils( jelly_bean_env )

   jelly_bean_agent         jb_agent;
   jelly_bean_fc_subscriber jb_fc_sub;
   jelly_bean_scoreboard    jb_sb;

   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new

   function void build_phase( uvm_phase phase );
      super.build_phase( phase );
      jb_agent  = jelly_bean_agent        ::type_id::create( .name( "jb_agent"  ), .parent( this ) );
      jb_fc_sub = jelly_bean_fc_subscriber::type_id::create( .name( "jb_fc_sub" ), .parent( this ) );
      jb_sb     = jelly_bean_scoreboard   ::type_id::create( .name( "jb_sb"     ), .parent( this ) );
    endfunction: build_phase

   function void connect_phase( uvm_phase phase );
      super.connect_phase( phase );
      jb_agent.jb_ap.connect( jb_fc_sub.analysis_export );
      jb_agent.jb_ap.connect( jb_sb.jb_analysis_export );
   endfunction: connect_phase
endclass: jelly_bean_env

   //---------------------------------------------------------------------------
   // Class: jelly_bean_test
   //---------------------------------------------------------------------------

class jelly_bean_test extends uvm_test;
   `uvm_component_utils( jelly_bean_test )

   jelly_bean_env jb_env;

   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new

   function void build_phase( uvm_phase phase );
      super.build_phase( phase );
      begin
	 jelly_bean_configuration jb_cfg;

	 jb_cfg = new;
`ifndef CL_USE_MODELSIM
	 assert( jb_cfg.randomize() );
`endif
	 uvm_config_db#( jelly_bean_configuration )::set
	   ( .cntxt( this ), .inst_name( "*" ), .field_name( "config" ), .value( jb_cfg ) );
	 
	 jelly_bean_transaction::type_id::set_type_override
	   ( sugar_free_jelly_bean_transaction::get_type() );

	 jb_env = jelly_bean_env::type_id::create( .name( "jb_env" ), .parent( this ) );
      end
   endfunction: build_phase

   task run_phase( uvm_phase phase );
      gift_boxed_jelly_beans_sequence jb_seq;

      phase.raise_objection( .obj( this ) );
      jb_seq = gift_boxed_jelly_beans_sequence::type_id::create( .name( "jb_seq" ) );
`ifndef CL_USE_MODELSIM
      assert( jb_seq.randomize() );
`endif
      `uvm_info( "jelly_bean_test", { "\n", jb_seq.sprint() }, UVM_LOW )
      jb_seq.start( jb_env.jb_agent.jb_seqr );
      #10ns ;
      phase.drop_objection( .obj( this ) );
   endtask: run_phase
endclass: jelly_bean_test

endpackage: jelly_bean_pkg

   //---------------------------------------------------------------------------
   // Module: jelly_bean_taster
   //   This is the DUT.
   //---------------------------------------------------------------------------

module jelly_bean_taster( jelly_bean_if.slave_mp jb_slave_if );
   import jelly_bean_pkg::*;

   always @ ( posedge jb_slave_if.clk ) begin
      if ( jb_slave_if.flavor == jelly_bean_transaction::CHOCOLATE &&
	   jb_slave_if.sour ) begin
	 jb_slave_if.taste <= jelly_bean_transaction::YUCKY;
      end else begin
	 jb_slave_if.taste <= jelly_bean_transaction::YUMMY;
      end
   end
endmodule: jelly_bean_taster

   //---------------------------------------------------------------------------
   // Module: top
   //---------------------------------------------------------------------------

module top;
   import uvm_pkg::*;

   reg clk;
   jelly_bean_if     jb_slave_if( clk );
   jelly_bean_taster jb_taster( jb_slave_if ); // DUT

   initial begin
      clk = 0;
      #5ns ;
      forever #5ns clk = ! clk;
   end

   initial begin
      uvm_resource_db#( virtual jelly_bean_if )::set
	( .scope( "ifs" ), .name( "jelly_bean_if" ), .val( jb_slave_if ) );
      run_test();
   end
endmodule: top

//==============================================================================
// Copyright (c) 2011-2014 ClueLogic, LLC
// http://cluelogic.com/
//==============================================================================
