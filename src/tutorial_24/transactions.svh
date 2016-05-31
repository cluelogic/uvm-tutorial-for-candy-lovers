//------------------------------------------------------------------------------
// Class: jelly_bean_transaction
//------------------------------------------------------------------------------

class jelly_bean_transaction extends uvm_sequence_item;
  `uvm_object_utils( jelly_bean_transaction )
  
  rand flavor_e  flavor;
  rand color_e   color;
  rand bit       sugar_free;
  rand bit       sour;
  rand command_e command;
  taste_e        taste;
  
  constraint flavor_color_con {
    flavor != NO_FLAVOR;
    flavor == APPLE     -> color != BLUE;
    flavor == BLUEBERRY -> color == BLUE;
  }
  
  //----------------------------------------------------------------------------
  // Function: new
  //----------------------------------------------------------------------------

  function new( string name = "jelly_bean_transaction" );
    super.new( name );
  endfunction: new
  
  //----------------------------------------------------------------------------
  // Function: do_copy
  //----------------------------------------------------------------------------

  virtual function void do_copy( uvm_object rhs );
    jelly_bean_transaction that;

    if ( ! $cast( that, rhs ) ) begin
      `uvm_error( get_name(), "rhs is not a jelly_bean_transaction" )
      return;
    end

    super.do_copy( rhs );
    this.flavor     = that.flavor;
    this.color      = that.color;
    this.sugar_free = that.sugar_free;
    this.sour       = that.sour;
    this.command    = that.command;
    this.taste      = that.taste;
  endfunction: do_copy
  
  //----------------------------------------------------------------------------
  // Function: do_compare
  //----------------------------------------------------------------------------

  virtual function bit do_compare( uvm_object rhs, uvm_comparer comparer );
    jelly_bean_transaction that;

    if ( ! $cast( that, rhs ) ) return 0;

    return ( super.do_compare( rhs, comparer )  &&
             this.flavor     == that.flavor     &&
             this.color      == that.color      &&
             this.sugar_free == that.sugar_free &&
             this.sour       == that.sour       &&
             this.command    == that.command    &&
             this.taste      == that.taste );
  endfunction: do_compare

  //----------------------------------------------------------------------------
  // Function: convert2string
  //----------------------------------------------------------------------------
  
  virtual function string convert2string();
    string s = super.convert2string();
    s = { s, $sformatf( "\nname      : %s", get_name() ) };
    s = { s, $sformatf( "\nflavor    : %s", flavor.name() ) };
    s = { s, $sformatf( "\ncolor     : %s", color.name() ) };
    s = { s, $sformatf( "\nsugar_free: %b", sugar_free ) };
    s = { s, $sformatf( "\nsour      : %b", sour ) };
    s = { s, $sformatf( "\ncommand   : %s", command.name() ) };
    s = { s, $sformatf( "\ntaste     : %s", taste.name() ) };
    return s;
  endfunction: convert2string
         
endclass: jelly_bean_transaction

//------------------------------------------------------------------------------
// Class: sugar_free_jelly_bean_transaction
//------------------------------------------------------------------------------

class sugar_free_jelly_bean_transaction extends jelly_bean_transaction;
  `uvm_object_utils( sugar_free_jelly_bean_transaction )

  constraint sugar_free_con {
    sugar_free == 1;
  }

  //----------------------------------------------------------------------------
  // Function: new
  //----------------------------------------------------------------------------

  function new( string name = "sugar_free_jelly_bean_transaction" );
    super.new( name );
  endfunction: new
  
endclass: sugar_free_jelly_bean_transaction

//==============================================================================
// Copyright (c) 2014 ClueLogic, LLC
// http://cluelogic.com/
//==============================================================================