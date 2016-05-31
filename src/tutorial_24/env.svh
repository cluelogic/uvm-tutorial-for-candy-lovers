//------------------------------------------------------------------------------
// Class: jelly_bean_fc_subscriber
//   Functional coverage collector.
//------------------------------------------------------------------------------

class jelly_bean_fc_subscriber extends uvm_subscriber#( jelly_bean_transaction );
  `uvm_component_utils( jelly_bean_fc_subscriber )

  jelly_bean_transaction jb_tx;
  
  //----------------------------------------------------------------------------
  // Covergroup: jelly_bean_cg
  //----------------------------------------------------------------------------

  covergroup jelly_bean_cg;
    flavor_cp:     coverpoint jb_tx.flavor;
    color_cp:      coverpoint jb_tx.color;
    sugar_free_cp: coverpoint jb_tx.sugar_free;
    sour_cp:       coverpoint jb_tx.sour;
    cross flavor_cp, color_cp, sugar_free_cp, sour_cp;
  endgroup: jelly_bean_cg

  //----------------------------------------------------------------------------
  // Function: new
  //----------------------------------------------------------------------------

  function new( string name, uvm_component parent );
    super.new( name, parent );
    jelly_bean_cg = new;
  endfunction: new

  //----------------------------------------------------------------------------
  // Function: write
  //----------------------------------------------------------------------------

  function void write( jelly_bean_transaction t );
    jb_tx = t;
    jelly_bean_cg.sample();
  endfunction: write
  
endclass: jelly_bean_fc_subscriber

//------------------------------------------------------------------------------
// Class: jelly_bean_sb_subscriber
//   Scoreboard.
//------------------------------------------------------------------------------

class jelly_bean_sb_subscriber extends uvm_subscriber#( jelly_bean_transaction );
  `uvm_component_utils( jelly_bean_sb_subscriber )
  
  //----------------------------------------------------------------------------
  // Function: new
  //----------------------------------------------------------------------------

  function new( string name, uvm_component parent );
    super.new( name, parent );
  endfunction: new
  
  //----------------------------------------------------------------------------
  // Function: write
  //----------------------------------------------------------------------------

  function void write( jelly_bean_transaction t );
    if (     t.flavor == CHOCOLATE && t.sour   && t.taste == YUMMY ||
         ! ( t.flavor == CHOCOLATE && t.sour ) && t.taste == YUCKY ) begin
      `uvm_error( get_name(), { "You lost sense of taste!", t.convert2string() } )
    end else begin
      `uvm_info( get_name(), { "You have a good sense of taste.", t.convert2string() },
                 UVM_LOW )
    end
  endfunction: write
  
endclass: jelly_bean_sb_subscriber

//------------------------------------------------------------------------------
// Class: jelly_bean_env_config
//------------------------------------------------------------------------------

class jelly_bean_env_config extends uvm_object;
  `uvm_object_utils( jelly_bean_env_config )

  bit has_jb_agent = 1;
  bit has_jb_sb    = 0;
   
  jelly_bean_agent_config jb_agent_cfg;
  jelly_bean_reg_block    jb_reg_block;
  
  //----------------------------------------------------------------------------
  // Function: new
  //----------------------------------------------------------------------------

  function new( string name = "" );
     super.new( name );
  endfunction: new
  
endclass: jelly_bean_env_config

//------------------------------------------------------------------------------
// Class: jelly_bean_env
//------------------------------------------------------------------------------

class jelly_bean_env extends uvm_env;
  `uvm_component_utils( jelly_bean_env )

  jelly_bean_env_config    jb_env_cfg;
  jelly_bean_agent         jb_agent;
  jelly_bean_fc_subscriber jb_fc;
  jelly_bean_sb_subscriber jb_sb;
  jelly_bean_reg_predictor jb_reg_predictor;
  
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
    
    if ( ! uvm_config_db#( jelly_bean_env_config )::get( .cntxt( this ),
                                                        .inst_name( "" ),
                                                        .field_name( "jb_env_cfg" ),
                                                        .value( jb_env_cfg  ) ) ) begin
      `uvm_fatal( get_name(), "jb_env_cfg not found" )
    end
    
    uvm_config_db#( jelly_bean_agent_config )::set( .cntxt( this ), 
                                                    .inst_name( "jb_agent*" ),
                                                    .field_name( "jb_agent_cfg" ),
                                                    .value( jb_env_cfg.jb_agent_cfg ) );
    jb_agent = jelly_bean_agent::type_id::create( .name( "jb_agent" ), .parent( this ) );
    jb_fc    = jelly_bean_fc_subscriber::type_id::create( .name( "jb_fc" ), .parent( this ) );
    if ( jb_env_cfg.has_jb_sb ) begin
      jb_sb = jelly_bean_sb_subscriber::type_id::create( .name( "jb_sb" ), .parent( this ) );
    end
    jb_reg_predictor = jelly_bean_reg_predictor::type_id::create( .name( "jb_reg_predictor" ),
                                                                  .parent ( this ) );
  endfunction: build_phase
  
  //----------------------------------------------------------------------------
  // Function: connect_phase
  //----------------------------------------------------------------------------

  function void connect_phase( uvm_phase phase );
    super.connect_phase( phase );
    jb_agent.jb_ap.connect( jb_fc.analysis_export );
    if ( jb_env_cfg.has_jb_sb ) jb_agent.jb_ap.connect( jb_sb.analysis_export );
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

//==============================================================================
// Copyright (c) 2014 ClueLogic, LLC
// http://cluelogic.com/
//==============================================================================