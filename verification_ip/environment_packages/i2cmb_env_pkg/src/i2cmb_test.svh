class i2cmb_test extends ncsu_component#(.T(wb_transaction));

  i2cmb_env_configuration  cfg;
  i2cmb_environment        env;
  i2cmb_generator          gen;


  function new(string name = "", ncsu_component_base parent = null); 
    super.new(name,parent);
    cfg = new("cfg");   //create object for cfg
    cfg.sample_coverage();
    env = new("env",this); //create object for env
    env.set_configuration(cfg); //setting the configuration for env
    env.build(); // calling the build function for env
    gen = new("gen",this); //create object for gen
    gen.set_agentwb(env.get_wb_agent()); // calling the set_agent function for generator of wb
    gen.set_agenti2c(env.get_i2c_agent()); // calling the set_agent function for generator of i2c
  endfunction

  virtual task run();
     env.run();
     gen.run();
  endtask

endclass

