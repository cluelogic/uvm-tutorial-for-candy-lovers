//------------------------------------------------------------------------------
// Class: jelly_bean_test
//------------------------------------------------------------------------------

class jelly_bean_test extends uvm_test;
  `uvm_component_utils( jelly_bean_test )

  jelly_bean_env jb_env;
  protected int default_fd;
  protected int warning_fd;
  protected int id1_fd;
  protected int warning_id1_fd;

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

    jelly_bean_transaction::type_id::set_type_override( 
      sugar_free_jelly_bean_transaction::get_type() );
    jb_env = jelly_bean_env::type_id::create( .name( "jb_env" ), .parent( this ) );
  endfunction: build_phase

  //----------------------------------------------------------------------------
  // Function: start_of_simulation_phase
  //----------------------------------------------------------------------------

  function void start_of_simulation_phase( uvm_phase phase );
    default_fd     = $fopen( "default_file",     "w" );
    warning_fd     = $fopen( "warning_file",     "w" );
    id1_fd         = $fopen( "id1_file",         "w" );
    warning_id1_fd = $fopen( "warning_id1_file", "w" );
    assert( default_fd     );
    assert( warning_fd     );
    assert( id1_fd         );
    assert( warning_id1_fd );
    
    jb_env.jb_fc.set_report_severity_action( UVM_INFO,    UVM_DISPLAY | UVM_LOG );
    jb_env.jb_fc.set_report_severity_action( UVM_WARNING, UVM_DISPLAY | UVM_LOG );
    jb_env.jb_fc.set_report_severity_action( UVM_ERROR,   UVM_DISPLAY | UVM_LOG );
    jb_env.jb_fc.set_report_severity_action( UVM_FATAL,   UVM_DISPLAY | UVM_LOG );
/*
    jb_env.jb_fc.set_report_id_action         (           "id1", UVM_DISPLAY | UVM_LOG );
    jb_env.jb_fc.set_report_severity_id_action( UVM_INFO, "id1", UVM_DISPLAY | UVM_LOG );
*/    
    jb_env.jb_fc.set_report_default_file    (                     default_fd     );
    jb_env.jb_fc.set_report_severity_file   ( UVM_WARNING,        warning_fd     );
    jb_env.jb_fc.set_report_id_file         (              "id1", id1_fd         );
    jb_env.jb_fc.set_report_severity_id_file( UVM_WARNING, "id1", warning_id1_fd );
  endfunction: start_of_simulation_phase

  //----------------------------------------------------------------------------
  // task: main_phase
  //----------------------------------------------------------------------------

  task main_phase( uvm_phase phase );
    gift_boxed_jelly_bean_sequence jb_seq;
    
    jb_seq = gift_boxed_jelly_bean_sequence::type_id::create( .name( "jb_seq" ) );
    assert( jb_seq.randomize() );
    `uvm_info( "jb_seq", jb_seq.convert2string(), UVM_NONE )
    jb_seq.set_starting_phase( phase );
    jb_seq.set_automatic_phase_objection( .value( 1 ) );
    jb_seq.start( jb_env.jb_agent.jb_seqr );
  endtask: main_phase

  //----------------------------------------------------------------------------
  // Function: final_phase
  //----------------------------------------------------------------------------

  function void final_phase( uvm_phase phase );
    $fclose( default_fd     );
    $fclose( warning_fd     );
    $fclose( id1_fd         );
    $fclose( warning_id1_fd );
  endfunction: final_phase

endclass: jelly_bean_test

//==============================================================================
// Copyright (c) 2015 ClueLogic, LLC
// http://cluelogic.com/
//==============================================================================