library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.eightthirtytwo_pkg.all;

entity eightthirtytwo_cpu_comb is
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

architecture behavoural of eightthirtytwo_cpu_comb is


-- Register file signals:

signal r_gpr_a : std_logic_vector(2 downto 0);
signal r_gpr_q : std_logic_vector(31 downto 0);
signal r_gpr_d : std_logic_vector(31 downto 0);
signal r_gpr_wr : std_logic;

signal r_tmp : std_logic_vector(31 downto 0); -- Working around a GHDL problem...

signal flag_z : std_logic;
signal flag_c : std_logic;
signal flag_sgn : std_logic;
signal flag_cond : std_logic;

signal cond_minterms : std_logic_vector(3 downto 0);

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


-- ALU signals

signal alu_req : std_logic;
signal alu_req_r : std_logic;
signal alu_busy : std_logic;
signal alu_c : std_logic;
signal alu_q : std_logic_vector(31 downto 0);
signal alu_d1 : std_logic_vector(31 downto 0);
signal alu_d2 : std_logic_vector(31 downto 0);
signal alu_op : std_logic_vector(2 downto 0);


-- Shifter signals

signal shifter_req : std_logic;
signal shifter_req_r : std_logic;
signal shifter_ack : std_logic;
signal shifter_q : std_logic_vector(31 downto 0);
signal shifter_d : std_logic_vector(31 downto 0);
signal shifter_amt : std_logic_vector(5 downto 0);


-- Fetch stage signals:

signal f_pc : unsigned(31 downto 0);
signal f_op : std_logic_vector(7 downto 0);
signal f_op_valid : std_logic := '0' ;	-- Execute stage can use f_op


-- Decode stage signals:

--signal d_stall : std_logic;

signal d_blocked : std_logic;
signal d_bubble : std_logic;
signal d_immediatestreak : std_logic;
signal d_opcode : std_logic_vector(7 downto 0);
signal d_reg : std_logic_vector(2 downto 0);
signal d_regfile : std_logic;
signal d_readtmp : std_logic;
signal d_writetmp : std_logic;
signal d_alu : std_logic;
signal d_readflags : std_logic;
signal d_writeflags : std_logic;
signal d_loadstore : std_logic;

signal d_regpc : std_logic;
signal d_setpc : std_logic;


-- Execute stage signals:

signal e_blocked : std_logic;
signal e_stall : std_logic;
signal e_bubble : std_logic;
signal e_newpc : std_logic_vector(31 downto 0);
signal e_setpc : std_logic;

signal e_opcode : std_logic_vector(7 downto 0);
signal e_reg : std_logic_vector(2 downto 0);
signal e_regpc : std_logic;
signal e_writepc : std_logic;
signal e_regfile_s : std_logic; -- just an intermediate result
signal e_regfile : std_logic;
signal e_readtmp : std_logic;
signal e_writetmp : std_logic;
signal e_alu : std_logic;
signal e_readflags : std_logic;
signal e_writeflags : std_logic;
signal e_loadstore : std_logic;


-- Store stage signals

signal s_stall : std_logic;
signal s_bubble : std_logic;

signal s_opcode : std_logic_vector(7 downto 0);
signal s_reg : std_logic_vector(2 downto 0);
signal s_regpc : std_logic;
signal s_regfile : std_logic;
signal s_readtmp : std_logic;
signal s_writetmp : std_logic;
signal s_alu : std_logic;
signal s_loadstore : std_logic;
signal s_readflags : std_logic;
signal s_writeflags : std_logic;
signal s_waitloadstore : std_logic;
signal s_waitalu : std_logic;


-- Store stage signals

signal w_stall : std_logic;

signal w_q : std_logic_vector(31 downto 0);
signal w_wait : std_logic;
signal w_regfile : std_logic;
signal w_writepc : std_logic;
signal w_writetmp : std_logic;
signal w_writeflags : std_logic;
signal w_waitloadstore : std_logic;
signal w_waitalu : std_logic;
signal w_waitshifter : std_logic;

signal w_ls_to_tmp : std_logic;
signal w_ls_to_reg : std_logic;
signal w_ls_to_flags : std_logic;
signal w_ls_to_pc : std_logic;
signal w_alu_to_tmp : std_logic;
signal w_alu_to_reg : std_logic;
signal w_alu_to_flags : std_logic;
signal w_alu_to_pc : std_logic;

