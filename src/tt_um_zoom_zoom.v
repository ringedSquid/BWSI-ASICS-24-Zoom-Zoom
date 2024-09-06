`default_nettype none

module tt_um_zoom_zoom (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       reset     // reset - low to reset
);

  wire [7:0] data_output_pins;  
  wire [15:0] memory_in;
  wire memory_ready;
  wire write_complete;
  wire uart_inbound;
  wire memory_critical;
  wire [15:0] request_address;
  wire request_type;
  wire request;
  wire [15:0] data_out;
  wire [7:0] data_input_pins;
  wire [15:0] memory_write;
  wire write_enable, register_enable, read_enable, lower_bit, upper_bit, tx;  
  wire [7:0] data_received;  // Output from uart_rx

  // input
  wire lower_byte_in = ui_in[0];
  wire upper_byte_in = ui_in[1];
  wire rx = ui_in[2];  // UART RX input
  wire IN3 = ui_in[3];
  wire IN4 = ui_in[4];
  wire IN5 = ui_in[5];
  wire IN6 = ui_in[6];
  wire IN7 = ui_in[7];

  // output
  assign uo_out[0] = write_enable;
  assign uo_out[1] = register_enable;
  assign uo_out[2] = read_enable;
  assign uo_out[3] = lower_bit;
  assign uo_out[4] = tx;
  assign uo_out[5] = upper_bit;
  assign uo_out[6] = 0;  // unused
  assign uo_out[7] = 0;  // unused

  // input output
  assign uio_out = data_output_pins;   
  assign data_input_pins = uio_in;     
  assign uio_oe = iovalue;             

  x3q16 cpu (
      .clk(clk),
      .reset(reset),
      .memory_in(memory_in),
      .memory_ready(memory_ready),
      .write_complete(write_complete),
      .uart_inbound(uart_inbound),
      .memory_critical(memory_critical),
      .request_address(request_address),
      .request_type(request_type),
      .request(request),
      .data_out(data_out),
      .tx(tx)  
  );

  memory_controller_arduino memory_controller (
      .clk(clk),
      .reset(reset),
      .request_address(request_address),
      .request_type(request_type),
      .request(request),
      .memory_write(memory_write),
      .data_out(memory_in),
      .memory_ready(memory_ready),
      .write_complete(write_complete),
      .write_enable(write_enable),  
      .register_enable(register_enable),
      .read_enable(read_enable),
      .lower_bit(lower_bit),
      .upper_bit(upper_bit),
      .lower_byte_in(lower_byte_in),
      .upper_byte_in(upper_byte_in),
      .data_input_pins(data_input_pins),
      .data_output_pins(data_output_pins),  // Connect data_output_pins properly
      .iovalue(uio_oe),  
      .uart_inbound(uart_inbound),
      .data_received(data_received)
  );

  uart_rx uart_receiver (
      .clk(clk),
      .reset(reset),
      .rx(rx),                          // RX input from ui_in
      .speed(13'h1869),                 // Default speed, or you can use another input if needed
      .set_speed(1'b0),                 // No speed setting input; default to 0
      .uart_inbound(uart_inbound),      // Output to memory_controller
      .data_received(data_received)     // Output to memory_controller
  );

  // unused pins
  wire _unused = &{ena, IN3, IN4, IN5, IN6, IN7, 1'b0};

endmodule
