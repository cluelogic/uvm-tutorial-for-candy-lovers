//==============================================================================
// tutorial_21.sv (v0.1.0) - Source code for "UVM Tutorial for Candy Lovers"
//                           Post #21
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
      jelly_bean_transaction jb_req;
      jb_req = jelly_bean_transaction::type_id::create( .name( "jb_req" ) );
      start_item( jb_req );
`ifndef CL_USE_MODELSIM
      assert( jb_req.randomize() );
`endif
      `uvm_info( "one_jelly_bean_sequence", { "Generated:\n", jb_req.sprint() }, UVM_NONE )
      finish_item( jb_req );
   endtask: body
endclass: one_jelly_bean_sequence

   //---------------------------------------------------------------------------
   // Typedef: jelly_bean_sequencer
   //---------------------------------------------------------------------------

   typedef uvm_sequencer#(jelly_bean_transaction) jelly_bean_sequencer;

   //---------------------------------------------------------------------------
   // Class: jelly_bean_put_driver
   //---------------------------------------------------------------------------

class jelly_bean_put_driver extends uvm_driver#( jelly_bean_transaction );
   `uvm_component_utils( jelly_bean_put_driver )

   uvm_put_port#( jelly_bean_transaction ) put_port;

   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new

   function void build_phase( uvm_phase phase );
      super.build_phase( phase );
      put_port = new( .name( "put_port" ), .parent( this ) );
   endfunction: build_phase

   task run_phase( uvm_phase phase );
      jelly_bean_transaction jb_req;

      forever begin
         seq_item_port.get_next_item( jb_req );
         `uvm_info( get_type_name(), "[seq_item_port]-->{jb_req}-->[put_port]", UVM_NONE )
         put_port.put( jb_req );
         seq_item_port.item_done();
      end
   endtask: run_phase
endclass: jelly_bean_put_driver

   //---------------------------------------------------------------------------
   // Class: jelly_bean_master
   //---------------------------------------------------------------------------

class jelly_bean_master extends uvm_component;
   `uvm_component_utils( jelly_bean_master )

   uvm_get_port#( jelly_bean_transaction ) get_port;
   uvm_master_port#( .REQ( jelly_bean_transaction ), 
                     .RSP( jelly_bean_transaction ) ) master_port;
   uvm_analysis_port#( jelly_bean_transaction ) rsp_ap;

   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new

   function void build_phase( uvm_phase phase );
      super.build_phase( phase );
      get_port    = new( .name( "get_port" ),    .parent( this ) );
      master_port = new( .name( "master_port" ), .parent( this ) );
      rsp_ap      = new( .name( "rsp_ap" ),      .parent( this ) );
   endfunction: build_phase

   task run_phase( uvm_phase phase );
      jelly_bean_transaction jb_req;
      jelly_bean_transaction jb_rsp;

      forever begin
         get_port.get( jb_req );
         `uvm_info( get_type_name(), "[get_port]-->{jb_req}-->[master_port]", UVM_NONE )
         master_port.put( jb_req );
         `uvm_info( get_type_name(), "{jb_rsp}<--[master_port]", UVM_NONE )
         master_port.get( jb_rsp );
         `uvm_info( get_type_name(), "{jb_rsp}-->[rsp_ap]", UVM_NONE )
         rsp_ap.write( jb_rsp );
      end
   endtask: run_phase
endclass: jelly_bean_master

   //---------------------------------------------------------------------------
   // Class: jelly_bean_slave
   //---------------------------------------------------------------------------

class jelly_bean_slave extends uvm_component;
   `uvm_component_utils( jelly_bean_slave )

   uvm_master_imp#( .REQ( jelly_bean_transaction ), 
                    .RSP( jelly_bean_transaction ),
                    .IMP( jelly_bean_slave ) ) master_export;
   uvm_transport_port#( .REQ( jelly_bean_transaction ),
                        .RSP( jelly_bean_transaction ) ) trans_port;
   jelly_bean_transaction req_q[$];
   jelly_bean_transaction rsp_q[$];

   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new

   function void build_phase( uvm_phase phase );
      super.build_phase( phase );
      master_export = new( "master_export", this );
      trans_port    = new( .name( "trans_port" ), .parent( this ) );
   endfunction: build_phase

   task run_phase( uvm_phase phase );
      jelly_bean_transaction jb_rsp;
      
      forever begin
         wait ( req_q.size() > 0 );
         `uvm_info( get_type_name(), "(master_export)---{jb_req}-->[trans_port]", UVM_NONE )
         trans_port.transport( req_q.pop_front(), jb_rsp );
         `uvm_info( get_type_name(), "{jb_rsp}<--[trans_port]", UVM_NONE )
         rsp_q.push_back( jb_rsp );
      end
   endtask: run_phase

   virtual task put( input jelly_bean_transaction t );
      req_q.push_back( t );
   endtask: put

   virtual function bit try_put( input jelly_bean_transaction t );
      req_q.push_back( t );
      return 1;
   endfunction: try_put

   virtual function bit can_put();
      return 1;
   endfunction: can_put

   virtual task get( output jelly_bean_transaction t );
      wait ( rsp_q.size() > 0 );
      t = rsp_q.pop_front();
   endtask: get

   virtual function bit try_get( output jelly_bean_transaction t );
      if ( rsp_q.size() > 0 ) begin
         t = rsp_q.pop_front();
         return 1;
      end else begin
         return 0;
      end
   endfunction: try_get

   virtual function bit can_get();
      return rsp_q.size() > 0;
   endfunction: can_get

   virtual task peek( output jelly_bean_transaction t );
      wait ( rsp_q.size() > 0 );
      t = rsp_q[0];
   endtask: peek

   virtual function bit try_peek( output jelly_bean_transaction t );
      if ( rsp_q.size() > 0 ) begin
         t = rsp_q[0];
         return 1;
      end else begin
         return 0;
      end
   endfunction: try_peek

   virtual function bit can_peek();
      return rsp_q.size() > 0;
   endfunction: can_peek