begin


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

	pc => std_logic_vector(f_pc),
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


alu : entity work.eightthirtytwo_alu 
port map
(
	clk => clk,
	reset_n => reset_n,

	operand1 => alu_d1,
	operand2 => alu_d2,
	operation => alu_op,
	sgn => flag_sgn,
	req => alu_req,

	result => alu_q,
	carry => alu_c,
	busy => alu_busy
);


--ls_req<=ls_req_r; --  and not ls_ack;
alu_req<=alu_req_r;
shifter_req<=shifter_req_r and not shifter_ack;

d_opcode<=f_op(7 downto 3) & "000";
d_reg<=f_op(2 downto 0);


-- Condition minterms:

cond_minterms(3)<= flag_z and flag_c;
cond_minterms(2)<= (not flag_z) and flag_c;
cond_minterms(1)<= flag_z and (not flag_c);
cond_minterms(0)<= (not flag_z) and (not flag_c);



-- Stall / bubble / hazard logic:

-- We have three pipeline stages: Fetch (F) / Decode (D), Execute (E) and Load/Store (S)
-- FIXME - need a fourth - Writeback (W)

-- D stage is purely combinational, so not really a stage in its own right.  
-- It extracts from the opcode which resources are required to start the operation.
-- Currently the critical path - this may be fixable just by using a smarter encoding.
-- Otherwise simply insert a register stage, at the cost of 1 cycle's latency between
-- PC changing and E.
-- Might also be better to calculate all stages' resources at D stage, rather than deriving
-- them combinationaly at each stage. 

-- FIXME D stage identifies instructions which write to R7.
-- Once one of these reached the EX stage we need to insert bubbles until it's cleared the
-- pipeline.

-- D stage creates bubbles when waiting for the opcode valid flag
-- FIXME - Needs to create them when resources are still tied up by the S stage too.  too.

-- E stage is responsible for advancing the PC, which it only does when d_bubble is low.
-- Currently a stall from the S stage will also prevent PC advancing - however that's
-- heavy-handed, and if the instruction being passed from D to E doesn't need the S stage
-- and doesn't collide with whatever S is doing, it can proceed.

-- All three stages generate combinational signals indicating which resources are in use:
-- writetmp, writereg, readtmp, readreg, writeflags, readflags, loadstore, alu
-- 'Cond', for example, can't be executed until after the flags have been written to,
-- so we want a d_bubble while anything that affects the flags is in S stage.

-- Suggest a d_blocked signal when the resources indicated by E and S are required by op in D.

-- Again, use an e_blocked signal to indicate when resources used by S are needed by E.

-- The S stage's resource signals indicate hazards to the previous stages, combinationally
-- from the opcode, and since those signals may cause the rest of the pipeline to stall,
-- we need to be able to clear them without anything coming from the previous stage.
-- Suggest simply setting s_opcode to 0.

-- D bubbles need to propagate through the pipeline, too - need to make sure we don't
-- retrigger the S part of an instruction.

-- W stage simply needs to wait for LS, ALU or Shifter operations to finish, and write the
-- results to either the regfile or tmp.



-- Decode stage, combinational logic:

d_regpc <='1' when d_opcode(7 downto 6)/="11" and d_reg="111" else '0';
d_setpc <= d_regpc and d_regfile; -- FIXME - EX stage can set cond=0 to prevent further instructions.
								 -- The PC change will clear the condition.  Might need an e_writereg for clearing cond.


d_regfile<='1' when	-- Might better to specify which instructions *don't* touch registers.
	d_opcode=e32_op_mr or
	(d_opcode=e32_op_exg and d_regpc='0') or
	d_opcode=e32_op_and or
	d_opcode=e32_op_or or
	d_opcode=e32_op_xor or
	d_opcode=e32_op_add or
	d_opcode=e32_op_addt or
	d_opcode=e32_op_sub or
	d_opcode=e32_op_mul or
	d_opcode=e32_op_ldinc or
	d_opcode=e32_op_ld or
	d_opcode=e32_op_st or
	d_opcode=e32_op_stdec
	else '0';

