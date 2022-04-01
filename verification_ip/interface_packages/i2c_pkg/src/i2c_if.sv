`timescale 1ns / 10ps
//import i2c_pkg ::*;
import i2c_enum::*;
interface i2c_if       #(
      int I2C_ADDR_WIDTH = 7,                                
      int I2C_DATA_WIDTH = 8                                
      )
(
  input tri scl,
  inout triand sda
  );
  

logic ms_cntl;
logic sda_out;

assign sda = ms_cntl ? 1'bz : sda_out;

bit start,stop;


initial 
begin
ms_cntl = 1;
sda_out=0;
end


always @(negedge sda)
begin

		if(scl==1)
			begin
			start=1;
			//$display("Start Condition hit");
			end
		else
			start=0;
end


always @(posedge sda)
begin
		if(scl==1)
			begin
			stop=1;
			//$display("Stop Condition hit");
			end
					
		else
			stop=0;
end


		
//********************************************* Write Task Implementation*************************************************************

task wait_for_i2c_transfer ( output i2c_op_t op, output bit [I2C_DATA_WIDTH-1:0] write_data []);

bit[6:0] address;
int i,j;
i=0;
j=0;
write_data = new[32];

wait(start==1);
repeat(7)
	@(posedge scl)
		address={address,sda};
	
@(posedge scl)
	begin
	if(sda==0)
	begin
		op=wr;
	end
		
	else 
	begin
		op=rd;
		//$display("I2C_BUS READ Transfer:");
	end
	end


if(op == wr)
begin		
@(negedge scl)
	begin
	ms_cntl=0;
	sda_out=0;
	end
@(negedge scl)
	ms_cntl=1;	
end

if(op == rd)
begin
@(negedge scl) 
	begin
	ms_cntl=0;
	sda_out=0;
	end
	return;
end

	
fork
begin
while((start==0)&&(stop==0)) 
begin
j=0;
repeat(8)
	begin
	@(posedge scl)
	write_data[i][7-j]=sda;
	j+=1;
	end
	i++;

@(negedge scl)
	begin
	ms_cntl=0; 
	sda_out=0;
	end
@(negedge scl) 
	ms_cntl=1;
end	
end

begin
wait(start==1||stop==1);
end

join_any
disable fork;
endtask

//*****************************************READ TASK IMPLEMENTATION********************************************************************

task provide_read_data ( input bit [I2C_DATA_WIDTH-1:0] read_data[], output bit transfer_complete);
bit [7:0] intermediate_var,temp_var;
int i;
i=0;
transfer_complete=0;
 

fork
begin
	while(i<read_data.size())
	begin
	ms_cntl=0;
	temp_var=0;
	intermediate_var=read_data[i];
	i+=1;
	for(int j=7;j>=0;j--)
	begin
		@(negedge scl)
			sda_out=intermediate_var[j];
			temp_var={temp_var,sda_out};		
	end
	@(negedge scl)
		ms_cntl=1;
	@(posedge scl)
		begin
		if(sda==1)
			break;
		end
	end
end

begin
wait(start==1||stop==1);
end

join_any
disable fork;
	transfer_complete=1;
endtask


//***********************************************MONITOR IMPLEMENTATIONN*************************************************************

task monitor ( output bit [I2C_ADDR_WIDTH-1:0] addr, output i2c_op_t op, output bit [I2C_DATA_WIDTH-1:0] data[]);
 
bit[7:0] int_var;
bit[7:0] queue[$]; 
wait(start==1);

repeat(7)
begin
	@(posedge scl)
		addr={addr,sda};
end

@(posedge scl);
	if(sda==0)
		op=wr;
	else 
		op=rd;
@(posedge scl);

fork
begin
while(1)
begin
	for(int i=7;i>=0;i--)
	begin
		@(posedge scl)
			int_var[i]=sda;
	end
	queue.push_back(int_var);
	@(posedge scl);
end
end

begin
wait((start==1)||(stop==1));
end

join_any
disable fork;

data=queue;
queue.delete();
endtask
endinterface

