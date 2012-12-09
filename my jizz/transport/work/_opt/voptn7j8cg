library verilog;
use verilog.vl_types.all;
entity packetBuffer is
    port(
        clk             : in     vl_logic;
        din             : in     vl_logic_vector(7 downto 0);
        rd_en           : in     vl_logic;
        srst            : in     vl_logic;
        wr_en           : in     vl_logic;
        data_count      : out    vl_logic_vector(10 downto 0);
        dout            : out    vl_logic_vector(7 downto 0);
        empty           : out    vl_logic;
        full            : out    vl_logic
    );
end packetBuffer;
