library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PC is
    port(
        clk     : in  std_logic;
        reset_n : in  std_logic;
        en      : in  std_logic;
        sel_a   : in  std_logic;
        sel_imm : in  std_logic;
        add_imm : in  std_logic;
        imm     : in  std_logic_vector(15 downto 0);
        a       : in  std_logic_vector(15 downto 0);
        addr    : out std_logic_vector(31 downto 0)
    );
end PC;

architecture synth of PC is
signal s_next,s_curr: std_logic_vector(31 downto 0);  
begin


Spc: process(clk, reset_n)
begin
	if reset_n = '0' then
		s_curr <= (others => '0');
	elsif rising_edge(clk) then
		if en = '1' then
			s_curr <= s_next;
		else
			--s_next <= ((15 downto 0 => '0') &  a) and X"FFFFFFFC";
		
		end if;
	end if;
	end process;

output : process(sel_imm, sel_a, add_imm,imm,a,s_curr)

begin	
	
	if add_imm = '1' then s_next <=   std_logic_vector(to_unsigned(to_integer(unsigned(s_curr)) + to_integer(unsigned( imm)),32));
	elsif sel_imm ='1' then s_next <= (15 downto 0 =>'0') &( imm(13 downto 0)) & "00";
	elsif sel_a = '1' then s_next <= (15 downto 0 =>'0') &( a(15 downto 2)) & "00";
	else s_next <= std_logic_vector(to_unsigned(to_integer(unsigned(s_curr)) + 4,32))  ;
	end if;


end process;

addr <=   s_curr and X"0000FFFF";

end synth;
