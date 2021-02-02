//This file is for defining constraints for instructions that are used in the testbench
`ifndef GAURD_INSTRUCTION
`define GAURD_INSTRUCTION

`include "params.sv"  //A file containing parameters that are used to define the instruction opcodes and types

class Instruction;
	rand bit [15:0] Instr_base;
	rand instr_type_e Instr_type;
	rand instr_opcode_e Instr_opcode;

	constraint c_PrevIsMEM {
		Instr_type dist {ALU:=1, CTRL:=1, MEM:=0};
	}
	
	constraint c_PrevIsCTRL {
		Instr_type dist {ALU:=1, MEM:=3, CTRL:=0};
	}
	
	constraint c_ALU {
		Instr_type inside {ALU};
	}
	
	constraint c1 {
		solve Instr_type before Instr_opcode;
		Instr_type == ALU -> Instr_opcode inside {ADD,AND,NOT,LEA};
		
	}

	constraint c2 {
		Instr_opcode == ADD -> Instr_base[5:0] inside {[0:7],[32:63]};
		Instr_opcode == AND -> Instr_base[5:0] inside {[0:7],[32:63]};
		Instr_opcode == NOT -> Instr_base[5:0] == 6'b111111;
		Instr_base[15:12] == Instr_opcode;
	}
endclass
`endif
