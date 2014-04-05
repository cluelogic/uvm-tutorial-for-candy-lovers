//==============================================================================
// tutorial_9.sv (v0.1.0) - Source code for "UVM Tutorial for Candy Lovers" 
//                          Post #9.
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

`timescale 1ns/1ns
`include "uvm_macros.svh"

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

   //---------------------------------------------------------------------------
   // Clocking Block: master_cb
   //---------------------------------------------------------------------------

   clocking master_cb @ ( posedge clk );
      default input #1ns output #1ns;
      output   flavor, color, sugar_free, sour, command;
      input    taste;
   endclocking: master_cb

   //---------------------------------------------------------------------------
   // Clocking Block: slave_cb
   //---------------------------------------------------------------------------

   clocking slave_cb @ ( posedge clk );
      default input #1ns output #1ns;
      input    flavor, color, sugar_free, sour, command;
      output   taste;
   endclocking: slave_cb

   //---------------------------------------------------------------------------
   // Module Ports:
   //---------------------------------------------------------------------------

   modport master_mp( input clk, taste, 
                      output flavor, color, sugar_free, sour, command );
   modport slave_mp( input clk, flavor, color, sugar_free, sour, command,
                     output taste );
   modport master_sync_mp( clocking master_cb );
   modport slave_sync_mp( clocking slave_cb );
endinterface: jelly_bean_if

//==============================================================================
// Package: jelly_bean_pkg
//==============================================================================

package jelly_bean_pkg;
   import uvm_pkg::*;

//------------------------------------------------------------------------------
// Class: jelly_bean_types
//------------------------------------------------------------------------------

class jelly_bean_types;
   typedef enum bit[2:0] { NO_FLAVOR, APPLE, BLUEBERRY, BUBBLE_GUM, CHOCOLATE }
                flavor_e;
   typedef enum bit[1:0] { NO_COLOR, RED, GREEN, BLUE } color_e;
   typedef enum bit[1:0] { NO_TASTE, YUMMY, YUCKY } taste_e;
   typedef enum bit[1:0] { NO_OP = 0, READ = 1, WRITE = 2 } command_e;
endclass: jelly_bean_types

//------------------------------------------------------------------------------
// Class: jelly_bean_transaction
//------------------------------------------------------------------------------

class jelly_bean_transaction extends uvm_sequence_item;
   rand jelly_bean_types::flavor_e  flavor;
   rand jelly_bean_types::color_e   color;
   rand bit                         sugar_free;
   rand bit                         sour;
   rand jelly_bean_types::command_e command;
   jelly_bean_types::taste_e        taste;

   constraint flavor_color_con {
      flavor != jelly_bean_types::NO_FLAVOR;
      flavor == jelly_bean_types::APPLE     -> color != jelly_bean_types::BLUE;
      flavor == jelly_bean_types::BLUEBERRY -> color == jelly_bean_types::BLUE;
   }

   function new( string name = "" );
      super.new( name );
   endfunction: new

   `uvm_object_utils_begin( jelly_bean_transaction )
      `uvm_field_enum( jelly_bean_types::flavor_e, flavor, UVM_ALL_ON )
      `uvm_field_enum( jelly_bean_types::color_e,  color,  UVM_ALL_ON )
      `uvm_field_int ( sugar_free,   UVM_ALL_ON )
      `uvm_field_int ( sour,         UVM_ALL_ON )
      `uvm_field_enum( jelly_bean_types::command_e, command, UVM_ALL_ON )
      `uvm_field_enum( jelly_bean_types::taste_e,   taste,   UVM_ALL_ON )
   `uvm_object_utils_end
endclass: jelly_bean_transaction

//------------------------------------------------------------------------------
// Class: sugar_free_jelly_bean_transaction
//------------------------------------------------------------------------------
   
