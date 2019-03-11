library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clock is
generic(CLK_speed : integer:=10000000);
port(
clk : in std_logic;
async_reset: in std_logic;
UP_HOUR, UP_MINUTE : in std_logic;
seconds : out std_logic_vector(5 downto 0);
disp_OUT : out std_logic_vector(31 downto 0)
);
end clock;

architecture clock_arch of clock is
signal sec_reg, min_reg: unsigned(5 downto 0);
signal hour_reg: unsigned(4 downto 0);
signal CNT: unsigned(23 downto 0);
signal sec,point: std_logic;
signal display: std_logic_vector(31 downto 0);
signal reg_in: unsigned(5 downto 0);
signal reg_in2: unsigned(7 downto 0);
alias hours_1: std_logic_vector(7 downto 0) is display(31 downto 24);
alias hours_2: std_logic_vector(7 downto 0) is display(23 downto 16); 
alias minutes_1: std_logic_vector(7 downto 0) is display(15 downto 8);
alias minutes_2: std_logic_vector(7 downto 0) is display(7 downto 0);
begin

process(clk,CNT,async_reset,point)
begin

if(async_reset='0') then
CNT <= (others =>'0');
sec <='0';
point <= '0';

elsif(rising_edge(clk)) then -- proces licznika(counter process)
if(CNT = CLK_speed) then
CNT <= (others => '0');
sec<='1';
if(point='1') then
point<='0';
else
point<='1';
end if;
else
CNT <= CNT+1;
sec <= '0';
end if;
end if;
end process;

process(async_reset,UP_HOUR,UP_MINUTE,sec,hour_reg,min_reg,sec_reg)--proces zegarka(clock process)
begin

if(async_reset ='0') then
sec_reg <= (others =>'0');
min_reg <= (others => '0');
hour_reg <= (others => '0');
elsif(sec='1' and rising_edge(sec) and UP_HOUR='0') then
if(hour_reg="10111") then
hour_reg <= (others =>'0');
else
hour_reg <= hour_reg +1;
end if;

elsif(sec='1' and rising_edge(sec) and UP_MINUTE='0') then
if(min_reg="111011") then
min_reg <=(others => '0');
else
min_reg <= min_reg +1;
end if;

elsif(rising_edge(sec)) then
if(sec_reg="111011") then
sec_reg <= (others=>'0');
if(min_reg="111011") then
min_reg <= (others =>'0');
if(hour_reg="10111") then
hour_reg <= (others=>'0');
else
hour_reg <= hour_reg+1;
end if;
else
min_reg <= min_reg+1;
end if;
else
sec_reg <= sec_reg +1;
end if;
end if;
end process;

--konwersja do wyswietlacza godziny 
process(sec,hour_reg,reg_in)
begin
reg_in <= '0'&(hour_reg/5);

if (rising_edge(sec)) then
hours_1 <= "0000"&std_logic_vector(reg_in(4 downto 1));
hours_2 <= "000"&std_logic_vector(hour_reg mod 10);
end if;
end process;

--konwersja do wyswietlacza minuty
process(sec,min_reg,reg_in2)
begin
reg_in2 <= "00"&(min_reg/5);


if (rising_edge(sec)) then
minutes_1 <= "000"&std_logic_vector(reg_in2(5 downto 1));
minutes_2 <= "00"&std_logic_vector(min_reg mod 10);
end if;
end process;


seconds <= std_logic_vector(sec_reg);
disp_OUT(23) <= point;

with hours_1 select
disp_OUT(31 downto 24) <= "00111111" when "00000000",
								  "00000110" when "00000001",
								  "01011011" when "00000010",
								  "01111001" when others;
with hours_2 select
disp_OUT(22 downto 16) <="0111111" when "00000000",
								 "0000110" when "00000001",
								 "1011011" when "00000010",
								 "1001111" when "00000011",
								 "1100110" when "00000100",
								 "1101101" when "00000101",
								 "1111101" when "00000110",
								 "0000111" when "00000111",
								 "1111111" when "00001000",
								 "1101111" when "00001001",
								 "1111001" when others;
with minutes_1 select
disp_OUT(15 downto 8) <= "00111111" when "00000000",
								 "00000110" when "00000001",
								 "01011011" when "00000010",
								 "01001111" when "00000011",
								 "01100110" when "00000100",
								 "01101101" when "00000101",
								 "01111001" when others;								 
with minutes_2 select
disp_OUT(7 downto 0) <=  "00111111" when "00000000",
								 "00000110" when "00000001",
								 "01011011" when "00000010",
								 "01001111" when "00000011",
								 "01100110" when "00000100",
								 "01101101" when "00000101",
								 "01111101" when "00000110",
								 "00000111" when "00000111",
								 "01111111" when "00001000",
								 "01101111" when "00001001",
								 "01111001" when others;								 

								
end clock_arch; 