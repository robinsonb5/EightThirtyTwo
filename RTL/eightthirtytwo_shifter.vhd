library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Shift and rotate unit
-- Very simple and slow - software should use the 64-bit multiplier
-- instead wherever possible.

entity eightthirtytwo_shifter is
port(
	clk : in std_logic;
	reset_n : in std_logic;
	d : in std_logic_vector(31 downto 0);
	q : out std_logic_vector(31 downto 0);
	shift : in std_logic_vector(4 downto 0);
--	immediate : in std_logic_vector(5 downto 0);
	right_left : in std_logic; -- 1 for right, 0 for left
	sgn : in std_logic;	-- Right shift only - logical (0) or arithmetic (1)?
	rotate : in std_logic;
	req : in std_logic;
	busy : out std_logic
);
end entity;

architecture rtl of eightthirtytwo_shifter is
	signal result : std_logic_vector(31 downto 0);
	signal count : unsigned(4 downto 0);
	signal signbit : std_logic;
begin

	q<=result;
	signbit<=sgn and d(31);

	process(clk,req,reset_n)
	begin

		if reset_n='0' then
			count<=(others=>'0');
		elsif rising_edge(clk) then

			if req='1' then
				count<=unsigned(shift);
				result<=d;
				busy<='1';
			else
				if count/="00000" then
					if rotate='1' then
						result(31)<=result(0);
						result(30 downto 0)<=result(31 downto 1);
					elsif right_left='1' then -- shift right, both logical and arithmetic
						result(31)<=signbit;
						result(30 downto 0)<=result(31 downto 1);
					else -- shift left - always shift in zeros
						result(31 downto 1)<=result(30 downto 0);
						result(0)<='0';
					end if;
					
					if count="00001" then
						busy<='0';
					end if;
					count<=count-1;

				end if;				
			end if;

		end if;
	end process;
end architecture;
