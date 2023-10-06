module jesd204b_rx_controller_slide #(
    //parameter FRAME_SIZE        = 1,   // frame size in byte. 
    //parameter FMLC_NUM          = 8,   // multi frame size.
    parameter USERDATA_WIDTH    = 32
) (
    // External ports from Transceiver
        input wire               i_gthrxn_in,
        input wire               i_gthrxp_in,
        input wire               i_gtrefclk00_in, // 100MHz  (Connect this port to IBUFDS_GTE4 or other transceiver buffer. Frequency is Actual reference clock on IP setting.)

    // External or Internal for Transceiver     
        input wire               i_clk_freerun,  //  100MHz (any frequency is OK. This clk is for reset sequence)
        input wire               i_usrclk,       //  250MHz (See UG578, p304 )

    // External for JESD204B core
        output wire o_nsync,
        input  wire i_sysref,

    // Interface for User Logic or AXI(S) Convertion Logic
        output wire o_data_clk,
        output wire [USERDATA_WIDTH-1:0] o_data_from_transceiver

);


wire [USERDATA_WIDTH-1:0] gtwiz_userdata_rx_out;

jesd204b_rx_core_slide #(
    .LMFC_CNT_WIDTH   (8),
    .USERDATA_WIDTH   (USERDATA_WIDTH),
    .JESD204B_CONFIG_L(5'b00000),
    .JESD204B_CONFIG_F(8'b00000000),
    .JESD204B_CONFIG_K(5'b00000),
    .JESD204B_CONFIG_M(8'b00000000)
) jesd20b_rx_core_inst (
    .o_nsync                    (o_nsync),
    .i_sysref                    (i_sysref),
    .i_dclk                      (i_usrclk),  
    .o_gtwiz_userclk_rx_active_in(gtwiz_userclk_rx_active_in),
    .i_gtwiz_reset_clk_freerun_in(i_clk_freerun),
    .o_gtwiz_reset_all_in        (gtwiz_reset_all_in),
    .i_gtwiz_reset_rx_done_out   (gtwiz_reset_rx_done_out),
    .i_gtpowergood_out           (gtpowergood_out),
    .o_rxslide_in                (rxslide_in),
    .o_rxusrclk2                 (rxusrclk2_in),  
    .i_gtwiz_userdata_rx_out     (gtwiz_userdata_rx_out),
    .o_data_clk                  (o_data_clk), 
    .o_data_from_transceiver     (o_data_from_transceiver)
);

gtwizard_ultrascale_0 gth_inst (
  .gtwiz_userclk_tx_active_in               (1'b1),                         //need to be H for reset process 
  .gtwiz_userclk_rx_active_in               (1'b1),                         //need to be H for reset process 
  .gtwiz_reset_clk_freerun_in               (i_clk_freerun),                // 
  .gtwiz_reset_all_in                       (gtwiz_reset_all_in),           // 
  .gtwiz_reset_tx_pll_and_datapath_in       (1'b0),                         // 0 Don't need to H if you use reset_all_in
  .gtwiz_reset_tx_datapath_in               (1'b0),                         // 0 Don't need to H if you use reset_all_in
  .gtwiz_reset_rx_pll_and_datapath_in       (1'b0),                         // 0 Don't need to H if you use reset_all_in
  .gtwiz_reset_rx_datapath_in               (1'b0),                         // 0 Don't need to H if you use reset_all_in 
  .gtwiz_reset_rx_cdr_stable_out            (gtwiz_reset_rx_cdr_stable_out),// DNC
  .gtwiz_reset_tx_done_out                  (gtwiz_reset_tx_done_out),      // output wire [0 : 0] gtwiz_reset_tx_done_out
  .gtwiz_reset_rx_done_out                  (gtwiz_reset_rx_done_out),      // output wire [0 : 0] gtwiz_reset_rx_done_out
  .gtwiz_userdata_tx_in                     (32'h00000000),                 // input wire [127 : 0] gtwiz_userdata_tx_in
  .gtwiz_userdata_rx_out                    (gtwiz_userdata_rx_out),        // output wire [127 : 0] gtwiz_userdata_rx_out
  .gtrefclk00_in                            (i_gtrefclk00_in),              // 
  .qpll0outclk_out                          (qpll0outclk_out),              // not necessary
  .qpll0outrefclk_out                       (qpll0outrefclk_out),           // Connect this clk to jesd204b_core clk
  .gthrxn_in                                (i_gthrxn_in),                  // 
  .gthrxp_in                                (i_gthrxp_in),                  // 
  .rx8b10ben_in                             (1'b1),                         // 1
  .rxcommadeten_in                          (1'b1),                         // 1
  .rxmcommaalignen_in                       (1'b0),                         // Need to be 0 when you use RXSLIDE  
  .rxpcommaalignen_in                       (1'b0),                         // Need to be 0 when you use RXSLIDE  
  .rxslide_in                               (rxslide_in),  
  .rxusrclk_in                              (i_usrclk),                     // connect from qplloutrefclk_out 
  .rxusrclk2_in                             (rxusrclk2_in),                 // 
  .tx8b10ben_in                             (1'b1),     
  .txctrl0_in                               (16'h0000),                      
  .txctrl1_in                               (16'h0000),                    
  .txctrl2_in                               (8'h0000)  ,                   
  .txusrclk_in                              (i_usrclk),                     // input wire [3 : 0] txusrclk_in
  .txusrclk2_in                             (i_usrclk),                     // input wire [3 : 0] txusrclk2_in
  .gtpowergood_out                          (gtpowergood_out),              // 
  .gthtxn_out                               (gthtxn_out),                   // not necessary (this port is only for gth transceiver)
  .gthtxp_out                               (gthtxp_out),                   // 
  .rxbyteisaligned_out                      (rxbyteisaligned_out),          // 
  .rxbyterealign_out                        (rxbyterealign_out),            // 
  .rxcommadet_out                           (rxcommadet_out),               // 
  .rxctrl0_out                              (rxctrl0_out),                  //  
  .rxctrl1_out                              (rxctrl1_out),                  //  
  .rxctrl2_out                              (rxctrl2_out),                  //  
  .rxctrl3_out                              (rxctrl3_out),                  //  
  .rxoutclk_out                             (rxoutclk_out),                 // output wire [3 : 0] rxoutclk_out
  .rxpmaresetdone_out                       (rxpmaresetdone_out),           // output wire [3 : 0] rxpmaresetdone_out
  .txoutclk_out                             (txoutclk_out),                 // output wire [3 : 0] txoutclk_out
  .txpmaresetdone_out                       (txpmaresetdone_out)            // output wire [3 : 0] txpmaresetdone_out
);

    
endmodule