/* a very simple module */
module line(
    i_port, o_port
);

input wire i_port;
output wire o_port;

assign o_port = i_port;

endmodule