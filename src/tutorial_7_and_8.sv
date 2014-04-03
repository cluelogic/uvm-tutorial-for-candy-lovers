//==============================================================================
// tutorial_7_and_8.sv (v0.1.0) - Source code for "UVM Tutorial for Candy Lovers" 
//                                Posts #7 and #8.
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

   clocking master_cb @( posedge clk );
      default input #1step output #1ns;
      output flavor, color, sugar_free, sour;
      input  taste;
   endclocking: master_cb

   clocking slave_cb @( posedge clk );
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
   // Class: jelly_bean_agent_config
   //---------------------------------------------------------------------------

class jelly_bean_agent_config extends uvm_object;
   `uvm_object_utils( jelly_bean_agent_config )

   uvm_active_passive_enum active = UVM_ACTIVE;
   bit has_jb_fc_sub = 1; // switch to instantiate a functional coverage subscriber

   virtual jelly_bean_if jb_if;

   function new( string name = "" );
      super.new( name );
   endfunction: new
endclass: jelly_bean_agent_config

   //---------------------------------------------------------------------------
   // Class: jelly_bean_env_config
   //---------------------------------------------------------------------------

class jelly_bean_env_config extends uvm_object;
   `uvm_object_utils( jelly_bean_env_config )

   bit has_jb_agent1 = 1; // switch to instantiate an agent #1
   bit has_jb_agent2 = 1; // switch to instantiate an agent #2
   bit has_jb_sb1    = 1; // switch to instantiate a scoreboard #1
   bit has_jb_sb2    = 1; // switch to instantiate a scoreboard #2
   
   jelly_bean_agent_config jb_agent_cfg1;
   jelly_bean_agent_config jb_agent_cfg2;

   function new( string name = "" );
      super.new( name );
   endfunction: new
endclass: jelly_bean_env_config

   //---------------------------------------------------------------------------
   // Class: jelly_bean_transaction
   //---------------------------------------------------------------------------

