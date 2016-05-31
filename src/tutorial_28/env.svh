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
    //            _ID__  ___________________MESSAGE____________________
    `uvm_info   ( "id1", { t.color.name(), " ", t.flavor.name(), " 1" }, UVM_NONE )
    `uvm_info   ( "id2", { t.color.name(), " ", t.flavor.name(), " 2" }, UVM_NONE )
    `uvm_warning( "id1", { t.color.name(), " ", t.flavor.name(), " 3" } )
    `uvm_warning( "id2", { t.color.name(), " ", t.flavor.name(), " 4" } )
    `uvm_error  ( "id1", { t.color.name(), " ", t.flavor.name(), " 5" } )
    `uvm_error  ( "id2", { t.color.name(), " ", t.flavor.name(), " 6" } )
    `uvm_fatal  ( "id1", { t.color.name(), " ", t.flavor.name(), " 7" } )
    `uvm_fatal  ( "id2", { t.color.name(), " ", t.flavor.name(), " 8" } )
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
    end
  endfunction: write
  
endclass: jelly_bean_sb_subscriber

//------------------------------------------------------------------------------
// Class: jelly_bean_env
//------------------------------------------------------------------------------

class jelly_bean_env extends uvm_env;
  `uvm_component_utils( jelly_bean_env )

  jelly_bean_agent         jb_agent;
  jelly_bean_fc_subscriber jb_fc;
  jelly_bean_sb_subscriber jb_sb;
  
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
    jb_agent = jelly_bean_agent        ::type_id::create( .name( "jb_agent" ), .parent( this ) );
    jb_fc    = jelly_bean_fc_subscriber::type_id::create( .name( "jb_fc"    ), .parent( this ) );
    jb_sb    = jelly_bean_sb_subscriber::type_id::create( .name( "jb_sb"    ), .parent( this ) );
  endfunction: build_phase
  
  //----------------------------------------------------------------------------
  // Function: connect_phase
  //----------------------------------------------------------------------------

  function void connect_phase( uvm_phase phase );
    super.connect_phase( phase );
    jb_agent.jb_ap.connect( jb_fc.analysis_export );
    jb_agent.jb_ap.connect( jb_sb.analysis_export );
  endfunction: connect_phase
  
endclass: jelly_bean_env

//==============================================================================
// Copyright (c) 2015 ClueLogic, LLC
// http://cluelogic.com/
//==============================================================================