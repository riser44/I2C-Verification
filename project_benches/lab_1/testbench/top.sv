`timescale 1ns / 10ps

module top();

parameter int WB_ADDR_WIDTH = 2;
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

// wire [WB_DATA_WIDTH-1:0]

// ****************************************************************************
// Clock generator
initial begin:clk_gen
clk = 1'b0;
forever 
#5 clk = ~clk;
end

// ****************************************************************************
// Reset generator
initial begin: rst_gen
forever
#113 rst = 1'b0;
end

// ****************************************************************************
// Monitor Wishbone bus and display transfers in the transcript

initial begin :wb_monitoring
reg [WB_ADDR_WIDTH-1:0]address;
reg [WB_DATA_WIDTH-1:0]dat;
reg write;

wb_bus.master_monitor(address,dat,write);
$display("Address is %b  Data is %b   Write is %b", address,dat,write);
// $display("addr=%0xh, data=%0xh, Write enable = %d",addrwr,datwr,wen);

end
// ****************************************************************************
// Define the flow of the simulation

initial begin :test_flow
reg [WB_DATA_WIDTH-1:0]dat2;
@(negedge rst);
@(posedge clk);
wb_bus.master_write(2'h00,8'b11xxxxxx);
wb_bus.master_write(2'h01,8'b00000101);
wb_bus.master_write(2'h02,8'bxxxxx110);


while(!(dat2[7]) || (!(irq)))
begin
@(posedge clk);
end
wb_bus.master_read(2'h02,dat2);


wb_bus.master_write(2'h02,8'bxxxxx100);



while(!(dat2[7]) || (!(irq)))
begin
@(posedge clk);
end
wb_bus.master_read(2'h02,dat2);

wb_bus.master_write(2'h01,8'h44);
wb_bus.master_write(2'h02,8'bxxxxx001);

while(!(dat2[7])|| (!(irq)))
begin
@(posedge clk);
end
wb_bus.master_read(2'h02,dat2);

wb_bus.master_write(2'h01,8'h78);
wb_bus.master_write(2'h02,8'bxxxxx001);

while(!(dat2[7]) || (!(irq)))
begin
@(posedge clk);
end
wb_bus.master_read(2'h02,dat2);

wb_bus.master_write(2'h02,8'bxxxxx101);

while(!(dat2[7]) || (!(irq)))
begin 
@(posedge clk);
end
wb_bus.master_read(2'h02,dat2);
end 




/*initial
begin:test_flow
bit[7:0] CMDR;
  wb_bus.master_write(.addr(2'b0),.data(8'b11xxxxxx));//ENABLE
  wb_bus.master_write(.addr(2'b1),.data(8'h05));wb_bus.master_write(.addr(2),.data(8'bxxxxx110));//SET bus 5 
  wb_bus.master_read('h02,CMDR);
  wait(!(CMDR[7]));//shld i advance in time?
  wb_bus.master_read('h02,CMDR);//To reset irq
  
  wb_bus.master_write(.addr(2'b10),.data(8'bxxxxx100));//START
  wb_bus.master_read('h02,CMDR);
  wait(CMDR[7]==1'b1 || irq == 1'b1);
  wb_bus.master_read('h02,CMDR);//To reset irq
  
  wb_bus.master_write(.addr(2'b1),.data(8'h44));wb_bus.master_write(.addr(2),.data(8'bxxxxx001));//Write addr of slave
  wb_bus.master_read('h02,CMDR);
  wait(CMDR[7]==1'b1 || irq == 1'b1);
  wb_bus.master_read('h02,CMDR);//To reset irq
  
  wb_bus.master_write(.addr(2'b1),.data(8'h78));wb_bus.master_write(.addr(2),.data(8'bxxxxx001));//Write data into slave
  wb_bus.master_read('h02,CMDR);
  wait(CMDR[7]==1'b1 || irq == 1'b1);
  wb_bus.master_read('h02,CMDR);//To reset irq
  
  wb_bus.master_write(.addr(2'b10),.data(8'bxxxxx101));//STOP
  wb_bus.master_read('h02,CMDR);
  wait(CMDR[7]==1'b1 || irq == 1'b1);
  wb_bus.master_read('h02,CMDR);//To reset irq
end*/



/* initial begin : test_flow
bit [15:0] CMDR;

@(posedge clk);

wb_bus.master_write(.addr(2'h00),.data(8'b11xxxxxx));//E,IE
wb_bus.master_write(.addr(2'h01),.data(8'h05));//
wb_bus.master_write(.addr(2'h02),.data(8'bxxxxx110));//set bus
wait( irq == 1 );
wb_bus.master_read(8'h02,CMDR);
wb_bus.master_write(.addr(2'h02),.data(8'bxxxxx100));//START
wait( irq == 1 );
wb_bus.master_write(.addr(2'h01),.data(8'h44));
wb_bus.master_write(.addr(2'h02),.data(8'bxxxxx001));//WRITE
wait( irq == 1 );
wb_bus.master_write(.addr(2'h01),.data(8'h78));
wb_bus.master_write(.addr(2'h02),.data(8'bxxxxx001));//WRITE
wait( irq == 1 );
wb_bus.master_write(.addr(2'h02),.data(8'bxxxxx101));//STOP
wait( irq == 1 );
end
*/

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
