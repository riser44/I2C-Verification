`timescale 1ns / 10ps
import i2c_pkg ::*;


module top();
parameter int i2c_ADDR_WIDTH = 7;
parameter int WB_ADDR_WIDTH = 2;
parameter int i2c_DATA_WIDTH = 8;
parameter int WB_DATA_WIDTH = 8;
parameter int NUM_I2C_BUSSES = 1;

bit  clk;
bit  rst = 1'b1;
wire cyc;
wire stb;
wire we;
tri1 ack;
wire [WB_ADDR_WIDTH-1:0] adr;
wire [WB_DATA_WIDTH-1:0] dat_wr_o;
wire [WB_DATA_WIDTH-1:0] dat_rd_i;
wire irq;
tri  [NUM_I2C_BUSSES-1:0] scl;
tri  [NUM_I2C_BUSSES-1:0] sda;
bit [WB_ADDR_WIDTH-1:0] data_out[];
int i;
bit [7:0]i2c_read_data[];
i2c_op_t op_top;
int temp1=0;
// ****************************************************************************
// Clock generator

initial
begin : clk_gen
  forever
    #5 clk=~clk;
end

// ****************************************************************************
// Reset generator

initial
begin : rst_gen
#113 rst=1'b0;
end

// ****************************************************************************
// Monitor Wishbone bus and display transfers in the transcript

initial 
begin: wb_monitoring
 bit [WB_DATA_WIDTH-1:0] datwr;
 bit [WB_ADDR_WIDTH-1:0] addrwr;
 bit wen;
  wb_bus.master_monitor(.addr(addrwr),.data(datwr),.we(wen));
  //$display("addr=%0xh, data=%0xh, Write enable = %d",adr,dat_wr_o,we);
end



// ****************************************************************************
// Define the flow of the simulation
initial begin :test_flow

reg [WB_DATA_WIDTH-1:0]cmdr_data;
bit[7:0] receiving_data;

int write_i;
write_i=64;


//WRITE execution

wb_bus.master_write(2'h00,8'b11xxxxxx);
wb_bus.master_write(2'h01,8'b00000101);
wb_bus.master_write(2'h02,8'bxxxxx110);
while(!(wb_bus.dat_o[7]) || (!(irq)))
begin
@(posedge clk);
end
wb_bus.master_read(2'h02,cmdr_data);
wb_bus.master_write(2'h02,8'bxxxxx100);
while(!(wb_bus.dat_o[7]) || (!(irq)))
begin
@(posedge clk);
end
wb_bus.master_read(2'h02,cmdr_data);
wb_bus.master_write(2'h01,8'h44);
wb_bus.master_write(2'h02,8'bxxxxx001);
while(!(wb_bus.dat_o[7])|| (!(irq)))
begin
@(posedge clk);
end
wb_bus.master_read(2'h02,cmdr_data);
while(!(wb_bus.dat_o[6]))
begin
@(posedge clk);
end
for(int i=0; i<32; i++) begin
wb_bus.master_write(2'h01,i);
wb_bus.master_write(2'h02,8'bxxxxx001);
while(!(wb_bus.dat_o[7]) || (!(irq)))
begin
@(posedge clk);
end
wb_bus.master_read(2'h02,cmdr_data);
end
wb_bus.master_write(2'h02,8'bxxxxx101);
while(!(wb_bus.dat_o[7]) || (!(irq)))
begin 
@(posedge clk);
end
wb_bus.master_read(2'h02,cmdr_data);



//READ

wb_bus.master_write(2'h00,8'b11xxxxxx);
wb_bus.master_write(2'h01,8'b00000101);
wb_bus.master_write(2'h02,8'bxxxxx110);
while(!(wb_bus.dat_o[7]) || (!(irq)))
begin
@(posedge clk);
end
wb_bus.master_read(2'h02,cmdr_data);
wb_bus.master_write(2'h02,8'bxxxxx100);
while(!(wb_bus.dat_o[7]) || (!(irq)))
begin
@(posedge clk);
end
wb_bus.master_read(2'h02,cmdr_data);
wb_bus.master_write(2'h01,8'h45);
wb_bus.master_write(2'h02,8'bxxxxx001);
while(!(wb_bus.dat_o[7])|| (!(irq)))
begin
@(posedge clk);
end
wb_bus.master_read(2'h02,cmdr_data);
for(i=0;i<31;i++)
begin
wb_bus.master_write(2'h02,8'bxxxxx010);
while(!(wb_bus.dat_o[7])|| (!(irq)))
begin
@(posedge clk);
end
wb_bus.master_read(2'h02,cmdr_data);
wb_bus.master_read(2'h01,receiving_data);
$display("Read Data is : %d",receiving_data);
end
wb_bus.master_write(2'h02,8'bxxxxx011);
while(!(wb_bus.dat_o[7])|| (!(irq)))
begin
@(posedge clk);
end
wb_bus.master_read(2'h02,cmdr_data);
wb_bus.master_read(2'h01,receiving_data);
$display("Read Data is : %d",receiving_data);
wb_bus.master_write(2'h02,8'bxxxxx101);
while(!(wb_bus.dat_o[7]) || (!(irq)))
begin 
@(posedge clk);
end
wb_bus.master_read(2'h02,cmdr_data);




//Alternate Read and Write

temp1=1;
wb_bus.master_write(2'h00,8'b11xxxxxx);
wb_bus.master_write(2'h01,8'b00000101);
wb_bus.master_write(2'h02,8'bxxxxx110);
while(!(wb_bus.dat_o[7]) || (!(irq)))
begin
@(posedge clk);
end
wb_bus.master_read(2'h02,cmdr_data);
for(i=0;i<64;i++)
begin
wb_bus.master_write(2'h02,8'bxxxxx100);
while(!(wb_bus.dat_o[7]) || (!(irq)))
begin
@(posedge clk);
end
wb_bus.master_read(2'h02,cmdr_data);

wb_bus.master_write(2'h01,8'h44);
wb_bus.master_write(2'h02,8'bxxxxx001);
while(!(wb_bus.dat_o[7])|| (!(irq)))
begin
@(posedge clk);
end
wb_bus.master_read(2'h02,cmdr_data);

wb_bus.master_write(2'h01,write_i);
wb_bus.master_write(2'h02,8'bxxxxx001);

while(!(wb_bus.dat_o[7]) || (!(irq)))
begin
@(posedge clk);
end
wb_bus.master_read(2'h02,cmdr_data);
write_i+=1;
wb_bus.master_write(2'h02,8'bxxxxx100);
while(!(wb_bus.dat_o[7]) || (!(irq)))
begin
@(posedge clk);
end
wb_bus.master_read(2'h02,cmdr_data);
wb_bus.master_write(2'h01,8'h45);
wb_bus.master_write(2'h02,8'bxxxxx001);
while(!(wb_bus.dat_o[7])|| (!(irq)))
begin
@(posedge clk);
end
wb_bus.master_read(2'h02,cmdr_data);
wb_bus.master_write(2'h02,8'bxxxxx011);
while(!(wb_bus.dat_o[7])|| (!(irq)))
begin
@(posedge clk);
end
wb_bus.master_read(2'h02,cmdr_data);
wb_bus.master_read(2'h01,receiving_data);
$display("Read data is : %d",receiving_data);
end

wb_bus.master_write(2'h02,8'bxxxxx101);
while(!(wb_bus.dat_o[7]) || (!(irq)))
begin 
@(posedge clk);
end
wb_bus.master_read(2'h02,cmdr_data);
$finish;
end

bit[7:0] wb_i2c_data [];
bit read_trans_comp;
reg [WB_DATA_WIDTH-1:0]cmdr_data;

initial
begin

bit [7:0] i2c_data[];
int j;
j=63;
i2c_data = new[1];


forever
begin
if(temp1==0)
begin
	i2c_bus.wait_for_i2c_transfer(op_top,wb_i2c_data);
	if(op_top==rd)
		begin
			for(int i=100;i<132;i++)
			begin
			i2c_data[0]=i;
			i2c_bus.provide_read_data( i2c_data,read_trans_comp);
			end
		end
end

else if(temp1==1)
begin

		i2c_bus.wait_for_i2c_transfer(op_top,wb_i2c_data);
		if(op_top==rd)
			begin
				i2c_data[0]=j--;
				i2c_bus.provide_read_data( i2c_data,read_trans_comp);
			end

end
end

end

initial
begin
bit [i2c_ADDR_WIDTH-1:0] addr_mon;
i2c_op_t op_mon;
bit [i2c_DATA_WIDTH-1:0] data_mon[];
	forever
	begin
	i2c_bus.monitor(addr_mon,op_mon,data_mon);
	end
end
	


// ****************************************************************************
// Instantiate the i2C  Bus Functional Model
i2c_if       #(
      .I2C_ADDR_WIDTH(i2c_ADDR_WIDTH),
      .I2C_DATA_WIDTH(i2c_DATA_WIDTH)
      )
i2c_bus (.sda(sda),
	.scl(scl));

// ****************************************************************************
// Instantiate the Wishbone master Bus Functional Model
wb_if       #(
      .ADDR_WIDTH(WB_ADDR_WIDTH),
      .DATA_WIDTH(WB_DATA_WIDTH)
      )
wb_bus (
  // System sigals
  .clk_i(clk),
  .rst_i(rst),
  // Master signals
  .cyc_o(cyc),
  .stb_o(stb),
  .ack_i(ack),
  .adr_o(adr),
  .we_o(we),
  // Slave signals
  .cyc_i(),
  .stb_i(),
  .ack_o(),
  .adr_i(),
  .we_i(),
  // Shred signals
  .dat_o(dat_wr_o),
  .dat_i(dat_rd_i)
  );

// ****************************************************************************
// Instantiate the DUT - I2C Multi-Bus Controller
\work.iicmb_m_wb(str) #(.g_bus_num(NUM_I2C_BUSSES)) DUT
  (
    // ------------------------------------
    // -- Wishbone signals:
    .clk_i(clk),         // in    std_logic;                            -- Clock
    .rst_i(rst),         // in    std_logic;                            -- Synchronous reset (active high)
    // -------------
    .cyc_i(cyc),         // in    std_logic;                            -- Valid bus cycle indication
    .stb_i(stb),         // in    std_logic;                            -- Slave selection
    .ack_o(ack),         //   out std_logic;                            -- Acknowledge output
    .adr_i(adr),         // in    std_logic_vector(1 downto 0);         -- Low bits of Wishbone address
    .we_i(we),           // in    std_logic;                            -- Write enable
    .dat_i(dat_wr_o),    // in    std_logic_vector(7 downto 0);         -- Data input
    .dat_o(dat_rd_i),    //   out std_logic_vector(7 downto 0);         -- Data output
    // ------------------------------------
    // ------------------------------------
    // -- Interrupt request:
    .irq(irq),           //   out std_logic;                            -- Interrupt request
    // ------------------------------------
    // ------------------------------------
    // -- I2C interfaces:
    .scl_i(scl),         // in    std_logic_vector(0 to g_bus_num - 1); -- I2C Clock inputs
    .sda_i(sda),         // in    std_logic_vector(0 to g_bus_num - 1); -- I2C Data inputs
    .scl_o(scl),         //   out std_logic_vector(0 to g_bus_num - 1); -- I2C Clock outputs
    .sda_o(sda)          //   out std_logic_vector(0 to g_bus_num - 1)  -- I2C Data outputs
    // ------------------------------------
  );


endmodule


