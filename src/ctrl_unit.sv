// Control Unit

`include "riscv.svh"

`include "alu_pkg.svh"
`include "cfu_pkg.svh"

module ctrl_unit 
    import alu_pkg::aluop_t;
    import cfu_pkg::cfuop_t;
    import alu_pkg::gen_aluop_f;
    import cfu_pkg::gen_cfuop_f;
#(
) (
    input  logic [6:0] opcode,
    input  logic [6:0] funct7,
    input  logic [2:0] funct3,
    output aluop_t     aluop,
    output cfuop_t     cfuop,
    output logic       rf_en,
    output logic       dm_en,
    output logic       opr_b_sel,
    output logic [1:0] wb_sel
);
    // micro op generation
    assign aluop = gen_aluop_f(opcode, funct7, funct3);
    assign cfuop = gen_cfuop_f(opcode, funct3);

    // control signals
    always_comb
    begin
        case(opcode)
            `OPCODE_OP:
            begin
                rf_en     = 1'b1;
                dm_en     = 1'b0;
                opr_b_sel = 1'b0;
                wb_sel    = 2'b00;
            end
            `OPCODE_OPIMM:
            begin
                rf_en     = 1'b1;
                dm_en     = 1'b0;
                opr_b_sel = 1'b1; 
                wb_sel    = 2'b00;
            end
            `OPCODE_LOAD:
            begin
                rf_en     = 1'b1;
                dm_en     = 1'b0;
                opr_b_sel = 1'b1; 
                wb_sel    = 2'b01;
            end
            `OPCODE_STORE:
            begin
                rf_en     = 1'b0;
                dm_en     = 1'b1;
                opr_b_sel = 1'b1;
                wb_sel    = 2'b00;
            end
            default:
            begin
                rf_en     = 1'b0;
                dm_en     = 1'b0;
                opr_b_sel = 1'b0;
                wb_sel    = 2'b00;
            end
        endcase
    end

endmodule: ctrl_unit
