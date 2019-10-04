library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Shift and rotate unit

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

			busy<='1';

			if req='1' then
				count<=unsigned(shift);
				result<=d;
			else
				if count="00000" then
					busy<='0';
				else
					if rotate='1' then
						if count(4 downto 2)/="000" then
							result(31 downto 28)<=result(3 downto 0);
							result(27 downto 0)<=result(31 downto 4);
							count<=count-4;
						else
							result(31)<=result(0);
							result(30 downto 0)<=result(31 downto 1);
							count<=count-1;
						end if;
					elsif right_left='1' then -- shift right, both logical and arithmetic
						if count(4 downto 2)/="000" then
							result(31 downto 28)<=signbit & signbit & signbit & signbit;
							result(27 downto 0)<=result(31 downto 4);
							count<=count-4;
						else
							result(31)<=signbit;
							result(30 downto 0)<=result(31 downto 1);
							count<=count-1;
						end if;
					elsif right_left='0' then -- shift left - always shift in zeros
--						if count>6 then	-- six bits, incorporate immediate data if we have any.
--							result(31 downto 6)<=result(25 downto 0);
--							result(5 downto 0)<=immediate;
--							count<=count-6;
--						else
							result(31 downto 1)<=result(30 downto 0);
							result(0)<='0';
							count<=count-1;
--						end if;
					end if;

				end if;				
			end if;

		end if;
	end process;



end architecture;
