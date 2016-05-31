//------------------------------------------------------------------------------
// Package: jelly_bean_pkg
//------------------------------------------------------------------------------

package jelly_bean_pkg;
import uvm_pkg::*;
typedef enum bit [2:0] { NO_FLAVOR, APPLE, BLUEBERRY, BUBBLE_GUM, CHOCOLATE } flavor_e;
typedef enum bit [1:0] { RED, GREEN, BLUE } color_e;
typedef enum bit [1:0] { UNKNOWN, YUMMY, YUCKY } taste_e;

`include "transactions.svh"
`include "sequences.svh"
`include "agent.svh"
`include "env.svh"
`include "test.svh"
endpackage: jelly_bean_pkg

//==============================================================================
// Copyright (c) 2015 ClueLogic, LLC
// http://cluelogic.com/
//==============================================================================