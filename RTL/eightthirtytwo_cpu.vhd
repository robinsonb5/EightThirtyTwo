library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.eightthirtytwo_pkg.all;

-- To do:
-- Flags - conditional execution
-- Sgn modifier
-- Hazards / stalls / bubbles
-- Load/store results
-- Predec / postinc

entity eightthirtytwo_cpu is
generic(
	pc_mask : std_logic_vector(31 downto 0) := X"ffffffff";
	stack_mask : std_logic_vector(31 downto 0) := X"ffffffff"
	);
port(
	clk : in std_logic;
	reset_n : in std_logic;
	addr : out std_logic_vector(31 downto 2);
	d : in std_logic_vector(31 downto 0);
	q : out std_logic_vector(31 downto 0);
	wr : out std_logic;
	req : out std_logic;
	ack : in std_logic;
	bytesel : out std_logic_vector(3 downto 0)
);
end entity;

architecture behavoural of eightthirtytwo_cpu is


-- Register file signals:

signal r_gpr_ra : std_logic_vector(2 downto 0);
signal r_gpr_wa : std_logic_vector(2 downto 0);
signal r_gpr_q : std_logic_vector(31 downto 0);
signal r_gpr_d : std_logic_vector(31 downto 0);
signal r_gpr_wr : std_logic;

signal r_tmp : std_logic_vector(31 downto 0); -- Working around a GHDL problem...

-- Load / store signals

signal ls_addr : std_logic_vector(31 downto 0);
signal ls_d : std_logic_vector(31 downto 0);
signal ls_q : std_logic_vector(31 downto 0);
signal ls_byte : std_logic;
signal ls_halfword : std_logic;
signal ls_req : std_logic;
signal ls_req_r : std_logic;
signal ls_wr : std_logic;
signal ls_ack : std_logic;


-- Fetch stage signals:

signal f_pc : std_logic_vector(31 downto 0);
signal f_op : std_logic_vector(7 downto 0);
signal f_prevop : std_logic_vector(7 downto 0);
signal f_op_valid : std_logic := '0' ;	-- Execute stage can use f_op


-- Decode stage signals:

signal d_alu_func : std_logic_vector(e32_alu_maxbit downto 0);
signal d_alu_reg1 : std_logic_vector(e32_reg_maxbit downto 0);
signal d_alu_reg2 : std_logic_vector(e32_reg_maxbit downto 0);
signal d_ex_op : std_logic_vector(e32_ex_maxbit downto 0);
signal d_run : std_logic;

-- Execute stage signals:

signal e_alu_func : std_logic_vector(e32_alu_maxbit downto 0);
signal e_alu_reg1 : std_logic_vector(e32_reg_maxbit downto 0);
signal e_alu_reg2 : std_logic_vector(e32_reg_maxbit downto 0);
signal e_reg : std_logic_vector(2 downto 0);
signal e_ex_op : std_logic_vector(e32_ex_maxbit downto 0);

signal e_setpc : std_logic;

signal alu_imm : std_logic_vector(5 downto 0);
signal alu_d1 : std_logic_vector(31 downto 0);
signal alu_d2 : std_logic_vector(31 downto 0);
signal alu_op : std_logic_vector(e32_alu_maxbit downto 0);
signal alu_q1 : std_logic_vector(31 downto 0);
signal alu_q2 : std_logic_vector(31 downto 0);
signal alu_sgn : std_logic;
signal alu_req : std_logic;
signal alu_carry : std_logic;
signal alu_busy : std_logic;


-- Memory stage signals

signal m_alu_reg1 : std_logic_vector(e32_reg_maxbit downto 0);
signal m_alu_reg2 : std_logic_vector(e32_reg_maxbit downto 0);
signal m_reg : std_logic_vector(2 downto 0);
signal m_ex_op : std_logic_vector(e32_ex_maxbit downto 0);

-- Writeback stage signals

signal w_alu_reg1 : std_logic_vector(e32_reg_maxbit downto 0);
signal w_alu_reg2 : std_logic_vector(e32_reg_maxbit downto 0);
signal w_reg : std_logic_vector(2 downto 0);
signal w_ex_op : std_logic_vector(e32_ex_maxbit downto 0);

-- hazard / stall signals

signal e_blocked : std_logic;

begin

-- Decoder

decoder: entity work.eightthirtytwo_decode
port map(
	clk => clk,
	reset_n => reset_n,
	opcode => f_op,
	alu_func => d_alu_func,
	alu_reg1 => d_alu_reg1,
	alu_reg2 => d_alu_reg2,
	ex_op => d_ex_op
);


-- Fetch/Load/Store unit is responsible for interfacing with main memory.
fetchloadstore : entity work.eightthirtytwo_fetchloadstore 
generic map(
	pc_mask => X"ffffffff"
	)
port map
(
	clk => clk,
	reset_n => reset_n,

	-- cpu fetch interface

	pc => f_pc,
	pc_req => e_setpc,
	opcode => f_op,
	opcode_valid => f_op_valid,

	-- cpu load/store interface

	ls_addr => ls_addr,
	ls_d => ls_d,
	ls_q => ls_q,
	ls_wr => ls_wr,
	ls_byte => ls_byte,
	ls_halfword => ls_halfword,
	ls_req => ls_req,
	ls_ack => ls_ack,

		-- external RAM interface:

	ram_addr => addr,
	ram_d => d,
	ram_q => q,
	ram_bytesel => bytesel,
	ram_wr => wr,
	ram_req => req,
	ram_ack => ack
);


