
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


library work;
use work.rom_pkg.all;

entity dualportram is
generic
	(
		maxAddrBitBRAM : natural := maxAddrBitBRAMLimit;
		BYTE_WIDTH : natural := 8;
		BYTES : natural := 4
--		maxAddrBitBRAM : integer := maxAddrBitBRAMLimit -- Specify your actual ROM size to save LEs and unnecessary block RAM usage.
	);
port (
	clk : in std_logic;
	areset : in std_logic := '0';
	from_soc : in toROM;
	to_soc : out fromROM
);
end entity;

architecture rtl of dualportram is

	alias be1 is from_soc.memAByteSel;
	alias be2 is from_soc.memBByteSel;
	alias we1 is from_soc.memAWriteEnable;
	alias we2 is from_soc.memBWriteEnable;
	alias data_in1 is from_soc.memAWrite;
	alias data_in2 is from_soc.memBWrite;
	signal addr1 : integer range 0 to 2**maxAddrBitBRAM-1;
	signal addr2 : integer range 0 to 2**maxAddrBitBRAM-1;
	alias data_out1 is to_soc.memARead;
	alias data_out2 is to_soc.memBRead;

	--  build up 2D array to hold the memory
	type word_t is array (0 to BYTES-1) of std_logic_vector(BYTE_WIDTH-1 downto 0);
	type ram_t is array (0 to 2 ** (maxAddrBitBRAM-1) - 1) of word_t;

	signal ram : ram_t:=
	(
