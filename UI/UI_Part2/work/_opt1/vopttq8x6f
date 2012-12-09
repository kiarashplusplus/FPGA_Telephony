library verilog;
use verilog.vl_types.all;
entity Text_Scroller_Interface is
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        addr            : in     vl_logic_vector(10 downto 0);
        length          : in     vl_logic_vector(10 downto 0);
        start           : in     vl_logic;
        ascii_out       : out    vl_logic_vector(7 downto 0);
        ascii_out_ready : out    vl_logic;
        done            : out    vl_logic
    );
end Text_Scroller_Interface;
