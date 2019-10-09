
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


library work;
use work.rom_pkg.all;

entity helloworld_rom is
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

architecture rtl of helloworld_rom is

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
     0 => (x"d3",x"49",x"ff",x"c0"),
     1 => (x"48",x"c4",x"c0",x"4a"),
     2 => (x"68",x"9a",x"02",x"f8"),
     3 => (x"87",x"11",x"05",x"78"),
     4 => (x"f3",x"87",x"00",x"48"),
     5 => (x"65",x"6c",x"6c",x"6f"),
     6 => (x"2c",x"20",x"77",x"6f"),
     7 => (x"72",x"6c",x"64",x"21"),
     8 => (x"00",x"6c",x"64",x"21"),
		others => (others => x"00")
	);
	signal q1_local : word_t;
	signal q2_local : word_t;  

	-- Xilinx XST attributes
	attribute ram_style: string;
	attribute ram_style of ram: signal is "no_rw_check";

	-- Altera Quartus attributes
	attribute ramstyle: string;
	attribute ramstyle of ram: signal is "no_rw_check";

begin  -- rtl

	addr1 <= to_integer(unsigned(from_soc.memAAddr(maxAddrBitBRAM downto 2)));
	addr2 <= to_integer(unsigned(from_soc.memBAddr(maxAddrBitBRAM downto 2)));

	-- Reorganize the read data from the RAM to match the output
	unpack: for i in 0 to BYTES - 1 generate    
		data_out1(BYTE_WIDTH*(i+1) - 1 downto BYTE_WIDTH*i) <= q1_local((BYTES-1)-i);
		data_out2(BYTE_WIDTH*(i+1) - 1 downto BYTE_WIDTH*i) <= q2_local((BYTES-1)-i);    
	end generate unpack;
        
	process(clk)
	begin
		if(falling_edge(clk)) then 
			if(we1 = '1') then
				-- edit this code if using other than four bytes per word
				if(be1(3) = '1') then
					ram(addr1)(3) <= data_in1(7 downto 0);
				end if;
				if be1(2) = '1' then
					ram(addr1)(2) <= data_in1(15 downto 8);
				end if;
				if be1(1) = '1' then
					ram(addr1)(1) <= data_in1(23 downto 16);
				end if;
				if be1(0) = '1' then
					ram(addr1)(0) <= data_in1(31 downto 24);
				end if;
			end if;
			q1_local <= ram(addr1);
		end if;
	end process;

	process(clk)
	begin
		if(falling_edge(clk)) then 
			if(we2 = '1') then
				-- edit this code if using other than four bytes per word
				if(be2(3) = '1') then
					ram(addr2)(3) <= data_in2(7 downto 0);
				end if;
				if be2(2) = '1' then
					ram(addr2)(2) <= data_in2(15 downto 8);
				end if;
				if be2(1) = '1' then
					ram(addr2)(1) <= data_in2(23 downto 16);
				end if;
				if be2(0) = '1' then
					ram(addr2)(0) <= data_in2(31 downto 24);
				end if;
			end if;
			q2_local <= ram(addr2);
		end if;
	end process;  
  
end rtl;
