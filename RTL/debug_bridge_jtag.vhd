library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debug_bridge_jtag is
port (
	clk : in std_logic;
	reset_n : in std_logic;
	d : in std_logic_vector(31 downto 0);
	q : out std_logic_vector(31 downto 0);
	req : in std_logic;
	wr : in std_logic;
	ack : buffer std_logic
);
end entity;

architecture rtl of debug_bridge_jtag is

type states is (IDLE, READADDR,GETRESPONSE,STEP);
signal state : states ;
signal counter : unsigned(15 downto 0);
signal data : std_logic_vector(31 downto 0);

-- JTAG signals

constant TX	: std_logic_vector(1 downto 0) := "00";
constant RX	: std_logic_vector(1 downto 0) := "01";
constant STATUS : std_logic_vector(1 downto 0) := "10";
constant BYPASS : std_logic_vector(1 downto 0) := "11";

signal ir_in : std_logic_vector(1 downto 0);
signal ir_out : std_logic_vector(1 downto 0);
signal ir : std_logic_vector(1 downto 0);
signal vstate_cdr : std_logic;
signal vstate_sdr : std_logic;
signal vstate_udr : std_logic;
signal vstate_uir : std_logic;
signal tdo : std_logic;
signal tdi : std_logic;
signal tck : std_logic;

signal cdr_d : std_logic;
signal sdr_d : std_logic;

signal shift : std_logic_vector(31 downto 0);
signal bp : std_logic_vector(1 downto 0);

-- FIFO control signals

signal txmt : std_logic;
signal txfl : std_logic;
signal txdata : std_logic_vector(31 downto 0);
signal txwr_req : std_logic;
signal txrd_req : std_logic;

signal rxmt : std_logic;
signal rxfl : std_logic;
signal rxwr_req : std_logic;
signal rxrd_req : std_logic;

begin

ir_out <= ir_in;
tdo <= bp(0) when ir=BYPASS else shift(0);


virtualjtag : entity work.debug_virtualjtag
port map(
	ir_in => ir_in,
	ir_out => ir_out,
	tdo => tdo,
	tck => tck,
	tdi => tdi,
	virtual_state_cdr => vstate_cdr,
	virtual_state_sdr => vstate_sdr,
	virtual_state_udr => vstate_udr,
	virtual_state_uir => vstate_uir
);



fifotojtag : entity work.debug_fifo_altera
port map (
--	aclr => not reset_n,

	data => d,
	wrclk => not clk,
	wrreq => txwr_req,
	wrfull => txfl,

	rdclk => not tck,
	rdreq => txrd_req,
	q => txdata,
	rdempty => txmt
);

txrd_req <= vstate_cdr when ir=TX else '0';


fifofromjtag : entity work.debug_fifo_altera
port map (
--	aclr => not reset_n,

	data => shift,
	wrclk => not tck,
	wrreq => rxwr_req,
	wrfull => rxfl,

	rdclk => not clk,
	rdreq => rxrd_req,
	q => q,
	rdempty => rxmt
);

rxwr_req <= vstate_udr when ir=RX else '0';


process(clk,reset_n)
begin

	if reset_n='0' then

	elsif rising_edge(clk) then
	
		rxrd_req<='0';
		txwr_req<='0';
		ack<='0';
	
		if req='1' and ack='0' then
			if wr='1' and txfl='0' then
				txwr_req<='1';
				ack<='1';
			elsif wr='0' and rxmt='0' then
				rxrd_req<='1';
			end if;
		end if;
		
		if rxrd_req='1' then
			ack<='1';
		end if;
	
	end if;

end process;


process (tck)
begin
	if falling_edge(tck) then
		cdr_d <= vstate_cdr;
		sdr_d <= vstate_sdr;

		if vstate_uir='1' then
			ir <= ir_in;
		end if;

	end if;

	if rising_edge(tck) then
		case ir is
			when TX =>
				if cdr_d='1' then
					shift <= txdata;
				elsif sdr_d='1' then
					shift <= tdi&shift(31 downto 1);
				end if;

			when RX =>
				if sdr_d='1' then
					shift <= tdi&shift(31 downto 1);
				end if;

			when STATUS =>
				if cdr_d='1' then
					shift <= X"0000000" & rxfl & rxmt & txfl & txmt;
				elsif sdr_d='1' then 
					shift <= tdi&shift(31 downto 1);
				end if;

			when others =>
				if sdr_d='1' then
					bp <= tdi&bp(1);
				end if;
		end case;

	end if;

end process;

end architecture;