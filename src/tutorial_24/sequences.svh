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

//------------------------------------------------------------------------------
// Class: jelly_bean_reg_sequence
//------------------------------------------------------------------------------

class jelly_bean_reg_sequence extends uvm_reg_sequence;
  `uvm_object_utils( jelly_bean_reg_sequence )
  
  //----------------------------------------------------------------------------
  // Function: new
  //----------------------------------------------------------------------------

  function new( string name = "" );
    super.new( name );
  endfunction: new
  
  //----------------------------------------------------------------------------
  // Task: body
  //----------------------------------------------------------------------------

  virtual task body();
    jelly_bean_reg_block jb_reg_block;
    flavor_e             flavor;
    color_e              color;
    bit                  sugar_free;
    bit                  sour;
    uvm_status_e         status;
    uvm_reg_data_t       value;

    $cast( jb_reg_block, model );
    flavor     = APPLE;

     if ( m_sequencer.get_report_verbosity_level() >= UVM_DEBUG ) begin // for debug
         string paths[$];
         uvm_hdl_path_concat pathc[$];
         
         $display( "--------------------" );
         paths.delete();
         jb_reg_block.get_hdl_path( paths );
         foreach ( paths[i] ) 
           $display( "jb_reg_block.get_hdl_path[%0d] is '%s'", i, paths[i] );
         paths.delete();
         jb_reg_block.get_full_hdl_path( paths );
         foreach ( paths[i] ) 
           $display( "jb_reg_block.get_full_hdl_path[%0d] is '%s'", i, paths[i] );

            $display( "--------------------" );
            pathc.delete();
            jb_reg_block.jb_recipe_reg.get_hdl_path( pathc );
            foreach ( pathc[i] ) 
              foreach ( pathc[i].slices[j] ) 
                $display( "jb_reg_block.jb_recipe_reg.get_hdl_path[%0d].slices[%0d].path is '%s'", 
                          i, j, pathc[i].slices[j].path );

            pathc.delete();
            jb_reg_block.jb_recipe_reg.get_full_hdl_path( pathc );
            foreach ( pathc[i] ) 
              foreach ( pathc[i].slices[j] ) 
                $display( "jb_reg_block.jb_recipe_reg.get_hdl_full_path[%0d].slices[%0d].path is '%s'", 
                          i, j, pathc[i].slices[j].path );
      end

    color      = GREEN;
    sugar_free = 0;
    sour       = 1;
      
    // front-door write
    write_reg( jb_reg_block.jb_recipe_reg, status, { sour, sugar_free, color, flavor } ); 
    
    // front-door read
    read_reg( jb_reg_block.jb_taste_reg, status, value );
    #20ns ;
    
    // back-door writes
    flavor = BLUEBERRY;
    poke_reg( jb_reg_block.jb_recipe_reg, status, { sour, sugar_free, color, flavor } ); 
    #10ns ;
    
    flavor = BUBBLE_GUM;
    write_reg( jb_reg_block.jb_recipe_reg, status, { sour, sugar_free, color, flavor },
               UVM_BACKDOOR ); 
    #10ns ;
    
    flavor = CHOCOLATE;
    jb_reg_block.jb_recipe_reg.write( status, { sour, sugar_free, color, flavor },
                                      UVM_BACKDOOR, .parent( this ) );
    #10ns ;
    
    // back-door reads
    peek_reg( jb_reg_block.jb_taste_reg, status, value );
    assert( value == YUMMY );
    
    read_reg( jb_reg_block.jb_taste_reg, status, value, UVM_BACKDOOR );
    assert( value == YUMMY );
    
    jb_reg_block.jb_taste_reg.read( status, value, UVM_BACKDOOR, .parent( this ) );
    assert( value == YUMMY );
    #10ns ;
  endtask: body
     
endclass: jelly_bean_reg_sequence

//==============================================================================
// Copyright (c) 2014 ClueLogic, LLC
// http://cluelogic.com/
//==============================================================================