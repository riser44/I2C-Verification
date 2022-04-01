//i2c_pkg.sv

package i2c_pkg;
//typedef enum bit {wr,rd}i2c_op_t ; 


  import ncsu_pkg::*;
  import i2c_enum::*;
  `include "ncsu_macros.svh"
  // `include "src/i2c_pkg.svh"
  `include "src/i2c_transaction.svh"
  `include "src/i2c_configuration.svh"
  
  `include "src/i2c_driver.svh"
  `include "src/i2c_monitor.svh"
  `include "src/i2c_agent.svh"

endpackage
