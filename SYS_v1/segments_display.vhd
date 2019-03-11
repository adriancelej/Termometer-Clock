library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity segments_display is
generic(long:integer:=50000);
port(
clk : in std_logic;
digits : in std_logic_vector(31 downto 0);
async_reset : in std_logic;
segment : out std_logic_vector(11 downto 0)
);
end segments_display;

architecture disp_arch of segments_display is
type STANY is (DS4,DS3,DS2,DS1);
signal state,next_state : STANY;
signal CNT: unsigned(15 downto 0);

begin

process(clk,async_reset)
begin
if(async_reset='0') then
CNT <= (others=>'0');
elsif rising_edge(clk) then
if(CNT=long) then
CNT<= (others=>'0');
else
CNT<=CNT+1;
end if;
end if;
end process;

process(clk,async_reset,CNT)
begin
if async_reset='0' then
state <= DS1;
elsif rising_edge(clk) then
if(CNT=long-1)then
state <= next_state;
else
state <= state;
end if; 
end if;
end process;

process(clk, digits)
begin
if(rising_edge(clk)) then
case state is
when DS1 =>
segment<="0001"&digits(7 downto 0);
next_state <= DS2;
when DS2 =>
segment<="0010"&digits(15 downto 8);
next_state <= DS3;
when DS3 =>
segment<="0100"&digits(23 downto 16);
next_state <= DS4;
when DS4 =>
segment<= "1000"&digits(31 downto 24);
next_state <= DS1;
end case;
end if;
end process;

end disp_arch;