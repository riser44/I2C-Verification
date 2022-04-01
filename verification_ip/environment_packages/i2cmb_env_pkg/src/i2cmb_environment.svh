class i2cmb_environment extends ncsu_component;

  i2cmb_env_configuration configuration;
  wb_agent wb_agent;
  i2c_agent i2c_agent;
  i2cmb_predictor  pred;
  i2cmb_scoreboard scbd;
  
  function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
  endfunction 

  function void set_configuration(i2cmb_env_configuration cfg);
    configuration = cfg;
  endfunction

  virtual function void build();
    wb_agent = new("wb_agent",this); //create object for wb_agent
    wb_agent.set_configuration(configuration.wb_agent_config);//setting the configuration for wb_agent
    wb_agent.build();  //calling the build function for wb_agent
    i2c_agent = new("i2c_agent",this); //create object for i2c_agent
    i2c_agent.set_configuration(configuration.i2c_agent_config);//setting the configuration for i2c_agent
    i2c_agent.build(); //calling the build function for i2c_agent
    pred  = new("pred", this); //create object for predictor
    pred.set_configuration(configuration);//setting the configuration for predictor
    pred.build(); //calling the build function for pred
    scbd  = new("scbd", this); //create object for scoreboard
    scbd.build(); //calling the build function for scoreboard
    wb_agent.connect_subscriber(pred); //calling the connect_subscriber function for wb_agent
    pred.set_scoreboard(scbd);
    i2c_agent.connect_subscriber(scbd);//calling the connect_subscriber function for i2c_agent
  endfunction

  function ncsu_component#(wb_transaction) get_wb_agent();
    return wb_agent;
  endfunction

  function ncsu_component#(i2c_transaction) get_i2c_agent();
    return i2c_agent;
  endfunction

  virtual task run();
  fork
    i2c_agent.run();
     wb_agent.run();
  join_none
     
  endtask

endclass


