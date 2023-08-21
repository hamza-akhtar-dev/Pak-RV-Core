// Parameterized Arithmetic Logic Unit

`include "alu_pkg.svh"

module alu
    import alu_pkg::aluop_t;
# (
    parameter DATA_WIDTH = 32
) (
    input  aluop_t                       aluop,
    input  logic signed [DATA_WIDTH-1:0] opr_a,
    input  logic signed [DATA_WIDTH-1:0] opr_b,
    output logic signed [DATA_WIDTH-1:0] opr_result
);
    always_comb
    begin
        case(aluop)
            alu_pkg::ADD:  opr_result = opr_a + opr_b;
            alu_pkg::SUB:  opr_result = opr_a - opr_b;
            alu_pkg::AND:  opr_result = opr_a & opr_b;
            alu_pkg::OR:   opr_result = opr_a | opr_b;
            alu_pkg::XOR:  opr_result = opr_a ^ opr_b;
            alu_pkg::SLL:  opr_result = opr_a << opr_b;
            alu_pkg::SRL:  opr_result = opr_a >> opr_b;
            alu_pkg::SRA:  opr_result = opr_a >>> opr_b;
            alu_pkg::SLT:  opr_result = opr_a < opr_b ? 1 : 0;
            alu_pkg::SLTU: opr_result = $unsigned(opr_a) < $unsigned(opr_b) ? 1 : 0;
            default: opr_result = 0;
        endcase
    end

endmodule