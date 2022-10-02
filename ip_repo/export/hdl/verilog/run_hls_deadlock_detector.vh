
    wire dl_reset;
    wire dl_clock;
    assign dl_reset = ap_rst_n;
    assign dl_clock = ap_clk;
    wire [0:0] proc_0_data_FIFO_blk;
    wire [0:0] proc_0_data_PIPO_blk;
    wire [0:0] proc_0_start_FIFO_blk;
    wire [0:0] proc_0_TLF_FIFO_blk;
    wire [0:0] proc_0_input_sync_blk;
    wire [0:0] proc_0_output_sync_blk;
    wire [0:0] proc_dep_vld_vec_0;
    reg [0:0] proc_dep_vld_vec_0_reg;
    wire [0:0] in_chan_dep_vld_vec_0;
    wire [1:0] in_chan_dep_data_vec_0;
    wire [0:0] token_in_vec_0;
    wire [0:0] out_chan_dep_vld_vec_0;
    wire [1:0] out_chan_dep_data_0;
    wire [0:0] token_out_vec_0;
    wire dl_detect_out_0;
    wire dep_chan_vld_1_0;
    wire [1:0] dep_chan_data_1_0;
    wire token_1_0;
    wire [0:0] proc_1_data_FIFO_blk;
    wire [0:0] proc_1_data_PIPO_blk;
    wire [0:0] proc_1_start_FIFO_blk;
    wire [0:0] proc_1_TLF_FIFO_blk;
    wire [0:0] proc_1_input_sync_blk;
    wire [0:0] proc_1_output_sync_blk;
    wire [0:0] proc_dep_vld_vec_1;
    reg [0:0] proc_dep_vld_vec_1_reg;
    wire [0:0] in_chan_dep_vld_vec_1;
    wire [1:0] in_chan_dep_data_vec_1;
    wire [0:0] token_in_vec_1;
    wire [0:0] out_chan_dep_vld_vec_1;
    wire [1:0] out_chan_dep_data_1;
    wire [0:0] token_out_vec_1;
    wire dl_detect_out_1;
    wire dep_chan_vld_0_1;
    wire [1:0] dep_chan_data_0_1;
    wire token_0_1;
    wire [1:0] dl_in_vec;
    wire dl_detect_out;
    wire token_clear;
    reg [1:0] origin;

    reg ap_done_reg_0;// for module grp_runTestAfterInit_fu_941.runTestAfterInit_Block_entry1119_proc7_U0
    always @ (negedge dl_reset or posedge dl_clock) begin
        if (~dl_reset) begin
            ap_done_reg_0 <= 'b0;
        end
        else begin
            ap_done_reg_0 <= grp_runTestAfterInit_fu_941.runTestAfterInit_Block_entry1119_proc7_U0.ap_done & ~grp_runTestAfterInit_fu_941.runTestAfterInit_Block_entry1119_proc7_U0.ap_continue;
        end
    end

    // Process: grp_runTestAfterInit_fu_941.read_train_U0
    run_hls_deadlock_detect_unit #(2, 0, 1, 1) run_hls_deadlock_detect_unit_0 (
        .reset(dl_reset),
        .clock(dl_clock),
        .proc_dep_vld_vec(proc_dep_vld_vec_0),
        .in_chan_dep_vld_vec(in_chan_dep_vld_vec_0),
        .in_chan_dep_data_vec(in_chan_dep_data_vec_0),
        .token_in_vec(token_in_vec_0),
        .dl_detect_in(dl_detect_out),
        .origin(origin[0]),
        .token_clear(token_clear),
        .out_chan_dep_vld_vec(out_chan_dep_vld_vec_0),
        .out_chan_dep_data(out_chan_dep_data_0),
        .token_out_vec(token_out_vec_0),
        .dl_detect_out(dl_in_vec[0]));

    assign proc_0_data_FIFO_blk[0] = 1'b0 | (~grp_runTestAfterInit_fu_941.read_train_U0.copyInputAOV_in_c_blk_n);
    assign proc_0_data_PIPO_blk[0] = 1'b0;
    assign proc_0_start_FIFO_blk[0] = 1'b0;
    assign proc_0_TLF_FIFO_blk[0] = 1'b0;
    assign proc_0_input_sync_blk[0] = 1'b0 | (grp_runTestAfterInit_fu_941.ap_sync_read_train_U0_ap_ready & grp_runTestAfterInit_fu_941.read_train_U0.ap_idle & ~grp_runTestAfterInit_fu_941.ap_sync_runTestAfterInit_Block_entry1119_proc7_U0_ap_ready);
    assign proc_0_output_sync_blk[0] = 1'b0;
    assign proc_dep_vld_vec_0[0] = dl_detect_out ? proc_dep_vld_vec_0_reg[0] : (proc_0_data_FIFO_blk[0] | proc_0_data_PIPO_blk[0] | proc_0_start_FIFO_blk[0] | proc_0_TLF_FIFO_blk[0] | proc_0_input_sync_blk[0] | proc_0_output_sync_blk[0]);
    always @ (negedge dl_reset or posedge dl_clock) begin
        if (~dl_reset) begin
            proc_dep_vld_vec_0_reg <= 'b0;
        end
        else begin
            proc_dep_vld_vec_0_reg <= proc_dep_vld_vec_0;
        end
    end
    assign in_chan_dep_vld_vec_0[0] = dep_chan_vld_1_0;
    assign in_chan_dep_data_vec_0[1 : 0] = dep_chan_data_1_0;
    assign token_in_vec_0[0] = token_1_0;
    assign dep_chan_vld_0_1 = out_chan_dep_vld_vec_0[0];
    assign dep_chan_data_0_1 = out_chan_dep_data_0;
    assign token_0_1 = token_out_vec_0[0];

    // Process: grp_runTestAfterInit_fu_941.runTestAfterInit_Block_entry1119_proc7_U0
    run_hls_deadlock_detect_unit #(2, 1, 1, 1) run_hls_deadlock_detect_unit_1 (
        .reset(dl_reset),
        .clock(dl_clock),
        .proc_dep_vld_vec(proc_dep_vld_vec_1),
        .in_chan_dep_vld_vec(in_chan_dep_vld_vec_1),
        .in_chan_dep_data_vec(in_chan_dep_data_vec_1),
        .token_in_vec(token_in_vec_1),
        .dl_detect_in(dl_detect_out),
        .origin(origin[1]),
        .token_clear(token_clear),
        .out_chan_dep_vld_vec(out_chan_dep_vld_vec_1),
        .out_chan_dep_data(out_chan_dep_data_1),
        .token_out_vec(token_out_vec_1),
        .dl_detect_out(dl_in_vec[1]));

    assign proc_1_data_FIFO_blk[0] = 1'b0 | (~grp_runTestAfterInit_fu_941.runTestAfterInit_Block_entry1119_proc7_U0.copyInputAOV_in_blk_n);
    assign proc_1_data_PIPO_blk[0] = 1'b0;
    assign proc_1_start_FIFO_blk[0] = 1'b0;
    assign proc_1_TLF_FIFO_blk[0] = 1'b0 | (~grp_runTestAfterInit_fu_941.contr_command_U.if_empty_n & grp_runTestAfterInit_fu_941.runTestAfterInit_Block_entry1119_proc7_U0.ap_idle & ~grp_runTestAfterInit_fu_941.contr_command_U.if_write) | (~grp_runTestAfterInit_fu_941.contr_taskId_V_U.if_empty_n & grp_runTestAfterInit_fu_941.runTestAfterInit_Block_entry1119_proc7_U0.ap_idle & ~grp_runTestAfterInit_fu_941.contr_taskId_V_U.if_write) | (~grp_runTestAfterInit_fu_941.contr_checkId_V_U.if_empty_n & grp_runTestAfterInit_fu_941.runTestAfterInit_Block_entry1119_proc7_U0.ap_idle & ~grp_runTestAfterInit_fu_941.contr_checkId_V_U.if_write) | (~grp_runTestAfterInit_fu_941.contr_AOV_U.if_empty_n & grp_runTestAfterInit_fu_941.runTestAfterInit_Block_entry1119_proc7_U0.ap_idle & ~grp_runTestAfterInit_fu_941.contr_AOV_U.if_write) | (~grp_runTestAfterInit_fu_941.contr_AOV_1_U.if_empty_n & grp_runTestAfterInit_fu_941.runTestAfterInit_Block_entry1119_proc7_U0.ap_idle & ~grp_runTestAfterInit_fu_941.contr_AOV_1_U.if_write) | (~grp_runTestAfterInit_fu_941.contr_AOV_2_U.if_empty_n & grp_runTestAfterInit_fu_941.runTestAfterInit_Block_entry1119_proc7_U0.ap_idle & ~grp_runTestAfterInit_fu_941.contr_AOV_2_U.if_write) | (~grp_runTestAfterInit_fu_941.contr_AOV_3_U.if_empty_n & grp_runTestAfterInit_fu_941.runTestAfterInit_Block_entry1119_proc7_U0.ap_idle & ~grp_runTestAfterInit_fu_941.contr_AOV_3_U.if_write) | (~grp_runTestAfterInit_fu_941.contr_AOV_4_U.if_empty_n & grp_runTestAfterInit_fu_941.runTestAfterInit_Block_entry1119_proc7_U0.ap_idle & ~grp_runTestAfterInit_fu_941.contr_AOV_4_U.if_write) | (~grp_runTestAfterInit_fu_941.contr_AOV_5_U.if_empty_n & grp_runTestAfterInit_fu_941.runTestAfterInit_Block_entry1119_proc7_U0.ap_idle & ~grp_runTestAfterInit_fu_941.contr_AOV_5_U.if_write) | (~grp_runTestAfterInit_fu_941.contr_AOV_6_U.if_empty_n & grp_runTestAfterInit_fu_941.runTestAfterInit_Block_entry1119_proc7_U0.ap_idle & ~grp_runTestAfterInit_fu_941.contr_AOV_6_U.if_write) | (~grp_runTestAfterInit_fu_941.contr_AOV_7_U.if_empty_n & grp_runTestAfterInit_fu_941.runTestAfterInit_Block_entry1119_proc7_U0.ap_idle & ~grp_runTestAfterInit_fu_941.contr_AOV_7_U.if_write) | (~grp_runTestAfterInit_fu_941.contr_uniId_V_U.if_empty_n & grp_runTestAfterInit_fu_941.runTestAfterInit_Block_entry1119_proc7_U0.ap_idle & ~grp_runTestAfterInit_fu_941.contr_uniId_V_U.if_write);
    assign proc_1_input_sync_blk[0] = 1'b0 | (grp_runTestAfterInit_fu_941.ap_sync_runTestAfterInit_Block_entry1119_proc7_U0_ap_ready & grp_runTestAfterInit_fu_941.runTestAfterInit_Block_entry1119_proc7_U0.ap_idle & ~grp_runTestAfterInit_fu_941.ap_sync_read_train_U0_ap_ready);
    assign proc_1_output_sync_blk[0] = 1'b0;
    assign proc_dep_vld_vec_1[0] = dl_detect_out ? proc_dep_vld_vec_1_reg[0] : (proc_1_data_FIFO_blk[0] | proc_1_data_PIPO_blk[0] | proc_1_start_FIFO_blk[0] | proc_1_TLF_FIFO_blk[0] | proc_1_input_sync_blk[0] | proc_1_output_sync_blk[0]);
    always @ (negedge dl_reset or posedge dl_clock) begin
        if (~dl_reset) begin
            proc_dep_vld_vec_1_reg <= 'b0;
        end
        else begin
            proc_dep_vld_vec_1_reg <= proc_dep_vld_vec_1;
        end
    end
    assign in_chan_dep_vld_vec_1[0] = dep_chan_vld_0_1;
    assign in_chan_dep_data_vec_1[1 : 0] = dep_chan_data_0_1;
    assign token_in_vec_1[0] = token_0_1;
    assign dep_chan_vld_1_0 = out_chan_dep_vld_vec_1[0];
    assign dep_chan_data_1_0 = out_chan_dep_data_1;
    assign token_1_0 = token_out_vec_1[0];


`include "run_hls_deadlock_report_unit.vh"