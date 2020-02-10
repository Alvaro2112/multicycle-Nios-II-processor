library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RAM is
    port(
        clk     : in  std_logic;
        cs      : in  std_logic;
        read    : in  std_logic;
        write   : in  std_logic;
        address : in  std_logic_vector(9 downto 0);
        wrdata  : in  std_logic_vector(31 downto 0);
        rddata  : out std_logic_vector(31 downto 0));
end RAM;

architecture synth of RAM is
signal tri_state: std_logic;
type ram_type is array(0 to 1023) of std_logic_vector(31 downto 0);
signal ram : ram_type; 
signal s_rdata : std_logic_vector(31 downto 0);
begin

tristate : process (clk)
begin 
	if rising_edge(clk)
		then tri_state <= cs and read;
	end if;
end process;


readprocess :process (clk)
begin
	if rising_edge(clk) then
		 s_rdata <=ram(to_integer(unsigned(address))) ;
	end if;
  end process;


writeprocess : process(clk) 
begin 
	if rising_edge(clk) then
		if cs ='1' and write = '1' 
		then ram(to_integer(unsigned(address))) <= wrdata ;
	end if;
end if;
end process;

rddata <= s_rdata when tri_state = '1' else (others => 'Z');


end synth;
