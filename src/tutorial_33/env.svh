//------------------------------------------------------------------------------
// Class: json_printer
//------------------------------------------------------------------------------

class json_printer extends uvm_printer;

  //----------------------------------------------------------------------------
  // Function: new
  //----------------------------------------------------------------------------

  function new();
     super.new();
  endfunction: new

  //----------------------------------------------------------------------------
  // Function: emit
  //----------------------------------------------------------------------------

   virtual function string emit();
      string s;
      string comma = "";
      string space = { 100 { " " } };
      string indent;
      int    next_level;

      s = "{\n"; // begin JSON

      foreach ( m_rows[i] ) begin
         uvm_printer_row_info row = m_rows[i];

         indent = space.substr( 1, ( row.level + 1 ) * knobs.indent );
         s = { s, comma, indent };

         if ( i == m_rows.size() - 1 ) begin // last row
            next_level = 0;
         end else begin // not last row
            next_level = m_rows[ i + 1 ].level;
            if ( row.level < next_level ) begin // next level is deepr
               s = { s, "\"", row.name, "\": {\n" }; // begin nested JSON object
               comma = "";
               continue;
            end
         end
         s = { s, "\"", row.name, "\": \"", row.val, "\"" }; // name-value pair
         comma = ",\n";

         if ( next_level < row.level ) begin // next level is shallower
            for ( int l = row.level; l > next_level; l-- ) begin
               indent = space.substr( 1, l * knobs.indent );
               s = { s, "\n", indent, "}" }; // end nested JSON object
            end
         end
      end // foreach ( m_rows[i] )

      emit = { s, "\n}" }; // end JSON
      m_rows.delete();
   endfunction: emit
endclass: json_printer

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

  json_printer json_p;
  
  //----------------------------------------------------------------------------
  // Function: new
  //----------------------------------------------------------------------------

  function new( string name, uvm_component parent );
    super.new( name, parent );
  endfunction: new
  
  //----------------------------------------------------------------------------
  // Function: build_phase
  //----------------------------------------------------------------------------
  
  virtual function void build_phase( uvm_phase phase );
    super.build_phase( phase );
    json_p = new;
  endfunction: build_phase

  //----------------------------------------------------------------------------
  // Function: write
  //----------------------------------------------------------------------------

  function void write( jelly_bean_transaction t );
    `uvm_info( get_name(), { "using convert2string", 
                            t.convert2string() }, UVM_LOW )
    `uvm_info( get_name(), { "using uvm_default_printer\n", 
                            t.sprint() }, UVM_LOW )
    `uvm_info( get_name(), { "using uvm_default_table_printer\n", 
                            t.sprint( uvm_default_table_printer ) }, UVM_LOW )
    `uvm_info( get_name(), { "using uvm_default_tree_printer\n", 
                            t.sprint( uvm_default_tree_printer ) }, UVM_LOW )
    `uvm_info( get_name(), { "using uvm_default_line_printer\n", 
                            t.sprint( uvm_default_line_printer ) }, UVM_LOW )
    `uvm_info( get_name(), { "using json_printer\n", 
                            t.sprint( json_p ) }, UVM_LOW )
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
// Copyright (c) 2016 ClueLogic, LLC
// http://cluelogic.com/
//==============================================================================