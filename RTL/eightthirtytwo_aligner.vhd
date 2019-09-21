library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity eightthirtytwo_aligner is
port(
	d : in std_logic_vector(31 downto 0);
	q : out std_logic_vector(31 downto 0);
	addr : in std_logic_vector(1 downto 0);
	load_store : in std_logic; -- 1 for load, 0 for store
	mask : out std_logic_vector(3 downto 0);
	mask2 : out std_logic_vector(3 downto 0);
	byteop : in std_logic;
	halfwordop : in std_logic
);
end entity;

architecture rtl of eightthirtytwo_aligner is

signal shift : std_logic_vector(1 downto 0);
signal key : std_logic_vector(4 downto 0);

begin

	key<=load_store&halfwordop&byteop&addr; -- Just a convenient alias; will be optmised out.

	-- First figure out the shift amount and masks from the lower two address bits.

	shift <=
		-- full word load:
		"00" when key="10000" else
		"01" when key="10001" else
		"10" when key="10010" else
		"11" when key="10011" else
		-- byte load:
		"01" when key="10100" else
		"10" when key="10101" else
		"11" when key="10110" else
		"00" when key="10111" else
		-- halfword load:
		"10" when key="11000" else
		"11" when key="11001" else
		"00" when key="11010" else
		"01" when key="11011" else
		
		-- full word store:
		"00" when key="00000" else
		"11" when key="00001" else
		"10" when key="00010" else
		"01" when key="00011" else
		-- byte store:
		"11" when key="00100" else
		"10" when key="00101" else
		"01" when key="00110" else
		"00" when key="00111" else
		-- halfword store:
		"10" when key="01000" else
		"01" when key="01001" else
		"00" when key="01010" else
		"11" when key="01011" else

		"XX";

		
	-- First word's mask

	mask <=
		-- Full word load:
		"1111" when key="10000" else
		"1110" when key="10001" else
		"1100" when key="10010" else
		"1000" when key="10011" else
		-- byte load:
		"0001" when key="10100" else
		"0001" when key="10101" else
		"0001" when key="10110" else
		"0001" when key="10111" else
		-- halfword load:
		"0011" when key="11000" else
		"0011" when key="11001" else
		"0011" when key="11010" else
		"0010" when key="11011" else
		
		-- Full word store:
		"1111" when key="00000" else
		"0111" when key="00001" else
		"0011" when key="00010" else
		"0001" when key="00011" else
		-- byte store:
		"1000" when key="00100" else
		"0100" when key="00101" else
		"0010" when key="00110" else
		"0001" when key="00111" else
		-- halfword store:
		"1100" when key="01000" else
		"0110" when key="01001" else
		"0011" when key="01010" else
		"0001" when key="01011" else

		"XXXX";


	-- Second word's mask
		
	mask2 <= 
		-- Full word load:
		"0000" when key="10000" else
		"0001" when key="10001" else
		"0011" when key="10010" else
		"0111" when key="10011" else
		-- byte load:
		"0000" when key="10100" else
		"0000" when key="10101" else
		"0000" when key="10110" else
		"0000" when key="10111" else
		-- halfword accesses:
		"0000" when key="11000" else
		"0000" when key="11001" else
		"0000" when key="11010" else
		"0001" when key="11011" else
		
		-- Full word store:
		"0000" when key="00000" else
		"1000" when key="00001" else
		"1100" when key="00010" else
		"1110" when key="00011" else
		-- byte store:
		"0000" when key="00100" else
		"0000" when key="00101" else
		"0000" when key="00110" else
		"0000" when key="00111" else
		-- halfword store:
		"0000" when key="01000" else
		"0000" when key="01001" else
		"0000" when key="01010" else
		"1000" when key="01011" else

		"XXXX";

	-- Now do the actual shifting...
	
	q(31 downto 24) <= d(31 downto 24) when shift="00"
		else d(23 downto 16) when shift="01"
		else d(15 downto 8) when shift="10"
		else d(7 downto 0);

	q(23 downto 16) <= 
		d(23 downto 16) when shift="00"
		else d(15 downto 8) when shift="01"
		else d(7 downto 0) when shift="10"
		else d(31 downto 24);

	q(15 downto 8) <= 
		d(15 downto 8) when shift="00"
		else d(7 downto 0) when shift="01"
		else d(31 downto 24) when shift="10"
		else d(23 downto 16);

	q(7 downto 0) <= 
		d(7 downto 0) when shift="00"
		else d(31 downto 24) when shift="01"
		else d(23 downto 16) when shift="10"
		else d(15 downto 8);
		
end architecture;