d_readtmp<='1' when -- Might better to specify which instructions *don't* touch temp.
	d_opcode(7 downto 6)="11" or -- li
	d_opcode=e32_op_and or
	d_opcode=e32_op_exg or
	d_opcode=e32_op_or or
	d_opcode=e32_op_xor or
	d_opcode=e32_op_add or
	d_opcode=e32_op_addt or
	d_opcode=e32_op_sub or
	d_opcode=e32_op_mul or
	d_opcode=e32_op_ldinc or
	d_opcode=e32_op_ld
--	d_opcode=e32_op_st	// Store instructions don't read tmp until the S stage.
--	d_opcode=e32_op_stdec
	else '0';

d_loadstore<='1' when
	d_opcode=e32_op_ld
	else '0';

d_alu<='1' when
	d_opcode=e32_op_and
	else '0';

d_readflags<='1' when
	d_opcode=e32_op_cond
	else '0';

-- FIXME - do we need this at all?  If so, add read/write variants.
d_blocked<=(d_readtmp and (e_readtmp or s_readtmp)) or
	(d_regfile and (e_regfile or s_regfile)) or
	(d_readflags and (e_writeflags or s_writeflags)) or
	(d_alu and (e_alu or s_alu));
	

--d_stall<='1' when (d_writetmp='1' and tmp_busy='1') or (d_writereg='1' and reg_busy='1')
--	else '0';


-- Execute stage, combinational logic:
-- These signals indicate what has to happen next in the load/store stage; if they don't collide
-- with what's currently happening in the load/store stage then we don't need to stall.

e_regpc <='1' when e_opcode(7 downto 6)/="11" and e_reg="111" else '0';

e_writepc<='1' when
	(e_opcode=e32_op_exg and e_regpc='1') or
	(e_opcode=e32_op_add and e_regpc='1')  or
	(e_opcode=e32_op_addt and e_regpc='1')  or
	(e_opcode=e32_op_sub and e_regpc='1')  or
	(e_opcode=e32_op_mr and e_regpc='1')
	else '0';

e_regfile_s<='1' when
	e_opcode=e32_op_exg or
	e_opcode=e32_op_and or
	e_opcode=e32_op_or or
	e_opcode=e32_op_xor or
	e_opcode=e32_op_add or
	e_opcode=e32_op_addt or
	e_opcode=e32_op_sub or
	e_opcode=e32_op_mul or
	e_opcode=e32_op_ld or
	e_opcode=e32_op_ldinc or
	e_opcode=e32_op_ldbinc or
	e_opcode=e32_op_st or
	e_opcode=e32_op_stdec or
	e_opcode=e32_op_stbinc
	else '0';

e_regfile<=e_regfile_s and not e_regpc;

e_readtmp<='1' when
	e_opcode=e32_op_exg or
	e_opcode=e32_op_ld or
	e_opcode=e32_op_ldinc or
	e_opcode=e32_op_ldbinc or
	e_opcode=e32_op_and or
	e_opcode=e32_op_or or
	e_opcode=e32_op_xor or
	e_opcode=e32_op_add or
	e_opcode=e32_op_addt or
	e_opcode=e32_op_sub or
	e_opcode=e32_op_mul
	else '0';

-- FIXME - this must include overloaded ops such as ldt
e_writetmp<='1' when
	e_opcode=e32_op_exg or
	e_opcode=e32_op_mt or
	e_opcode=e32_op_ld or
	e_opcode=e32_op_ldinc or
	e_opcode=e32_op_ldbinc
	else '0';

e_loadstore<='1' when
	e_opcode=e32_op_ld or
	e_opcode=e32_op_ldinc or
	e_opcode=e32_op_ldbinc or
	e_opcode=e32_op_st or
	e_opcode=e32_op_stdec or
	e_opcode=e32_op_stbinc
	else '0';

e_alu<='1' when
	e_opcode=e32_op_and or
	e_opcode=e32_op_or or
	e_opcode=e32_op_xor or
	e_opcode=e32_op_add or
	e_opcode=e32_op_addt or
	e_opcode=e32_op_sub or
	e_opcode=e32_op_mul or
	e_opcode=e32_op_ldinc or
	e_opcode=e32_op_ldbinc or
	e_opcode=e32_op_stdec or
	e_opcode=e32_op_stbinc
	else '0';

