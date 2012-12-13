library verilog;
use verilog.vl_types.all;
entity audioBuffer is
    port(
        din             : in     vl_logic_vector(15 downto 0);
        rd_clk          : in     vl_logic;
        rd_en           : in     vl_logic;
        rst             : in     vl_logic;
        wr_clk          : in     vl_logic;
        wr_en           : in     vl_logic;
        dout            : out    vl_logic_vector(15 downto 0);
        empty           : out    vl_logic;
        full            : out    vl_logic
    );
end audioBuffer;
