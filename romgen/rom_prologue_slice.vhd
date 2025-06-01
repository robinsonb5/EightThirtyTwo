library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity eightthirtytwo_rom_slice is
generic	(
	ADDR_WIDTH : integer := 8 -- ROM's address width (words, not bytes)
	);
port (
	clk : in std_logic;
	reset_n : in std_logic := '1';
	addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
	q : out std_logic_vector(7 downto 0);
	-- Allow writes - defaults supplied to simplify projects that don't need to write.
	d : in std_logic_vector(7 downto 0) := (others => '0');
	we : in std_logic := '0';
	sel : in std_logic := '0'
);
end entity;

architecture arch of eightthirtytwo_rom_slice is

-- type word_t is std_logic_vector(31 downto 0);
type ram_type is array (0 to 2 ** ADDR_WIDTH - 1) of std_logic_vector(7 downto 0);

signal ram : ram_type :=
(