e_writeflags<='1' when
	e_opcode=e32_op_and or
	e_opcode=e32_op_or or
	e_opcode=e32_op_xor or
	e_opcode=e32_op_add or
	e_opcode=e32_op_addt or
	e_opcode=e32_op_sub or
	e_opcode=e32_op_mul or
	e_opcode=e32_op_ld or
	e_opcode=e32_op_ldinc or
	e_opcode=e32_op_ldbinc
	else '0';

e_readflags<='1' when
	e_opcode=e32_op_cond
	else '0';

e_blocked<=(e_readtmp and (s_writetmp or w_writetmp)) or
	(e_regfile and (s_regfile or w_regfile)) or
	(e_readflags and (s_writeflags or w_writeflags)) or
	(e_alu and s_alu) or
	w_writepc;

-- Load/Store stage, combinational logic:

s_regpc<='1' when s_reg="111" else '0';

s_regfile<='1' when
	(s_opcode=e32_op_exg and s_regpc='0') or
	s_opcode=e32_op_and or
	s_opcode=e32_op_or or
	s_opcode=e32_op_xor or
	s_opcode=e32_op_add or
	s_opcode=e32_op_addt or
	s_opcode=e32_op_sub or
	s_opcode=e32_op_mul
	else '0';

s_readtmp<='1' when
	s_opcode=e32_op_exg
	else '0';

s_writetmp<='1' when
	s_opcode=e32_op_exg or
	s_opcode=e32_op_ld or
	s_opcode=e32_op_ldinc or
	s_opcode=e32_op_ldbinc or
	s_opcode=e32_op_mt
	else '0';

s_readflags<='0';

s_writeflags<='1' when
	s_opcode=e32_op_and or
	s_opcode=e32_op_or or
	s_opcode=e32_op_xor or
	s_opcode=e32_op_add or
	s_opcode=e32_op_addt or
	s_opcode=e32_op_sub or
	s_opcode=e32_op_cmp or
	s_opcode=e32_op_mul or
	s_opcode=e32_op_ld or
	s_opcode=e32_op_ldinc or
	s_opcode=e32_op_ldbinc
	else '0';

s_loadstore<='1' when
	s_opcode=e32_op_ld or
	s_opcode=e32_op_ldinc or
	s_opcode=e32_op_ldbinc or
	s_opcode=e32_op_st or
	s_opcode=e32_op_stdec or
	s_opcode=e32_op_stbinc or
	s_opcode=e32_op_ltmpinc or
	s_opcode=e32_op_stmpdec
	else '0';

s_alu<='1' when
	s_opcode=e32_op_add or
	s_opcode=e32_op_addt or
	s_opcode=e32_op_sub or
	s_opcode=e32_op_cmp or
	s_opcode=e32_op_mul
	else '0';

s_waitloadstore<='1' when
	s_opcode=e32_op_ld or
	s_opcode=e32_op_ldinc or
	s_opcode=e32_op_ldbinc
	else '0';

--w_waitloadstore<='1' when
--	w_opcode=e32_op_ld or
--	w_opcode=e32_op_ldinc or
--	w_opcode=e32_op_ldbinc
--	else '0';

--w_waitalu<='1' when
--	w_opcode=e32_op_add or
--	w_opcode=e32_op_addt or
--	w_opcode=e32_op_sub or
--	w_opcode=e32_op_cmp or
--	w_opcode=e32_op_mul
--	else '0';

--w_waitshifter<='1' when
--	w_opcode=e32_op_shr or
--	w_opcode=e32_op_shl or
--	w_opcode=e32_op_ror
--	else '0';

w_stall <='1' when
	(w_waitloadstore='1' and ls_ack='0')
	or (w_waitalu='1' and alu_busy='1')
	or (w_waitshifter='1' and shifter_ack='0')
	else '0';

w_q <= ls_q when w_waitloadstore='1' else
	alu_q when w_waitalu='1' else
	shifter_q when w_waitshifter='1' else
	(others=>'X');

w_wait <= w_waitloadstore or w_waitalu or w_waitshifter;

