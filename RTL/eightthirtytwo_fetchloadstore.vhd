library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- FIXME - add sign extension and zeroing of upper bits for byte or halfword loads

entity eightthirtytwo_fetchloadstore is
port
(
	clk : in std_logic;
	reset_n : in std_logic;

	-- cpu fetch interface

	pc_d : in std_logic_vector(31 downto 0); -- Program counter - in
	pc_q : out std_logic_vector(31 downto 0); -- Program counter - out.  Will always be the current instruction + 1
	pc_req : in std_logic; -- PC has changed, request a fetch.
	pc_next : in std_logic; -- Fetch the next opcode.
	opcode : out std_logic_vector(7 downto 0);
	opc_ready : out std_logic; -- opcode is valid.

	-- cpu load/store interface

	ls_addr : in std_logic_vector(31 downto 0);
	ls_d : in std_logic_vector(31 downto 0);
	ls_q : out std_logic_vector(31 downto 0);
	ls_wr : in std_logic;
	ls_byte : in std_logic;
	ls_halfword : in std_logic;
	ls_req : in std_logic;
	ls_ack : out std_logic;

	-- external RAM interface:

	ram_addr : out std_logic_vector(31 downto 2); -- Transfer 32-bit words.
	ram_d : in std_logic_vector(31 downto 0);
	ram_q : out std_logic_vector(31 downto 0);
	ram_bytesel : out std_logic_vector(3 downto 0); -- Select which bytes of the word should be written.  (Always "1111" for reads.)
	ram_wr : out std_logic; -- 0 for reads, 1 for writes.
	ram_req : out std_logic;
	ram_ack : in std_logic
);
end entity;

architecture behavioural of eightthirtytwo_fetchloadstore is

-- Fetch signals

signal pc : unsigned(31 downto 0);
signal pc_lsbs : std_logic_vector(1 downto 0);
signal programword : std_logic_vector(31 downto 0);

type fetchstates is (FS_RUNNING,FS_WAIT,FS_ABORT);
signal fetchstate : fetchstates;
signal fetch_jump : std_logic;

signal fetch_ram_req : std_logic;

-- Load store signals

signal load_store : std_logic; -- 1 for load, 0 for store.
type ls_states is (LS_WAIT, LS_PREPSTORE, LS_STORE, LS_STORE2, LS_STORE3, LS_LOAD, LS_LOAD2, LS_FETCH);
signal ls_state : ls_states;
signal ls_mask : std_logic_vector(3 downto 0);
signal ls_mask2 : std_logic_vector(3 downto 0);
signal ls_addrplus4 : unsigned(31 downto 0);

-- aligner signals
signal aligner_mask : std_logic_vector(3 downto 0);
signal aligner_shift : std_logic_vector(1 downto 0);
signal from_aligner : std_logic_vector(31 downto 0);
signal to_aligner : std_logic_vector(31 downto 0);

signal ram_req_r : std_logic;
signal ram_addr_r : std_logic_vector(31 downto 2);

begin


-- Fetch

pc_q <= std_logic_vector(pc);

opcode <= programword(31 downto 24) when pc_lsbs="00"
	else programword(23 downto 16) when pc_lsbs="01"
	else programword(15 downto 8) when pc_lsbs="10"
	else programword(7 downto 0);

process(pc_d,pc,clk,ram_ack,reset_n)
begin

	if rising_edge(clk) then
		if reset_n='0' then
			pc<=(others=>'0');
			fetch_ram_req<='0';
			fetchstate <= FS_RUNNING;
			programword <= (others=>'0');
			pc_lsbs<="00";
		else
			opc_ready<='0';

			case fetchstate is
				when FS_RUNNING =>
					if pc(1 downto 0)="00" then -- FIXME - deal with prefetch here
						fetch_ram_req<='1';
						fetchstate<=FS_WAIT;
					elsif pc_next='1' then
						pc_lsbs<=std_logic_vector(pc(1 downto 0));
						pc<=pc+1;
						opc_ready<='1';
					end if;

				when FS_ABORT =>
					if ram_ack='1' then
						fetch_ram_req<='1';
						fetchstate<=FS_WAIT;
					end if;

				when FS_WAIT =>
					if ram_ack='1' then
						fetch_ram_req<='0';
						programword<=ram_d;
						pc_lsbs<=std_logic_vector(pc(1 downto 0));
						pc<=pc+1;
						opc_ready<='1';
						fetchstate<=FS_RUNNING;
					end if;
						
				when others =>
					NULL;

			end case;

			if pc_req='1' then	-- PC has changed - could happen while fetching...
				pc<=unsigned(pc_d);
				fetch_ram_req<='1';
				if fetchstate /= FS_RUNNING and ram_ack='0' then -- Is a fetch pending?
					fetchstate<=FS_ABORT;
				else
					fetch_ram_req<='1';
					fetchstate<=FS_WAIT;
				end if;
			end if;

		end if;

	end if;
