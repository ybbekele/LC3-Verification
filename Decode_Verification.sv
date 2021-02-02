// This file is a golden reference file that states the operation of the decode block as per the specification document. The values that are given as golden references
// will later be compared with the actual DUT signals that are the outputs of the device under test. The discrepancies in these values gives the verification result for 
// each output of the given block.
////////////

class goldenref_decode;
virtual dut_Probe_DE.DECODE dut_de;

function new(virtual dut_Probe_DE.DECODE dut_de);
this.dut_de = dut_de;
endfunction

task run();
forever begin
@dut_de.cb;
	if(dut_de.decode_reset) // if reset = 1
		begin
		dut_de.goldenref_IR <= 16'h0000; //Initial value for Instruction Register (from the given IMem_5.dat file)
		dut_de.goldenref_npc_out<=16'h0000; //Initial value for npc_out (NOT the fetch block npc_out initial value which is connected through npc_in as reset = 1)
		dut_de.goldenref_E_control<=6'b000000; //Initial value for E_Control
		dut_de.goldenref_W_Control<=2'b00; //Intial value of W_Control
		end
	else // if reset = 0
	begin
	if(dut_de.cb.decode_enable_decode) // enable_decode is high thus the block starts operation here
		begin
		dut_de.goldenref_IR<=dut_de.cb.decode_Instr_dout;
		dut_de.goldenref_npc_out<=dut_de.cb.decode_npc_in;
       //W_Control output golden reference
		if(dut_de.cb.decode_Instr_dout[15:12]==4'b0001 || dut_de.cb.decode_Instr_dout[15:12]==4'b0101 || dut_de.cb.decode_Instr_dout[15:12]==4'b1001)
			dut_de.goldenref_W_Control<=2'b00;
		if(dut_de.cb.decode_Instr_dout[15:12]==4'b1110)
			dut_de.goldenref_W_Control<=2'b10;
      //E_Control output golden reference
	        if(dut_de.cb.decode_Instr_dout[15:12]== 4'b0001 && dut_de.cb.decode_Instr_dout[5]==1'b0)
			dut_de.goldenref_E_control<=6'b000001;
		else if (dut_de.cb.decode_Instr_dout[15:12]==4'b0001 && dut_de.cb.decode_Instr_dout[5]==1'b1)
			dut_de.goldenref_E_control<=6'b000000;		
		else if (dut_de.cb.decode_Instr_dout[15:12]== 4'b0101&& dut_de.cb.decode_Instr_dout[5]==1'b0)
			dut_de.goldenref_E_control<=6'b010001;
		else if (dut_de.cb.decode_Instr_dout[15:12]==4'b0101 && dut_de.cb.decode_Instr_dout[5]==1'b1)
			dut_de.goldenref_E_control<=6'b010000;
		else if (dut_de.cb.decode_Instr_dout[15:12]==4'b1001)
			dut_de.goldenref_E_control<=6'b100000;   
		else if (dut_de.cb.decode_Instr_dout[15:12]==4'b1110)
			dut_de.goldenref_E_control<=6'b000110;
		end
	else // enable_decode = 0
		begin
		dut_de.goldenref_IR<=dut_de.cb.goldenref_IR;
		dut_de.goldenref_npc_out<=dut_de.cb.goldenref_npc_out;
		dut_de.goldenref_E_control<=dut_de.cb.goldenref_E_control;
		dut_de.goldenref_W_Control<=dut_de.cb.goldenref_W_Control;
		end
	end	
$display("********************* Verifying the Decode Block of LC3 ******************");
check_decode();
$display($time,"reset = %h | enable_decode = %h | Instr_dout= %h | W_Control = %b | E_Control = %b | decode_IR[15:12] = %b", dut_de.decode_reset, dut_de.cb.decode_enable_decode, dut_de.cb.decode_Instr_dout, dut_de.cb.goldenref_W_Control, dut_de.cb.goldenref_E_control, dut_de.cb.goldenref_IR[15:12]);
$display("********************* Verification Done **********************************");
$display("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
end
endtask : run

task  check_decode();

	if(dut_de.cb.goldenref_npc_out !== dut_de.decode_npc_out && dut_de.decode_reset==0)
		$display($time,"DECODE BUG: Golden reference value of npc_out %h and DUT value of npc_out %h do not match", dut_de.cb.goldenref_npc_out, dut_de.decode_npc_out);
            
	if(dut_de.cb.goldenref_W_Control !== dut_de.decode_W_control&& dut_de.decode_reset==0)
		$display($time,"DECODE BUG: Golden reference value of W_CONTROL %b and DUT value of W_CONTROL %b do not match", dut_de.cb.goldenref_W_Control, dut_de.decode_W_control );
	            		
	if(dut_de.cb.goldenref_E_control !== dut_de.decode_E_control && dut_de.decode_reset==0)
		$display($time,"DECODE BUG: Golden reference value of E_CONTROL %b and DUT value of E_CONTROL %b do not match", dut_de.cb.goldenref_E_control, dut_de.decode_E_control);
	    
   	if(dut_de.cb.goldenref_IR !== dut_de.decode_IR && dut_de.decode_reset==0)
		$display($time,"DECODE BUG: Golden reference value of IR %b and DUT value of IR %b do not match", dut_de.cb.goldenref_IR, dut_de.decode_IR );	
	else 
    		$display($time,"DECODE BUG: Golden reference value of IR %b and DUT value of IR %b ", dut_de.cb.goldenref_IR, dut_de.decode_IR);
endtask : check_decode

endclass:goldenref_decode













