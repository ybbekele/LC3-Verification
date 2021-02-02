interface LC3_io(input bit clock); //Top level interface for LC3
  	
	logic reset, instrmem_rd, complete_instr, complete_data, Data_rd; 
	logic [15:0] pc, Instr_dout, Data_addr,  Data_dout, Data_din;
  	

  	clocking cb @(posedge clock);
 	default input #1 output #2;

		input	pc; 
   		input  instrmem_rd;  
   		input  Data_din;
		input  Data_rd;
		input  Data_addr;		
		output Data_dout;
		output Instr_dout;
		output reset;
		
  	endclocking

  	modport TB(clocking cb, output complete_data, output complete_instr);   
endinterface




interface dut_Probe_if(	
                        // fetch block interface signals
                        input   logic fetch_enable_updatePC,
                        input   logic fetch_enable_fetch,
                        input   logic fetch_br_taken,
                        input   logic [15:0] fetch_taddr,
                        input   logic fetch_instrmem_rd,
                        input   logic [15:0] fetch_pc,
                        input  logic [15:0] fetch_npc,
                        input	bit fetch_reset,
			input   bit clock
						);

 	logic	goldenref_instrmem_rd;
 	logic	[15:0]	goldenref_pc, goldenref_npc;

  	clocking cb @(posedge clock);
	
		default input #1 output #2;
		input fetch_enable_updatePC;
		input fetch_br_taken;
	 	input fetch_instrmem_rd;
		input goldenref_pc;
		input goldenref_npc;
  	endclocking	
	
	modport FETCH (clocking cb, input fetch_reset,output goldenref_instrmem_rd, input fetch_enable_fetch, input fetch_taddr, input fetch_pc, input fetch_npc, input goldenref_pc, input goldenref_npc);
endinterface

interface dut_Probe_DE(	
                        // decode block interface signals
                        input   logic           [15:0]          decode_npc_in,
                        input   logic                           decode_enable_decode,
                        input   logic           [15:0]          decode_Instr_dout,
                        input  logic           [15:0]         	decode_IR,
                        input   logic           [5:0]           decode_E_control,
                        input  logic           [15:0]          decode_npc_out,
                        input  logic           	        decode_Mem_control,
			input   logic           [1:0]           decode_W_control,
			input	bit 				decode_reset,
			input   bit				decode_clk
						);
						
 	logic		goldenref_Mem_Control;
 	logic	[15:0] 	goldenref_IR, goldenref_npc_out;
	logic 	[5:0]	goldenref_E_control;
	logic	[1:0]	goldenref_W_Control;
	
	
	clocking cb @(posedge decode_clk);
		
		default input #1 output #1;

		// inputs to decode 
		input decode_enable_decode;
       		input decode_npc_in;
		input decode_Instr_dout;
        
		// outputs from the decode

		input 	goldenref_IR;
		input	goldenref_npc_out;
		input	goldenref_E_control;
		input	goldenref_W_Control;
		
  	endclocking
	modport DECODE (clocking cb, input decode_reset,input decode_W_control,input decode_Mem_control,input decode_npc_out,input decode_E_control, 
	 output	goldenref_Mem_Control,input decode_IR, input goldenref_IR,input	goldenref_npc_out, input goldenref_E_control,input goldenref_W_Control);
          
endinterface

interface executeInterface (input logic clock, input logic reset, input logic [5:0] E_Control, input logic bypass_alu_1,
						input logic bypass_alu_2, input logic [15:0] IR, input logic [15:0] npc, input logic [1:0] W_Control_in, input logic Mem_Control_in,
						input logic [15:0] VSR1, input logic [15:0] VSR2, input logic bypass_mem_1, input logic bypass_mem_2, input logic [15:0] Mem_Bypass_Val,
						input logic enable_execute, input logic [1:0] W_Control_out, input logic Mem_Control_out, input logic [15:0] aluout, input logic [15:0] pcout,
						input logic [2:0] sr1, input logic [2:0] sr2, input logic [2:0] dr, input logic [15:0] M_Data, input logic [2:0] NZP, input logic [15:0] IR_Exec);

	logic [15:0] check_aluout;
	logic [1:0] check_W_Control_out;
	logic check_Mem_Control_out;
	logic [15:0] check_M_Data;
	logic [2:0] check_dr;
	logic [2:0] check_sr1;
	logic [2:0] check_sr2;
	logic [2:0] check_NZP;
	logic [15:0] check_IR_Exec;
	logic [15:0] check_pcout;
        logic [15:0] ALU1;
	logic [15:0] ALU2;
