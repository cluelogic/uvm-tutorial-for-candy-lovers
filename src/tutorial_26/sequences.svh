//------------------------------------------------------------------------------
// Class: jelly_bean_order_sequence
//------------------------------------------------------------------------------

class jelly_bean_order_sequence extends uvm_sequence#( jelly_bean_transaction );
  `uvm_object_utils( jelly_bean_order_sequence )

  rand int unsigned num_jelly_beans; // knob
  rand flavor_e     jb_flavor;

  //----------------------------------------------------------------------------
  // Function: new
  //----------------------------------------------------------------------------

  function new( string name = "jelly_bean_order_sequence" );
    super.new( name );
  endfunction: new

  //----------------------------------------------------------------------------
  // Task: body
  //----------------------------------------------------------------------------
   
  task body();
    jelly_bean_transaction jb_tx;

    repeat ( num_jelly_beans ) begin
      jb_tx = jelly_bean_transaction::type_id::create( .name( get_name() ) );
      start_item( jb_tx );
      assert( jb_tx.randomize() with { jb_tx.flavor == jb_flavor; } );
      finish_item( jb_tx );
    end
  endtask: body
   
  //----------------------------------------------------------------------------
  // Function: do_copy
  //----------------------------------------------------------------------------

  virtual function void do_copy( uvm_object rhs );
    jelly_bean_order_sequence that;

    if ( ! $cast( that, rhs ) ) begin
	  `uvm_error( get_name(), "rhs is not a jelly_bean_order_sequence" )
	  return;
    end

    super.do_copy( rhs );
    this.num_jelly_beans = that.num_jelly_beans;
    this.jb_flavor       = that.jb_flavor;
  endfunction: do_copy
   
  //----------------------------------------------------------------------------
  // Function: do_compare
  //----------------------------------------------------------------------------

  virtual function bit do_compare( uvm_object rhs, uvm_comparer comparer );
    jelly_bean_order_sequence that;

    if ( ! $cast( that, rhs ) ) return 0;

    return ( super.do_compare( rhs, comparer )            &&
             this.num_jelly_beans == that.num_jelly_beans &&
	      	 this.jb_flavor       == that.jb_flavor );
  endfunction: do_compare

  //----------------------------------------------------------------------------
  // Function: convert2string
  //----------------------------------------------------------------------------
   
  virtual function string convert2string();
    string s = super.convert2string();
    s = { s, $sformatf( "num_jelly_beans=%0d jb_flavor=%s", 
                        num_jelly_beans, jb_flavor.name() ) };
    return s;
  endfunction: convert2string

endclass: jelly_bean_order_sequence

//==============================================================================
// Copyright (c) 2015 ClueLogic, LLC
// http://cluelogic.com/
//==============================================================================