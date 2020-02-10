library ieee;
use ieee.std_logic_1164.all;

entity mux2x5 is
    port(
        i0  : in  std_logic_vector(4 downto 0);
        i1  : in  std_logic_vector(4 downto 0);
        sel : in  std_logic;
        o   : out std_logic_vector(4 downto 0)
    );
end mux2x5;

architecture synth of mux2x5 is
begin

mult : process(sel,i1,i0)
begin 
	if sel = '1' then
		o <= i1;
	else 
		o<= i0;
end if;
end process;

end synth;
