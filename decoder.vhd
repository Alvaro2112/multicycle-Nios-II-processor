library ieee;
use ieee.std_logic_1164.all;


entity decoder is
    port(
        address : in  std_logic_vector(15 downto 0);
        cs_LEDS : out std_logic;
        cs_RAM  : out std_logic;
        cs_ROM  : out std_logic;
	cs_buttons : out std_logic
    );
end decoder;

architecture synth of decoder is
begin


cs_buttons <= '1'
	WHEN address <= "0010000000110100" and address <= "0010000000110100" ELSE
	'0';
cs_ROM <= '1'
	WHEN address <= "0000111111111100" ELSE
	'0';
cs_RAM <= '1'
	WHEN address >= "0001000000000000" and address <= "0001111111111100" ELSE
	'0';
cs_LEDS <= '1'
	WHEN address >= "0010000000000000" and address <= "0010000000001100" ELSE
	'0';

end synth;