endclass: jelly_bean_slave

   //---------------------------------------------------------------------------
   // Class: jelly_bean_transporter
   //---------------------------------------------------------------------------

class jelly_bean_transporter extends uvm_component;
   `uvm_component_utils( jelly_bean_transporter )

   uvm_transport_imp#( .REQ( jelly_bean_transaction ),
                       .RSP( jelly_bean_transaction ),
                       .IMP( jelly_bean_transporter ) ) trans_export;

   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new

   function void build_phase( uvm_phase phase );
      super.build_phase( phase );
      trans_export = new( "trans_export", this );
   endfunction: build_phase

   virtual task transport( input  jelly_bean_transaction jb_req,
                           output jelly_bean_transaction jb_rsp );
      assert( nb_transport( jb_req, jb_rsp ) );
   endtask: transport

   virtual function bit nb_transport( input  jelly_bean_transaction jb_req,
                                      output jelly_bean_transaction jb_rsp );
      jb_rsp = jelly_bean_transaction::type_id::create( "jb_rsp" );
      jb_rsp.copy( jb_req );
      if ( jb_req.flavor == jelly_bean_transaction::CHOCOLATE && jb_req.sour )
        jb_rsp.taste = jelly_bean_transaction::YUCKY;
      else
        jb_rsp.taste = jelly_bean_transaction::YUMMY;
      `uvm_info( get_type_name(), { "Returning:\n", jb_rsp.sprint() }, UVM_NONE )
      return 1;
   endfunction: nb_transport
endclass: jelly_bean_transporter
   
class jelly_bean_subscriber extends uvm_subscriber#( jelly_bean_transaction );
   `uvm_component_utils( jelly_bean_subscriber )

   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new

   function void write( jelly_bean_transaction t );
      `uvm_info( get_type_name(), { "Received:\n", t.sprint() }, UVM_NONE )
   endfunction: write
