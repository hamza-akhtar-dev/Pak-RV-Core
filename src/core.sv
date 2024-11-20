// Core

`include "if_stage_pkg.svh"
`include "id_stage_pkg.svh"
`include "ex_stage_pkg.svh"
`include "mem_stage_pkg.svh"
`include "wb_stage_pkg.svh"

module core 
    import if_stage_pkg ::if_stage_in_t;
    import id_stage_pkg ::id_stage_in_t;
    import ex_stage_pkg ::ex_stage_in_t;
    import mem_stage_pkg::mem_stage_in_t;
    import wb_stage_pkg ::wb_stage_in_t;
    import if_stage_pkg ::if_stage_out_t;
    import id_stage_pkg ::id_stage_out_t;
    import ex_stage_pkg ::ex_stage_out_t;
    import mem_stage_pkg::mem_stage_out_t;
    import wb_stage_pkg ::wb_stage_out_t;

    import id_stage_pkg ::id_stage_in_frm_ex_t;
    import id_stage_pkg ::id_hdu_out_t;
    import ex_stage_pkg ::ex_cfu_out_t;
    import ex_stage_pkg ::ex_stage_in_frm_mem_t;
    import ex_stage_pkg ::ex_stage_in_frm_wb_t;
# (
    parameter  DATA_WIDTH                = 32,
    parameter  IMEM_SZ_IN_KB             = 1,
    parameter  DMEM_SZ_IN_KB             = 1,
    parameter  SUPPORT_BRANCH_PREDICTION = 1
) (
    input  logic                    clk,
    input  logic                    arst_n,
    output logic [DATA_WIDTH-1:0]   pc,
    input  logic [DATA_WIDTH-1:0]   inst_in,

    // data memory related ports to/from shared memory
    input  logic [DATA_WIDTH-1:0]   core_in_mem_data_out,
    output logic [DATA_WIDTH-1:0]   core_out_mem_addr_in,
    output logic [DATA_WIDTH-1:0]   core_out_mem_data_in,
    output logic                    core_out_mem_we_in,
    output logic [DATA_WIDTH/8-1:0] core_out_mem_mask_in
);
    // stage signals
    if_stage_in_t  if_stage_in;
    if_stage_out_t if_stage_out;

    id_stage_in_t  id_stage_in;
    id_stage_out_t id_stage_out;

    ex_stage_in_t  ex_stage_in;
    ex_stage_out_t ex_stage_out;

    mem_stage_in_t  mem_stage_in;
    mem_stage_out_t mem_stage_out;

    wb_stage_in_t  wb_stage_in;
    wb_stage_out_t wb_stage_out;

    // combinational connection signals
    id_stage_in_frm_ex_t  id_stage_in_frm_ex;
    id_hdu_out_t          id_hdu_out;
    ex_cfu_out_t          ex_cfu_out;
    ex_stage_in_frm_mem_t ex_stage_in_frm_mem;
    ex_stage_in_frm_wb_t  ex_stage_in_frm_wb;
    logic                 misprediction_frm_ex;

    logic [DATA_WIDTH-1:0] pc4;

    // stage instantiations
    if_stage # (
        .DATA_WIDTH                ( DATA_WIDTH                         ),
        .IMEM_SZ_IN_KB             ( IMEM_SZ_IN_KB                      ),
        .SUPPORT_BRANCH_PREDICTION ( SUPPORT_BRANCH_PREDICTION          )
    ) i_if_stage (
        .clk                       ( clk                                ),
        .arst_n                    ( arst_n                             ),
        .if_stage_in               ( if_stage_in                        ),
        .if_stage_out              ( if_stage_out                       )
    );

    assign pc = if_stage_out.pc;

    id_stage #(
        .DATA_WIDTH         ( DATA_WIDTH         )
    ) i_id_stage (
        .clk                ( clk                ),
        .arst_n             ( arst_n             ),
        .wb_in              ( wb_stage_out       ), // writeback interface
        .id_stage_in        ( id_stage_in        ),
        .id_stage_in_frm_ex ( id_stage_in_frm_ex ),
        .id_stage_out       ( id_stage_out       ),
        .id_hdu_out         ( id_hdu_out         )
    );

    ex_stage #(
        .DATA_WIDTH          ( DATA_WIDTH           )
    ) i_ex_stage (
        .ex_stage_in         ( ex_stage_in          ),
        .ex_stage_in_frm_mem ( ex_stage_in_frm_mem  ),
        .ex_stage_in_frm_wb  ( ex_stage_in_frm_wb   ),
        .ex_stage_out        ( ex_stage_out         ),
        .misprediction       ( misprediction_frm_ex ),
        .ex_cfu_out          ( ex_cfu_out           )
    );

    mem_stage #(
        .DATA_WIDTH    ( DATA_WIDTH           )
    ) i_mem_stage (
        .clk           ( clk                  ),
        .arst_n        ( arst_n               ),
        .mem_data_in   ( core_in_mem_data_out ),
        .mem_stage_in  ( mem_stage_in         ),

        // this input is brought here because
        // if given in mem_stage_in, then should have driven from exe_stage_out;
        // implies one cycles delay because of pipeline
        // could a better solution of it
        .mem_stage_out ( mem_stage_out        )
    );

    wb_stage #(
    ) i_wb_stage (
        .wb_stage_in  (wb_stage_in  ),
        .wb_stage_out (wb_stage_out )
    );

    // ports going to shared memory
    assign core_out_mem_addr_in = mem_stage_out.core_out_mem_addr_in;
    assign core_out_mem_data_in = mem_stage_out.core_out_mem_data_in;
    assign core_out_mem_we_in   = mem_stage_in.dm_en;
    assign core_out_mem_mask_in = mem_stage_out.mask;

    // combinational connections
    always_comb
    begin
        if_stage_in.instruction     = inst_in;
        if_stage_in.br_taken        = ex_cfu_out.br_taken;
        if_stage_in.br_target       = ex_cfu_out.br_target;
        if_stage_in.misprediction   = misprediction_frm_ex;
        if_stage_in.stall           = id_hdu_out.stall;
        ex_stage_in_frm_mem.rf_en   = mem_stage_in.rf_en;
        ex_stage_in_frm_mem.rd      = mem_stage_in.rd;
        ex_stage_in_frm_mem.opr_res = mem_stage_in.opr_res;
        ex_stage_in_frm_mem.pc4     = mem_stage_in.pc4;
        ex_stage_in_frm_mem.is_jal  = mem_stage_in.is_jal;
        ex_stage_in_frm_wb.rf_en    = wb_stage_in.rf_en;
        ex_stage_in_frm_wb.rd       = wb_stage_in.rd;
        ex_stage_in_frm_wb.wb_data  = wb_stage_out.wb_data;
        id_stage_in_frm_ex.rd       = ex_stage_in.rd;
        id_stage_in_frm_ex.wb_sel   = ex_stage_in.wb_sel;
    end

    // if -> id
    always_ff @(posedge clk or negedge arst_n) 
    begin
        if (~arst_n | misprediction_frm_ex) 
        begin
            id_stage_in  <= '0;
        end
        else if (~id_hdu_out.stall)
        begin
            id_stage_in  <= if_stage_out;
        end
    end

    // id -> ex
    always_ff @(posedge clk or negedge arst_n) 
    begin
        if (~arst_n | id_hdu_out.flush | misprediction_frm_ex) 
        begin
            ex_stage_in  <= '0;
        end
        else
        begin
            ex_stage_in  <= id_stage_out;
        end
    end

    // ex -> mem
    always_ff @(posedge clk or negedge arst_n) 
    begin
        if (~arst_n) 
        begin
            mem_stage_in <= '0;
        end
        else
        begin
            mem_stage_in <= ex_stage_out;
        end
    end

    // mem -> wb
    always_ff @(posedge clk or negedge arst_n) 
    begin
        if (~arst_n)
        begin
            wb_stage_in  <= '0;
        end
        else 
        begin
            wb_stage_in  <= mem_stage_out;
        end
    end

endmodule: core
