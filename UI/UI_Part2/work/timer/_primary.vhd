library verilog;
use verilog.vl_types.all;
entity timer is
    port(
        start_timer     : in     vl_logic;
        sys_reset       : in     vl_logic;
        clk             : in     vl_logic;
        enable          : in     vl_logic;
        clk_value       : in     vl_logic_vector(3 downto 0);
        expired         : out    vl_logic;
        countdown       : out    vl_logic_vector(3 downto 0)
    );
end timer;
