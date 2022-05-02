
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debug_virtualjtag_lattice is
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

architecture rtl of debug_virtualjtag_lattice is

signal ir_cap : std_logic;
signal ir_sel : std_logic;
signal ir_shift : std_logic;
signal ir_update : std_logic;
signal ir_tck : std_logic;
signal ir_tdi : std_logic;
signal ir_tdo : std_logic;
signal ir_sreg : std_logic_vector(1 downto 0);

signal dr_cap : std_logic;
signal dr_sel : std_logic;
signal dr_shift : std_logic;
signal dr_update : std_logic;

begin

-- FIXME - just a stub to make the project compile

end architecture;

