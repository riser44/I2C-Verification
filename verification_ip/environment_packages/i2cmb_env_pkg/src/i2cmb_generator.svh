class i2cmb_generator extends ncsu_component#(.T(ncsu_transaction));

  wb_transaction wb_trans;
  i2c_transaction i2c_trans_a, i2c_trans_b , i2c_trans_c, i2c_trans, i2c_trans_pred;


  ncsu_component #(wb_transaction) wbagent; 
  ncsu_component #(i2c_transaction) i2cagent; 
  
string wb_trans_name = "wb_transaction";
string i2c_trans_name = "i2c_transaction";


int WB_ADDR_WIDTH = 2;
int WB_DATA_WIDTH = 8;
int i2C_ADDR_WIDTH = 7;
int i2C_DATA_WIDTH = 8;
int trans_type;
bit [7:0] data_send_a[32];	 
bit [7:0] data_send_b[32];
bit [7:0] data_send_c[32];
bit [7:0] data;




  function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
	i2c_trans = new("i2c_trans");
	i2c_trans_pred = new ("i2c_trans_pred");
    // if ( !$value$plusargs("GEN_TRANS_TYPE=%s", wb_trans_name)) begin
    //   $display("FATAL: +GEN_TRANS_TYPE plusarg not found on command line");
    //   $fatal;
    // end
    // $display("%m found +GEN_TRANS_TYPE=%s", wb_trans_name);
  endfunction



task wb (bit [1:0] wb_addr,bit [7:0] wb_data, bit wb_operation, bit IRQ);
	
	wb_trans.wb_addr = wb_addr; 
	wb_trans.wb_data= wb_data; 
	wb_trans.wb_operation=wb_operation; 
	wb_trans.IRQ=IRQ;
	wbagent.bl_put(wb_trans);

  endtask


