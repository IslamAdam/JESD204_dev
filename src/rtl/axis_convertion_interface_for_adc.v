module AXIS_CONVERTION_INTERFACE_FOR_ADC #(
    parameter DATA_WIDTH = 64,
    parameter FIFO_DEPTH = 16 
) (
    // AXIS Interface
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0  m_axis_aclk CLK" *)
    (* X_INTERFACE_PARAMETER = " ASSOCIATED_BUSIF <AXI_interface_sample>, FREQ_HZ 125000000" *)
        //output wire  m_axis_aclk, //125 MHz
        input wire  m_axis_aclk, //125 MHz
        input wire  m_axis_aresetn,
        output reg  m_axis_tvalid,
        output reg [63 : 0] m_axis_tdata,
        output reg  m_axis_tlast,
        input wire  m_axis_tready,

    // ADC interface
        input wire [31 : 0] i_adc_data,
        input wire  i_adc_data_clk, // 250 MHz

    // Controll and Status
        input  wire i_con_axisside, // 1 : AXIS data is send if FIFO is not empty.          0 : AXIS data is NOT send.  
        input  wire i_con_adcside , // 1 : FIFO is written from ADC if FIFO is not full.    0 : FIFO is not written. 
        output wire o_status        // 1 : fifo is full. Should increase FIFO_DEPTH

);



//assign m_axis_aclk = div_clk;  // axis_aclk is correspond to adc_data_clk

wire [63:0] fifo_read_data;
wire [63:0] inputdata_tmp;
reg [63:0] shift_reg;
reg [1:0] clk_divtwo = 2'b00;
wire div_clk;

assign div_clk = clk_divtwo[1:1];

reg  i_ren;
wire i_wen;
wire o_empty;
wire o_full;

assign i_wen    = i_con_adcside & !o_full ;
assign o_status = o_full;



always @(posedge m_axis_aclk ) begin
    // Reset 
    if(!m_axis_aresetn)begin
        m_axis_tvalid <= 0;
        m_axis_tdata  <= 0;
        m_axis_tlast  <= 0;

        i_ren <= 0;

    end else begin
        if(i_con_axisside && !o_empty)begin
            m_axis_tvalid <= 1'b1;
            m_axis_tdata <= fifo_read_data;

            if(m_axis_tready == 1)begin
                i_ren <= 1'b1;
            end else begin
                i_ren <= 1'b0;
            end

        end else begin
            m_axis_tvalid <= 1'b0;
        end
    end
end



localparam ADDR_WIDTH = $clog2(FIFO_DEPTH);

FIFO_ASYNC #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH)
) fifo_sync_inst (
    .write_clk(div_clk),
    .write_rst(!m_axis_arestn),
    .write_en(i_wen),
    .data_in(shift_reg),
    .empty(o_empty),
    
    .read_clk(m_axis_aclk),
    .read_rst(!m_axis_arestn),
    .read_en(i_ren),
    
    .data_out(fifo_read_data),
    .full(o_full)
);

always @(posedge i_adc_data_clk) begin
      shift_reg[31:0] <= i_adc_data;
      shift_reg[63:32]<= shift_reg[31:0];
      clk_divtwo <= clk_divtwo + 1;
end

endmodule