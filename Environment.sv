//The testbench environment file which controls the execution of individual test blocks and the entire testbench
`ifndef PROTECT_ENVIRONMENT
`define PROTECT_ENVIRONMENT

`include "Instruction.sv"
`include "Generator.sv"
`include "Driver.sv"
`include "Fetch_Verification.sv"
`include "Decode_Verification.sv"
`include "Execute_Verification.sv"
`include "Writeback_Verification.sv"
`include "Controller_Verification.sv"

class environment;
	virtual LC3_io.TB top_io;
	virtual dut_Probe_if.FETCH dut_if;
	virtual dut_Probe_DE.DECODE dut_de;
	virtual executeInterface execute_Interface;
	virtual dut_Probe_WB.WB dut_wb;
	virtual memAccess_if mem_io;
	virtual dut_Probe_CON dut_Con;
	
	mailbox #(Instruction) gen2drv;
	generator gen;
	driver drv;
	goldenref_fetch Fetch;
	goldenref_decode Decode;
	goldenref_execute Execute;
	goldenref_writeback Writeback;
	goldenref_control Control;
	
	
	function new(virtual LC3_io.TB top_io,virtual dut_Probe_if.FETCH dut_if, virtual dut_Probe_DE.DECODE dut_de, virtual executeInterface execute_Interface, virtual dut_Probe_WB.WB dut_wb, virtual memAccess_if mem_io, virtual dut_Probe_CON C_int);
		this.top_io = top_io;
		this.dut_if = dut_if;
		this.dut_de = dut_de;
		this.execute_Interface = execute_Interface;
		this.dut_wb = dut_wb;
		this.dut_Con = C_int;
	endfunction : new 

	function void build();
		gen2drv = new(10);
		gen = new(gen2drv);
		drv = new(gen2drv,top_io,dut_wb,dut_if,dut_de,execute_Interface,mem_io,dut_Con);
		Fetch = new(dut_if);
		Decode = new(dut_de);
		Execute= new(execute_Interface);
		Writeback=new(dut_wb);
		Control = new(dut_Con);

		
	endfunction : build

	
	task run();
		build();
		fork
			gen.run();
                        
			drv.run();
			
			Fetch.run();
			
			Decode.run();
			
			Execute.run();
			
			Writeback.run();
			
			Control.run();
			
		join_any
		
	endtask : run
endclass
`endif
