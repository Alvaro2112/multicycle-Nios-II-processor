library ieee;
use ieee.std_logic_1164.all;

entity controller is
    port(
        clk        : in  std_logic;
        reset_n    : in  std_logic;
        -- instruction opcode
        op         : in  std_logic_vector(5 downto 0);
        opx        : in  std_logic_vector(5 downto 0);
        -- activates branch condition
        branch_op  : out std_logic;
        -- immediate value sign extention
        imm_signed : out std_logic;
        -- instruction register enable
        ir_en      : out std_logic;
        -- PC control signals
        pc_add_imm : out std_logic;
        pc_en      : out std_logic;
        pc_sel_a   : out std_logic;
        pc_sel_imm : out std_logic;
        -- register file enable
        rf_wren    : out std_logic;
        -- multiplexers selections
        sel_addr   : out std_logic;
        sel_b      : out std_logic;
        sel_mem    : out std_logic;
        sel_pc     : out std_logic;
        sel_ra     : out std_logic;
        sel_rC     : out std_logic;
        -- write memory output
        read       : out std_logic;
        write      : out std_logic;
        -- alu op
        op_alu     : out std_logic_vector(5 downto 0) := "000000"
    );
end controller;

architecture synth of controller is
type state is (FETCH1, FETCH2, DECODE, R_OP, I_OP, LOAD1,LOAD2 , STORE, BREAK, BRANCH, CALL,JMP,UI_OP,RI_OP);
signal s_curr, s_next :state;
constant  rtype : std_logic_vector(7 downto 0) := X"3A";
signal s_op, s_opx : std_logic_vector(7 downto 0);

begin

s_op <= "00" & op;
s_opx <= "00" & opx;





next_cycle: process(clk,reset_n) is
begin
	if(reset_n = '0') then
		s_curr <= FETCH1;
	elsif(rising_edge(clk)) then
		s_curr <= s_next;
	end if;
end process;


statepro : process(s_op,s_opx,s_curr) is
	begin
		case s_curr is
		when  FETCH1 => 
			s_next <= FETCH2;

		when FETCH2 =>
			s_next <= DECODE;
		when LOAD1 =>
			s_next <= LOAD2;
		when BREAK => 
			s_next <= BREAK;

		when DECODE =>
			
			if( s_op = rtype and s_opx = X"34") then
				s_next <= BREAK;

			elsif s_op = X"15" then
				s_next <= STORE;

			elsif s_op = X"17" then
				s_next <= LOAD1;

			elsif s_op = X"04" or s_op = X"08" or s_op = X"10" or s_op = X"18" or s_op = X"20" then
				s_next <= I_OP;
			elsif s_op = X"06" or s_op = X"0E" or s_op = X"16" or s_op = X"1E" or s_op = X"26" or s_op = X"2E" or s_op = X"36" then
				s_next <= BRANCH;
			elsif s_op = X"00" or ( s_op = rtype and (s_opx = X"1D")) then
				s_next <= CALL;  
			elsif s_op = X"01" or (s_op = rtype and ( s_opx = X"05" or s_opx = X"0D")) then
				s_next <= JMP;
			elsif s_op = X"0C" or s_op = X"14" or s_op = X"28" or s_op = X"1C" or s_op = X"30" then
				s_next <= UI_OP;
			elsif  s_op = rtype and (s_opx = X"12" or s_opx = X"1A" or s_opx= X"3A" or s_opx = X"02") then
				s_next <= RI_OP;
			elsif  s_op = rtype then
				s_next <= R_OP;
			end if;
		when others => s_next <= FETCH1;

		end case;
	end process;

out_put : process(s_curr,s_op,s_opx) is
begin
	if (s_curr = LOAD1 or s_curr = FETCH1) then read <= '1'; else read <= '0';
	end if;
	if ( s_curr = FETCH2 or s_curr = CALL or s_curr = JMP) then pc_en <= '1'; else pc_en <= '0';
	end if;
	if ( s_curr = FETCH2) then ir_en <= '1'; else ir_en <= '0';
	end if;
	if(s_curr = RI_OP or s_curr = I_OP or s_curr = R_OP or s_curr = LOAD2 or s_curr = CALL or s_curr = UI_OP) then rf_wren <= '1'; else rf_wren <= '0';
	end if;
	if s_curr = I_OP or s_curr =  STORE or s_curr = LOAD1 then imm_signed <= '1'; else imm_signed <= '0';
	end if;
 	if s_curr = R_OP or s_curr = BRANCH then sel_b <='1'; else sel_b <= '0';
	end if;
	if s_curr = R_OP or s_curr = RI_OP or (s_curr = CALL and s_opx = X"1D") then sel_rC <= '1'; else sel_rC <='0';
	end if;
	if s_curr = LOAD1 or s_curr = STORE then sel_addr <= '1'; else sel_addr <= '0';
	end if;
	if s_curr = LOAD2 then sel_mem <= '1'; else sel_mem <= '0';
	end if;
	if s_curr = STORE then write <= '1'; else write <= '0';
	end if;
	if s_curr = BRANCH then pc_add_imm <= '1'; branch_op <= '1'; else pc_add_imm <= '0'; branch_op <= '0';
	end if;
	if (s_curr = CALL and s_op = X"00") or (s_curr = JMP and s_op = X"01") then pc_sel_imm <= '1'; else pc_sel_imm <= '0';
	end if;
	if s_curr = CALL then sel_pc <= '1'; sel_ra <= '1'; else sel_pc <= '0';  sel_ra <= '0';
	end if;
	if (s_curr = CALL and s_op = rtype) or  (s_curr = JMP and s_op = rtype) then pc_sel_a <= '1'; else pc_sel_a  <= '0';
	end if;

end process;
	
alu_outpute : process(s_op, s_opx) is 
begin
	if s_op = rtype then op_alu(2 downto 0) <= s_opx(5 downto 3);
	elsif s_op = X"06" then op_alu(2 downto 0) <= "100";
	else op_alu(2 downto 0) <= s_op(5 downto 3);
	end if;

	if (s_op = rtype and (s_opx = X"0E" or s_opx = X"06" or s_opx = X"16" or s_opx = X"1E")) or ( s_op = X"0C" or s_op = X"14" or s_op = X"1C") then op_alu(5 downto 3) <= "100";
	elsif s_op = rtype and s_opx = X"39" then op_alu(5 downto 3) <= "001";
	elsif s_op = rtype and ( s_opx = X"1B" or s_opx = X"13" or s_opx = X"3B" or s_opx = X"03" or s_opx = X"0B" or s_opx = X"12" or s_opx = X"1A" or s_opx = X"3A" or s_opx = X"02" ) then op_alu(5 downto 3) <= "110";
	--elsif  s_op = rtype and s_opx = X"31" then op_alu(5 downto 3) <= "000";
	elsif (s_op = rtype and (s_opx = X"08" or s_opx = X"10" or  s_opx = X"18" or s_opx = X"28" or s_opx = X"20" or s_opx = X"30")) or (s_op = X"0E" or s_op = X"16"  or s_op = X"1E"  or s_op = X"26" or s_op = X"2E" or s_op = X"36" or s_op = X"10"  or s_op = X"08" or s_op = X"18" or s_op = X"20"  or s_op = X"28" or s_op = X"30"  or s_op = X"06") then op_alu(5 downto 3) <= "011";	 
	else  op_alu(5 downto 3) <= "000";	
	end if;

end process;



end synth;
