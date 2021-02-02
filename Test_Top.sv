//Top level testbench module
//
`timescale 1ns/10ps
`include "TopLevelLC3.v"
`include "LC3_Testbench.sv"
`include "Interface.sv"
module LC3_test_top;
	
	parameter simulation_cycle = 10;
	reg  SysClock;
	LC3_io top_io(SysClock);  
	
	//Interconnection between DUT fetch block and testbench for the fetch block
	dut_Probe_if dut_if (	
					.fetch_enable_updatePC(dut.Fetch.enable_updatePC), 
					.fetch_enable_fetch(dut.Fetch.enable_fetch), 
					.fetch_pc(dut.Fetch.pc), 
					.fetch_npc(dut.Fetch.npc_out),
					.fetch_instrmem_rd(dut.Fetch.instrmem_rd),
					.fetch_taddr(dut.Fetch.taddr),
					.fetch_br_taken(dut.Fetch.br_taken),
					.fetch_reset(dut.Fetch.reset),
					.clock(SysClock)
				);

	//Interconnection between DUT decode block and testbench for the decode block
	dut_Probe_DE dut_de (.decode_npc_in(dut.Dec.npc_in),
					.decode_enable_decode(dut.Dec.enable_decode),
					.decode_Instr_dout(dut.Dec.dout),
					.decode_IR(dut.Dec.IR),
					.decode_E_control(dut.Dec.E_Control),
					.decode_npc_out(dut.Dec.npc_out),
					.decode_Mem_control(dut.Dec.Mem_Control),
					.decode_W_control(dut.Dec.W_Control),
					.decode_reset(dut.Dec.reset),
					.decode_clk(SysClock)				); 

	//Interconnection between DUT execute block and testbench for the execute block				
	executeInterface execute_Interface (.E_Control(dut.Ex.E_Control),
							.IR(dut.Ex.IR),
							.npc(dut.Ex.npc),
							.bypass_alu_1(dut.Ex.bypass_alu_1),
					                .bypass_alu_2(dut.Ex.bypass_alu_2),
							.bypass_mem_1(dut.Ex.bypass_mem_1),
							.bypass_mem_2(dut.Ex.bypass_mem_2),
							.VSR1(dut.Ex.VSR1),
							.VSR2(dut.Ex.VSR2),
							.W_Control_in(dut.Ex.W_Control_in),
							.Mem_Control_in(dut.Ex.Mem_Control_in),
							.enable_execute(dut.Ex.enable_execute),
							.Mem_Bypass_Val(dut.Ex.Mem_Bypass_Val),
							.W_Control_out(dut.Ex.W_Control_out),
							.Mem_Control_out(dut.Ex.Mem_Control_out),
							.aluout(dut.Ex.aluout),
							.pcout(dut.Ex.pcout),
							.dr(dut.Ex.dr),
							.sr1(dut.Ex.sr1),
							.sr2(dut.Ex.sr2),
							.IR_Exec(dut.Ex.IR_Exec),
							.NZP(dut.Ex.NZP),
							.M_Data(dut.Ex.M_Data),
							.reset(dut.Ex.reset),
							.clock(SysClock)				);

	
	//Interconnection between DUT writeback block and testbench for the writeback block	
  	dut_Probe_WB dut_wb (.writeback_npc(dut.WB.Writeback.npc),
                    .writeback_W_control_in(dut.WB.Writeback.W_Control),
                    .writeback_aluout(dut.WB.Writeback.aluout),
                    .writeback_pcout(dut.WB.Writeback.pcout),
                    .writeback_memout(dut.WB.Writeback.memout),
                    .writeback_enable_writeback(dut.WB.Writeback.enable_writeback),
                    .writeback_sr1(dut.WB.Writeback.sr1),
                    .writeback_sr2(dut.WB.Writeback.sr2),
                    .writeback_dr(dut.WB.Writeback.dr),
                    .writeback_VSR1(dut.WB.Writeback.d1),
                    .writeback_VSR2(dut.WB.Writeback.d2),
                    .writeback_psr(dut.WB.Writeback.psr),
			.writeback_reset(dut.WB.Writeback.reset),
			.writeback_clk(SysClock)
					);

	//Interconnection between DUT memaccess and testbench for memaccess
	memAccess_if mem_io (		.M_Data(dut.MemAccess.M_Data),
					.M_addr(dut.MemAccess.M_Addr),
					.memout(dut.MemAccess.memout),
					.M_Control(dut.MemAccess.M_Control),
					.mem_state(dut.MemAccess.mem_state),
					.Data_addr(dut.MemAccess.Data_addr),
					.Data_din(dut.MemAccess.Data_din),
					.Data_dout(dut.MemAccess.Data_dout),
					.Data_rd(dut.MemAccess.Data_rd),
					.clock(SysClock)
				); 
	//Interconnection between DUT controller component and testbench for the controller component
				
	dut_Probe_CON 	dut_Con(
					.control_complete_data(dut.Ctrl.complete_data),    
					.control_complete_instr(dut.Ctrl.complete_instr),
                    .control_IR(dut.Ctrl.IR),
                    .control_PSR(dut.Ctrl.psr),
                    .control_IR_Exec(dut.Ctrl.IR_Exec),
                    .control_NZP(dut.Ctrl.NZP),
                    .control_enable_updatePC(dut.Ctrl.enable_updatePC),
					.control_enable_fetch(dut.Ctrl.enable_fetch),
					.control_enable_decode(dut.Ctrl.enable_decode),
					.control_enable_execute(dut.Ctrl.enable_execute),
					.control_enable_writeback(dut.Ctrl.enable_writeback),
					.control_mem_state(dut.Ctrl.mem_state),
					.control_br_taken(dut.Ctrl.br_taken),
					.control_reset(dut.Ctrl.reset),
					.control_clk(SysClock)
				);

	// Passing the top level interface and probe interface to the testbench.
	
	LC3_test test(top_io,dut_if, dut_de, execute_Interface, dut_wb, mem_io, dut_Con);
	 
	// Instatiating the top-level DUT
	LC3 dut(
		.clock(top_io.clock), 
		.reset(top_io.reset), 
		.pc(top_io.pc), 
		.instrmem_rd(top_io.instrmem_rd), 
		.Instr_dout(top_io.Instr_dout), 
		.Data_addr(top_io.Data_addr), 
		.complete_instr(top_io.complete_instr), 
		.complete_data(top_io.complete_data),
		.Data_din(top_io.Data_din),
		.Data_dout(top_io.Data_dout),
		.Data_rd(top_io.Data_rd)
		);

