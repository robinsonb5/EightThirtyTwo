library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.eightthirtytwo_pkg.all;

entity eightthirtytwo_hazard is
port(
	valid : std_logic;
	d_ex_op : e32_ex;
	d_reg : e32_reg;
	d_alu_reg1 : e32_regtype;
	d_alu_reg2 : e32_regtype;
	e_ex_op : e32_ex;
	e_reg : e32_reg;
	m_ex_op : e32_ex;
	m_reg : e32_reg;
	w_ex_op : e32_ex;
	hazard : out std_logic
);
end entity;

architecture rtl of eightthirtytwo_hazard is

signal hazard_tmp : std_logic;
signal hazard_pc : std_logic;
signal hazard_reg : std_logic;
signal hazard_load : std_logic;
signal hazard_flags : std_logic;

begin

-- hazard_tmp:
-- If the instruction being decoded requires tmp as either source we
-- block the transfer from D to E and the advance of PC
-- until any previous instruction writing to tmp has cleared the pipeline.
-- (If we don't implement ltmpinc or ltmp then nothing beyond M will write to the regfile.)

hazard_tmp<='1' when
	(e_ex_op(e32_exb_q1totmp)='1' or e_ex_op(e32_exb_q2totmp)='1'
		or m_ex_op(e32_exb_q1totmp)='1' or m_ex_op(e32_exb_q2totmp)='1'
		or e_ex_op(e32_exb_load)='1' or m_ex_op(e32_exb_load) ='1' or w_ex_op(e32_exb_load)='1')
		and (d_alu_reg1(e32_regb_tmp)='1' or d_alu_reg2(e32_regb_tmp)='1')
	else '0';


-- hazard_reg:
-- If the instruction being decoded requires a register as source we block
-- the transfer from D to E and the advance of PC until any previous
-- instruction writing to the regfile has cleared the pipeline.

hazard_reg<='1' when
	((e_ex_op(e32_exb_q1toreg)='1' and e_reg=d_reg)	or
		(m_ex_op(e32_exb_q1toreg)='1' and m_reg=d_reg))
		and ((d_alu_reg1(e32_regb_gpr)='1' or d_alu_reg2(e32_regb_gpr)='1'))
	else '0';

hazard_pc<='1' when
	(e_ex_op(e32_exb_q1toreg)='1' and e_reg="111")
		or (m_ex_op(e32_exb_q1toreg)='1' and m_reg="111")
	else '0';

	
-- Load hazard - if a load or store is in the pipeline we have to delay further loads/stores
-- and also ops which write to tmp.  FIXME - the latter can run against a store.
hazard_load<='1' when
	(d_ex_op(e32_exb_load)='1' or d_ex_op(e32_exb_store)='1'
			or d_ex_op(e32_exb_q1totmp)='1' or d_ex_op(e32_exb_q2totmp)='1') and 
	(e_ex_op(e32_exb_load)='1' or m_ex_op(e32_exb_load)='1' or w_ex_op(e32_exb_load)='1'
			or e_ex_op(e32_exb_store)='1' or m_ex_op(e32_exb_store)='1' or w_ex_op(e32_exb_store)='1')
	else '0';


-- We have a flags hazard with the sgn or cond instructions
-- if anything still in the pipeline is writing to the flags.
-- FIXME - might be able to remove sgn from this.
hazard_flags<='1' when
	(d_ex_op(e32_exb_cond)='1' or d_ex_op(e32_exb_sgn)='1')
		and (e_ex_op(e32_exb_flags)='1' or m_ex_op(e32_exb_flags)='1' or
			e_ex_op(e32_exb_load)='1' or m_ex_op(e32_exb_load)='1' or w_ex_op(e32_exb_load)='1')
	else '0';

hazard<=(not valid)
	or hazard_tmp
	or hazard_reg
	or hazard_pc
	or hazard_load
	or hazard_flags;

end architecture;
