//This is the coverage file which spans through the verification process to show if the test covers the DUT functionalities
//Code adopted from the coverage code by Kunal Buch from Github
`ifndef PROTECT_COVERAGE
`define PROTECT_COVERAGE

`include "Instruction.sv"
`include "param_mod.sv"
class Coverage;
	logic [15:0] Instr_dout;
	
	virtual dut_Probe_WB.WB dut_wb;
	virtual dut_Probe_if.FETCH dut_if;
	virtual dut_Probe_DE.DECODE dut_de;
	virtual executeInterface execute_Interface;
	virtual memAccess_if mem_io;
	virtual dut_Probe_CON dut_Con;
	virtual LC3_io.TB top_io;
	logic [2:0] psr;
		
	
	
	
	//Memory Instructions Covergroup (LEA for this project)
	covergroup MEM_OPR_cg;
	cov_mem_opcode : coverpoint Instr_dout[15:12]  
	{
		
		bins mem_type_lea = {4'b1110};
		
	}
	
	
	cov_DR_LEA : coverpoint Instr_dout[11:9]iff(Instr_dout[15:12] == 4'b1110)
			{
				bins LEA_DR[] = {[3'b000:3'b111]};
			}
	
	
	cov_PCoffset9: coverpoint Instr_dout[8:0] iff(Instr_dout[15:12]== 4'b1110)
	{
		option.auto_bin_max = 10;
	}
	
	cov_PCoffset9_c : coverpoint Instr_dout[8:0] iff( Instr_dout[15:12] == 4'b1110)
	{	
		bins pcoffset9_corner_all0 = { 9'b0 };
		bins pcoffset9_corner_all1 = { 9'b111111111 };
	}

		
	endgroup: MEM_OPR_cg
	
	//ALU Instructions Covergroup
	covergroup ALU_OPR_cg;
		Cov_alu_opcode: coverpoint Instr_dout[15:12] {
			bins add_instr = {4'd1};
			bins and_instr = {4'd5};
			bins not_instr = {4'd9};
		}
		Cov_imm_en: coverpoint Instr_dout[5] iff (Instr_dout[15:12] == ADDX || Instr_dout[15:12] == ANDX || Instr_dout[15:12] == NOTX);
		Cov_SR1: coverpoint Instr_dout[8:6] iff (Instr_dout[15:12] == ADDX || Instr_dout[15:12] == ANDX || Instr_dout[15:12] == NOTX); 
		Cov_SR2: coverpoint Instr_dout[2:0] iff (Instr_dout[15:12] == ADDX || Instr_dout[15:12] == ANDX || Instr_dout[15:12] == NOTX); 
		Cov_DR: coverpoint Instr_dout[11:9] iff (Instr_dout[15:12] == ADDX || Instr_dout[15:12] == ANDX || Instr_dout[15:12] == NOTX || Instr_dout[15:12]==LEAX);
		Cov_imm5: coverpoint Instr_dout[4:0] iff ( Instr_dout[15:12] == ADDX || Instr_dout[15:12] == ANDX && Instr_dout[5]) {
			option.auto_bin_max = 10;
		}
		Cov_bypass_alu1: coverpoint execute_Interface.bypass_alu_1 {
					bins bin1 = {1};
		}
		Cov_bypass_alu2: coverpoint execute_Interface.bypass_alu_2 {
					bins bin1 = {1};
		}
		Cov_bypass_mem1: coverpoint execute_Interface.bypass_mem_1 {
					bins bin1 = {1};
		}
		Cov_bypass_mem2: coverpoint execute_Interface.bypass_mem_2 {
					bins bin1 = {1};
		}
		Xc_opcode_bypass_alu1_alu2: cross Cov_alu_opcode, Cov_bypass_alu1, Cov_bypass_alu2;
		Xc_opcode_bypass_mem1_mem2: cross Cov_alu_opcode, Cov_bypass_mem1, Cov_bypass_mem2;
		Xc_opcode_bypass_alu1_imm5: cross Cov_alu_opcode, Cov_bypass_alu1, Cov_imm_en {
			ignore_bins no_not_instr = binsof(Cov_alu_opcode.not_instr);
		}
		Xc_opcode_bypass_mem1_imm5: cross Cov_alu_opcode, Cov_bypass_mem1, Cov_imm_en {
			ignore_bins no_not_instr = binsof(Cov_alu_opcode.not_instr);
		}
		Xc_opcode_imm_en: cross Cov_alu_opcode, Cov_imm_en {
			ignore_bins no_not_instr = binsof(Cov_alu_opcode.not_instr);
		}
		Xc_opcode_dr_sr1_imm5: cross Cov_alu_opcode, Cov_SR1, Cov_imm5, Cov_DR {
			ignore_bins no_not_instr = binsof(Cov_alu_opcode.not_instr);
		}
		Xc_opcode_dr_sr1_sr2: cross Cov_alu_opcode, Cov_SR1, Cov_SR2, Cov_DR {
			ignore_bins no_not_instr = binsof(Cov_alu_opcode.not_instr);
		}

		Cov_aluin1  : coverpoint execute_Interface.ALU1
				{ option.auto_bin_max = 10; }
				
		Cov_aluin1_corner : coverpoint execute_Interface.ALU1 {
					bins ALL_0  = {16'h0000};
					bins ALL_1  = {16'hFFFF};
				}
		Cov_aluin2   : coverpoint execute_Interface.ALU2
				{ option.auto_bin_max = 10 ; }
				
		Cov_aluin2_corner : coverpoint execute_Interface.ALU2 {
					bins ALL_0  = {16'h0000};
					bins ALL_1  = {16'hFFFF};
				}
		Xc_opcode_aluin1 : cross Cov_alu_opcode, Cov_aluin1 ;
		Xc_opcode_aluin2 : cross Cov_alu_opcode, Cov_aluin2 ;
		Xc_opcode_aluin1_corner : cross Cov_alu_opcode, Cov_aluin1_corner ;
		Xc_opcode_aluin2_corner : cross Cov_alu_opcode, Cov_aluin2_corner ;
		
		Cov_opr_zero_zero : coverpoint { execute_Interface.ALU1, execute_Interface.ALU2 } {
					bins ALL_0_ALL_0 = {32'h0000_0000};
				}
		
		Cov_opr_zero_all1 : coverpoint { execute_Interface.ALU1, execute_Interface.ALU2 } {
					bins ALL_0_ALL_1 = {32'h0000_FFFF};
				}
				
		Cov_opr_all1_zero : coverpoint { execute_Interface.ALU1, execute_Interface.ALU2 } {
					bins ALL_1_ALL_0 = {32'hFFFF_0000};
				}
				
		Cov_opr_all1_all1 : coverpoint { execute_Interface.ALU1, execute_Interface.ALU2 } {
					bins ALL_1_ALL_1 = {32'hFFFF_FFFF};
				}

		Cov_opr_alt01_alt01 : coverpoint { execute_Interface.ALU1, execute_Interface.ALU2 } {
					bins alt01_alt01 = {32'h5555_5555};
				}
		Cov_opr_alt01_alt10 : coverpoint { execute_Interface.ALU1, execute_Interface.ALU2 } {
					bins alt01_alt10 = {32'h5555_AAAA};
				}
		Cov_opr_alt10_alt01 : coverpoint { execute_Interface.ALU1, execute_Interface.ALU2 } {
					bins alt10_alt01 = {32'hAAAA_5555};
				}
		Cov_opr_alt10_alt10 : coverpoint { execute_Interface.ALU1, execute_Interface.ALU2 } {
					bins alt10_alt10 = {32'hAAAA_AAAA};
				}
				
	 	cov_aluin1_pos_neg: coverpoint  execute_Interface.ALU1{
			wildcard bins all_neg_1 = {16'b1???_????_????_????};
			wildcard bins all_pos_1 = {16'b0???_????_????_????};
		}

		cov_aluin2_pos_neg: coverpoint  execute_Interface.ALU2 {
			wildcard bins all_neg_2 = {16'b1???_????_????_????};
			wildcard bins all_pos_2 = {16'b0???_????_????_????};
		}
	
		x_aluin1_aluin2_pos_neg: cross cov_aluin1_pos_neg,cov_aluin2_pos_neg; 


	endgroup : ALU_OPR_cg


covergroup opr_seq_cg;
	 add_seq : coverpoint Instr_dout[15:12]{
		        bins add_add = (ADDX=>ADDX);
		        bins add_and = (ADDX=>ANDX);
		        bins add_not = (ADDX=>NOTX);
		        bins add_ld = (ADDX=>LDX);
			bins add_ldr = (ADDX=>LDRX);
		        bins add_ldi = (ADDX=>LDIX);
		        bins add_lea = (ADDX=>LEAX);
		        bins add_st = (ADDX=>STX);
		        bins add_str = (ADDX=>STRX);
		        bins add_sti = (ADDX=>STIX);
		        bins add_br = (ADDX=>BRX);
		        bins add_jmp = (ADDX=>JMPX);

	  }

	  and_seq : coverpoint Instr_dout[15:12]{
		        bins and_add = (ANDX=>ADDX);
		        bins and_and = (ANDX=>ANDX);
		        bins and_not = (ANDX=>NOTX);
		        bins and_ld = (ANDX=>LDX);
		        bins and_ldr = (ANDX=>LDRX);
		        bins and_ldi = (ANDX=>LDIX);
		        bins and_lea = (ANDX=>LEAX);
		        bins and_st = (ANDX=>STX);
		        bins and_str = (ANDX=>STRX);
		        bins and_sti = (ANDX=>STIX);
		        bins and_br = (ANDX=>BRX);
		        bins and_jmp = (ANDX=>JMPX);

	  }
	
	  not_seq : coverpoint Instr_dout[15:12]{
		        bins not_add = (NOTX=>ADDX);
		        bins not_and = (NOTX=>ANDX);
		        bins not_not = (NOTX=>NOTX);
		        bins not_ld = (NOTX=>LDX);
		        bins not_ldr = (NOTX=>LDRX);
		        bins not_ldi = (NOTX=>LDIX);
		        bins not_lea = (NOTX=>LEAX);
		        bins not_st = (NOTX=>STX);
		        bins not_str = (NOTX=>STRX);
		        bins not_sti = (NOTX=>STIX);
		        bins not_br = (NOTX=>BRX);
		        bins not_jmp = (NOTX=>JMPX);

	  }

	   lea_seq : coverpoint Instr_dout[15:12]{
		        bins lea_add = (LEAX=>ADDX);
		        bins lea_and = (LEAX=>ANDX);
		        bins lea_not = (LEAX=>NOTX);
		        bins lea_ld = (LEAX=>LDX);
		        bins lea_ldr = (LEAX=>LDRX);
		        bins lea_ldi = (LEAX=>LDIX);
		        bins lea_lea = (LEAX=>LEAX);
		        bins lea_st = (LEAX=>STX);
		        bins lea_str = (LEAX=>STRX);
		        bins lea_sti = (LEAX=>STIX);
		        bins lea_br = (LEAX=>BRX);
		        bins lea_jmp = (LEAX=>JMPX);
	  }

	

	endgroup : opr_seq_cg

	covergroup GOLDENREF_test_cg;
		w_control: coverpoint dut_de.cb.goldenref_W_Control {
				ignore_bins bin_3 = {2'd3};
		}
		e_control: coverpoint dut_de.cb.goldenref_E_control {
				bins bin0 = {6'd0};
				bins bin1 = {6'd1};
				bins bin6 = {6'd6};
				bins bin8 = {6'd8};
				bins bin12 = {6'd12};
				bins bin16 = {6'd16};
				bins bin17 = {6'd17};
				bins bin32 = {6'd32};
		}
		mem_control: coverpoint dut_de.goldenref_Mem_Control;
	endgroup : GOLDENREF_test_cg

	
	function new(virtual dut_Probe_WB.WB dut_wb,
				virtual dut_Probe_if.FETCH dut_if,
				virtual dut_Probe_DE.DECODE dut_de,
				virtual executeInterface execute_Interface,
				virtual memAccess_if mem_io,
				virtual dut_Probe_CON dut_Con,
				virtual LC3_io.TB top_io);
		
		this.dut_wb = dut_wb;
		this.dut_if = dut_if;
		this.dut_de = dut_de;
		this.dut_Con = dut_Con;
		this.execute_Interface = execute_Interface;
		this.mem_io = mem_io;
		this.top_io = top_io;
		
		ALU_OPR_cg = new();
		opr_seq_cg = new();
		MEM_OPR_cg = new();
		GOLDENREF_test_cg = new();
	endfunction : new

	

	task sample(logic [15:0] Instr_dout);
		this.Instr_dout = Instr_dout;
		ALU_OPR_cg.sample();
		opr_seq_cg.sample();
		MEM_OPR_cg.sample();
		GOLDENREF_test_cg.sample();
	endtask : sample
endclass : Coverage
`endif
