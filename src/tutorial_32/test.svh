//------------------------------------------------------------------------------
// Class: jelly_bean_test
//------------------------------------------------------------------------------

class jelly_bean_test extends uvm_test;
  `uvm_component_utils( jelly_bean_test )

  jelly_bean_env jb_env;

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
  
endclass: jelly_bean_test

//==============================================================================
// Copyright (c) 2014 ClueLogic, LLC
// http://cluelogic.com/
//==============================================================================