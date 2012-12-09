library verilog;
use verilog.vl_types.all;
entity Text_Scroller is
    generic(
        SCROLL_SPEED_CNT: integer := 9000000;
        SCROLL_BEGIN_CNT: integer := 27000000;
        SCROLL_END_CNT  : integer := 27000000
    );
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        ascii_data      : in     vl_logic_vector(7 downto 0);
        ascii_data_ready: in     vl_logic;
        string_data     : out    vl_logic_vector(127 downto 0);
        wr_en_DEBUG     : out    vl_logic;
        wr_data_DEBUG   : out    vl_logic_vector(7 downto 0);
        wr_addr_DEBUG   : out    vl_logic_vector(10 downto 0);
        cntr_DEBUG      : out    vl_logic;
        set_disp_DEBUG  : out    vl_logic;
        rel_pos_DEBUG   : out    vl_logic_vector(3 downto 0);
        rd_addr_DEBUG   : out    vl_logic_vector(10 downto 0);
        rd_data_DEBUG   : out    vl_logic_vector(7 downto 0)
    );
end Text_Scroller;
