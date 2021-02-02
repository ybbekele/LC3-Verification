// This file is a golden reference file that states the operation of the Control block as per the specification document. The values that are given as golden references
// will later be compared with the actual DUT signals that are the outputs of the device under test. The discrepancies in these values gives the verification result for 
// each output of the given block.
////////////

class goldenref_control;

	virtual dut_Probe_CON C_int;
	int flag_reset;
	int flag_br_taken;
	int flag_next;
	int flag_go_to_next;
	int flag_writeback;
	int branch_nottaken;
function new(virtual dut_Probe_CON C_int);
begin
	this.C_int = C_int;
	this.flag_reset = 0;
	this.flag_br_taken=0;
	this.branch_nottaken=0;
	this.flag_go_to_next=0;
	this.flag_writeback=0;
	
end
endfunction:new

	
task run();
forever
		begin
			@(posedge C_int.control_clk);
			#2
			if(C_int.control_reset == 1 && flag_reset == 0)
			begin
				
				C_int.goldenref_enable_updatePC = 0;
				C_int.goldenref_enable_fetch = 0;
				C_int.goldenref_enable_decode = 0;
				C_int.goldenref_enable_execute = 0;
				C_int.goldenref_enable_writeback = 0;
				C_int.goldenref_br_taken = 0;
				@(posedge C_int.control_clk);
				C_int.goldenref_enable_fetch = 1;
				C_int.goldenref_br_taken = 0;
				flag_reset = 2;
			end
			else
			begin
				
				if(flag_reset == 1)
				begin
					flag_reset = 2;
				end
				else if(flag_reset == 2)
				begin
					
					
					flag_reset = 3;
				end
				else if(flag_reset == 3)
				begin
					C_int.goldenref_enable_updatePC = 1;
					
					flag_reset = 4;
				end
				else if(flag_reset == 4)
				begin
					C_int.goldenref_enable_decode = 1;
					flag_reset = 5;
				end
				else if(flag_reset == 5)
				begin
					C_int.goldenref_enable_execute = 1;
					flag_reset = 6;
				end
				else if(flag_reset ==6)
				begin
					C_int.goldenref_enable_writeback = 1;
					flag_reset = 0;
				end
				
				
								
			end		
			$display("********************* Verifying the Controller of LC3 ******************");
			control_checker();
			$display($time,"reset = %b | enable updatePC = %b | enable fetch= %b | enable decode = %b | enable execute = %b | enabel writeback = %b | complete instruction = %b", C_int.control_reset, C_int.control_enable_updatePC, C_int.control_enable_fetch, C_int.control_enable_decode, C_int.control_enable_execute, C_int.control_enable_writeback, C_int.control_complete_instr);
			$display("********************* Verification Done **********************************");
			$display("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
end

endtask

task control_checker();
	
	
		
		if(C_int.goldenref_enable_updatePC !== C_int.control_enable_updatePC)
			$display($time,"CONTROLLER BUG: Golden reference value of enable_updatePC %b and DUT value of enable_updatePC %b do not match ",C_int.goldenref_enable_updatePC,C_int.control_enable_updatePC);
			
		if(C_int.goldenref_enable_fetch !== C_int.control_enable_fetch)
			$display($time,"CONTROLLER BUG: Golden reference value of enable_fetch %b and DUT value of enable_fetch %b do not match",C_int.goldenref_enable_fetch,C_int.control_enable_fetch);
			
		if(C_int.goldenref_enable_decode !== C_int.control_enable_decode)
			$display($time,"CONTROLLER BUG: Golden reference value of enable_decode %b and DUT value of enable_decode %b do not match", C_int.goldenref_enable_decode, C_int.control_enable_decode);
			
		if(C_int.goldenref_enable_execute !== C_int.control_enable_execute)
			$display($time,"CONTROLLER BUG: Golden reference value of enable_execute %b and DUT value of enable_execute %b do not match", C_int.goldenref_enable_execute, C_int.control_enable_execute);
			
		if(C_int.goldenref_enable_writeback !== C_int.control_enable_writeback)
			$display($time,"CONTROLLER BUG: Golden reference value of enable_writeback %b and DUT value of enable_writeback %b do not match", C_int.goldenref_enable_writeback, C_int.control_enable_writeback);
			
		
endtask: control_checker

endclass: goldenref_control
