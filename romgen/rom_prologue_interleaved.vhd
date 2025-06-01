library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity eightthirtytwo_rom is
generic	(
	ADDR_WIDTH : integer := 8; -- ROM's address width (words, not bytes)
	COL_WIDTH  : integer := 8;  -- Column width (8bit -> byte)
	NB_COL     : integer := 4  -- Number of columns in memory
	);
port (
	clk : in std_logic;
	reset_n : in std_logic := '1';
	addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
	q : out std_logic_vector(COL_WIDTH*NB_COL-1 downto 0);
	-- Allow writes - defaults supplied to simplify projects that don't need to write.
	d : in std_logic_vector(COL_WIDTH*NB_COL-1 downto 0) := (others => '0');
	we : in std_logic := '0';
	bytesel : in std_logic_vector(NB_COL-1 downto 0) := (others => '1')
);
end entity;

architecture arch of eightthirtytwo_rom is
begin
rom0 : entity work.eightthirtytwo_rom_slice0
generic map (
	ADDR_WIDTH => ADDR_WIDTH
)
port map (
	clk => clk,
	reset_n => reset_n,
	addr => addr,
	q => q(31 downto 24),
	d => d(31 downto 24),
	we => we,
	sel => bytesel(3)
);

rom1 : entity work.eightthirtytwo_rom_slice1
generic map (
	ADDR_WIDTH => ADDR_WIDTH
)
port map (
	clk => clk,
	reset_n => reset_n,
	addr => addr,
	q => q(23 downto 16),
	d => d(23 downto 16),
	we => we,
	sel => bytesel(2)
);

rom2 : entity work.eightthirtytwo_rom_slice2
generic map (
	ADDR_WIDTH => ADDR_WIDTH
)
port map (
	clk => clk,
	reset_n => reset_n,
	addr => addr,
	q => q(15 downto 8),
	d => d(15 downto 8),
	we => we,
	sel => bytesel(1)
);

rom3 : entity work.eightthirtytwo_rom_slice3
generic map (
	ADDR_WIDTH => ADDR_WIDTH
)
port map (
	clk => clk,
	reset_n => reset_n,
	addr => addr,
	q => q(7 downto 0),
	d => d(7 downto 0),
	we => we,
	sel => bytesel(0)
);

end architecture;