end process;


-- Load store



-- Memory interface

-- We want to assert ram_req immediately if we can:
ram_req<=fetch_ram_req when ls_state=LS_WAIT
	else ram_req_r and not ram_ack;

ram_addr<=std_logic_vector(pc(31 downto 2)) when ls_state=LS_WAIT and fetch_ram_req='1'
	else	ls_addr(31 downto 2) when ls_state=LS_WAIT and ls_req='1' and ls_wr='0'
	else ram_addr_r;

	
process(clk, reset_n, ls_req, ls_wr)
begin
	if reset_n='0' then
		ls_state<=LS_WAIT;
		ram_req_r<='0';
	elsif rising_edge(clk) then

		ls_addrplus4<=unsigned(ls_addr)+4;

		case ls_state is
			when LS_WAIT =>

				if fetch_ram_req='1' then
					ram_addr_r<=std_logic_vector(pc(31 downto 2));
					ram_req_r<='1';
					ls_state<=LS_FETCH;
				elsif ls_req='1' then
					if ls_wr='1' then
						load_store<='0';	-- Store operation.  Need to set mask
						ls_state<=LS_STORE;
					else
						ram_addr_r<=ls_addr(31 downto 2);
						ram_req_r<='1';
						load_store<='1';
						ls_state<=LS_LOAD;
					end if;	
				end if;

			when LS_FETCH =>
				if ram_ack='1' then
					ram_req_r<='0';
					ls_state<=LS_WAIT;
				end if;

			when LS_LOAD =>
				if ram_ack='1' then
					if ls_mask(3)='1' then
						ls_q(31 downto 24)<=from_aligner(31 downto 24);
					end if;
					if ls_mask(2)='1' then
						ls_q(23 downto 16)<=from_aligner(23 downto 16);
					end if;
					if ls_mask(1)='1' then
						ls_q(15 downto 8)<=from_aligner(15 downto 8);
					end if;
					if ls_mask(0)='1' then
						ls_q(7 downto 0)<=from_aligner(7 downto 0);
					end if;
					if ls_mask2="0000" then
						ram_req_r<='0';
						ls_ack<='1';
						ls_state<=LS_WAIT;
					else
						ram_addr_r<=std_logic_vector(ls_addrplus4(31 downto 2));
						ls_state<=LS_LOAD2;
					end if;
				end if;

			when LS_LOAD2 =>
				if ram_ack='1' then
					if ls_mask2(3)='1' then
						ls_q(31 downto 24)<=from_aligner(31 downto 24);
					end if;
					if ls_mask2(2)='1' then
						ls_q(23 downto 16)<=from_aligner(23 downto 16);
					end if;
					if ls_mask2(1)='1' then
						ls_q(15 downto 8)<=from_aligner(15 downto 8);
					end if;
					if ls_mask2(0)='1' then
						ls_q(7 downto 0)<=from_aligner(7 downto 0);
					end if;
					ram_req_r<='0';
					ls_ack<='1';
					ls_state<=LS_WAIT;
				end if;

			when LS_STORE =>
				ram_addr_r<=ls_addr(31 downto 2);
				ram_bytesel<=ls_mask;
				ram_req_r<='1';
				if ram_ack='1' then
					ls_state<=LS_STORE2;
				end if;

			when LS_STORE2 =>
				ram_addr_r<=std_logic_vector(ls_addrplus4(31 downto 2));
				ram_bytesel<=ls_mask2;
				ram_req_r<='1';
				ls_ack<='1';
				ls_state<=LS_STORE3;

			when LS_STORE3 =>				
				if ram_ack='1' then
					ram_req_r<='0';
					ls_state<=LS_WAIT;
				end if;
		
			when others =>
				null;

		end case;
	
	end if;
end process;



-- aligner

to_aligner <= ls_d when load_store='0' else ram_d;
ram_q<=from_aligner;

aligner : entity work.eightthirtytwo_aligner
port map(
	d => to_aligner,
	q => from_aligner,
	mask => ls_mask,
	mask2 => ls_mask2,
	load_store => load_store,
	addr => ls_addr(1 downto 0),
	byteop => ls_byte,
	halfwordop => ls_halfword
);


end architecture;


