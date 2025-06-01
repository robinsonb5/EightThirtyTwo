
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Library UNISIM;
use UNISIM.vcomponents.all;

entity debug_virtualjtag_xilinx is
generic (
	irsize : integer := 2;
	drsize : integer := 32
);
port(
	ir_out : out std_logic_vector(irsize-1 downto 0);
	tdo : in std_logic;
	tck : out std_logic;
	tdi : out std_logic;
	virtual_state_cdr : out std_logic;
	virtual_state_sdr : out std_logic;
	virtual_state_udr : out std_logic;
	virtual_state_uir : out std_logic
);
end entity;

architecture rtl of debug_virtualjtag_xilinx is

signal cap : std_logic;
signal ir_sel : std_logic;
signal dr_sel : std_logic;
signal shift : std_logic;
signal update : std_logic;
signal ir_tck : std_logic;
signal ir_tdi : std_logic;
signal ir_tdo : std_logic;
signal ir_sreg : std_logic_vector(1 downto 0);

begin


-- Use chain 1 for virtual IR
irscan : BSCAN_SPARTAN3
port map (
	CAPTURE => cap,       -- 1-bit output: CAPTURE output from TAP controller.
	DRCK1 => ir_tck,      -- 1-bit output: Gated TCK output. When SEL is asserted, DRCK toggles when CAPTURE or
                         -- SHIFT are asserted.
	DRCK2 => tck,         -- 1-bit output: Gated TCK output. When SEL is asserted, DRCK toggles when CAPTURE or
	RESET=> open,         -- 1-bit output: Reset output for TAP controller.
	SEL1 => ir_sel,       -- 1-bit output: USER instruction active output.
	SEL2 => dr_sel,       -- 1-bit output: USER instruction active output.
	SHIFT => shift,       -- 1-bit output: SHIFT output from TAP controller.
	TDI => ir_tdi,        -- 1-bit output: Test Data Input (TDI) output from TAP controller.
	UPDATE => update,     -- 1-bit output: UPDATE output from TAP controller
	TDO1 => ir_tdo,       -- 1-bit input: Test Data Output (TDO) input for USER function.
	TDO2 => tdo        -- 1-bit input: Test Data Output (TDO) input for USER function.
);

ir_tdo <= ir_sreg(0);
ir_out <= ir_sreg;

process(ir_tck)
begin
	if rising_edge(ir_tck) then
		if ir_sel='1' and shift='1' then
			ir_sreg <= ir_tdi & ir_sreg(irsize-1 downto 1);
		end if;
	end if;
end process;

virtual_state_uir <= ir_sel and update;

virtual_state_cdr <= dr_sel and cap;
virtual_state_sdr <= dr_sel and shift;
virtual_state_udr <= dr_sel and update;

end architecture;

