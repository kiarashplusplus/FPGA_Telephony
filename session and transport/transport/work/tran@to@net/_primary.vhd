library verilog;
use verilog.vl_types.all;
entity tranToNet is
    generic(
        packetSize      : integer := 16
    );
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        data            : in     vl_logic_vector(7 downto 0);
        sending         : in     vl_logic;
        dummyBufferRd   : in     vl_logic;
        sendData        : out    vl_logic;
        packetOut       : out    vl_logic_vector(7 downto 0);
        phoneNum        : out    vl_logic_vector(7 downto 0);
        dummyBufferCount: out    vl_logic_vector(9 downto 0);
        dummyBufferEmpty: out    vl_logic;
        debug           : out    vl_logic_vector(2 downto 0)
    );
end tranToNet;
