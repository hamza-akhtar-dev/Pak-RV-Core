`ifndef EX_STAGE_PKG_SVH

`define EX_STAGE_PKG_SVH

    `include "alu_pkg.svh"
    `include "cfu_pkg.svh"
    `include "lsu_pkg.svh"

    package ex_stage_pkg;

        import alu_pkg::aluop_t;
        import cfu_pkg::cfuop_t;
        import lsu_pkg::lsuop_t;

        typedef struct packed
        {
            logic [ 4:0] rs1;
            logic [ 4:0] rs2;
            logic [ 4:0] rd;
            logic [31:0] opr_a;
            logic [31:0] opr_b;
            logic [31:0] imm;
            logic [31:0] zimm;
            logic [31:0] pc;
            logic [31:0] pc4;
            // ctrl
            aluop_t      aluop;
            cfuop_t      cfuop;
            lsuop_t      lsuop;
            csrop_t      csrop;
            logic        rf_en;
            logic        dm_wr_en;
            logic        dm_rd_en;
            logic        csr_wr_en;
            logic        opr_a_sel;
            logic        opr_b_sel;
            logic [ 1:0] wb_sel;

            // from branch predictor
            logic        is_conditional_branch;
            logic        is_jalr;
            logic        is_jal;
            logic        predict_taken;
            logic [31:0] predict_pc;
        } ex_stage_in_t;

        typedef struct packed
        {
            logic        rf_en;
            logic [ 4:0] rd;
            logic [31:0] opr_res;
            logic [31:0] pc4;
            logic        is_jal;
        } ex_stage_in_frm_mem_t;

        typedef struct packed
        {
            logic        rf_en;
            logic [ 4:0] rd;
            logic [31:0] wb_data;
        } ex_stage_in_frm_wb_t;

        typedef struct packed
        {
            logic        [ 4:0] rd;
            logic signed [31:0] opr_a;
            logic signed [31:0] opr_b;
            logic        [31:0] imm;
            logic        [31:0] zimm;
            logic signed [31:0] opr_res;
            logic        [31:0] pc4;
            // ctrl
            lsuop_t             lsuop;
            csrop_t             csrop;
            logic               rf_en;
            logic               dm_wr_en;
            logic               dm_rd_en;
            logic               csr_wr_en;
            logic        [ 1:0] wb_sel;
            logic               is_jal;
        } ex_stage_out_t;

        typedef struct packed 
        {
            logic               br_taken;
            logic signed [31:0] br_target;
        } ex_cfu_out_t;
        
    endpackage

`endif
