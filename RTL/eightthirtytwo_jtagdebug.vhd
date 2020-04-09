library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.eightthirtytwo_pkg.all;

entity eightthirtytwo_jtagdebug is
port (
	clk : in std_logic;
	reset_n : in std_logic;
	addr : out std_logic_vector(31 downto 0);
	d : in std_logic_vector(31 downto 0);
	q : out std_logic_vector(31 downto 0);
	req : out std_logic;
	ack : in std_logic;
	wr : out std_logic;
	rdreg : out std_logic;
	setbrk : out std_logic;
	run : out std_logic;
	step : out std_logic
);
end entity;

architecture rtl of eightthirtytwo_jtagdebug is

constant DBG832_RUN : std_logic_vector(7 downto 0) := X"02";
constant DBG832_SINGLESTEP : std_logic_vector(7 downto 0) := X"03";
constant DBG832_STEPOVER : std_logic_vector(7 downto 0) := X"04";
constant DBG832_READREG : std_logic_vector(7 downto 0) := X"05";
constant DBG832_READFLAGS : std_logic_vector(7 downto 0) := X"06";
constant DBG832_READ : std_logic_vector(7 downto 0) := X"07";
constant DBG832_WRITE : std_logic_vector(7 downto 0) := X"08";
constant DBG832_BREAKPOINT : std_logic_vector(7 downto 0) := X"09";

-- Transactions:
--   Step:  8-bit parameter, number of steps:
--     q(7 downto 0) 

type debugstate_t is (IDLE,SINGLESTEP,READADDR,READDATA,EXECUTE,READ);
signal debugstate : debugstate_t := IDLE;

signal jtag_cmd : std_logic_vector(7 downto 0);
signal jtag_parambytes : std_logic_vector(7 downto 0);
signal jtag_responsebytes : std_logic_vector(7 downto 0);
signal jtag_param : std_logic_vector(7 downto 0);
signal jtag_req : std_logic;
signal jtag_ack : std_logic;

signal jtag_d : std_logic_vector(31 downto 0);
signal jtag_q : std_logic_vector(31 downto 0);

signal counter : unsigned(3 downto 0) := X"0";
signal jtag_wr : std_logic;

begin

process(clk)
begin
	if reset_n='0' then
		req<='0';
		wr<='0';
		rdreg<='0';
		setbrk<='0';
		step<='0';
		run<='0';
		addr<=X"00000000";
	elsif rising_edge(clk) then

		rdreg<='0';
		setbrk<='0';
		run<='0';
		step<='0';
		jtag_ack<='0';

		case debugstate is
			when IDLE =>
				if jtag_req='1' then
					jtag_cmd<=jtag_d(31 downto 24);
					jtag_parambytes<=jtag_d(23 downto 16);
					jtag_responsebytes<=jtag_d(15 downto 8);
					jtag_param<=jtag_d(7 downto 0);
					q(7 downto 0)<=jtag_d(7 downto 0);

					case jtag_d(23 downto 16) is
						when X"00" =>
							debugstate<=EXECUTE;
						when X"04" =>
							debugstate<=READADDR;
						when X"08" =>
							debugstate<=READADDR;
						when others =>
							null;
					end case;
				end if;

--				counter<=counter+1;
--				if counter=X"0" then
--					debugstate<=SINGLESTEP;
--				end if;

			when READADDR =>
				if jtag_req='1' then
					addr<=jtag_d;
					if jtag_parambytes=X"08" then
						debugstate<=READDATA;
					else
						debugstate<=EXECUTE;
					end if;
				end if;

			when READDATA =>
				if jtag_req='1' then
					q<=jtag_d;
					debugstate<=EXECUTE;
				end if;

			when EXECUTE =>
				debugstate<=IDLE;
				case jtag_cmd is
					when DBG832_RUN =>
						run<='1';
					when DBG832_BREAKPOINT =>
						setbrk<='1';
					when DBG832_SINGLESTEP =>
						step<='1';
					when DBG832_STEPOVER =>
						-- FIXME - set breakpoint to PC + 1, then run.
					when DBG832_READREG =>
						rdreg<='1';
						debugstate<=READ;
					when DBG832_READ =>
						req<='1';
						wr<='0';
						debugstate<=READ;
					when DBG832_WRITE =>
						req<='1';
						wr<='1';
						debugstate<=READ;
					when others =>
						null;
				end case;


			when READ =>
				if ack='1' then
					-- FIXME - this can probably be done directly.	
					jtag_q<=d;
					jtag_ack<='1';
					wr<='0';
					req<='0';
					debugstate<=IDLE;
				end if;

			when others =>
				null;

		end case;

	end if;
end process;

end architecture;


