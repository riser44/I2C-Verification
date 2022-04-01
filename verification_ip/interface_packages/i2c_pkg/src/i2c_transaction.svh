class i2c_transaction extends ncsu_transaction;
  `ncsu_register_object(i2c_transaction)


bit [7:0] i2c_address;  
bit [7:0] i2c_data[];   
bit [7:0] read_data[];
i2c_op_t i2c_operation; 
bit trans_comp; 

  function new(string name="");  
    super.new(name);
  endfunction

  virtual function string convert2string();
     return {super.convert2string(),$sformatf("address:0x%x data:0x%x operation:%p ", this.i2c_address, this.i2c_data, this.i2c_operation)};
  endfunction

  function bit compare(i2c_transaction rhs); 
    // $display("Line 20 i2c transaction address:0x%x data:0x%x operation:0x%p ", this.i2c_address, this.i2c_data, this.i2c_operation);
    // $display("Line 20 wIshbone transaction address:0x%x data:0x%x operation:0x%p ", rhs.i2c_address, rhs.i2c_data, rhs.i2c_operation);
    return ((this.i2c_address  == rhs.i2c_address ) && 
            (this.i2c_data == rhs.i2c_data) &&
            (this.i2c_operation == rhs.i2c_operation) );
    //return 1;
  endfunction

endclass


