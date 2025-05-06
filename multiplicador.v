module Multiplier #(
    parameter N = 4
) (
    input wire clk,
    input wire rst_n,

    input wire start,
    output reg ready,

    input wire [N-1:0] multiplier,
    input wire [N-1:0] multiplicand,
    output reg [2*N-1:0] product
);

    // Registradores internos
    reg [N-1:0] reg_multiplier;
    reg [2*N-1:0] reg_multiplicand;
    reg [2*N-1:0] acc;
    reg [$clog2(N+1)-1:0] count;
    reg busy;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            acc <= 0;
            reg_multiplier <= 0;
            reg_multiplicand <= 0;
            count <= 0;
            product <= 0;
            ready <= 0;
            busy <= 0;
        end else begin
            // Início da multiplicação
            if (start && !busy) begin
                acc <= 0;
                reg_multiplier <= multiplier;
                reg_multiplicand <= { {N{1'b0}}, multiplicand }; // ajusta para 2N bits
                count <= N;
                busy <= 1;
                ready <= 0;
            end

            else if (busy) begin
                if (reg_multiplier[0]) begin
                    acc <= acc + reg_multiplicand;
                end
                reg_multiplicand <= reg_multiplicand << 1;
                reg_multiplier <= reg_multiplier >> 1;
                count <= count - 1;

                if (count == 1) begin
                    product <= acc + (reg_multiplier[0] ? reg_multiplicand : 0);
                    ready <= 1;
                    busy <= 0;
                end
            end

            else begin
                ready <= 0; // mantém ready alto por apenas 1 ciclo
            end
        end
    end
endmodule
