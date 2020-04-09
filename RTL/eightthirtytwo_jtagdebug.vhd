library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.eightthirtytwo_pkg.all;

entity eightthirtytwo_jtagdebug is
port (
	clk : in std_logic;
	reset_n : in std_logic;
	addr : out std_logic_vector(31 downto 0);
	d : in std_logic_vector(31 downto 0);
	q : out std_logic_vector(31 downto 0);
	req : out std_logic;
	ack : in std_logic;
	wr : out std_logic;
	rdreg : out std_logic;
	setbrk : out std_logic;
	run : out std_logic;
	step : out std_logic
);
end entity;

architecture rtl of eightthirtytwo_jtagdebug is

type debugstate_t is (IDLE,SINGLESTEP,GO,READ,WRITE,READREG,BREAKPOINT);
signal debugstate : debugstate_t := IDLE;

signal counter : unsigned(3 downto 0) := X"0";

begin

process(clk)
begin
	if reset_n='0' then
		req<='0';
		wr<='0';
		rdreg<='0';
		setbrk<='0';
		step<='0';
		run<='0';
		addr<=X"00000000";
	elsif rising_edge(clk) then

		setbrk<='0';
		run<='0';
		step<='0';

		case debugstate is
			when IDLE =>
				counter<=counter+1;
				if counter=X"0" then
					debugstate<=SINGLESTEP;
				end if;

			when BREAKPOINT =>
				setbrk<='1';

			when GO => 
				run<='1';
				debugstate<=IDLE;

			when SINGLESTEP => 
				step<='1';
				debugstate<=IDLE;

			when others =>
				null;

		end case;

	end if;
end process;

end architecture;