class sugar_free_jelly_bean_transaction extends jelly_bean_transaction;
   `uvm_object_utils( sugar_free_jelly_bean_transaction )

   constraint sugar_free_con {
      sugar_free == 1;
   }

   function new( string name = "" );
      super.new( name );
   endfunction: new
endclass: sugar_free_jelly_bean_transaction

//------------------------------------------------------------------------------
// Class: jelly_bean_recipe_reg
//------------------------------------------------------------------------------

class jelly_bean_recipe_reg extends uvm_reg;
   `uvm_object_utils( jelly_bean_recipe_reg )

   rand uvm_reg_field flavor;
   rand uvm_reg_field color;
   rand uvm_reg_field sugar_free;
   rand uvm_reg_field sour;

   constraint flavor_color_con {
      flavor.value != jelly_bean_types::NO_FLAVOR;
      flavor.value == jelly_bean_types::APPLE
                   -> color.value != jelly_bean_types::BLUE;
      flavor.value == jelly_bean_types::BLUEBERRY
                   -> color.value == jelly_bean_types::BLUE;
      flavor.value <= jelly_bean_types::CHOCOLATE;
   }

   function new( string name = "jelly_bean_recipe_reg" );
      super.new( .name( name ), .n_bits( 7 ), .has_coverage( UVM_NO_COVERAGE ) );
   endfunction: new

   virtual function void build();
      flavor = uvm_reg_field::type_id::create( "flavor" );
      flavor.configure( .parent                 ( this ), 
                        .size                   ( 3    ), 
                        .lsb_pos                ( 0    ), 
                        .access                 ( "WO" ), 
                        .volatile               ( 0    ),
                        .reset                  ( 0    ), 
                        .has_reset              ( 1    ), 
                        .is_rand                ( 1    ), 
                        .individually_accessible( 1    ) );

      color = uvm_reg_field::type_id::create( "color" );
      color.configure( .parent                 ( this ), 
                       .size                   ( 2    ), 
                       .lsb_pos                ( 3    ), 
                       .access                 ( "WO" ), 
                       .volatile               ( 0    ),
                       .reset                  ( 0    ), 
                       .has_reset              ( 1    ), 
                       .is_rand                ( 1    ), 
                       .individually_accessible( 1    ) );

      sugar_free = uvm_reg_field::type_id::create( "sugar_free" );
      sugar_free.configure( .parent                 ( this ), 
                            .size                   ( 1    ), 
                            .lsb_pos                ( 5    ), 
                            .access                 ( "WO" ), 
                            .volatile               ( 0    ),
                            .reset                  ( 0    ), 
                            .has_reset              ( 1    ), 
                            .is_rand                ( 1    ), 
                            .individually_accessible( 1    ) );

      sour = uvm_reg_field::type_id::create( "sour" );
      sour.configure( .parent                 ( this ), 
                      .size                   ( 1    ), 
                      .lsb_pos                ( 6    ), 
                      .access                 ( "WO" ), 
                      .volatile               ( 0    ),
                      .reset                  ( 0    ), 
                      .has_reset              ( 1    ), 
                      .is_rand                ( 1    ), 
                      .individually_accessible( 1    ) );
   endfunction: build
endclass: jelly_bean_recipe_reg

//------------------------------------------------------------------------------
// Class: jelly_bean_taste_reg
//------------------------------------------------------------------------------

