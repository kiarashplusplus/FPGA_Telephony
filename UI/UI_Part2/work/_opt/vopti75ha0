library verilog;
use verilog.vl_types.all;
entity Divider is
    generic(
        N               : integer := 27000000;
        W               : integer := 25
    );
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        sys_reset       : in     vl_logic;
        new_clk         : out    vl_logic
    );
end Divider;
