//------------------------------------------------------------------------------
// Package: jelly_bean_pkg
//------------------------------------------------------------------------------

package jelly_bean_pkg;
import uvm_pkg::*;
typedef enum bit [2:0] { NO_FLAVOR, APPLE, BLUEBERRY, BUBBLE_GUM, CHOCOLATE } flavor_e;
typedef enum bit [1:0] { NO_COLOR, RED, GREEN, BLUE } color_e;
typedef enum bit [1:0] { UNKNOWN, YUMMY, YUCKY } taste_e;
typedef enum bit [1:0] { NO_OP, JB_READ, JB_WRITE } command_e;

`include "transactions.svh"
`include "ral.svh"
`include "sequences.svh"
`include "agent.svh"
`include "env.svh"
`include "tests.svh"
endpackage: jelly_bean_pkg

//==============================================================================
// Copyright (c) 2014 ClueLogic, LLC
// http://cluelogic.com/
//==============================================================================