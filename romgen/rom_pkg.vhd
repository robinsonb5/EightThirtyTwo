
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package rom_pkg is

constant maxAddrBitBRAMLimit : integer := 15;
constant minAddrBit : integer := 2;
constant wordSize : integer := 32;

type toROM is record
	memAWriteEnable : std_logic;
	memAAddr : std_logic_vector(maxAddrBitBRAMLimit downto minAddrBit);
	memAWrite : std_logic_vector(wordSize-1 downto 0);
	memAByteSel : std_logic_vector(3 downto 0);
end record;

type fromROM is record
	memARead : std_logic_vector(wordSize-1 downto 0);
end record;

end rom_pkg;
