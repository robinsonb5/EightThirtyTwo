library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.eightthirtytwo_pkg.all;


entity eightthirtytwo_alu is
port(
	clk : in std_logic;
	reset_n : in std_logic;

	imm : in std_logic_vector(5 downto 0);
	d1 : in std_logic_vector(31 downto 0);
	d2 : in std_logic_vector(31 downto 0);
	op : in std_logic_vector(3 downto 0);
	sgn : in std_logic;
	req : in std_logic;

	q1 : out std_logic_vector(31 downto 0);
	q2 : out std_logic_vector(31 downto 0);
	carry : out std_logic;
	busy : out std_logic
);
end entity;

architecture rtl of eightthirtytwo_alu is

signal sgn_mod : std_logic;
signal op_d : std_logic_vector(3 downto 0);
signal d1_2 : std_logic_vector(31 downto 0);
signal busycounter : unsigned(1 downto 0);
signal addresult : unsigned(32 downto 0);
signal subresult : unsigned(32 downto 0);
signal mulresult : unsigned(63 downto 0);
signal immresult : std_logic_vector(31 downto 0);

signal shiftresult : std_logic_vector(31 downto 0);
signal shiftbusy : std_logic;
signal shiftrl : std_logic;
signal shiftrot : std_logic;
signal shiftreq : std_logic;

signal immediatestreak : std_logic;

begin

sgn_mod<=sgn and (d1(31) xor d2(31));

with op select shiftreq <=
	req when e32_alu_shr,
	req when e32_alu_shl,
	req when e32_alu_ror,
	'0' when others;

with op select shiftrl <=
	'1' when e32_alu_shr,
	'1' when e32_alu_ror,
	'0' when others;

with op select shiftrot <=
	'1' when e32_alu_ror,
	'0' when others;

with op select d1_2 <=
	X"00000001" when e32_alu_incb,
	X"00000004" when e32_alu_incw,
	X"00000004" when e32_alu_decw,
	d1 when others;

with op_d select q1 <=
	std_logic_vector(addresult(31 downto 0)) when e32_alu_add,
	std_logic_vector(addresult(31 downto 0)) when e32_alu_incb,
	std_logic_vector(addresult(31 downto 0)) when e32_alu_incw,
	std_logic_vector(subresult(31 downto 0)) when e32_alu_sub,
	std_logic_vector(subresult(31 downto 0)) when e32_alu_decw,
	std_logic_vector(mulresult(31 downto 0)) when e32_alu_mul,
	(d1 and d2) when e32_alu_and,
	(d1 or d2) when e32_alu_or,
	(d1 xor d2) when e32_alu_xor,
	shiftresult when e32_alu_shl,
	shiftresult when e32_alu_shr,
	shiftresult when e32_alu_ror,
	d1 when others;

with op_d select q2 <=
	std_logic_vector(addresult(31 downto 0)) when e32_alu_addt,
	std_logic_vector(mulresult(63 downto 32)) when e32_alu_mul,
	immresult when e32_alu_li,
	d2 when others;

with op_d select carry <=
	addresult(32) xor sgn_mod when e32_alu_add,
	addresult(32) xor sgn_mod when e32_alu_addt,
	addresult(32) xor sgn_mod when e32_alu_sub,
	mulresult(63) xor sgn_mod when e32_alu_mul,
	'0' when others;
	
busy <=req or shiftbusy when busycounter="00" else '1';

process(clk,reset_n)
begin
	if reset_n='0' then
		busycounter<="00";
	elsif rising_edge(clk) then

		if busycounter/="00" then
			busycounter<=busycounter-1;
		end if;

		addresult <= unsigned('0'&d1_2) + unsigned('0'&d2);
		subresult <= unsigned('0'&d1_2) - unsigned('0'&d2);
		mulresult <= unsigned(d1) * unsigned(d2);
		op_d<=op;

		immediatestreak<='0';
		
		if req='1' then
			case op is
				when e32_alu_mul =>
					busycounter<="01";

				when e32_alu_li =>
					immediatestreak<='1';
					if immediatestreak='0' then
						immresult(31 downto 6)<=(others=>imm(5));
					else
						immresult(31 downto 6)<=immresult(25 downto 0);
					end if;
					immresult(5 downto 0)<=imm(5 downto 0);

				when others =>
					busycounter<="00";

			end case;
			
		end if;
		
	end if;
	
end process;

shifter : entity work.eightthirtytwo_shifter
port map(
	clk => clk,
	reset_n => reset_n,
	d => d1,
	q => shiftresult,
	shift => d2(4 downto 0),
--	immediate : in std_logic_vector(5 downto 0);
	right_left => shiftrl,
	sgn => sgn,
	rotate => shiftrot,
	req => shiftreq,
	busy => shiftbusy
);

end architecture;
