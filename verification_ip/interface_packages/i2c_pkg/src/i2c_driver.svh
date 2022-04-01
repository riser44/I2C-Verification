class i2c_driver extends ncsu_component#(.T(i2c_transaction));

virtual i2c_if#(.i2c_ADDR_WIDTH(7), .i2c_DATA_WIDTH(8)) bus;
event done;


  function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
  endfunction

  i2c_configuration configuration;
  T i2c_trans;

  function void set_configuration(i2c_configuration cfg);
    configuration = cfg;
  endfunction

  virtual task bl_put(T trans);
    i2c_trans = trans;
    wait(done);
  endtask

virtual task run();
forever
begin
  
  bus.wait_for_i2c_transfer(i2c_trans.i2c_operation,i2c_trans.i2c_data ); 
	if(i2c_trans.i2c_operation==rd)
	begin
    
    ->done;
  	bus.provide_read_data(i2c_trans.read_data,i2c_trans.trans_comp);
    
	end

end
endtask


endclass