-- Execute

alu : entity work.eightthirtytwo_alu
port map(
	clk => clk,
	reset_n => reset_n,

	imm => alu_imm,
	d1 => alu_d1,
	d2 => alu_d2,
	op => alu_op,
	sgn => alu_sgn,
	req => alu_req,

	q1 => alu_q1,
	q2 => alu_q2,
	carry => alu_carry,
	busy => alu_busy
);


-- Load/store

ls_req<=ls_req_r and not ls_ack;





-- Store stage



regfile : entity work.eightthirtytwo_regfile
generic map(
	pc_mask => X"ffffffff"
	)
port map(
	clk => clk,
	reset_n => reset_n,
	
	gpr_wa => r_gpr_wa,
	gpr_d => r_gpr_d,
	gpr_wr => r_gpr_wr,
	gpr_ra => r_gpr_ra,
	gpr_q => r_gpr_q
);

r_gpr_ra<=f_op(2 downto 0);

-- Experimentally making this combinational.  Will probably kill fmax!
e_alu_func<=d_alu_func;
e_alu_reg1<=d_alu_reg1;
e_alu_reg2<=d_alu_reg2;
e_reg<=f_op(2 downto 0);
e_ex_op<=d_ex_op;

e_blocked<='1' when
		((m_ex_op(e32_exb_q1totmp)='1' or m_ex_op(e32_exb_q2totmp)='1'
			or w_ex_op(e32_exb_q1totmp)='1' or w_ex_op(e32_exb_q2totmp)='1')	-- Blocks on tmp
			and (d_alu_reg1(e32_regb_tmp)='1' or d_alu_reg2(e32_regb_tmp)='1'))
	else '0';

process(clk,reset_n,f_op_valid)
begin
	if reset_n='0' then
		f_pc<=(others=>'0');
		e_setpc<='1';
		ls_req_r<='0';
	elsif rising_edge(clk) then
		d_run<='1';
		e_setpc<='0';

		if d_run='1' and f_op_valid='1' then


			-- Decode stage:

			alu_imm<=f_op(5 downto 0);

			-- Execute stage:  (Can we do some this combinationally? Probably not -
			-- must be registered so it doesn't change during ALU op.

			if e_blocked='1' then
				m_ex_op<=e32_ex_bubble;
			else
				f_pc<=std_logic_vector(unsigned(f_pc)+1);
				m_alu_reg1<=e_alu_reg1;
				m_alu_reg2<=e_alu_reg2;
				m_reg<=e_reg;
				m_ex_op<=e_ex_op;
				alu_req<='1';
			end if;

			alu_op<=e_alu_func;
			if e_alu_reg1(e32_regb_tmp)='1' then
				alu_d1<=r_tmp;
			elsif e_alu_reg1(e32_regb_pc)='1' then
				alu_d1<=f_pc;
			else
				alu_d1<=r_gpr_q;
			end if;

			if e_alu_reg2(e32_regb_tmp)='1' then
				alu_d2<=r_tmp;
			elsif e_alu_reg2(e32_regb_pc)='1' then
				alu_d2<=f_pc;
			else
				alu_d2<=r_gpr_q;
			end if;
			
			-- Mem stage
			-- FIXME - just plumbed in to evalate logic usage - still need to handle hazards / busy signals

			-- FIXME - need to move back a stage in the pipeline - addr from ALU isn't ready yet
			
			ls_halfword<=m_ex_op(e32_exb_halfword);
			ls_byte<=m_ex_op(e32_exb_halfword);
			if m_ex_op(e32_exb_load)='1' then
				ls_addr<=alu_q1;
				if ls_ack='1' then
					ls_req_r<='0';
					if w_alu_reg2(e32_regb_tmp)='1' then
						r_tmp<=ls_q;
					elsif w_alu_reg2(e32_regb_pc)='1' then
						f_pc<=ls_q;
						e_setpc<='1';
					else
						r_gpr_wa<=w_reg;
						r_gpr_wr<='1';
					end if;		
				else
					ls_req_r<='1';
				end if;
			end if;			

			if m_ex_op(e32_exb_store)='1' then
				ls_addr<=alu_q1;
				ls_d<=alu_q2;
				ls_wr<='1';
				if ls_ack='1' then
					ls_req_r<='0';
				else
					ls_req_r<='1';
				end if;
			end if;			
		
			-- Writeback stage

			if w_ex_op(e32_exb_q1totmp)='1' then
				r_tmp<=alu_q1;
			elsif w_ex_op(e32_exb_q2totmp)='1' then
				r_tmp<=alu_q2;
			end if;
			
			r_gpr_wa<=w_reg(2 downto 0);
			r_gpr_d<=alu_q1;
			r_gpr_wr<='0';
			if w_ex_op(e32_exb_q1toreg)='1' then
				if w_reg(2 downto 0)="111" then
					e_setpc<='1';
					f_pc<=alu_q1;
				else
					r_gpr_wr<='1';
				end if;
			end if;
			
			w_alu_reg1<=m_alu_reg1;
			w_alu_reg2<=m_alu_reg2;
			w_reg<=m_reg;
			w_ex_op<=m_ex_op;

	
	
		end if;
		
	end if;

	
end process;


end architecture;