class jelly_bean_transaction extends uvm_sequence_item;
   typedef enum bit[2:0] { NO_FLAVOR, APPLE, CHOCOLATE, CINNAMON, COCONUT,
			   LEMON, STRAWBERRY, VANILLA  } flavor_e;
   typedef enum bit[1:0] { RED, GREEN, YELLOW, WHITE   } color_e;
   typedef enum bit[1:0] { UNKNOWN_TASTE, YUMMY, YUCKY } taste_e;

   rand flavor_e flavor;
   rand color_e  color;
   rand bit      sugar_free;
   rand bit      sour;
   taste_e       taste; // response

   constraint flavor_color_con {
      flavor != NO_FLAVOR;
      flavor == APPLE      -> color inside { RED, GREEN };
      flavor == CINNAMON   -> color == RED;
      flavor == COCONUT    -> color == WHITE;
      flavor == LEMON      -> color == YELLOW;
      flavor == STRAWBERRY -> color == RED;
      flavor == VANILLA    -> color == WHITE;
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
   // Class: same_flavored_jelly_beans_sequence
   //   Sequence of transactions.
   //---------------------------------------------------------------------------

class same_flavored_jelly_beans_sequence extends uvm_sequence#( jelly_bean_transaction );

   // knobs

   rand int unsigned num_jelly_beans;
   rand jelly_bean_transaction::flavor_e flavor;

   local same_flavored_jelly_beans_sequence self = this;

   constraint num_jelly_beans_con { num_jelly_beans inside { [1:4] }; }

   function new( string name = "" );
      super.new( name );
   endfunction: new

   task body();
      jelly_bean_transaction jb_tx;
      repeat ( num_jelly_beans ) begin
	 jb_tx = jelly_bean_transaction::type_id::create( .name( "jb_tx" ) );
	 start_item( jb_tx );
`ifndef CL_USE_MODELSIM
	 assert( jb_tx.randomize() with { this.flavor == self.flavor; } );
`endif
	 `uvm_info( get_name(), { "\n", jb_tx.sprint() }, UVM_LOW )
	 finish_item( jb_tx );
      end
   endtask: body

   `uvm_object_utils_begin( same_flavored_jelly_beans_sequence )
      `uvm_field_int ( num_jelly_beans,                          UVM_ALL_ON )
      `uvm_field_enum( jelly_bean_transaction::flavor_e, flavor, UVM_ALL_ON )
   `uvm_object_utils_end
endclass: same_flavored_jelly_beans_sequence

   //---------------------------------------------------------------------------
   // Typedef: jelly_bean_sequencer
   //---------------------------------------------------------------------------

   typedef uvm_sequencer#( jelly_bean_transaction ) jelly_bean_sequencer;

   //---------------------------------------------------------------------------
   // Class: jelly_bean_recipe_virtual_sequence
   //---------------------------------------------------------------------------

class jelly_bean_recipe_virtual_sequence extends uvm_sequence#( uvm_sequence_item );
   typedef enum bit[1:0] { LEMON_MERINGUE_PIE,   // 2 LEMON      + 2 COCONUT
			   STRAWBERRY_SHORTCAKE, // 2 STRAWBERRY + 2 VANILLA
			   CANDY_APPLE           // 2 APPLE      + 1 CINNAMON
			   } recipe_e;
   rand recipe_e recipe;

   jelly_bean_sequencer jb_seqr1;
   jelly_bean_sequencer jb_seqr2;

   same_flavored_jelly_beans_sequence jb_seq1;
   same_flavored_jelly_beans_sequence jb_seq2;

   function new( string name = "" );
      super.new( name );
   endfunction: new

   task body();
      jb_seq1 = same_flavored_jelly_beans_sequence::type_id::create( .name( "jb_seq1" ) );
      jb_seq2 = same_flavored_jelly_beans_sequence::type_id::create( .name( "jb_seq2" ) );
      case ( recipe )
	LEMON_MERINGUE_PIE: begin
	   jb_seq1.flavor          = jelly_bean_transaction::LEMON;
	   jb_seq2.flavor          = jelly_bean_transaction::COCONUT;
           jb_seq1.num_jelly_beans = 2;
           jb_seq2.num_jelly_beans = 2;
	end
	STRAWBERRY_SHORTCAKE: begin
	   jb_seq1.flavor          = jelly_bean_transaction::STRAWBERRY;
	   jb_seq2.flavor          = jelly_bean_transaction::VANILLA;
           jb_seq1.num_jelly_beans = 2;
           jb_seq2.num_jelly_beans = 2;
	end
	CANDY_APPLE: begin
	   jb_seq1.flavor          = jelly_bean_transaction::APPLE;
	   jb_seq2.flavor          = jelly_bean_transaction::CINNAMON;
           jb_seq1.num_jelly_beans = 2;
           jb_seq2.num_jelly_beans = 1;
	end
      endcase // case ( recipe )
      `uvm_info( get_name(), { "\n", this.sprint() }, UVM_LOW )
      fork
	 jb_seq1.start( .sequencer( jb_seqr1 ), .parent_sequence( this ) );
	 jb_seq2.start( .sequencer( jb_seqr2 ), .parent_sequence( this ) );
      join
   endtask: body
   
   `uvm_object_utils_begin( jelly_bean_recipe_virtual_sequence )
      `uvm_field_enum  ( recipe_e, recipe, UVM_ALL_ON )
      `uvm_field_object( jb_seq1,          UVM_ALL_ON )
      `uvm_field_object( jb_seq2,          UVM_ALL_ON )
   `uvm_object_utils_end
endclass: jelly_bean_recipe_virtual_sequence

   //---------------------------------------------------------------------------
   // Class: jelly_bean_driver
   //---------------------------------------------------------------------------

class jelly_bean_driver extends uvm_driver#( jelly_bean_transaction );
   `uvm_component_utils( jelly_bean_driver )

   virtual jelly_bean_if jb_if;

   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new

   function void build_phase( uvm_phase phase );
      super.build_phase( phase );
   endfunction: build_phase

   task main_phase( uvm_phase phase );
      jelly_bean_transaction jb_tx;

      forever begin
	 @jb_if.master_cb;
	 jb_if.master_cb.flavor <= jelly_bean_transaction::NO_FLAVOR;
	 seq_item_port.get_next_item( jb_tx );
	 @jb_if.master_cb;
	 jb_if.master_cb.flavor     <= jb_tx.flavor;
	 jb_if.master_cb.color      <= jb_tx.color;
	 jb_if.master_cb.sugar_free <= jb_tx.sugar_free;
	 jb_if.master_cb.sour       <= jb_tx.sour;
	 seq_item_port.item_done();
      end
   endtask: main_phase
   
endclass: jelly_bean_driver

   //---------------------------------------------------------------------------
   // Class: jelly_bean_monitor
   //---------------------------------------------------------------------------

class jelly_bean_monitor extends uvm_monitor;
   `uvm_component_utils( jelly_bean_monitor )

   uvm_analysis_port#( jelly_bean_transaction ) jb_ap;

   virtual jelly_bean_if jb_if;

   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new

   function void build_phase( uvm_phase phase );
      super.build_phase( phase );
      jb_ap = new( .name( "jb_ap" ), .parent( this ) );
   endfunction: build_phase

   task main_phase( uvm_phase phase );
      forever begin
	 jelly_bean_transaction jb_tx;
	 @jb_if.slave_cb;
	 if ( jb_if.slave_cb.flavor != jelly_bean_transaction::NO_FLAVOR ) begin
	    jb_tx = jelly_bean_transaction::type_id::create( .name( "jb_tx" ) );
	    jb_tx.flavor     = jelly_bean_transaction::flavor_e'( jb_if.slave_cb.flavor );
	    jb_tx.color      = jelly_bean_transaction::color_e' ( jb_if.slave_cb.color  );
	    jb_tx.sugar_free = jb_if.slave_cb.sugar_free;
	    jb_tx.sour       = jb_if.slave_cb.sour;
	    @jb_if.master_cb;
	    jb_tx.taste = jelly_bean_transaction::taste_e'( jb_if.master_cb.taste );
	    jb_ap.write( jb_tx );
	 end
      end
   endtask: main_phase
endclass: jelly_bean_monitor

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
   // Class: jelly_bean_agent
   //---------------------------------------------------------------------------

class jelly_bean_agent extends uvm_agent;
   `uvm_component_utils( jelly_bean_agent )

   jelly_bean_agent_config  jb_agent_cfg;
   jelly_bean_sequencer     jb_seqr;
   jelly_bean_driver        jb_drvr;
   jelly_bean_monitor       jb_mon;
   jelly_bean_fc_subscriber jb_fc_sub;

   uvm_analysis_port#( jelly_bean_transaction ) jb_ap;

   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new

   function void build_phase( uvm_phase phase );
      super.build_phase( phase );

      if ( ! uvm_config_db#( jelly_bean_agent_config )::get( .cntxt     ( this ), 
							     .inst_name ( "" ), 
							     .field_name( "jb_agent_cfg" ),
							     .value     (  jb_agent_cfg ) ) ) begin
	 `uvm_error( "jelly_bean_agent", "jb_agent_cfg not found" )
      end

      if ( jb_agent_cfg.active == UVM_ACTIVE ) begin
	 jb_seqr = jelly_bean_sequencer::type_id::create( .name( "jb_seqr" ), .parent( this ) );
	 jb_drvr = jelly_bean_driver   ::type_id::create( .name( "jb_drvr" ), .parent( this ) );
      end

      if ( jb_agent_cfg.has_jb_fc_sub ) begin
	jb_fc_sub = jelly_bean_fc_subscriber::type_id::create( .name( "jb_fc_sub" ), .parent( this ) );
      end

      jb_mon = jelly_bean_monitor::type_id::create( .name( "jb_mon" ), .parent( this ) );
   endfunction: build_phase

   function void connect_phase( uvm_phase phase );
      super.connect_phase( phase );

      jb_mon.jb_if = jb_agent_cfg.jb_if;
      jb_ap = jb_mon.jb_ap;
      
      if ( jb_agent_cfg.active == UVM_ACTIVE ) begin
	 jb_drvr.seq_item_port.connect( jb_seqr.seq_item_export );
	 jb_drvr.jb_if = jb_agent_cfg.jb_if;
      end

      if ( jb_agent_cfg.has_jb_fc_sub ) begin
	 jb_ap.connect( jb_fc_sub.analysis_export );
      end
   endfunction: connect_phase
endclass: jelly_bean_agent

   //---------------------------------------------------------------------------
   // Typedef: jelly_bean_scoreboard
   //---------------------------------------------------------------------------

typedef class jelly_bean_scoreboard;
   
   //---------------------------------------------------------------------------
   // Class: jelly_bean_sb_subscriber
   //---------------------------------------------------------------------------

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
   local int unsigned num_failed = 0;
   
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

   function void report_phase( uvm_phase phase );
      super.report_phase( phase );
      if ( num_failed > 0 ) $display( "=== TEST FAILED (%s num_failed=%0d) ===", get_name(), num_failed );
      else                  $display( "=== TEST PASSED (%s) ===", get_name() );
   endfunction: report_phase

   virtual function void check_jelly_bean_taste( jelly_bean_transaction jb_tx );
      uvm_table_printer p = new;
      if ( jb_tx.flavor == jelly_bean_transaction::CHOCOLATE && jb_tx.sour &&
	   jb_tx.taste  == jelly_bean_transaction::YUMMY ) begin
	 `uvm_error( "jelly_bean_scoreboard", { "You lost sense of taste!\n", jb_tx.sprint(p) } )
	 num_failed++;
      end else begin
	 `uvm_info( get_name(), { "You have a good sense of taste.\n", jb_tx.sprint(p) }, UVM_LOW )
      end
   endfunction: check_jelly_bean_taste

endclass: jelly_bean_scoreboard

   //---------------------------------------------------------------------------
   // Class: jelly_bean_env
   //---------------------------------------------------------------------------

class jelly_bean_env extends uvm_env;
   `uvm_component_utils( jelly_bean_env )

   jelly_bean_env_config jb_env_cfg;
   jelly_bean_agent      jb_agent1;
   jelly_bean_agent      jb_agent2;
   jelly_bean_scoreboard jb_sb1;
   jelly_bean_scoreboard jb_sb2;

   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new

   function void build_phase( uvm_phase phase );
      super.build_phase( phase );

      if ( ! uvm_config_db#( jelly_bean_env_config )::get
	   ( .cntxt( this ), .inst_name( "" ), .field_name( "jb_env_cfg" ), .value( jb_env_cfg ) ) ) begin
	 `uvm_error( "jelly_bean_env", "jb_env_cfg not found" )
      end

      if ( jb_env_cfg.has_jb_agent1 ) begin
	 uvm_config_db#( jelly_bean_agent_config )::set( .cntxt( this ), .inst_name( "jb_agent1*" ), 
	    .field_name( "jb_agent_cfg" ), .value( jb_env_cfg.jb_agent_cfg1 ) );
	 jb_agent1 = jelly_bean_agent::type_id::create( .name( "jb_agent1" ), .parent( this ) );

	 if ( jb_env_cfg.has_jb_sb1 ) begin
	    jb_sb1 = jelly_bean_scoreboard::type_id::create( .name( "jb_sb1" ), .parent( this ) );
	 end
      end

      if ( jb_env_cfg.has_jb_agent2 ) begin
	 uvm_config_db#( jelly_bean_agent_config )::set( .cntxt( this ), .inst_name( "jb_agent2*" ),
	    .field_name( "jb_agent_cfg" ), .value( jb_env_cfg.jb_agent_cfg2 ) );
	 jb_agent2 = jelly_bean_agent::type_id::create( .name( "jb_agent2" ), .parent( this ) );

	 if ( jb_env_cfg.has_jb_sb2 ) begin
	    jb_sb2 = jelly_bean_scoreboard::type_id::create( .name( "jb_sb2" ), .parent( this ) );
	 end
      end

    endfunction: build_phase

   function void connect_phase( uvm_phase phase );
      super.connect_phase( phase );

      if ( jb_env_cfg.has_jb_agent1 && jb_env_cfg.has_jb_sb1 )
	jb_agent1.jb_ap.connect( jb_sb1.jb_analysis_export );
      if ( jb_env_cfg.has_jb_agent2 && jb_env_cfg.has_jb_sb2 )
	jb_agent2.jb_ap.connect( jb_sb2.jb_analysis_export );
   endfunction: connect_phase
endclass: jelly_bean_env

   //---------------------------------------------------------------------------
   // Class: jelly_bean_base_test
   //---------------------------------------------------------------------------

class jelly_bean_base_test extends uvm_test;
   `uvm_component_utils( jelly_bean_base_test )

   jelly_bean_env          jb_env;
   jelly_bean_env_config   jb_env_cfg;
   jelly_bean_agent_config jb_agent_cfg1;
   jelly_bean_agent_config jb_agent_cfg2;

   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new

   function void build_phase( uvm_phase phase );
      super.build_phase( phase );

      jb_env_cfg    = jelly_bean_env_config  ::type_id::create( "jb_env_cfg"    );
      jb_agent_cfg1 = jelly_bean_agent_config::type_id::create( "jb_agent_cfg1" );
      jb_agent_cfg2 = jelly_bean_agent_config::type_id::create( "jb_agent_cfg2" );
      
      if ( ! uvm_config_db#( virtual jelly_bean_if )::get
	   ( .cntxt( this ), .inst_name( "" ), .field_name( "jb_if1" ), .value( jb_agent_cfg1.jb_if ) ) ) begin
	 `uvm_error( "jelly_bean_test", "jb_if1 not found" )
      end

      if ( ! uvm_config_db#( virtual jelly_bean_if )::get
	   ( .cntxt( this ), .inst_name( "" ), .field_name( "jb_if2" ), .value( jb_agent_cfg2.jb_if ) ) ) begin
	 `uvm_error( "jelly_bean_test", "jb_if2 not found" )
      end

      jb_env_cfg.jb_agent_cfg1 = jb_agent_cfg1;
      jb_env_cfg.jb_agent_cfg2 = jb_agent_cfg2;

      uvm_config_db#( jelly_bean_env_config )::set
	( .cntxt( this ), .inst_name( "*" ), .field_name( "jb_env_cfg" ), .value( jb_env_cfg ) );

      jb_env = jelly_bean_env::type_id::create( .name( "jb_env" ), .parent( this ) );
   endfunction: build_phase
