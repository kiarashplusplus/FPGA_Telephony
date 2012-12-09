library verilog;
use verilog.vl_types.all;
entity transportSend is
    generic(
        packetSize      : integer := 16
    );
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        cmd             : in     vl_logic_vector(1 downto 0);
        data            : in     vl_logic_vector(15 downto 0);
        sendData        : in     vl_logic;
        sending         : out    vl_logic;
        packetOut       : out    vl_logic_vector(7 downto 0);
        busy            : out    vl_logic
    );
end transportSend;