task write_operation(int offset);
		begin
			wb(2'b01,(offset),1,0); //DPR DATA = 0x78
			wb(2'b10,8'b00000001,1,0);   //Send Write Command      
			wb(2'b00,8'bxxxxxx00,0,1);   // IRQ     
			wb(2'b10,8'bxxxxxxxx,0,0);        

		end
  endtask 
  
  
 task read_operation();
	for(int y=0; y<31; y++)
			begin
				wb(2'b10,8'b00000010,1,0);//ACK
				wb(2'b00,8'b00000000,0,1);        
            	wb(2'b10,8'bxxxxxxxx,0,0);        				
				//wb(2'b01,8'bxxxxxxxx,0,0);//Drive DPR
			end
		wb(2'b10,8'b00000011,1,0);//NACK
		wb(2'b00,8'b00000000,0,1);         
		wb(2'b10,8'bxxxxxxxx,0,0);        
		//wb(2'b01,8'bxxxxxxxx,0,0);//Drive DPR
	
 endtask




 virtual task run();
	
	fork 
		wb_flow();
		i2c_flow();
	join

endtask

task wb_flow;
	begin
		$display("*********************************************[TASK-1]  Test Flow for writing 0 to 31 values************************************************************");
		wb_trans_name = "wb_transaction";	
		$cast(wb_trans,ncsu_object_factory::create(wb_trans_name));
		trans_type =1;
		//Test flow for writing from 0 to 31
		wb(2'b00,8'b11xxxxxx,1,0);  //Enable Core 
		wb(2'b01,8'bxxxxx101,1,0);  // Bus ID
		wb(2'b10,8'bxxxxx110,1,0);  //Set bus
		wb(2'b00,8'bxxxxxx00,0,1);  //IRQ	        
		wb(2'b10,8'bxxxxxxxx,0,0);
		for(int i=0;i<32;i++) 
		begin
		wb(2'b10,8'bxxxxx100,1,0); // Start
		wb(2'b00,8'bxxxxxx00,0,1);
		wb(2'b10,8'bxxxxxxxx,0,0);
		wb(2'b01,8'h88,1,0);    //Address
		wb(2'b10,8'b00000001,1,0);  // Drive to DPR 
		wb(2'b00,8'bxxxxxx00,0,1);         
		wb(2'b10,8'bxxxxxxxx,0,0);
		write_operation(i);
		end
		wb(2'b10,8'b00000101,1,0);  //Stop
		wb(2'b00,8'bxxxxxx00,0,1);         
		wb(2'b10,8'bxxxxxxxx,0,0);        
		////////////////
		//Flow for reading from 100 to 131
		$display("*********************************************[TASK-2]  Test flow for reading 100 to 131 values ************************************************************");	
		wb(2'b00,8'b11xxxxxx,1,0);//Enable Core
		wb(2'b01,8'bxxxxx101,1,0);//I2C Bus ID
		wb(2'b10,8'bxxxxx110,1,0);//Set bus
		wb(2'b00,8'bxxxxxx00,0,1);         
		wb(2'b10,8'bxxxxxxxx,0,0); 
		repeat(32)
		begin
		wb(2'b10,8'bxxxxx100,1,0);//Start
		wb(2'b00,8'bxxxxxx00,0,1);
		wb(2'b10,8'bxxxxxxxx,0,0);
		wb(2'b01,8'h89,1,0);//Address
		wb(2'b10,8'b00000001,1,0);//drive to dpr 
		wb(2'b00,8'bxxxxxx00,0,1);         
		wb(2'b10,8'bxxxxxxxx,0,0);
		//read_operation();//Read with ACK/NACK
		wb(2'b10,8'b00000011,1,0);//NACK
		wb(2'b00,8'b00000000,0,1);        
    	wb(2'b10,8'bxxxxxxxx,0,0);
		wb(2'b01,data,0,0);
		end	
		wb(2'b10,8'b00000101,1,0);//Stop
		wb(2'b00,8'bxxxxxx00,0,1);         
		wb(2'b10,8'bxxxxxxxx,0,0);        
		
		
		$display("*********************************************[TASK-3]  Test Flow for alternate read and write ************************************************************");	
		trans_type = 2;
		//Write Incrementing values 64 - 95
		wb(2'b0,8'b11xxxxxx,1,0);//Enable Core
		wb(2'b01,8'bxxxxxx01,1,0);//I2C Bus ID
		wb(2'b10,8'bxxxxx110,1,0);//Set bus
		wb(2'b00,8'bxxxxxx00,0,1);         
		wb(2'b10,8'bxxxxxxxx,0,0); 
		for(int i=0;i<64;i++)
		begin
		wb(2'b10,8'bxxxxx100,1,0);//Start
		wb(2'b00,8'bxxxxxx00,0,1);
		wb(2'b10,8'bxxxxxxxx,0,0);
		wb(2'b01,8'h88,1,0);      // Address
		wb(2'b10,8'b00000001,1,0); //Drive to DPR 
		wb(2'b00,8'bxxxxxx00,0,1);         
		wb(2'b10,8'bxxxxxxxx,0,0);	
		wb(2'b01,i+64,1,0);
		wb(2'b10,8'b00000001,1,0);    //Stop     
		wb(2'b00,8'bxxxxxx00,0,1);         
		wb(2'b10,8'bxxxxxxxx,0,0);
		
		//Read Decrementing values 63 - 32 
		//wb(2'b0,8'b11xxxxxx,1,0);//Enable Core
		//wb(2'b01,8'bxxxxxx01,1,0);//I2C Bus ID
		//wb(2'b10,8'bxxxxx110,1,0);//Set bus
		//wb(2'b00,8'bxxxxxx00,0,1);         
		//wb(2'b10,8'bxxxxxxxx,0,0); 
		
		wb(2'b10,8'bxxxxx100,1,0); //Start
		wb(2'b00,8'bxxxxxx00,0,1);
		wb(2'b10,8'bxxxxxxxx,0,0);
		wb(2'b01,8'h89,1,0);       // Address
		wb(2'b10,8'b00000001,1,0);  
		wb(2'b00,8'bxxxxxx00,0,1);         
		wb(2'b10,8'bxxxxxxxx,0,0);
		wb(2'b10,8'b00000011,1,0);//NACK
		wb(2'b00,8'b00000000,0,1);        
    	wb(2'b10,8'bxxxxxxxx,0,0);
		wb(2'b01,data,0,0);
		end	
		wb(2'b10,8'b00000101,1,0);//Stop
		wb(2'b00,8'bxxxxxx00,0,1);         
		wb(2'b10,8'bxxxxxxxx,0,0); 		
		$display("Test flow ends");
		
	end

endtask


task i2c_flow;
	begin
		i2c_trans_name = "i2c_transaction";

		$cast(i2c_trans_a,ncsu_object_factory::create(i2c_trans_name));
		$cast(i2c_trans_b,ncsu_object_factory::create(i2c_trans_name));
		$cast(i2c_trans_c,ncsu_object_factory::create(i2c_trans_name));		
			i2c_trans_a.i2c_data = new[1];
			for(int i=0;i<32;i++)
			begin
			data_send_a[0] = 100+i;
			i2c_trans_a.read_data = data_send_a;	
			i2cagent.bl_put(i2c_trans_a);
			end
			i2c_trans_b.i2c_data = new[1];
			for(int i=63;i>=0;i--)
			begin
			data_send_b[0] = i;
			i2c_trans_b.read_data = data_send_b;	
			i2cagent.bl_put(i2c_trans_b);
			end				
	end
endtask
	
 
 function void set_agentwb(ncsu_component #(wb_transaction) agent);
    this.wbagent = agent;
 endfunction
  
 function void set_agenti2c(ncsu_component #(i2c_transaction) agent);
    this.i2cagent = agent;
 endfunction
  
endclass


