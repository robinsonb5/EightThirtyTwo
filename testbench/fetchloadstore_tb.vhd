library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.rom_pkg.all;

entity fetchloadstore_tb is
end fetchloadstore_tb;

architecture behaviour of fetchloadstore_tb
is
	constant clk_period : time := 10 ns;
	signal clk : std_logic;

	signal reset_n : std_logic;
	signal pc :std_logic_vector(31 downto 0);
	signal pc_req : std_logic;
	signal pc_next : std_logic;

	signal ram_addr : std_logic_vector(31 downto 2);
	signal from_ram : std_logic_vector(31 downto 0);
	signal to_ram : std_logic_vector(31 downto 0);
	signal ram_wr : std_logic;
	signal ram_bytesel : std_logic_vector(3 downto 0);
	signal ram_req : std_logic;
	signal ram_ack : std_logic;

	type tbstates is (RESET,INIT,MAIN);
	signal tbstate : tbstates:=RESET;

	signal romin : fromROM;
	signal romout : toROM;

begin

	rom : entity work.helloworld_rom
	port map(
		clk => clk,
		from_soc => romout,
		to_soc => romin
	);

	romout.MemAAddr<=ram_addr(15 downto 2);
	romout.MemAWrite<=to_ram;
	romout.MemAWriteEnable<=ram_wr and ram_req;
	romout.MemAByteSel<=ram_bytesel;
	from_ram<=romin.MemARead;

	fetchloadstore : entity work.eightthirtytwo_fetchloadstore
	port map
	(
		clk => clk,
		reset_n => reset_n,

		-- cpu fetch interface

		pc_d => pc,
		pc_q => open,
		pc_req => pc_req,
		pc_next => pc_next,
		opcode => open,
		opc_ready => open,

		-- cpu load/store interface

		ls_addr => (others =>'0'),
		ls_d => (others=>'0'),
		ls_q => open,
		ls_wr => '0',
		ls_byte => '0',
		ls_halfword => '0',
		ls_req => '0',
		ls_ack => open,

		-- external RAM interface:

		ram_addr => ram_addr,
		ram_d => from_ram,
		ram_q => to_ram,
		ram_bytesel => ram_bytesel,
		ram_wr => ram_wr,
		ram_req => ram_req,
		ram_ack => ram_ack
	);

  -- Clock process definition
  clk_process: process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;

	process(clk)
	begin

		if rising_edge(clk) then

			pc_req<='0';
			reset_n<='1';
			pc_next<='0';
			ram_ack<='1';
			if ram_req='1' then
				ram_ack<='1';
			end if;

			case tbstate is
				when RESET =>
					reset_n<='0';
					tbstate<=INIT;
				when INIT =>
					pc<=(others => '0');
					pc_req<='1';
					tbstate<=MAIN;
				when MAIN =>
					pc_next<='1';
					tbstate<=MAIN;

			end case;

		end if;

	end process;

end behaviour;

