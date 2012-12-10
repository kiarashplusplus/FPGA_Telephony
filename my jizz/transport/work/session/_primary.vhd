library verilog;
use verilog.vl_types.all;
entity session is
    generic(
        s_idle          : integer := 0;
        s_calling       : integer := 1;
        s_connected     : integer := 2;
        s_noAnswer      : integer := 3;
        s_voicemail     : integer := 4;
        s_ringing       : integer := 6;
        timeOutConstant : integer := 10
    );
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        phoneNum        : in     vl_logic_vector(7 downto 0);
        userInp         : in     vl_logic_vector(4 downto 0);
        audioIn         : in     vl_logic_vector(15 downto 0);
        cmdIn           : in     vl_logic_vector(1 downto 0);
        packetIn        : in     vl_logic_vector(15 downto 0);
        transportBusy   : in     vl_logic;
        audioInFlag     : out    vl_logic;
        audioOutFlag    : out    vl_logic;
        audioOut        : out    vl_logic_vector(15 downto 0);
        cmd             : out    vl_logic_vector(1 downto 0);
        dataOut         : out    vl_logic_vector(15 downto 0);
        sessionBusy     : out    vl_logic;
        phoneOut        : out    vl_logic_vector(7 downto 0);
        current_state   : out    vl_logic_vector(3 downto 0)
    );
end session;
