# LC3-Verification
This project deals with the verification of the data and control path of an unpipelined LC-3 microcontroller with a reduced instruction set. <br/>
The Design Under Test (DUT) has 4 blocks namely fetch, decode, execute and writeback. For this project verification of these blocks and a controller component which controls the overall operation of the DUT. <br/> 
Although the LC-3 microcontroller supports many instructions in its instruction set, in this project only ALU (ADD, AND, NOT) and one of the memory operations Load Effective Address (LEA) instructions are considered. <br/> 
This report gives the verification results in terms of bugs found in the mentioned blocks and the controller component. For the verification task the provided instruction sets with the DUT are used. The BUG X/XX are the bug numbers as per the given bug documentation which are also confirmed by this project.
