// This file is a golden reference file that states the operation of the fetch block as per the specification document. The values that are given as golden references
// will later be compared with the actual DUT signals that are the outputs of the device under test. The discrepancies in these values gives the 
// verification result for each output of the given block.
////////////////
class goldenref_fetch;
virtual dut_Probe_if.FETCH dutprobeif;

function new(virtual dut_Probe_if.FETCH dutprobeif);
	this.dutprobeif=dutprobeif;
endfunction

task run();
	fork
	begin
		forever
		begin
			@dutprobeif.fetch_enable_fetch;
			if(dutprobeif.fetch_enable_fetch) dutprobeif.goldenref_instrmem_rd <= 1'b1;
			else dutprobeif.goldenref_instrmem_rd <= 1'bz; // ??????? although I can set the conditions, I can't get the given bug
		end
	end
	begin
		forever 
		begin
			@dutprobeif.cb;
			if(dutprobeif.fetch_reset) //reset = 1
			begin
				dutprobeif.goldenref_pc <= 16'h3000; //starting value for PC as per the design specification	
				dutprobeif.goldenref_npc <= dutprobeif.goldenref_pc+1; // npc = pc + 1
			end
			else // reset = 0
			begin
				if(dutprobeif.cb.fetch_enable_updatePC) // enable_updatePC = 1 
				begin
					if(dutprobeif.cb.fetch_br_taken) //a control signal has been encountered and hence the next instruction to be executed does not come from PC+1 
					begin
						dutprobeif.goldenref_pc <= dutprobeif.fetch_taddr;
						dutprobeif.goldenref_npc <= dutprobeif.goldenref_pc+1;
					end
					else //br_taken = 0
					begin
						dutprobeif.goldenref_pc <= dutprobeif.cb.goldenref_npc;
						dutprobeif.goldenref_npc <= dutprobeif.cb.goldenref_pc+1;
					end	
              			end
				else // enable_updatePC = 0
				begin
					dutprobeif.goldenref_pc <= dutprobeif.cb.goldenref_pc;
					dutprobeif.goldenref_npc <= dutprobeif.cb.goldenref_pc+1;
				end
				
			end
                        $display("********************* Verifying the Fetch Block of LC3 *******************");
			check_fetch_pc(); // Task to verify pc output signal
                        check_fetch_npc(); // Task to verify npc_out output signal
			check_fetch_instrmem(); // Task to verify instrmem_rd output signal
     			$display($time,"reset = %b | enable_updatePC = %b |  br_taken= %b | enable_fetch = %b | instrmem_rd = %b", dutprobeif.fetch_reset, dutprobeif.cb.fetch_enable_updatePC, dutprobeif.cb.fetch_br_taken, dutprobeif.fetch_enable_fetch, dutprobeif.cb.fetch_instrmem_rd );
		        $display("********************* Verification Done **********************************");
   			$display("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
		end
	end
	join
endtask : run

task check_fetch_pc();
		if(dutprobeif.cb.goldenref_pc !== dutprobeif.fetch_pc)
		$display($time,"FETCH BUG: Golden reference value of pc %h and DUT value of pc %h do not match ", dutprobeif.cb.goldenref_pc, dutprobeif.fetch_pc );
               
endtask : check_fetch_pc

task check_fetch_npc();
                if(dutprobeif.cb.goldenref_npc !== dutprobeif.fetch_npc)
		$display($time,"FETCH BUG: Golden reference value of npc_out %h and DUT value of npc_out %h do not match", dutprobeif.cb.goldenref_npc, dutprobeif.fetch_npc);
               
endtask : check_fetch_npc
	
task check_fetch_instrmem();
		if(dutprobeif.goldenref_instrmem_rd !== dutprobeif.cb.fetch_instrmem_rd)
		  $display($time,"FETCH BUG: Golden reference value of instrmem_rd %h and DUT value of instrmem_rd %h do not match", dutprobeif.goldenref_instrmem_rd, dutprobeif.cb.fetch_instrmem_rd);
                
endtask : check_fetch_instrmem
endclass: goldenref_fetch