d_bubble<=not f_op_valid;


-- synchronous logic

	
process(clk,reset_n,f_op_valid)
begin 

	if reset_n='0' then
		f_pc <= (others=>'0');
--		r_tmp<= (others=>'0');
		e_setpc <='1';
		flag_z<='0';
		flag_c<='0';
		flag_sgn<='0';
		flag_cond<='0';
		e_bubble<='0';
		s_bubble<='0';
		w_writepc<='0';
		w_writetmp<='0';
		w_writeflags<='0';
		w_regfile<='0';
		w_waitloadstore<='0';
		w_waitalu<='0';
		w_waitshifter<='0';
		s_stall<='0';

		ls_req<='0';
		alu_d1<=(others=>'0');
		alu_d2<=(others=>'0');
		alu_op<=e32_alu_add;
		alu_req_r<='0';
		shifter_req_r<='0';

	elsif rising_edge(clk) then

		e_setpc<='0';
		r_gpr_wr<='0';

--		-- Execute stage

		e_stall<='0';


		-- Transfer op from S to W, if possible.  Leave a bubble behind.

		if w_stall='0' then
			s_bubble<='1';
			s_opcode<=e32_op_li;
		end if;


		-- Transfer op from E to S, if possible, filling the bubble left in the S to W transfer.
		--  Leave a bubble behind.

		if w_stall='0' and flag_cond='0' then -- and e_blocked='0' then
			s_opcode<=e_opcode;
			s_bubble<='0';
			e_bubble<='1';
			e_opcode<=e32_op_li;
			s_reg<=e_reg;
		end if;

		-- Transfer op from D to E, if possible, filling the bubble left in the E to S transfer.

		-- This only needs to wait if the store stage is doing something that blocks the execute stage.

		if d_bubble='0' and d_blocked='0' and e_blocked='0' then -- and s_stall='0' then
			e_bubble<='0';
			e_opcode<=d_opcode;
			e_reg<=d_reg;
			f_pc <= f_pc+1;
		end if;

		if flag_cond='1' and e_writepc='1' then
			flag_cond<='0';
		end if;

		-- Execute load immediate...

		if d_bubble='0' and e_bubble='0' and w_stall='0' and (flag_cond='0' or e_opcode=e32_op_cond) then
			if e_opcode(7 downto 6)="11" then
				d_immediatestreak<='1';
				if d_immediatestreak='1' then	-- shift existing value six bits left...
					r_tmp<=r_tmp(25 downto 0) & e_opcode(5 downto 3) & e_reg(2 downto 0);
				else
					if e_opcode(5)='1' then
						r_tmp(31 downto 5)<=(others=>'1');
					else
						r_tmp(31 downto 5)<=(others=>'0');
					end if;
					r_tmp(5 downto 0)<=e_opcode(5 downto 3) & e_reg(2 downto 0);
				end if;
			else
				d_immediatestreak<='0';

				case e_opcode is
					when e32_op_cond =>	-- cond
						if (e_reg(1)&e_reg and cond_minterms) = "0000" then
							flag_cond<='1';
						else
							flag_cond<='0';
						end if;
		
	
					when e32_op_mr =>	-- mr
						r_gpr_d<=r_tmp;
						r_gpr_a<=e_reg;
						if e_regpc='1' then -- Updating the PC
							f_pc<=unsigned(r_tmp);
							e_setpc<='1';
						else
							r_gpr_wr<='1';
						end if;
	
					when e32_op_sub =>	-- sub
						r_gpr_a<=e_reg;
	
					when e32_op_cmp =>	-- cmp
						r_gpr_a<=e_reg;
	
					when e32_op_st =>	-- st
						r_gpr_a<=e_reg;
			
					when e32_op_stdec =>	-- stdec
						r_gpr_a<=e_reg;
	
					when e32_op_stbinc =>	-- stbinc
						r_gpr_a<=e_reg;
	
					when e32_op_stmpdec =>	-- stmpdec
						r_gpr_a<=e_reg;
	
					when e32_op_and =>	-- and
						r_gpr_a<=e_reg;
	
					when e32_op_or =>	-- or
						r_gpr_a<=e_reg;
	
					when e32_op_xor =>	-- xor
						r_gpr_a<=e_reg;

					when e32_op_shl =>	-- shl
						r_gpr_a<=e_reg;

					when e32_op_shr =>	-- shr
						r_gpr_a<=e_reg;

					when e32_op_ror =>	-- ror
						r_gpr_a<=e_reg;

					when e32_op_sth =>	-- sth
						r_gpr_a<=e_reg;

					when e32_op_mul =>	-- mul
						r_gpr_a<=e_reg;

					when e32_op_exg =>	-- exg
						if e_regpc='1' then
							f_pc<=unsigned(r_tmp);
							r_tmp<=std_logic_vector(f_pc+1);
							e_bubble<='1';
						else
							r_gpr_a<=e_reg;
						end if;
	
					when e32_op_mt =>	-- mt
						r_gpr_a<=e_reg;
	
					when e32_op_add =>	-- add
						r_gpr_a<=e_reg;

					when e32_op_addt =>	-- addt
						r_gpr_a<=e_reg;

					when e32_op_ld =>	-- ld
						r_gpr_a<=e_reg;

					when e32_op_ldinc =>	-- ldinc
						r_gpr_a<=e_reg;

					when e32_op_ldbinc =>	-- ldbinc
						r_gpr_a<=e_reg;

					when e32_op_ltmpinc =>	-- ltmpinc
						alu_d1<=r_tmp;

					when others =>
						null;

				end case;

			end if;

		end if;
	

		--		-- Writeback stage:

		if w_wait='1' then

			if ls_ack='1' then
				w_waitloadstore<='0';
				w_ls_to_tmp<='0';
				w_ls_to_reg<='0';
				w_ls_to_flags<='0';
				w_ls_to_pc<='0';
				ls_req<='0';
				ls_wr<='0';
				w_writetmp<='0'; -- FIXME - won't work for ldtmp / stmpinc
				w_regfile<='0'; -- FIXME - won't work for ldtmp / stmpinc
				w_writeflags<='0'; -- FIXME - won't work for ldtmp / stmpinc

				if w_ls_to_flags='1' then
					flag_z<='0';
					if ls_q=X"00000000" then
						flag_z<='1';
					end if;
				end if;

				if w_ls_to_tmp='1' then
					r_tmp<=ls_q;
					w_writetmp<='0';
				end if;

				if w_ls_to_reg='1' then
					r_gpr_d<=ls_q;
					r_gpr_wr<='1';
					w_regfile<='0';
				end if;

				if w_ls_to_pc='1' then
					f_pc<=unsigned(ls_q);
					e_setpc<='1';
					w_writepc<='0';
				end if;
			end if;


			if alu_busy='0' and w_waitalu='1' then
				w_waitalu<='0';
				w_alu_to_tmp<='0';
				w_alu_to_reg<='0';
				w_alu_to_flags<='0';
				w_alu_to_pc<='0';

				if w_alu_to_flags='1' then
					flag_z<='0';
					if alu_q=X"00000000" then
						flag_z<='1';
					end if;
					flag_c<=alu_c;
				end if;

				if w_alu_to_tmp='1' then
					r_tmp<=alu_q;
					w_writetmp<='0';
				end if;

				if w_alu_to_reg='1' then
					r_gpr_d<=alu_q;
					r_gpr_wr<='1';
					w_regfile<='0';
				end if;

				if w_alu_to_pc='1' then
					f_pc<=unsigned(alu_q);
					e_setpc<='1';
					w_writepc<='0';
				end if;

			end if;

			if shifter_ack='1' then
				w_waitshifter<='0';

				r_gpr_d<=shifter_q;
				r_gpr_wr<='1';
				w_regfile<='0';
			end if;

		end if;


		--		-- Load/store stage

		alu_req_r<='0';

		if s_bubble='0' then

			case s_opcode is		
				when e32_op_sub =>	-- sub
					if s_regpc='1' then
						alu_d1<=std_logic_vector(f_pc);
						w_alu_to_pc<='1';
					else
						alu_d1<=r_gpr_q;
						w_alu_to_reg<='1';
						w_alu_to_flags<='1';
					end if;
					alu_d2<=r_tmp;
					alu_op<=e32_alu_sub;
					alu_req_r<='1';

					w_writeflags<='1';
					w_regfile<='1';
					w_writetmp<='0';
					w_waitalu<='1';
			
				when e32_op_cmp =>	-- cmp
					alu_d1<=r_gpr_q;
					alu_d2<=r_tmp;
					alu_op<=e32_alu_add;
					alu_req_r<='1';
					w_alu_to_flags<='1';

					w_writeflags<='1';
					w_regfile<='0';
					w_writetmp<='0';
					w_waitalu<='1';


				when e32_op_st =>	-- st
					ls_addr<=r_gpr_q;
					ls_d<=r_tmp;
					ls_byte<='0';
					ls_halfword<='0';
					ls_wr<='1';
					ls_req<='1';

					w_writeflags<='0';
					w_writepc<='0';
					w_regfile<='0';
					w_writetmp<='0';
					w_waitloadstore<='1';
					
				when e32_op_stdec =>	-- stdec
					r_gpr_d<=std_logic_vector(unsigned(r_gpr_q)-4); -- FIXME - this hurts performance.  ALU?
					r_gpr_wr<='1';

					ls_addr<=std_logic_vector(unsigned(r_gpr_q)-4); -- FIXME - this hurts performance.  ALU?
					ls_d<=r_tmp;
					ls_byte<='0';
					ls_halfword<='0';
					ls_wr<='1';
					ls_req<='1';

					w_writeflags<='0';
					w_writepc<='0';
					w_regfile<='0';
					w_writetmp<='0';
					w_waitloadstore<='1';
			
				when e32_op_stbinc =>	-- stbinc
					r_gpr_d<=std_logic_vector(unsigned(r_gpr_q)+1); -- FIXME - this hurts performance.  ALU?
					r_gpr_wr<='1';

					ls_addr<=r_gpr_q;
					ls_d<=r_tmp;
					ls_byte<='1';
					ls_halfword<='0';
					ls_wr<='1';
					ls_req<='1';

					w_writeflags<='0';
					w_writepc<='0';
					w_regfile<='0';
					w_writetmp<='0';
					w_waitloadstore<='1';
			
				when e32_op_stmpdec =>	-- stmpdec
					ls_addr<=r_tmp;
					ls_d<=r_gpr_q;
					ls_byte<='0';
					ls_halfword<='0';
					ls_wr<='1';
					ls_req<='1';

					w_writeflags<='0';
					w_writepc<='0';
					w_regfile<='0';
					w_writetmp<='0';
					w_waitloadstore<='1';


				when e32_op_and =>	-- and
					alu_d1<=r_gpr_q;
					alu_d2<=r_tmp;
					alu_op<=e32_alu_and;
					alu_req_r<='1';

					w_writeflags<='1';
					w_writepc<='0';
					w_regfile<='1';
					w_writetmp<='0';
					w_waitalu<='1';
			
				when e32_op_or =>	-- or
					alu_d1<=r_gpr_q;
					alu_d2<=r_tmp;
					alu_op<=e32_alu_or;
					alu_req_r<='1';

					w_writeflags<='1';
					w_writepc<='0';
					w_regfile<='1';
					w_writetmp<='0';
					w_waitalu<='1';
			
				when e32_op_xor =>	-- xor
					alu_d1<=r_gpr_q;
					alu_d2<=r_tmp;
					alu_op<=e32_alu_xor;
					alu_req_r<='1';

					w_writeflags<='1';
					w_writepc<='0';
					w_regfile<='1';
					w_writetmp<='0';
					w_waitalu<='1';

				when e32_op_shl =>	-- shl

				when e32_op_shr =>	-- shr

				when e32_op_ror =>	-- ror

				when e32_op_sth =>	-- sth

				when e32_op_mul =>	-- mul
					alu_d1<=r_gpr_q;
					alu_d2<=r_tmp;
					alu_op<=e32_alu_mul;
					alu_req_r<='1';
					w_alu_to_reg<='1';
					w_alu_to_flags<='1';

					w_writeflags<='1';
					w_writepc<='0';
					w_regfile<='1';
					w_writetmp<='0';
					w_waitalu<='1';

				when e32_op_exg =>	-- exg - write to both tmp and regfile
					r_tmp<=r_gpr_q;
					r_gpr_d<=r_tmp;
					r_gpr_wr<='1';

				when e32_op_mt =>	-- mt
					r_tmp<=r_gpr_d;

				when e32_op_add =>	-- add
					if s_regpc='1' then -- Special-case adding to R7; old contents go to tmp
						alu_d1<=std_logic_vector(f_pc);
						r_tmp<=std_logic_vector(f_pc);
						w_regfile<='0';
						w_writepc<='1';
						w_alu_to_pc<='1';
					else
						w_writepc<='0';
						w_regfile<='1';
						w_alu_to_reg<='1';
						w_alu_to_flags<='1';
						alu_d1<=r_gpr_q;
					end if;
					alu_d2<=r_tmp;
					alu_op<=e32_alu_add;
					alu_req_r<='1';

					w_writeflags<='1';
					w_writetmp<='0';
					w_waitalu<='1';

				when e32_op_addt =>	-- addt
					if s_regpc='1' then
						alu_d1<=std_logic_vector(f_pc);
					else
						alu_d1<=r_gpr_q;
					end if;
					w_alu_to_tmp<='1';
					w_alu_to_flags<='1';
					alu_d2<=r_tmp;
					alu_op<=e32_alu_add;
					alu_req_r<='1';

					w_writeflags<='1';
					w_writepc<='0';
					w_regfile<='0';
					w_writetmp<='1';
					w_waitalu<='1';

				when e32_op_ld =>	-- ld
					ls_addr<=r_gpr_q;
					ls_byte<='0';
					ls_halfword<='0';
					ls_wr<='0';
					ls_req<='1';
					w_ls_to_tmp<='1';

					w_writeflags<='1';
					w_writepc<='0';
					w_regfile<='0';
					w_writetmp<='1';
					w_waitloadstore<='1';

				when e32_op_ldinc =>	-- ldinc
					-- FIXME - this can apply to the PC too.
