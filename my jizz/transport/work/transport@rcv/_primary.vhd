library verilog;
use verilog.vl_types.all;
entity transportRcv is
    generic(
        packetSize      : integer := 16
    );
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        rcvSignal       : in     vl_logic;
        packetIn        : in     vl_logic_vector(7 downto 0);
        sessionBusy     : in     vl_logic;
        sendingToSession: out    vl_logic_vector(1 downto 0);
        data            : out    vl_logic_vector(15 downto 0);
        dafuq           : out    vl_logic
    );
end transportRcv;