class jelly_bean_taste_reg extends uvm_reg;
   `uvm_object_utils( jelly_bean_taste_reg )

   rand uvm_reg_field taste;

   function new( string name = "jelly_bean_taste_reg" );
      super.new( .name( name ), .n_bits( 2 ), .has_coverage( UVM_NO_COVERAGE ) );
   endfunction: new


   virtual function void build();
      taste = uvm_reg_field::type_id::create( "taste" );
      taste.configure( .parent                 ( this ), 
                       .size                   ( 2    ), 
                       .lsb_pos                ( 0    ), 
                       .access                 ( "RO" ), 
                       .volatile               ( 1    ),
                       .reset                  ( 0    ), 
                       .has_reset              ( 1    ), 
                       .is_rand                ( 1    ), 
                       .individually_accessible( 1    ) );
   endfunction: build
endclass: jelly_bean_taste_reg

//------------------------------------------------------------------------------
// Class: jelly_bean_reg_block
//------------------------------------------------------------------------------

class jelly_bean_reg_block extends uvm_reg_block;
   `uvm_object_utils( jelly_bean_reg_block )

   rand jelly_bean_recipe_reg jb_recipe_reg;
   rand jelly_bean_taste_reg  jb_taste_reg;
   uvm_reg_map                reg_map;

   function new( string name = "jelly_bean_reg_block" );
      super.new( .name( name ), .has_coverage( UVM_NO_COVERAGE ) );
   endfunction: new

   virtual function void build();
      jb_recipe_reg = jelly_bean_recipe_reg::type_id::create( "jb_recipe_reg" );
      jb_recipe_reg.configure( .blk_parent( this ) );
      jb_recipe_reg.build();

      jb_taste_reg = jelly_bean_taste_reg::type_id::create( "jb_taste_reg" );
      jb_taste_reg.configure( .blk_parent( this ) );
      jb_taste_reg.build();

      reg_map = create_map( .name( "reg_map" ), .base_addr( 8'h00 ), 
                            .n_bytes( 1 ), .endian( UVM_LITTLE_ENDIAN ) );
      reg_map.add_reg( .rg( jb_recipe_reg ), .offset( 8'h00 ), .rights( "WO" ) );
      reg_map.add_reg( .rg( jb_taste_reg  ), .offset( 8'h01 ), .rights( "RO" ) );
      lock_model(); // finalize the address mapping
   endfunction: build

endclass: jelly_bean_reg_block   

//------------------------------------------------------------------------------
// Class: jelly_bean_reg_adapter
//------------------------------------------------------------------------------

class jelly_bean_reg_adapter extends uvm_reg_adapter;
   `uvm_object_utils( jelly_bean_reg_adapter )

   function new( string name = "" );
      super.new( name );
      supports_byte_enable = 0;
      provides_responses   = 0;
   endfunction: new

   virtual function uvm_sequence_item reg2bus( const ref uvm_reg_bus_op rw );
      jelly_bean_transaction jb_tx 
        = jelly_bean_transaction::type_id::create("jb_tx");

      if ( rw.kind == UVM_READ )       jb_tx.command = jelly_bean_types::READ;
      else if ( rw.kind == UVM_WRITE ) jb_tx.command = jelly_bean_types::WRITE;
      else                             jb_tx.command = jelly_bean_types::NO_OP;
      if ( rw.kind == UVM_WRITE )
        { jb_tx.sour, jb_tx.sugar_free, jb_tx.color, jb_tx.flavor } = rw.data;
      return jb_tx;
   endfunction: reg2bus

   virtual function void bus2reg( uvm_sequence_item bus_item,
                                  ref uvm_reg_bus_op rw );
      jelly_bean_transaction jb_tx;

      if ( ! $cast( jb_tx, bus_item ) ) begin
         `uvm_fatal( get_name(),
                     "bus_item is not of the jelly_bean_transaction type." )
         return;
      end

      rw.kind = ( jb_tx.command == jelly_bean_types::READ ) ? UVM_READ : UVM_WRITE;
      if ( jb_tx.command == jelly_bean_types::READ )
        rw.data = jb_tx.taste;
      else if ( jb_tx.command == jelly_bean_types::WRITE )
        rw.data = { jb_tx.sour, jb_tx.sugar_free, jb_tx.color, jb_tx.flavor };
      rw.status = UVM_IS_OK;
   endfunction: bus2reg
endclass: jelly_bean_reg_adapter

//------------------------------------------------------------------------------
// jelly_bean_reg_predictor
//------------------------------------------------------------------------------

typedef uvm_reg_predictor#( jelly_bean_transaction ) jelly_bean_reg_predictor;

//--------------------------------------------------------------------------
// Class: jelly_bean_agent_config
//--------------------------------------------------------------------------

class jelly_bean_agent_config extends uvm_object;
   `uvm_object_utils( jelly_bean_agent_config )

   uvm_active_passive_enum active = UVM_ACTIVE;
   bit has_jb_fc_sub = 1; // switch to instantiate a functional coverage subscriber

   virtual jelly_bean_if jb_if;

   function new( string name = "" );
      super.new( name );
   endfunction: new
endclass: jelly_bean_agent_config

//------------------------------------------------------------------------------
// Class: jelly_bean_env_config
//------------------------------------------------------------------------------

class jelly_bean_env_config extends uvm_object;
   `uvm_object_utils( jelly_bean_env_config )

   bit has_jb_agent = 1;
   bit has_jb_sb    = 1;
   
   jelly_bean_agent_config jb_agent_cfg;
   jelly_bean_reg_block    jb_reg_block;

   function new( string name = "" );
      super.new( name );
   endfunction: new
endclass: jelly_bean_env_config

//------------------------------------------------------------------------------
// Class: jelly_bean_sequence
//------------------------------------------------------------------------------
   
class jelly_bean_sequence extends uvm_sequence#( jelly_bean_transaction );
   `uvm_object_utils( jelly_bean_sequence )

   function new( string name = "" );
      super.new( name );
   endfunction: new

   task body();
      jelly_bean_transaction jb_tx;
      jb_tx = jelly_bean_transaction::type_id::create( .name( "jb_tx" ) );
      start_item( jb_tx );
      jb_tx.flavor     = jelly_bean_types::APPLE;
      jb_tx.color      = jelly_bean_types::GREEN;
      jb_tx.sugar_free = 0;
      jb_tx.sour       = 1;
      finish_item(jb_tx);
   endtask: body
endclass: jelly_bean_sequence

//------------------------------------------------------------------------------
// Class: jelly_bean_reg_sequence
//------------------------------------------------------------------------------

class jelly_bean_reg_sequence extends uvm_reg_sequence;
   `uvm_object_utils( jelly_bean_reg_sequence )

   function new( string name = "" );
      super.new( name );
   endfunction: new

   virtual task body();
      jelly_bean_reg_block       jb_reg_block;
      jelly_bean_types::flavor_e flavor;
      jelly_bean_types::color_e  color;
      bit                        sugar_free;
      bit                        sour;
      uvm_status_e               status;
      uvm_reg_data_t             value;

      $cast( jb_reg_block, model );
      flavor     = jelly_bean_types::APPLE;
      color      = jelly_bean_types::GREEN;
      sugar_free = 0;
      sour       = 1;
      
      write_reg( jb_reg_block.jb_recipe_reg, status, { sour, sugar_free, color, flavor } );
      read_reg( jb_reg_block.jb_taste_reg, status, value );
   endtask: body
     
endclass: jelly_bean_reg_sequence

//------------------------------------------------------------------------------
// jelly_bean_sequencer
//------------------------------------------------------------------------------

typedef uvm_sequencer#( jelly_bean_transaction ) jelly_bean_sequencer;

//------------------------------------------------------------------------------
// Class: jelly_bean_driver
//------------------------------------------------------------------------------

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
         jb_if.master_cb.command <= jelly_bean_types::NO_OP;
         jb_if.master_cb.color   <= jelly_bean_types::NO_COLOR;
         jb_if.master_cb.flavor  <= jelly_bean_types::NO_FLAVOR;
         
         seq_item_port.get_next_item( jb_tx );
         @jb_if.master_cb;
         jb_if.master_cb.command <= jb_tx.command;
         if ( jb_tx.command == jelly_bean_types::WRITE ) begin
            jb_if.master_cb.flavor       <= jb_tx.flavor;
            jb_if.master_cb.color        <= jb_tx.color;
            jb_if.master_cb.sugar_free   <= jb_tx.sugar_free;
            jb_if.master_cb.sour         <= jb_tx.sour;
         end
         seq_item_port.item_done();
      end
   endtask: main_phase
   
endclass: jelly_bean_driver

//------------------------------------------------------------------------------
// Class: jelly_bean_monitor
//------------------------------------------------------------------------------

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
         if ( jb_if.command == jelly_bean_types::READ ) begin
            jb_tx = jelly_bean_transaction::type_id::create( .name( "jb_tx" ) );
            jb_tx.command = jelly_bean_types::command_e'( jb_if.command );
            @jb_if.master_cb;
            jb_tx.taste = jelly_bean_types::taste_e'( jb_if.taste );
            jb_ap.write( jb_tx );
         end else if ( jb_if.command == jelly_bean_types::WRITE &&
                       jb_if.slave_cb.flavor != jelly_bean_types::NO_FLAVOR ) begin
            jb_tx = jelly_bean_transaction::type_id::create( .name( "jb_tx" ) );
            jb_tx.command    = jelly_bean_types::command_e'( jb_if.command );
            jb_tx.flavor     = jelly_bean_types::flavor_e'( jb_if.slave_cb.flavor );
            jb_tx.color      = jelly_bean_types::color_e'( jb_if.slave_cb.color );
            jb_tx.sugar_free = jb_if.slave_cb.sugar_free;
            jb_tx.sour       = jb_if.slave_cb.sour;
            jb_ap.write( jb_tx );
         end
      end
   endtask: main_phase
endclass: jelly_bean_monitor

//------------------------------------------------------------------------------
// Class: jelly_bean_agent
//------------------------------------------------------------------------------

class jelly_bean_agent extends uvm_agent;
   `uvm_component_utils( jelly_bean_agent )

   uvm_analysis_port#( jelly_bean_transaction ) jb_ap;
     
   jelly_bean_agent_config jb_agent_cfg;
   jelly_bean_sequencer    jb_seqr;
   jelly_bean_driver       jb_drvr;
   jelly_bean_monitor      jb_mon;
   jelly_bean_reg_adapter  jb_reg_adapter;

   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new

   function void build_phase( uvm_phase phase );
      super.build_phase( phase );

      if ( ! uvm_config_db#( jelly_bean_agent_config )::get( .cntxt( this ), 
                                                             .inst_name ( "" ), 
                                                             .field_name( "jb_agent_cfg" ),
                                                             .value( jb_agent_cfg ))) begin
         `uvm_error( "jelly_bean_agent", "jb_agent_cfg not found" )
      end

      jb_ap = new( .name( "jb_ap" ), .parent( this ) );
      if ( jb_agent_cfg.active == UVM_ACTIVE ) begin
         jb_seqr = jelly_bean_sequencer::type_id::create( .name( "jb_seqr" ), 
                                                          .parent( this ) );
         jb_drvr = jelly_bean_driver::type_id::create( .name( "jb_drvr" ), 
                                                       .parent( this ) );
      end
      jb_mon = jelly_bean_monitor::type_id::create( .name( "jb_mon" ),
                                                    .parent( this ) );
      jb_reg_adapter = jelly_bean_reg_adapter::type_id::create( .name( "jb_reg_adapter" ),
                                                                .parent( this ) );
   endfunction: build_phase

   function void connect_phase( uvm_phase phase );
      super.connect_phase( phase );

      jb_mon.jb_if = jb_agent_cfg.jb_if;
      if ( jb_agent_cfg.active == UVM_ACTIVE ) begin
         jb_drvr.seq_item_port.connect( jb_seqr.seq_item_export );
         jb_drvr.jb_if = jb_agent_cfg.jb_if;
      end
      jb_mon.jb_ap.connect( jb_ap );
   endfunction: connect_phase
endclass: jelly_bean_agent

//------------------------------------------------------------------------------
// Class: jelly_bean_fc_subscriber
//------------------------------------------------------------------------------

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

typedef class jelly_bean_scoreboard;
   
//------------------------------------------------------------------------------
// Class: jelly_bean_sb_subscriber
//------------------------------------------------------------------------------

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

//------------------------------------------------------------------------------
// Class: jelly_bean_scoreboard
//------------------------------------------------------------------------------

class jelly_bean_scoreboard extends uvm_scoreboard;
   `uvm_component_utils( jelly_bean_scoreboard )

   uvm_analysis_export#( jelly_bean_transaction ) jb_analysis_export;
   local jelly_bean_sb_subscriber jb_sb_sub;
   
   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new

   function void build_phase(uvm_phase phase );
      super.build_phase( phase );
      jb_analysis_export = new( .name( "jb_analysis_export" ), .parent( this ) );
      jb_sb_sub = jelly_bean_sb_subscriber::type_id::create( .name( "jb_sb_sub" ),
                                                             .parent( this ) );
   endfunction: build_phase

   function void connect_phase( uvm_phase phase );
      super.connect_phase( phase );
      jb_analysis_export.connect( jb_sb_sub.analysis_export );
   endfunction: connect_phase

   virtual function void check_jelly_bean_taste( jelly_bean_transaction jb_tx );
      uvm_table_printer p = new;
      if ( jb_tx.flavor == jelly_bean_types::CHOCOLATE && jb_tx.sour &&
           jb_tx.taste == jelly_bean_types::YUMMY ) begin
         `uvm_error( "jelly_bean_scoreboard", 
                     { "You lost sense of taste!\n", jb_tx.sprint( p ) } );
      end else begin
         `uvm_info( "jelly_bean_scoreboard",
                    { "You have a good sense of taste.\n", jb_tx.sprint( p ) },
                    UVM_LOW );
      end
   endfunction: check_jelly_bean_taste

endclass: jelly_bean_scoreboard

//------------------------------------------------------------------------------
// Class: jelly_bean_env
//------------------------------------------------------------------------------

class jelly_bean_env extends uvm_env;
   `uvm_component_utils( jelly_bean_env )

   jelly_bean_env_config    jb_env_cfg;
   jelly_bean_agent         jb_agent;
   jelly_bean_fc_subscriber jb_fc_sub;
   jelly_bean_scoreboard    jb_sb;
   jelly_bean_reg_predictor jb_reg_predictor;

   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new

   function void build_phase( uvm_phase phase );
      super.build_phase( phase );
      if ( ! uvm_config_db#( jelly_bean_env_config )::get
           ( .cntxt( this ),
             .inst_name( "" ),
             .field_name( "jb_env_cfg" ),
             .value( jb_env_cfg ) ) ) begin
         `uvm_fatal( get_name(), "jb_env_cfg not found" )
      end

      uvm_config_db#( jelly_bean_agent_config )::set( .cntxt( this ), 
                                                      .inst_name( "jb_agent*" ),
                                                      .field_name( "jb_agent_cfg" ),
                                                      .value( jb_env_cfg.jb_agent_cfg ) );
      jb_agent = jelly_bean_agent::type_id::create( .name( "jb_agent" ),
                                                    .parent( this ) );
      jb_reg_predictor = jelly_bean_reg_predictor::type_id::create( .name( "jb_reg_predictor" ),
                                                                    .parent( this ) );
      if ( jb_env_cfg.has_jb_sb ) begin
         jb_sb = jelly_bean_scoreboard::type_id::create( .name( "jb_sb" ),
                                                         .parent( this ) );
      end
      jb_fc_sub = jelly_bean_fc_subscriber::type_id::create( .name( "jb_fc_sub" ),
                                                             .parent( this ) );
    endfunction: build_phase

   function void connect_phase( uvm_phase phase );
      super.connect_phase( phase );
      jb_agent.jb_ap.connect( jb_fc_sub.analysis_export );
      jb_agent.jb_ap.connect( jb_sb.jb_analysis_export );
      if ( jb_env_cfg.jb_reg_block.get_parent() == null ) begin // if the top-level env
         jb_env_cfg.jb_reg_block.reg_map.set_sequencer( .sequencer( jb_agent.jb_seqr ),
                                                        .adapter( jb_agent.jb_reg_adapter ) );
      end
      jb_env_cfg.jb_reg_block.reg_map.set_auto_predict( .on( 0 ) );
      jb_reg_predictor.map     = jb_env_cfg.jb_reg_block.reg_map;
      jb_reg_predictor.adapter = jb_agent.jb_reg_adapter;
      jb_agent.jb_ap.connect( jb_reg_predictor.bus_in );
   endfunction: connect_phase

endclass: jelly_bean_env

//------------------------------------------------------------------------------
// Class: jelly_bean_base_test
//------------------------------------------------------------------------------

class jelly_bean_base_test extends uvm_test;
   `uvm_component_utils( jelly_bean_base_test )

   jelly_bean_env          jb_env;
   jelly_bean_env_config   jb_env_cfg;
   jelly_bean_agent_config jb_agent_cfg;
   jelly_bean_reg_block    jb_reg_block;

   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      jb_reg_block = jelly_bean_reg_block::type_id::create( "jb_reg_block" );
      jb_reg_block.build();

      jb_env_cfg = jelly_bean_env_config::type_id::create( "jb_env_cfg" );
      jb_env_cfg.jb_reg_block = jb_reg_block;

      jb_agent_cfg = jelly_bean_agent_config::type_id::create( "jb_agent_cfg" );
      
      if ( ! uvm_config_db#( virtual jelly_bean_if )::get( .cntxt( this ),
                                                           .inst_name( "" ),
                                                           .field_name( "jb_if" ),
                                                           .value( jb_agent_cfg.jb_if ))) begin
         `uvm_error( "jelly_bean_test", "jb_if not found" )
      end

      jb_env_cfg.jb_agent_cfg = jb_agent_cfg;

      uvm_config_db#(jelly_bean_env_config)::set( .cntxt( null ),
                                                  .inst_name( "*" ),
                                                  .field_name( "jb_env_cfg" ),
                                                  .value( jb_env_cfg ) );
      jb_env = jelly_bean_env::type_id::create( .name( "jb_env" ), 
                                                .parent( this ) );
   endfunction: build_phase

   virtual function void start_of_simulation_phase( uvm_phase phase );
      super.start_of_simulation_phase( phase );
      uvm_top.print_topology();
   endfunction: start_of_simulation_phase

endclass: jelly_bean_base_test

//------------------------------------------------------------------------------
// Class: jelly_bean_reg_test
//------------------------------------------------------------------------------

class jelly_bean_reg_test extends jelly_bean_base_test;
   `uvm_component_utils( jelly_bean_reg_test )

   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new

   task main_phase( uvm_phase phase );
      jelly_bean_reg_sequence jb_reg_seq;

      phase.raise_objection( .obj( this ) );
      jb_reg_seq = jelly_bean_reg_sequence::type_id::create( .name( "jb_reg_seq" ) );
      jb_reg_seq.model = jb_reg_block;
      jb_reg_seq.start( .sequencer( jb_env.jb_agent.jb_seqr ) );
      
      #100ns;
      phase.drop_objection( .obj( this ) );
      
   endtask: main_phase
endclass: jelly_bean_reg_test

//------------------------------------------------------------------------------
// Class: jelly_bean_reg_hw_reset_test
//------------------------------------------------------------------------------

class jelly_bean_reg_hw_reset_test extends jelly_bean_base_test;
   `uvm_component_utils( jelly_bean_reg_hw_reset_test )

   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new

   task main_phase( uvm_phase phase );
      uvm_reg_hw_reset_seq reg_hw_reset_seq;

      phase.raise_objection( .obj( this ) );
      reg_hw_reset_seq = uvm_reg_hw_reset_seq::type_id::create( .name( "reg_hw_reset_seq" ) );
      reg_hw_reset_seq.model = jb_reg_block;
      reg_hw_reset_seq.start( .sequencer( jb_env.jb_agent.jb_seqr ) );
      
      phase.drop_objection( .obj( this ) );
   endtask: main_phase
endclass: jelly_bean_reg_hw_reset_test

endpackage: jelly_bean_pkg

//------------------------------------------------------------------------------
// Module: jelly_bean_taster
//   This is the DUT.
//------------------------------------------------------------------------------

module jelly_bean_taster( jelly_bean_if.slave_mp jb_slave_if );
   import jelly_bean_pkg::*;

   reg [2:0] flavor;
   reg [1:0] color;
   reg       sugar_free;
   reg       sour;
   reg [1:0] command;
   reg [1:0] taste;

   initial begin
      flavor     = 0;
      color      = 0;
      sugar_free = 0;
      sour       = 0;
      command    = 0;
      taste      = 0;
   end

   always @ ( posedge jb_slave_if.clk ) begin
      if ( jb_slave_if.command == jelly_bean_types::WRITE ) begin
         flavor     <= jb_slave_if.flavor;
         color      <= jb_slave_if.color;
         sugar_free <= jb_slave_if.sugar_free;
         sour       <= jb_slave_if.sour;
      end else if ( jb_slave_if.command == jelly_bean_types::READ ) begin
         jb_slave_if.taste <= taste;
      end
   end

   always @ ( posedge jb_slave_if.clk ) begin
      if ( jb_slave_if.flavor == jelly_bean_types::CHOCOLATE &&
           jb_slave_if.sour ) begin
         taste <= jelly_bean_types::YUCKY;
      end else if ( jb_slave_if.flavor != jelly_bean_types::NO_FLAVOR ) begin
         taste <= jelly_bean_types::YUMMY;
      end
   end
endmodule: jelly_bean_taster

//------------------------------------------------------------------------------
// Module: top
//------------------------------------------------------------------------------

module top;
   import uvm_pkg::*;

   reg clk;
   
   jelly_bean_if     jb_if( clk );
   jelly_bean_taster jb_taster( jb_if );

   initial begin
      clk = 0;
      #5ns ;
      forever #5ns clk = ! clk;
   end

   initial begin
      uvm_config_db#( virtual jelly_bean_if )::set( .cntxt( null ), 
                                                    .inst_name( "uvm_test_top" ),
                                                    .field_name( "jb_if" ),
                                                    .value( jb_if ) );
      run_test();
   end
endmodule: top

//==============================================================================
// Copyright (c) 2011-2014 ClueLogic, LLC
// http://cluelogic.com/
//==============================================================================
