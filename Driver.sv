//This file contains the instructions that are used to do the test on the given DUT. The instructions are ALU instructions that are given in the Imem_5.dat and LEA instruction 
//generated using GenerateInstr.pl
`ifndef PROTECT_GENERATOR
`define PROTECT_GENERATOR

`include "Instruction.sv"
`include "Coverage.sv"

class driver;
	Coverage Cov;
	Instruction instr;
	mailbox #(Instruction) gen2drv;
	virtual LC3_io.TB top_io;
	virtual dut_Probe_WB.WB dut_wb;
	virtual dut_Probe_if.FETCH dut_if;
	virtual dut_Probe_DE.DECODE dut_de;
	virtual executeInterface execute_Interface;
	virtual memAccess_if mem_io;
	virtual dut_Probe_CON dut_Con;
				
	local logic instrmem_rd_prev = 1;
	local int temp;

	function new(mailbox #(Instruction) mbx, virtual LC3_io.TB top_io,virtual dut_Probe_WB.WB dut_wb,virtual dut_Probe_if.FETCH dut_if, virtual dut_Probe_DE.DECODE dut_de,	virtual executeInterface execute_Interface,virtual memAccess_if mem_io,virtual dut_Probe_CON dut_Con);
		this.gen2drv = mbx;
		this.top_io = top_io;
		this.dut_wb = dut_wb;
		this.dut_if = dut_if;
		this.dut_de = dut_de;
		this.execute_Interface = execute_Interface;
		this.mem_io = mem_io;
		this.dut_Con = dut_Con;
		Cov = new(dut_wb,dut_if,dut_de,execute_Interface,mem_io,dut_Con,top_io);
	endfunction : new

	task Reset_dut();
		@top_io.cb;
		top_io.cb.reset <= 1;
		top_io.complete_data <= 0;
    		top_io.complete_instr <= 0;
	    	repeat(3)@top_io.cb;
		top_io.cb.reset <= 0;
	endtask : Reset_dut


	task Init_dut();
		top_io.complete_instr <= 1;
		top_io.complete_data <= 1;
		
		
		repeat(1)@top_io.cb;
		$display("%dns AND R0, R0, #0",$time);
		top_io.cb.Instr_dout <= 16'h5020;
		repeat(1)@top_io.cb;
		$display("%dns AND R2, R2, #0",$time);
		top_io.cb.Instr_dout <= 16'h54A0;
		repeat(1)@top_io.cb;
		$display("%dns  AND R1, R1, #0",$time);
		top_io.cb.Instr_dout <= 16'h5260;
		repeat(1)@top_io.cb;
		$display("%dns LEA, R6, #3",$time);
		top_io.cb.Instr_dout <= 16'hEC03;
		repeat(1)@top_io.cb;
		$display("%dns ADD R6, R6, #1",$time);
		top_io.cb.Instr_dout <= 16'h1DA1;
		repeat(1)@top_io.cb;
		$display("%dns ADD R3, R2, #5 ",$time);
		top_io.cb.Instr_dout <= 16'h16A5;
		repeat(1)@top_io.cb;
		$display("%dns ADD R5, R3, R3",$time);
		top_io.cb.Instr_dout <= 16'h1AC3;
		repeat(1)@top_io.cb;
		$display("%dns ADD R5, R5, R5",$time);
		top_io.cb.Instr_dout <= 16'h1B45;	
 		repeat(1)@top_io.cb;
		$display("%dns ADD R3, R3,  #-1",$time);
		top_io.cb.Instr_dout <= 16'h16FF;	
		repeat(1)@top_io.cb;
		$display("%dns ADD R6, R6, #1",$time);
		top_io.cb.Instr_dout <= 16'h1DA1;
 		repeat(1)@top_io.cb;
		$display("%dns ADD R4, R6, R6",$time);
		top_io.cb.Instr_dout <= 16'h1986;
		repeat(1)@top_io.cb;
		$display("%dns ADD R5, R4, R3",$time);
		top_io.cb.Instr_dout <= 16'h1B03;
		repeat(1)@top_io.cb;
		$display("%dns ADD R7,R4, R3",$time);
		top_io.cb.Instr_dout <= 16'h1F03;
		repeat(1)@top_io.cb;
		$display("%dns NOT R7,R7",$time);
		top_io.cb.Instr_dout <= 16'h9FFF;
	endtask : Init_dut

	task Randomtest_dut();
		forever begin
			@top_io.cb;
			if(top_io.cb.instrmem_rd)
			begin
				gen2drv.get(instr);
				top_io.complete_instr <= 1;
				top_io.complete_data <= 1;
				top_io.cb.Instr_dout <= instr.Instr_base;
				
			end
			else
			begin
				
			end
			instrmem_rd_prev = top_io.cb.instrmem_rd;
		end
	endtask : Randomtest_dut

	task run();
		Reset_dut();
		Init_dut();
		Randomtest_dut();
		
	endtask
endclass

`endif
