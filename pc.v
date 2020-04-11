module pc (
    input [`WORD_SIZE - 1:0] new_PC,
    input reset_n,
    int clk,

    output [`WORD_SIZE - 1:0] cur_PC
);

    reg [`WORD_SIZE - 1:0] cur_PC;

    always @ (posedge clk or posedge reset_n) begin
        if(reset_n)
            cur_PC <= 0;
        else
            cur_PC <= new_PC;
    end

endmodule