endinterface 
/*

interface writebackInterface (input logic clock, reset, enable_writeback, 
					input logic [15:0] aluout, memout, pcout, npc, d1, d2,
					input logic [2:0] sr1, sr2, dr, psr,
					input logic [1:0] W_Control);
			
	logic [15:0] check_VSR1;
	logic [15:0] check_VSR2;
	logic [2:0] check_psr;			
				
endinterface : writebackInterface */

interface dut_Probe_WB(
			
					// Mem Block design Interface
					input	logic  [15:0]	writeback_npc,
                    input	logic  [1:0]  	writeback_W_control_in,
                    input	logic  [15:0] 	writeback_aluout,
                    input	logic  [15:0] 	writeback_pcout,
                    input	logic  [15:0] 	writeback_memout,
                    input	logic        	writeback_enable_writeback,
                    input	logic  [2:0]  	writeback_sr1,
                    input	logic  [2:0]  	writeback_sr2,
                    input	logic  [2:0]  	writeback_dr,
                    input	logic  [15:0] 	writeback_VSR1,
                    input	logic  [15:0] 	writeback_VSR2,
                    input	logic  [2:0]  	writeback_psr,
					input	bit 			writeback_reset,
					input   bit				writeback_clk
					);
					
	logic  [15:0] 	goldenref_writeback_VSR1;
    logic  [15:0] 	goldenref_writeback_VSR2;
    logic  [2:0]  	goldenref_writeback_psr;
	
	clocking cb_writeback @(posedge writeback_clk);
		
		default input #1 output #0;

		// inputs to writeback
		input	writeback_npc;
       	 	input	writeback_W_control_in;
        	input	writeback_aluout;
        	input	writeback_pcout;
        	input	writeback_memout;
        	input	writeback_enable_writeback;
        	input	writeback_dr;

		// outputs from the Writeback

		//output	goldenref_writeback_psr;
		
  	endclocking
	
	modport WB (clocking cb_writeback,output goldenref_writeback_VSR1,output goldenref_writeback_VSR2,input writeback_reset,input writeback_sr1,input writeback_sr2,input writeback_psr,input writeback_VSR1,input writeback_VSR2,input writeback_clk,output goldenref_writeback_psr);
endinterface


interface memAccess_if(
					//Required o/p signals of DUT's Execute for driving GoldRef's MemAccess 
					input logic   [15:0] M_Data,
					input logic   [15:0] M_addr,
					input logic   [15:0] memout,
					input logic 	     M_Control,
					//Required o/p signals of DUT's Controller for driving GoldRef's MemAccess 
					input logic   [1:0]  mem_state,
					//Required o/p signals of DUT's MemAccess for checking GoldRef's MemAccess o/p's 
					input logic   [15:0] Data_addr,Data_din,Data_dout,
					input logic          Data_rd,
					input bit 	     clock
			);
			logic [15:0] GoldRef_Data_addr, GoldRef_Data_din, GoldRef_Data_dout;
		        logic GoldRef_Data_rd;
			//No clocking block is required as stage is completely
			//async
endinterface


interface dut_Probe_CON(	
                        // control block interface signals
                        input   logic      			control_complete_data,    
                        input   logic      			control_complete_instr,
                        input   logic      [15:0]	control_IR,
                        input   logic      [2:0]     control_PSR,
                        input   logic      [15:0]     control_IR_Exec,
                        input   logic      [15:0]     control_IMem_dout,
                        input   logic      [2:0]     control_NZP,
                        input   logic           control_enable_updatePC,
						input   logic           control_enable_fetch,
						input   logic           control_enable_decode,
						input   logic           control_enable_execute,
						input   logic           control_enable_writeback,
						input   logic           control_bypass_alu_1,
						input   logic           control_bypass_alu_2,
						input   logic           control_bypass_mem_1,
						input   logic           control_bypass_mem_2,
						input   logic      [1:0]     control_mem_state,
						input   logic           control_br_taken,
						input	bit 			control_reset,
						input   bit				control_clk
						);
						
 	logic          goldenref_enable_updatePC;
	logic          goldenref_enable_fetch;
	logic          goldenref_enable_decode;
	logic          goldenref_enable_execute;
	logic           goldenref_enable_writeback;
	logic          goldenref_bypass_alu_1;
	logic           goldenref_bypass_alu_2;
	logic           goldenref_bypass_mem_1;
	logic           goldenref_bypass_mem_2;
	logic [1:0]     goldenref_mem_state;
	logic           goldenref_br_taken;
	
endinterface


