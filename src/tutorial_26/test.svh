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

    jb_env = jelly_bean_env::type_id::create( .name( "jb_env" ), .parent( this ) );
  endfunction: build_phase

  //----------------------------------------------------------------------------
  // task: main_phase
  //----------------------------------------------------------------------------

  task main_phase( uvm_phase phase );
    jelly_bean_order_sequence standard_order_seq;
    jelly_bean_order_sequence priority_order_seq1;
    jelly_bean_order_sequence priority_order_seq2;
    jelly_bean_order_sequence overnight_order_seq;

    standard_order_seq  = jelly_bean_order_sequence::type_id::create( "standard_order_seq" );
    priority_order_seq1 = jelly_bean_order_sequence::type_id::create( "priority_order_seq1" );
    priority_order_seq2 = jelly_bean_order_sequence::type_id::create( "priority_order_seq2" );
    overnight_order_seq = jelly_bean_order_sequence::type_id::create( "overnight_order_seq" );
    
    assert( standard_order_seq .randomize() with { num_jelly_beans == 4; jb_flavor == APPLE;      } );
    assert( priority_order_seq1.randomize() with { num_jelly_beans == 4; jb_flavor == BLUEBERRY;  } );
    assert( priority_order_seq2.randomize() with { num_jelly_beans == 4; jb_flavor == BUBBLE_GUM; } );
    assert( overnight_order_seq.randomize() with { num_jelly_beans == 4; jb_flavor == CHOCOLATE;  } );
    
    standard_order_seq .set_starting_phase( phase );
    priority_order_seq1.set_starting_phase( phase );
    priority_order_seq2.set_starting_phase( phase );
    overnight_order_seq.set_starting_phase( phase );
    
    standard_order_seq .set_automatic_phase_objection( .value( 1 ) );
    priority_order_seq1.set_automatic_phase_objection( .value( 1 ) );
    priority_order_seq2.set_automatic_phase_objection( .value( 1 ) );
    overnight_order_seq.set_automatic_phase_objection( .value( 1 ) );
    
    //jb_env.jb_agent.jb_seqr.set_arbitration( UVM_SEQ_ARB_FIFO ); // default
    //jb_env.jb_agent.jb_seqr.set_arbitration( UVM_SEQ_ARB_RANDOM );
    //jb_env.jb_agent.jb_seqr.set_arbitration( UVM_SEQ_ARB_STRICT_FIFO );
    //jb_env.jb_agent.jb_seqr.set_arbitration( UVM_SEQ_ARB_STRICT_RANDOM );
    //jb_env.jb_agent.jb_seqr.set_arbitration( UVM_SEQ_ARB_WEIGHTED );
    //jb_env.jb_agent.jb_seqr.set_arbitration( UVM_SEQ_ARB_USER );

    fork
      standard_order_seq .start( jb_env.jb_agent.jb_seqr, .this_priority( 100 ) ); // default priority
      priority_order_seq1.start( jb_env.jb_agent.jb_seqr, .this_priority( 200 ) );
      priority_order_seq2.start( jb_env.jb_agent.jb_seqr, .this_priority( 200 ) );
      overnight_order_seq.start( jb_env.jb_agent.jb_seqr, .this_priority( 300 ) );
    join
  endtask: main_phase

endclass: jelly_bean_test

//==============================================================================
// Copyright (c) 2015 ClueLogic, LLC
// http://cluelogic.com/
//==============================================================================