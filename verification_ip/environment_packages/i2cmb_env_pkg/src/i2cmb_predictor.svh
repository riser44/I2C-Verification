class i2cmb_predictor extends ncsu_component#(.T(wb_transaction));

  ncsu_component#(i2c_transaction) scoreboard;
  i2c_transaction transport_trans;
  i2c_transaction i2c_trans_pred;
  i2cmb_env_configuration configuration;
  bit start;
  bit stop;
  bit set_flag;
  bit address_flag;
  bit set_bus; 
  int i;
  bit [7:0] temp[1];

function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
	i2c_trans_pred = new("i2c_trans_pred");
	i2c_trans_pred.i2c_data = new[1];
	transport_trans = new ("transport_trans");
	start = 0;
    stop = 0;
    set_flag = 0;
	i=0;
	address_flag = 0;
	
endfunction
	

  function void set_configuration(i2cmb_env_configuration cfg);
    configuration = cfg;
  endfunction

  virtual function void set_scoreboard(ncsu_component #(i2c_transaction) scoreboard);
      this.scoreboard = scoreboard;
  endfunction

virtual function void nb_put(T trans);
    if(trans.wb_addr==2'b00 && trans.wb_data == 8'b11000000)
	begin
		set_flag=1;
	end
	
	if(trans.wb_addr==2'b10 && trans.wb_data == 8'b110 && set_flag == 1)
	begin
		set_bus =1;
	end
	//Start
	if(trans.wb_addr==2'b10 && trans.wb_data==8'b100 && set_bus==1)
	begin
	
		start=1;
		if(start==1 && stop == 0)
		begin
		i++;
		if(!(i==1))
		begin
         		 // Put transaction into Scoreboard when Repeated Start Occurs
         		scoreboard.nb_transport(i2c_trans_pred, transport_trans);
		end
		
		end
		stop=0;
		address_flag=0;
	end
	//Stop
	if(trans.wb_addr==2'b10 && trans.wb_data==8'b101)
	begin
		stop=1;
		if(stop ==1 && start ==1 )
		begin
		i++;
		if(!(i==1))
		begin
			scoreboard.nb_transport(i2c_trans_pred, transport_trans);
		end
		end
		address_flag=0;
		start=0;
	end
	
 	//Address
	if((trans.wb_data == 8'b10001000 || trans.wb_data == 8'b10001001) && (start ==1 ) && trans.wb_addr==2'b01)
	begin
		address_flag=1;
		if(trans.wb_data[0]==0)
			i2c_trans_pred.i2c_operation=wr;
		else if(trans.wb_data[0] == 1)
			i2c_trans_pred.i2c_operation=rd;
		i2c_trans_pred.i2c_address=trans.wb_data[7:1];
	end
 	else if(address_flag==1 && stop==0 && trans.wb_addr==2'b01)
	begin
		i2c_trans_pred.i2c_data[0]=trans.wb_data[7:0];
	end
   
  endfunction

endclass



