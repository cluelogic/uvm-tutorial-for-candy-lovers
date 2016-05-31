//------------------------------------------------------------------------------
// Typedef: jelly_bean_sequencer
//------------------------------------------------------------------------------

typedef uvm_sequencer#( jelly_bean_transaction ) jelly_bean_sequencer;

//------------------------------------------------------------------------------
// Class: jelly_bean_driver
//------------------------------------------------------------------------------

class jelly_bean_driver extends uvm_driver#( jelly_bean_transaction );
  `uvm_component_utils( jelly_bean_driver )

  virtual jelly_bean_if jb_vi;
  
  //----------------------------------------------------------------------------
  // Function: new
  //----------------------------------------------------------------------------

  function new( string name, uvm_component parent );
    super.new( name, parent );
  endfunction: new

  //----------------------------------------------------------------------------
  // Function: build_phase
  //----------------------------------------------------------------------------

  function void build_phase( uvm_phase phase );
    super.build_phase( phase );
  endfunction: build_phase

  //----------------------------------------------------------------------------
  // Function: main_phase
  //----------------------------------------------------------------------------

  task main_phase( uvm_phase phase );
    jelly_bean_transaction jb_tx;

    forever begin
      @jb_vi.master_cb;
      jb_vi.master_cb.command <= NO_OP;
      jb_vi.master_cb.color   <= NO_COLOR;
      jb_vi.master_cb.flavor  <= NO_FLAVOR;
      
      seq_item_port.get_next_item( jb_tx );
      phase.raise_objection( .obj( this ), .description( get_name() ) );
      @jb_vi.master_cb;
      jb_vi.master_cb.command <= jb_tx.command;
      if ( jb_tx.command == JB_WRITE ) begin
        jb_vi.master_cb.flavor     <= jb_tx.flavor;
        jb_vi.master_cb.color      <= jb_tx.color;
        jb_vi.master_cb.sugar_free <= jb_tx.sugar_free;
        jb_vi.master_cb.sour       <= jb_tx.sour;
      end
      seq_item_port.item_done();
      phase.drop_objection( .obj( this ), .description( get_name() ) );
    end
  endtask: main_phase
  
endclass: jelly_bean_driver

//------------------------------------------------------------------------------
// Class: jelly_bean_monitor
//------------------------------------------------------------------------------

class jelly_bean_monitor extends uvm_monitor;
  `uvm_component_utils( jelly_bean_monitor )

  uvm_analysis_port#( jelly_bean_transaction ) jb_ap;
  
  virtual jelly_bean_if jb_vi;
  
  //----------------------------------------------------------------------------
  // Function: new
  //----------------------------------------------------------------------------

  function new( string name, uvm_component parent );
    super.new( name, parent );
  endfunction: new

  //----------------------------------------------------------------------------
  // Function: build_phase
  //----------------------------------------------------------------------------
  
  function void build_phase( uvm_phase phase );
    super.build_phase( phase );
    jb_ap = new( .name( "jp_ap" ), .parent( this ) );
  endfunction: build_phase
  
  //----------------------------------------------------------------------------
  // Function: main_phase
  //----------------------------------------------------------------------------

  task main_phase( uvm_phase phase );
    forever begin
      jelly_bean_transaction jb_tx;
      
      @jb_vi.slave_cb;
      if ( jb_vi.command == JB_READ ) begin
        phase.raise_objection( .obj( this ), .description( get_name() ) );
        jb_tx = jelly_bean_transaction::type_id::create( .name( "jb_tx" ) );
        jb_tx.command = command_e'( jb_vi.command );
        @jb_vi.slave_cb;
        jb_tx.taste = taste_e'( jb_vi.taste );
        jb_ap.write( jb_tx );
        phase.drop_objection( .obj( this ), .description( get_name() ) );
      end else if ( jb_vi.command == JB_WRITE && jb_vi.flavor != NO_FLAVOR ) begin
        jb_tx = jelly_bean_transaction::type_id::create( .name( "jb_tx" ) );
        jb_tx.command    = command_e'( jb_vi.command );
        jb_tx.flavor     =  flavor_e'( jb_vi.flavor  );
        jb_tx.color      =   color_e'( jb_vi.color   );
        jb_tx.sugar_free = jb_vi.sugar_free;
        jb_tx.sour       = jb_vi.sour;
        jb_ap.write( jb_tx );
      end
    end
  endtask: main_phase
  
endclass: jelly_bean_monitor

//--------------------------------------------------------------------------
// Class: jelly_bean_agent_config
//--------------------------------------------------------------------------

class jelly_bean_agent_config extends uvm_object;
  `uvm_object_utils( jelly_bean_agent_config )

  uvm_active_passive_enum active = UVM_ACTIVE;
  bit has_jb_fc_sub = 1; // switch to instantiate a functional coverage subscriber

  virtual jelly_bean_if jb_vi;
  
  //----------------------------------------------------------------------------
  // Function: new
  //----------------------------------------------------------------------------

  function new( string name = "" );
     super.new( name );
  endfunction: new
  
endclass: jelly_bean_agent_config

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
  
  //----------------------------------------------------------------------------
  // Function: new
  //----------------------------------------------------------------------------

  function new( string name, uvm_component parent );
    super.new( name, parent );
  endfunction: new

  //----------------------------------------------------------------------------
  // Function: build_phase
  //----------------------------------------------------------------------------
  
  function void build_phase( uvm_phase phase );
    super.build_phase( phase );
    
    if ( ! uvm_config_db#( jelly_bean_agent_config )::get( .cntxt( this ), 
                                                           .inst_name( "" ), 
                                                           .field_name( "jb_agent_cfg" ),
                                                           .value( jb_agent_cfg ) ) ) begin
      `uvm_error( "jelly_bean_agent", "jb_agent_cfg not found" )
    end

    jb_ap = new( .name( "jb_ap" ), .parent( this ) );
    if ( jb_agent_cfg.active == UVM_ACTIVE ) begin
      jb_seqr = jelly_bean_sequencer::type_id::create( .name( "jb_seqr" ), .parent( this ) );
      jb_drvr = jelly_bean_driver   ::type_id::create( .name( "jb_drvr" ), .parent( this ) );
    end
    jb_mon = jelly_bean_monitor::type_id::create( .name( "jb_mon" ), .parent( this ) );
    jb_reg_adapter = jelly_bean_reg_adapter::type_id::create( .name( "jb_reg_adapter" ),
                                                              .parent( this ) );
  endfunction: build_phase
  
  //----------------------------------------------------------------------------
  // Function: connect_phase
  //----------------------------------------------------------------------------

  function void connect_phase( uvm_phase phase );
    super.connect_phase( phase );
    
    jb_mon.jb_vi = jb_agent_cfg.jb_vi;
    if ( jb_agent_cfg.active == UVM_ACTIVE ) begin
      jb_drvr.seq_item_port.connect( jb_seqr.seq_item_export );
      jb_drvr.jb_vi = jb_agent_cfg.jb_vi;
    end
    jb_mon.jb_ap.connect( jb_ap );
  endfunction: connect_phase
  
endclass: jelly_bean_agent

//==============================================================================
// Copyright (c) 2014 ClueLogic, LLC
// http://cluelogic.com/
//==============================================================================