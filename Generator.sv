`ifndef GAURD_GENERATOR
`define GAURD_GENERATOR

//`include "params.sv"
`include "Instruction.sv"

class generator;
	Instruction Instr;
	mailbox #(Instruction) gen2drv;
	instr_type_e prev_Instr_type;
	instr_type_e q_prev_Instr[$] = {ALU,ALU,ALU,ALU,ALU,ALU};
	
	int flag_CTRLfound;
	int flag_MEMfound;
	
	function new(mailbox #(Instruction) mbx);
		this.gen2drv = mbx;
	endfunction : new

	task chekPrevFive_MEM();
		
		flag_MEMfound = 0;
		flag_CTRLfound = 0;
		
		for(int i=0;i<5; i= i+1)
		begin
			if(q_prev_Instr[i] == MEM)
			begin
				flag_MEMfound = 1;
				flag_CTRLfound = 1;
				break;
			end
		end
	endtask: chekPrevFive_MEM
	
	task chekPrevFive_CTRL();
		
		flag_MEMfound = 0;
		flag_CTRLfound = 0;
		
		for(int i=0;i<5; i= i+1)
		begin
			if(q_prev_Instr[i] == CTRL)
			begin
				flag_MEMfound = 1;
				flag_CTRLfound = 1;
				break;
			end
		end
	endtask: chekPrevFive_CTRL
	
	task chekPrevFive_BOTH();
		
		flag_MEMfound = 0;
		flag_CTRLfound = 0;
		
		for(int i=0;i<5; i= i+1)
		begin
			if(q_prev_Instr[i] == CTRL)
			begin
				flag_CTRLfound = 1;
				break;
			end
		end
		
		for(int i=0;i<5; i= i+1)
		begin
			if(q_prev_Instr[i] == MEM)
			begin
				flag_MEMfound = 1;
				break;
			end
		end
	endtask: chekPrevFive_BOTH
	
	task set_constraints();
		
		if (prev_Instr_type == MEM)
		begin
			
			chekPrevFive_CTRL();
			if(flag_CTRLfound == 1)
			begin
				Instr.c_PrevIsMEM.constraint_mode(0);
				Instr.c_PrevIsCTRL.constraint_mode(0);
				Instr.c_ALU.constraint_mode(1);
			end
			else
			begin
				Instr.c_PrevIsMEM.constraint_mode(1);
				Instr.c_PrevIsCTRL.constraint_mode(0);
				Instr.c_ALU.constraint_mode(0);
			end
			
		end
		else if (prev_Instr_type == CTRL)
		begin
			chekPrevFive_MEM();
			if(flag_MEMfound == 1)
			begin
				Instr.c_PrevIsMEM.constraint_mode(0);
				Instr.c_PrevIsCTRL.constraint_mode(0);
				Instr.c_ALU.constraint_mode(1);
			end
			else
			begin
				Instr.c_PrevIsMEM.constraint_mode(0);
				Instr.c_PrevIsCTRL.constraint_mode(1);
				Instr.c_ALU.constraint_mode(0);
			end
		end
		else
		begin
			chekPrevFive_BOTH();
			if(flag_CTRLfound == 1 && flag_MEMfound == 1)
			begin
				Instr.c_PrevIsMEM.constraint_mode(0);
				Instr.c_PrevIsCTRL.constraint_mode(0);
				Instr.c_ALU.constraint_mode(1);
				//$display($time,"here scheduling ALU");
			end
			else if(flag_CTRLfound == 1 && flag_MEMfound == 0)
			begin
				Instr.c_PrevIsMEM.constraint_mode(0);
				Instr.c_PrevIsCTRL.constraint_mode(1);
				Instr.c_ALU.constraint_mode(0);
			end
			else if(flag_CTRLfound == 0 && flag_MEMfound == 1)
			begin
				Instr.c_PrevIsMEM.constraint_mode(1);
				Instr.c_PrevIsCTRL.constraint_mode(0);
				Instr.c_ALU.constraint_mode(0);
			end
			else
			begin
				Instr.c_PrevIsMEM.constraint_mode(0);
				Instr.c_PrevIsCTRL.constraint_mode(0);
				Instr.c_ALU.constraint_mode(0);
			end
		end	
	
	endtask : set_constraints

	

task run();
	forever begin
		Instr = new();
		//set_flag();
		set_constraints();
		//test();
		Instr.randomize;
		//$display($time,"===>INSTR Type",Instr.Instr_type);
		gen2drv.put(Instr);
		prev_Instr_type = Instr.Instr_type;
		q_prev_Instr.push_back(Instr.Instr_type);
		q_prev_Instr.pop_front;
		//$display("in generator");
		end
		//$display("out of generator");
		endtask : run
endclass : generator
`endif
