// This file is a golden reference file that states the operation of the execute block as per the specification document. The values that are given as golden references
// will later be compared with the actual DUT signals that are the outputs of the device under test. The discrepancies in these values gives the verification result for 
// each output of the given block.
////////////
class goldenref_execute;
virtual executeInterface execute_Interface;

function new (virtual executeInterface execute_Interface);
	this.execute_Interface = execute_Interface;
endfunction : new

//Input internal signals for the ALU module
logic [15:0] ALU1;
logic [15:0] ALU2;

//Extension internal signals
logic [15:0] imm5;
logic [15:0] offset6;
logic [15:0] offset9;
logic [15:0] offset11;

//E_Control input signals
logic [1:0] pcselect1;
logic pcselect2;
logic op2select;
logic [1:0] alu_control;
logic [15:0] pcselect1_out;
logic [15:0] pcselect2_out;
logic [15:0] op2select_out;
 
task run();
	//Extension module signals
	imm5 =  { {11{execute_Interface.IR[4]}} , execute_Interface.IR[4:0]};
	offset6 = { {10{execute_Interface.IR[5]}} , execute_Interface.IR[5:0]};
	offset9 = { {7{execute_Interface.IR[8]}} , execute_Interface.IR[8:0]};
	offset11 = { {5{execute_Interface.IR[10]}} , execute_Interface.IR[10:0]};
	//E_Control signals {alu_control + Pcselect1 + pcselct2 + op2select}
	pcselect1 = execute_Interface.E_Control[3:2];
	alu_control = execute_Interface.E_Control[5:4];
	pcselect2 = execute_Interface.E_Control[1];
	op2select = execute_Interface.E_Control[0];

	case(pcselect1)
		3: pcselect1_out = 0;
		2: pcselect1_out = offset6;
		1: pcselect1_out = offset9;
		0: pcselect1_out = offset11;
	endcase

	case(pcselect2)
		1: pcselect2_out = execute_Interface.npc;
		0: pcselect2_out = execute_Interface.VSR1;
	endcase

	case(op2select)
		1: op2select_out = execute_Interface.VSR2;
		0: op2select_out = imm5;
	endcase
	fork
	forever 
	begin
		@(posedge execute_Interface.clock);
		#1
		//checker_execute_sync();
			if (execute_Interface.reset == 1)
			begin
				execute_Interface.check_aluout = 0; execute_Interface.check_pcout = 0; execute_Interface.check_dr = 0; execute_Interface.check_sr1 = 0; execute_Interface.check_sr2 = 0;
				execute_Interface.check_NZP = 0; execute_Interface.check_M_Data = 0; execute_Interface.check_IR_Exec = 0; execute_Interface.check_Mem_Control_out = 0; execute_Interface.check_W_Control_out = 0;
			end
			#5
			if (execute_Interface.reset == 0)
			
			begin

			 //sr1 is the address for first source register 
				execute_Interface.check_sr1 = execute_Interface.IR[8:6];

       			 //sr2 is the address for second source register
				execute_Interface.check_sr2 = 3'b0;
			//For ALU instructions	
				if ( execute_Interface.IR[15:12] == 4'b0101 || execute_Interface.IR[15:12] == 4'b0001 || execute_Interface.IR[15:12] == 4'b1001 )
					execute_Interface.check_sr2 = execute_Interface.IR[2:0];

			end
			#5
			if ( execute_Interface.reset == 0 && execute_Interface.enable_execute == 1 )
			
			begin

			//Golden reference value for W_Control_out
				execute_Interface.check_W_Control_out = execute_Interface.W_Control_in;
	

			//aluout : Check for bypass conditions from ALU and memory.


			ALU1 = execute_Interface.VSR1;

			//Two conditions for VSR2
			if (execute_Interface.IR[5] == 0)
				ALU2 = execute_Interface.VSR2;
			else
				ALU2 = imm5;

			//ALU ops
			if (execute_Interface.IR[15:12] == 4'b0101  || execute_Interface.IR[15:12] == 4'b0001  || execute_Interface.IR[15:12] == 4'b1001)
			begin

			// computing Aluout based on the values of ALU1, ALU2 and E_control[5:4]
				if (execute_Interface.E_Control[5:4] == 2'b00)
					execute_Interface.check_aluout = ALU1 + ALU2;
				else if (execute_Interface.E_Control[5:4] == 2'b01)
					execute_Interface.check_aluout = ALU1 & ALU2;
				else if (execute_Interface.E_Control[5:4] == 2'b10)
					execute_Interface.check_aluout = ~(ALU1);

				execute_Interface.check_pcout = execute_Interface.check_aluout;

			end

			if ( execute_Interface.IR[15:12] == 4'b1110 )
			begin

			//check_pcout

				if (execute_Interface.E_Control[3:1] == 3'b000)

					execute_Interface.check_pcout = ALU1 + offset11;    

				if (execute_Interface.E_Control[3:1] == 3'b001)

					execute_Interface.check_pcout = execute_Interface.npc + offset11;

				if (execute_Interface.E_Control[3:1] == 3'b010)

					execute_Interface.check_pcout = ALU1 + offset9;

				if (execute_Interface.E_Control[3:1] == 3'b011)

					execute_Interface.check_pcout = execute_Interface.npc + offset9;

				if (execute_Interface.E_Control[3:1] == 3'b100)

					execute_Interface.check_pcout = ALU1 + offset6;

				if (execute_Interface.E_Control[3:1] == 3'b101)

					execute_Interface.check_pcout = execute_Interface.npc + offset6;

				if (execute_Interface.E_Control[3:1] == 3'b110)

					execute_Interface.check_pcout = ALU1;

				if (execute_Interface.E_Control[3:1] == 3'b111)

					execute_Interface.check_pcout = execute_Interface.npc;

				if ( execute_Interface.IR[15:12] == 4'b1110 ) 	
					execute_Interface.check_pcout = execute_Interface.check_pcout - 1;

			execute_Interface.check_aluout = execute_Interface.check_pcout;
			end

			//Destination Register golden reference value
			execute_Interface.check_dr = 3'b0;
			if ( execute_Interface.IR[15:12] == 4'b0101  || execute_Interface.IR[15:12] == 4'b0001 || execute_Interface.IR[15:12] == 4'b1001 || execute_Interface.IR[15:12] == 4'b1110 )
				execute_Interface.check_dr = execute_Interface.IR[11:9];

			//IR_Exec
			execute_Interface.check_IR_Exec = execute_Interface.IR;

		
 


		end
		$display("********************* Verifying the Execute Block of LC3 ******************");
		checker_execute_sync();
		checker_execute_async();
		$display("clock=%b | W_Control_out = %b | reset=%b | enable_execute=%b ", execute_Interface.clock, execute_Interface.W_Control_out, execute_Interface.reset, execute_Interface.enable_execute);	
		$display("E_Control=%b | sr1 = %b | sr2=%b | dr=%b | IR= %h", execute_Interface.E_Control, execute_Interface.sr1, execute_Interface.sr2, execute_Interface.dr, execute_Interface.IR);
		$display("********************* Verification Done **********************************");
		$display("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
	
	end
	join
endtask : run	

 task  checker_execute_sync();
	
	if(execute_Interface.W_Control_out != execute_Interface.check_W_Control_out)
		$display($time,"EXECUTE BUG: Golden reference value of W_Control_out %b and DUT value of W_Control_out %b do not match", execute_Interface.check_W_Control_out, execute_Interface.W_Control_out);
	
	
	if (execute_Interface.aluout != execute_Interface.check_aluout)
		$display($time,"EXECUTE BUG: Golden reference value of aluout %b and DUT value of aluout %b do not match", execute_Interface.check_aluout, execute_Interface.aluout);
	


	if (execute_Interface.dr != execute_Interface.check_dr)
		$display($time,"EXECUTE BUG: Golden reference value of dr %b and DUT value of dr %b do not match", execute_Interface.check_dr, execute_Interface.dr);
	

	
	if (execute_Interface.IR_Exec != execute_Interface.check_IR_Exec)
		$display($time,"EXECUTE BUG: Golden reference value of IR_Exec %h and DUT value of IR_Exec %h do not match", execute_Interface.check_IR_Exec, execute_Interface.IR_Exec);
	


	if (execute_Interface.pcout != execute_Interface.check_pcout)
		$display($time,"EXECUTE BUG: Golden reference value of pcout %h and DUT value of pcout %h do not match", execute_Interface.check_pcout, execute_Interface.pcout);
	


     if (execute_Interface.reset == 1 )
     begin
	if (execute_Interface.sr1 != execute_Interface.check_sr1)
		$display($time,"EXECUTE BUG: Golden reference value of sr1 %b and DUT value of sr1 %b do not match", execute_Interface.check_sr1, execute_Interface.sr1);
	

	if (execute_Interface.sr2 != execute_Interface.check_sr2)
		$display($time,"EXECUTE BUG: Golden reference value of sr2 %b and DUT value of sr2 %b do not match", execute_Interface.check_sr2, execute_Interface.sr2);
	
	end
endtask : checker_execute_sync

task checker_execute_async();
	
	if (execute_Interface.sr1 != execute_Interface.check_sr1)
		$display($time,"EXECUTE BUG: Golden reference value of sr1 %h and DUT value of sr1 %h do not match", execute_Interface.check_sr1, execute_Interface.sr1);
	      


	if (execute_Interface.sr2 != execute_Interface.check_sr2)
		$display($time,"EXECUTE BUG: Golden reference value of sr2 %h and DUT value of sr2 %h do not match", execute_Interface.check_sr2, execute_Interface.sr2);
	
endtask : checker_execute_async
endclass:goldenref_execute