endclass: jelly_bean_subscriber

   //---------------------------------------------------------------------------
   // Class: jelly_bean_agent
   //---------------------------------------------------------------------------

class jelly_bean_agent extends uvm_agent;
   `uvm_component_utils( jelly_bean_agent )

   jelly_bean_sequencer                    jb_seqr;
   jelly_bean_put_driver                   jb_put_drvr;
   uvm_tlm_fifo#( jelly_bean_transaction ) jb_fifo;
   jelly_bean_master                       jb_master;
   jelly_bean_slave                        jb_slave;
   jelly_bean_transporter                  jb_trans;
   jelly_bean_subscriber                   jb_sub;

   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new

   function void build_phase( uvm_phase phase );
      super.build_phase( phase );
      jb_seqr     = jelly_bean_sequencer  ::type_id::create( .name( "jb_seqr" ),     .parent( this ) );
      jb_put_drvr = jelly_bean_put_driver ::type_id::create( .name( "jb_put_drvr" ), .parent( this ) );
      jb_fifo     = new(                                     .name( "jb_fifo" ),     .parent( this ) );
      jb_master   = jelly_bean_master     ::type_id::create( .name( "jb_master" ),   .parent( this ) );
      jb_slave    = jelly_bean_slave      ::type_id::create( .name( "jb_slave" ),    .parent( this ) );
      jb_trans    = jelly_bean_transporter::type_id::create( .name( "jb_trans" ),    .parent( this ) );
      jb_sub      = jelly_bean_subscriber ::type_id::create( .name( "jb_sub" ),      .parent( this ) );
   endfunction: build_phase

   function void connect_phase( uvm_phase phase );
      super.connect_phase( phase );
      jb_put_drvr.seq_item_port.connect( jb_seqr.seq_item_export );
      jb_put_drvr.     put_port.connect( jb_fifo.put_export );
      jb_master.       get_port.connect( jb_fifo.get_peek_export );
      jb_master.    master_port.connect( jb_slave.master_export );
      jb_slave.      trans_port.connect( jb_trans.trans_export );
      jb_master.         rsp_ap.connect( jb_sub.analysis_export );
   endfunction: connect_phase
endclass: jelly_bean_agent

   //---------------------------------------------------------------------------
   // Class: jelly_bean_env
   //---------------------------------------------------------------------------

class jelly_bean_env extends uvm_env;
   `uvm_component_utils( jelly_bean_env )

   jelly_bean_agent jb_agent;

   function new( string name, uvm_component parent );
      super.new( name, parent );
   endfunction: new

   function void build_phase( uvm_phase phase );
      super.build_phase( phase );
      jb_agent  = jelly_bean_agent::type_id::create( .name( "jb_agent"  ), .parent( this ) );
    endfunction: build_phase

   function void connect_phase( uvm_phase phase );
      super.connect_phase( phase );
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
      one_jelly_bean_sequence jb_seq;

      phase.raise_objection( .obj( this ) );
      jb_seq = one_jelly_bean_sequence::type_id::create( .name( "jb_seq" ) );
`ifndef CL_USE_MODELSIM
      assert( jb_seq.randomize() );
`endif
//    `uvm_info( "jelly_bean_test", { "\n", jb_seq.sprint() }, UVM_LOW )
      jb_seq.start( jb_env.jb_agent.jb_seqr );
      #10ns ;
      phase.drop_objection( .obj( this ) );
   endtask: run_phase
endclass: jelly_bean_test

endpackage: jelly_bean_pkg

   //---------------------------------------------------------------------------
   // Module: top
   //---------------------------------------------------------------------------

module top;
   import uvm_pkg::*;
   import jelly_bean_pkg::*;

   initial run_test();
endmodule: top

//==============================================================================
// Copyright (c) 2011-2014 ClueLogic, LLC
// http://cluelogic.com/
//==============================================================================
