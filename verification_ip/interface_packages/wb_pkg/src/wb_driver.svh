

class wb_driver extends ncsu_component#(.T(wb_transaction)); 

virtual wb_if bus;

  function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
  endfunction

  wb_configuration configuration;
  wb_transaction wb_trans;

  function void set_configuration(wb_configuration cfg);
    configuration = cfg;
  endfunction

  virtual task bl_put(T trans);
  // $display(" In wb_driver addr= %x data= %x op =%b",trans.wb_addr,trans.wb_data, trans.wb_operation);
  bus.wait_for_reset();
  // $display("1");
	if(trans.IRQ == 1'b1)     
          begin
                bus.wait_for_interrupt();    
    	    end

  else
  begin
       if (trans.wb_operation == 1'b1) 
   		    begin
                bus.master_write(trans.wb_addr,trans.wb_data);  
          end
      else
				begin
					bus.master_read(trans.wb_addr,trans.wb_data);  
        end
  end

  // if(trans.wb_operation ==1)
  // begin
  //   bus.master_write(trans.wb_addr, trans.wb_data);
  //   if(trans.wb_addr == 2'b10) begin
  //        begin
  //       //wait for Interrupt 
  //       bus.wait_for_interrupt();
  //       //Clear the Interruput
  //       bus.master_read(2'b10, trans.wb_data);
  //     end
  //   end
  //   else
  //     bus.master_read(trans.wb_addr, trans.wb_data);
  //   end

   endtask

endclass


