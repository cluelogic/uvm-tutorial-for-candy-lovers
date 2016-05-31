//------------------------------------------------------------------------------
// Class: one_jelly_bean_sequence
//------------------------------------------------------------------------------

class one_jelly_bean_sequence extends uvm_sequence#( jelly_bean_transaction );
  `uvm_object_utils( one_jelly_bean_sequence )
  
  //----------------------------------------------------------------------------
  // Function: new
  //----------------------------------------------------------------------------

  function new( string name = "one_jelly_bean_sequence" );
    super.new( name );
  endfunction: new

  //----------------------------------------------------------------------------
  // Task: body
  //----------------------------------------------------------------------------
  
  task body();
    jelly_bean_transaction jb_tx;
    jb_tx = jelly_bean_transaction::type_id::create( .name( "jb_tx" ) );
    start_item( jb_tx );
    assert( jb_tx.randomize() );
    finish_item( jb_tx );
  endtask: body
  
endclass: one_jelly_bean_sequence

//------------------------------------------------------------------------------
// Class: same_flavored_jelly_bean_sequence
//   Sequence of transactions.
//------------------------------------------------------------------------------

class same_flavored_jelly_bean_sequence extends uvm_sequence#( jelly_bean_transaction );
  `uvm_object_utils( same_flavored_jelly_bean_sequence )
  
  rand int unsigned num_jelly_beans; // knob

  constraint num_jelly_beans_con { num_jelly_beans inside { [2:4] }; }

  //----------------------------------------------------------------------------
  // Function: new
  //----------------------------------------------------------------------------

  function new( string name = "" );
    super.new( name );
  endfunction: new

  //----------------------------------------------------------------------------
  // Task: body
  //----------------------------------------------------------------------------

  task body();
    jelly_bean_transaction jb_tx;
    flavor_e               jb_flavor;

    jb_tx = jelly_bean_transaction::type_id::create( .name( "jb_tx" ) );
    assert( jb_tx.randomize() );
    jb_flavor = jb_tx.flavor;

    repeat ( num_jelly_beans ) begin
      jb_tx = jelly_bean_transaction::type_id::create( .name( "jb_tx" ) );
      start_item( jb_tx );
      assert( jb_tx.randomize() with { jb_tx.flavor == jb_flavor; } );
      finish_item( jb_tx );
    end
   endtask: body

  //----------------------------------------------------------------------------
  // Function: do_copy
  //----------------------------------------------------------------------------

  virtual function void do_copy( uvm_object rhs );
    same_flavored_jelly_bean_sequence that;

    if ( ! $cast( that, rhs ) ) begin
      `uvm_error( get_name(), "rhs is not a same_flavored_jelly_bean_sequence" )
      return;
    end

    super.do_copy( rhs );
    this.num_jelly_beans = that.num_jelly_beans;
  endfunction: do_copy
  
  //----------------------------------------------------------------------------
  // Function: do_compare
  //----------------------------------------------------------------------------

  virtual function bit do_compare( uvm_object rhs, uvm_comparer comparer );
    same_flavored_jelly_bean_sequence that;

    if ( ! $cast( that, rhs ) ) return 0;

    return ( super.do_compare( rhs, comparer )  &&
             this.num_jelly_beans == that.num_jelly_beans );
  endfunction: do_compare

  //----------------------------------------------------------------------------
  // Function: convert2string
  //----------------------------------------------------------------------------
  
  virtual function string convert2string();
    string s = super.convert2string();
    s = { s, $sformatf( "\nnum_jelly_beans: %0d", num_jelly_beans ) };
    return s;
  endfunction: convert2string

endclass: same_flavored_jelly_bean_sequence

//------------------------------------------------------------------------------
// Class: gift_boxed_jelly_bean_sequence
//   Sequence of sequences.
//------------------------------------------------------------------------------

class gift_boxed_jelly_bean_sequence extends uvm_sequence#( jelly_bean_transaction );
  `uvm_object_utils( gift_boxed_jelly_bean_sequence )
  
  rand int unsigned num_jelly_bean_flavors; // knob

  constraint num_jelly_bean_flavors_con { num_jelly_bean_flavors inside { [2:3] }; }
  
  //----------------------------------------------------------------------------
  // Function: new
  //----------------------------------------------------------------------------

  function new( string name = "" );
    super.new( name );
  endfunction: new
  
  //----------------------------------------------------------------------------
  // Task: body
  //----------------------------------------------------------------------------

  task body();
    same_flavored_jelly_bean_sequence jb_seq;
    
    repeat ( num_jelly_bean_flavors ) begin
      jb_seq = same_flavored_jelly_bean_sequence::type_id::create( .name( "jb_seq" ) );
      assert( jb_seq.randomize() );
      `uvm_info( get_name(), jb_seq.convert2string(), UVM_NONE )
      jb_seq.start( m_sequencer );
    end
  endtask: body
  
  //----------------------------------------------------------------------------
  // Function: do_copy
  //----------------------------------------------------------------------------

  virtual function void do_copy( uvm_object rhs );
    gift_boxed_jelly_bean_sequence that;

    if ( ! $cast( that, rhs ) ) begin
      `uvm_error( get_name(), "rhs is not a gift_boxed_jelly_bean_sequence" )
      return;
    end

    super.do_copy( rhs );
    this.num_jelly_bean_flavors = that.num_jelly_bean_flavors;
  endfunction: do_copy
  
  //----------------------------------------------------------------------------
  // Function: do_compare
  //----------------------------------------------------------------------------

  virtual function bit do_compare( uvm_object rhs, uvm_comparer comparer );
    gift_boxed_jelly_bean_sequence that;

    if ( ! $cast( that, rhs ) ) return 0;

    return ( super.do_compare( rhs, comparer )  &&
             this.num_jelly_bean_flavors == that.num_jelly_bean_flavors );
  endfunction: do_compare

  //----------------------------------------------------------------------------
  // Function: convert2string
  //----------------------------------------------------------------------------
  
  virtual function string convert2string();
    string s = super.convert2string();
    s = { s, $sformatf( "\nnum_jelly_bean_flavors: %0d", num_jelly_bean_flavors ) };
    return s;
  endfunction: convert2string

endclass: gift_boxed_jelly_bean_sequence

//==============================================================================
// Copyright (c) 2014, 2015 ClueLogic, LLC
// http://cluelogic.com/
//==============================================================================