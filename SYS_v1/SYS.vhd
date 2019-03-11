library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SYS is
port(
async_reset : in std_logic;
sw_L, sw_R : in std_logic;
clk : in std_logic;
sw_res : in std_logic;
disp_seg : out std_logic_vector(11 downto 0)
);
end SYS;

architecture SYS_arch of SYS is

component clock is
port(
clk : in std_logic;
async_reset: in std_logic;
UP_HOUR, UP_MINUTE : in std_logic;
seconds : out std_logic_vector(5 downto 0);
disp_OUT : out std_logic_vector(31 downto 0)
);
end component;

component segments_display is
port(
clk : in std_logic;
digits : in std_logic_vector(31 downto 0);
async_reset : in std_logic;
segment : out std_logic_vector(11 downto 0)
);
end component;

component termometr is
port(
clk : in std_logic;
seg: out std_logic_vector(11 downto 0);
async_reset : in std_logic
);
end component;

signal digits: std_logic_vector(31 downto 0);
signal disp_termometer: std_logic_vector(11 downto 0);
signal disp_clock: std_logic_vector(11 downto 0);
signal seconds,probe: std_logic_vector(5 downto 0);
type state_type is(TMP,WATCH);
signal state,next_state: state_type;

begin

clock_1:clock
port map(
clk=>clk,
async_reset=>async_reset,
UP_HOUR=>sw_L,
UP_MINUTE=>sw_R,
disp_OUT=>digits,
seconds => seconds
);

display_1:segments_display
port map(
clk=>clk,
digits=>digits,
async_reset=>async_reset,
segment=>disp_clock
);

termometer_1:termometr
port map(
clk => clk,
seg => disp_termometer,
async_reset => async_reset
);

process(clk, seconds, async_reset)
begin
if(async_reset='0') then
state <= TMP;
elsif(rising_edge(clk)) then
if(seconds="011110")then
probe <= seconds;
end if;
if(probe="011110") then
if((unsigned(seconds)-unsigned(probe))="010100") then
state<= next_state;
end if;
end if;
else
state <= state; 
end if;
end process;

process(clk,state)
begin
if rising_edge(clk) then
case state is
when TMP =>
disp_seg(0) <= disp_termometer(11);
disp_seg(1) <= disp_termometer(10);
disp_seg(2) <= disp_termometer(9);
disp_seg(3) <= disp_termometer(8);
disp_seg(4) <= disp_termometer(7);
disp_seg(5) <= disp_termometer(6);
disp_seg(6) <= disp_termometer(5);
disp_seg(7) <= disp_termometer(4);
disp_seg(8) <= disp_termometer(3);
disp_seg(9) <= disp_termometer(2);
disp_seg(10) <= disp_termometer(1);
disp_seg(11) <= disp_termometer(0);
next_state <= WATCH;
when WATCH =>
disp_seg <= disp_clock;
next_state <= TMP;
end case;
end if;
end process;

end SYS_arch;