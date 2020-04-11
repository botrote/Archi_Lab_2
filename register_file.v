
module register_file (
	intput [2:0] read_register_1, read_register_2,
	input [31:0] write_data,
	input [2:0] write_register,
	input signal_RegWrite,
	input clk,
	input reset_n,

	output reg [31:0] read_data_1, read_data_2,
);

	reg [`WORD_SIZE-1:0] Registers [0:3]

	assign read_data_1 = Registers[read_register_1];
	assign read_data_2 = Registers[read_register_2];

	integer i;
    always @ (posedge clk or posedge reset_n) begin
    	if(reset_n)
    		for(i = 0; i < 4; i = i + 1)
    			Registers <= 0;
    	else if(signal_RegWrite && write_register != 0)
    		Registers[write_register] <= write_data;
    end

endmodule