library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity display is
port(
clk : in std_logic;
digits : in std_logic_vector(31 downto 0);
async_reset : in std_logic;
segment : out std_logic_vector(8 downto 0)
);
end display;

architecture disp_arch of display is
type STANY is (DS4,DS3,DS2,DS1);
signal state,next_state : STANY;
signal digit: std_logic_vector(7 downto );

begin

process(clk,async_reset)
begin
if async_reset='0' then
state <= DS1;
elsif rising_edge(clk) then
state <= next_state;
end if; 
end process;

process(clk, digits)
begin
if(rising_edge(clk)) then
case state is
when DS1 =>
state_next <= DS2;

end case;
end if;
end process;

end disp_arch;