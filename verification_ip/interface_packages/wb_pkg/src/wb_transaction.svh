class wb_transaction extends ncsu_transaction;
  `ncsu_register_object(wb_transaction)

bit [1:0] wb_addr; 
bit [7:0] wb_data;
bit wb_we;
bit wb_operation;
bit IRQ;

  function new(string name=""); 
    super.new(name);
  endfunction

  virtual function string convert2string();
     return {super.convert2string(),$sformatf("wb_addr:%h wb_data:%d wb_we:%d wb_operation:%d", wb_addr, wb_data, wb_we, wb_operation)};
  endfunction

  function bit compare(wb_transaction rhs);
    return ((this.wb_addr  == rhs.wb_addr ) && 
            (this.wb_data == rhs.wb_data) &&
            (this.wb_we == rhs.wb_we) );
  endfunction


endclass


