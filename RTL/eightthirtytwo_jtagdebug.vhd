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

begin

process(clk)
begin
	if reset_n='0' then
		req<='0';
		wr<='0';
		rdreg<='0';
		setbrk<='0';
		step<='0';
		addr<=X"00000000";
	end if;
end process;

end architecture;