endclass: jelly_bean_base_test

   //---------------------------------------------------------------------------
   // Class: jelly_bean_recipe_test
   //---------------------------------------------------------------------------

class jelly_bean_recipe_test extends jelly_bean_base_test;
   `uvm_component_utils( jelly_bean_recipe_test )

   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new

   task main_phase( uvm_phase phase );
      jelly_bean_recipe_virtual_sequence jb_vseq;

      phase.raise_objection( .obj( this ) );
      jb_vseq = jelly_bean_recipe_virtual_sequence::type_id::create( .name( "jb_vseq" ) );
      jb_vseq.jb_seqr1 = jb_env.jb_agent1.jb_seqr;
      jb_vseq.jb_seqr2 = jb_env.jb_agent2.jb_seqr;
`ifndef CL_USE_MODELSIM
      assert( jb_vseq.randomize() );
`endif
      jb_vseq.start( .sequencer( null ) );
      #100ns ;
      phase.drop_objection( .obj( this ) );
   endtask: main_phase
endclass: jelly_bean_recipe_test

endpackage: jelly_bean_pkg

   //---------------------------------------------------------------------------
   // Module: jelly_bean_taster
   //   This is the DUT.
   //---------------------------------------------------------------------------

module jelly_bean_taster( jelly_bean_if.slave_mp jb_if );
   import jelly_bean_pkg::*;

   always @ ( posedge jb_if.clk ) begin
      if ( jb_if.flavor == jelly_bean_transaction::NO_FLAVOR ) begin
	 jb_if.taste <= jelly_bean_transaction::UNKNOWN_TASTE;
      end if ( jb_if.flavor == jelly_bean_transaction::CHOCOLATE && jb_if.sour ) begin
	 jb_if.taste <= jelly_bean_transaction::YUCKY;
      end else begin
	 jb_if.taste <= jelly_bean_transaction::YUMMY;
      end
   end
endmodule: jelly_bean_taster

module jelly_bean_subsystem( jelly_bean_if.slave_mp jb_if1,
			     jelly_bean_if.slave_mp jb_if2 );
   import jelly_bean_pkg::*;

   jelly_bean_taster taster1( .jb_if( jb_if1 ) );
   jelly_bean_taster taster2( .jb_if( jb_if2 ) );
endmodule: jelly_bean_subsystem

//------------------------------------------------------------------------------
// Module: top
//------------------------------------------------------------------------------

module top;
   import uvm_pkg::*;

   reg clk;
   
   jelly_bean_if        jb_if1( clk );
   jelly_bean_if        jb_if2( clk );
   jelly_bean_subsystem dut( jb_if1, jb_if2 );

   initial begin
      clk = 0;
      #5ns ;
      forever #5ns clk = ! clk;
   end

   initial begin
      uvm_config_db#( virtual jelly_bean_if )::set
	( .cntxt( null ), .inst_name( "uvm_test_top" ), .field_name( "jb_if1" ), .value( jb_if1 ) );
      uvm_config_db#( virtual jelly_bean_if )::set
	( .cntxt( null ), .inst_name( "uvm_test_top" ), .field_name( "jb_if2" ), .value( jb_if2 ) );
      run_test();
   end
endmodule: top

//==============================================================================
// Copyright (c) 2011-2014 ClueLogic, LLC
// http://cluelogic.com/
//==============================================================================