--					r_gpr_d<=std_logic_vector(unsigned(r_gpr_q)+4); -- FIXME - this hurts performance.  ALU?
--					r_gpr_wr<='1';

					ls_addr<=r_gpr_q;
					ls_byte<='0';
					ls_halfword<='0';
					ls_wr<='0';
					ls_req<='1';
					w_writeflags<='1';
					w_writetmp<='1';
					w_ls_to_tmp<='1';
					w_waitloadstore<='1';

					alu_d1<=r_gpr_q;
					alu_d2<=X"00000004";
					alu_op<=e32_alu_add;
					alu_req_r<='1';
					w_waitalu<='1';
					w_alu_to_reg<='1';
					w_regfile<='1';
					if s_regpc='1' then -- Special-case adding to R7
						alu_d1<=std_logic_vector(f_pc);
						w_regfile<='0';
						w_writepc<='1';
					end if;
					w_waitalu<='1';


				when e32_op_ldbinc =>	-- ldbinc
					ls_addr<=r_gpr_q;
					ls_byte<='1';
					ls_halfword<='0';
					ls_wr<='0';
					ls_req<='1';
					w_writeflags<='1';
					w_writetmp<='1';
					w_ls_to_tmp<='1';
					w_waitloadstore<='1';

					alu_d1<=r_gpr_q;
					alu_d2<=X"00000001";
					alu_op<=e32_alu_add;
					alu_req_r<='1';
					w_waitalu<='1';
					w_alu_to_reg<='1';
					w_regfile<='1';
					if s_regpc='1' then -- Special-case adding to R7
						alu_d1<=std_logic_vector(f_pc);
						w_regfile<='0';
						w_writepc<='1';
					end if;
					w_waitalu<='1';

				when e32_op_ltmpinc =>	-- ltmpinc

				when others =>
					null;

			end case;

		end if;

	end if;

end process;

regfile : entity work.eightthirtytwo_regfile
generic map(
	pc_mask => X"ffffffff",
	stack_mask => X"ffffffff"
	)
port map(
	clk => clk,
	reset_n => reset_n,
	
	gpr_a => r_gpr_a,
	gpr_q => r_gpr_q,
	gpr_d => r_gpr_d,
	gpr_wr => r_gpr_wr
);

end architecture;
