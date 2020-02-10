library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity add_sub is
    port(
        a        : in  std_logic_vector(31 downto 0);
        b        : in  std_logic_vector(31 downto 0);
        sub_mode : in  std_logic;
        carry    : out std_logic;
        zero     : out std_logic;
        r        : out std_logic_vector(31 downto 0)
    );
end add_sub;

architecture synth of add_sub is
signal b1: std_logic_vector(32 downto 0);
signal c : std_logic_vector(32 downto 0);
signal sum : std_logic_vector(32 downto 0);

begin	
	b1 <=  '0' & (b xor (31 downto 0 => sub_mode));
	c <= (31 downto 0 => '0') & sub_mode; 
	sum <= std_logic_vector(unsigned(('0' & a)) + unsigned(b1) + unsigned(c));
	r <= (sum(31 downto 0));
	
	carry <=  sum(32);
	zero <=  '1' when (sum(31 downto 0) = (31 downto 0 => '0')) else '0';
end synth;