//Assertions for reset and ALU + LEA 
	property reset;
		@(posedge top_io.clock)
			(top_io.reset==1'b1) |-> (dut_if.fetch_pc==16'h3000 && 
									dut_de.decode_IR==0 && 
									dut_de.decode_npc_out==0 && 
									dut_de.decode_E_control==0 && 
									dut_de.decode_W_control==0 && 
									execute_Interface.W_Control_out==0 && 
									execute_Interface.aluout==0 && 
									execute_Interface.pcout==0 && 
									execute_Interface.IR_Exec==0 && 
									execute_Interface.dr==0 && 
									dut_wb.writeback_psr==0);
	endproperty					
	top_reset :cover property (reset);
	
	property cover_ALULEA;
		@(posedge top_io.clock)
			((dut_Con.control_IR_Exec[15:12]==ADD ||
			dut_Con.control_IR_Exec[15:12]==AND ||
			dut_Con.control_IR_Exec[15:12]==NOT ||
			dut_Con.control_IR_Exec[15:12]==LEA)
			&&
			(dut_Con.control_IR[15:12]==ADD || dut_Con.control_IR[15:12]==AND || dut_Con.control_IR[15:12]==NOT)
			&& 
			dut_Con.control_IR_Exec[11:9]==dut_Con.control_IR[8:6])
			|-> 
			dut_Con.control_bypass_alu_1==1'b1;
	endproperty
	
	Cover_cover_ALULEA : cover property (cover_ALULEA);
	
	property cover_ALULEA2;
	
		@(posedge top_io.clock)
			((dut_Con.control_IR_Exec[15:12]==0001 ||
			dut_Con.control_IR_Exec[15:12]==0101 ||
			dut_Con.control_IR_Exec[15:12]==1001 ||
			dut_Con.control_IR_Exec[15:12]==1110)
			&&
			(dut_Con.control_IR[15:12]==4'b0001 || dut_Con.control_IR[15:12]==4'b0101 || dut_Con.control_IR[15:12]==4'b1001)
			&& 
			((dut_Con.control_IR_Exec[11:9]==dut_Con.control_IR[2:0]) && (dut_Con.control_IR[5]!=1'b1)))
			|-> 
			dut_Con.control_bypass_alu_2==1'b1;
	endproperty
	
	Cover_cover_ALULEA2 : cover property (cover_ALULEA2);
	
	initial 
	begin
		SysClock = 0;
		forever 
		begin
			#(simulation_cycle/2)
                         SysClock=~SysClock;
			
		end
	end
endmodule

