library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.eightthirtytwo_pkg.all;


entity eightthirtytwo_cpu is
generic(
	littleendian : boolean := true;
	storealign : boolean := true;
	interrupts : boolean := true
	);
port(
	clk : in std_logic;
	reset_n : in std_logic;
	interrupt : in std_logic := '0';
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
signal r_gpr_q : std_logic_vector(31 downto 0);
signal r_gpr0 : std_logic_vector(31 downto 0);
signal r_gpr1 : std_logic_vector(31 downto 0);
signal r_gpr2 : std_logic_vector(31 downto 0);
signal r_gpr3 : std_logic_vector(31 downto 0);
signal r_gpr4 : std_logic_vector(31 downto 0);
signal r_gpr5 : std_logic_vector(31 downto 0);
signal r_gpr6 : std_logic_vector(31 downto 0);
signal r_gpr7 : std_logic_vector(31 downto 0);
signal r_gpr7_flags : std_logic_vector(31 downto e32_pc_maxbit+1);
signal r_gpr7_readflags : std_logic;

signal r_tmp : std_logic_vector(31 downto 0);



signal flag_z : std_logic;
signal flag_c : std_logic;
signal flag_cond : std_logic;
signal flag_sgn : std_logic;
signal flag_interrupting : std_logic;
signal flag_halfword : std_logic;

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

signal f_pc : std_logic_vector(e32_pc_maxbit downto 0);
signal f_nextpc : std_logic_vector(e32_pc_maxbit downto 0);
signal f_op : std_logic_vector(7 downto 0);
signal f_alu_op : std_logic_vector(e32_alu_maxbit downto 0);
signal f_alu_reg1 : std_logic_vector(e32_reg_maxbit downto 0);
signal f_alu_reg2 : std_logic_vector(e32_reg_maxbit downto 0);
signal f_ex_op : std_logic_vector(e32_ex_maxbit downto 0);
signal f_op_valid : std_logic := '0' ;	-- Execute stage can use f_op
signal f_interruptable : std_logic;


-- Decode stage signals:
signal d_imm : std_logic_vector(5 downto 0);
signal d_reg : std_logic_vector(2 downto 0);
signal d_alu_op : std_logic_vector(e32_alu_maxbit downto 0);
signal d_alu_reg1 : std_logic_vector(e32_reg_maxbit downto 0);
signal d_alu_reg2 : std_logic_vector(e32_reg_maxbit downto 0);
signal d_ex_op : std_logic_vector(e32_ex_maxbit downto 0);

-- Execute stage signals:

signal e_continue : std_logic; -- Used to stretch postinc operations over two cycles.
signal e_pause_cond : std_logic;
signal e_reg : std_logic_vector(2 downto 0);
signal e_ex_op : std_logic_vector(e32_ex_maxbit downto 0);
signal cond_minterms : std_logic_vector(3 downto 0);

signal e_setpc : std_logic;

signal alu_imm : std_logic_vector(5 downto 0);
signal alu_d1 : std_logic_vector(31 downto 0);
signal alu_d2 : std_logic_vector(31 downto 0);
signal alu_op : std_logic_vector(e32_alu_maxbit downto 0);
signal alu_q1 : std_logic_vector(31 downto 0);
signal alu_q2 : std_logic_vector(31 downto 0);
signal alu_req : std_logic;
signal alu_carry : std_logic;
signal alu_ack : std_logic;


-- Memory stage signals

signal m_reg : std_logic_vector(2 downto 0);
signal m_ex_op : std_logic_vector(e32_ex_maxbit downto 0);

-- Writeback stage signals

signal w_ex_op : std_logic_vector(e32_ex_maxbit downto 0);

-- hazard / stall signals
signal hazard_tmp : std_logic;
signal hazard_pc : std_logic;
signal hazard_reg : std_logic;
signal hazard_load : std_logic;
signal hazard_flags : std_logic;

signal hazard : std_logic;
signal stall : std_logic;

begin


-- Register file logic:

f_nextpc<=std_logic_vector(unsigned(f_pc)+1);
r_gpr_ra<=d_reg;

r_gpr7_flags(e32_fb_zero)<=flag_z;
r_gpr7_flags(e32_fb_carry)<=flag_c;
--r_gpr7_flags(e32_fb_cond)<=flag_cond;
--r_gpr7_flags(e32_fb_sgn)<=flag_sgn;
r_gpr7(e32_pc_maxbit downto 0)<=f_pc;
r_gpr7(31 downto e32_pc_maxbit+1)<=r_gpr7_flags when r_gpr7_readflags='1' else (others => '0');
-- r_gpr7(29 downto e32_pc_maxbit+1)<=(others=>'X');

with r_gpr_ra select r_gpr_q <=
	r_gpr0 when "000",
	r_gpr1 when "001",
	r_gpr2 when "010",
	r_gpr3 when "011",
	r_gpr4 when "100",
	r_gpr5 when "101",
	r_gpr6 when "110",
	r_gpr7 when "111",
	(others=>'X') when others;	-- r7 is the program counter.



-- Fetch/Load/Store unit is responsible for interfacing with main memory.

GENBE:
if littleendian=false generate
	fetchloadstore : entity work.eightthirtytwo_fetchloadstore 
	generic map
	(
		storealign=>storealign
	)
	port map
	(
		clk => clk,
		reset_n => reset_n,

		-- cpu fetch interface

		pc(31 downto e32_pc_maxbit+1) => (others => '0'),
		pc(e32_pc_maxbit downto 0) => f_pc,
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
end generate;

GENLE:
if littleendian=true generate
	fetchloadstore : entity work.eightthirtytwo_fetchloadstore_le
	generic map
	(
		storealign=>storealign
	)
	port map
	(
		clk => clk,
		reset_n => reset_n,

		-- cpu fetch interface

		pc(31 downto e32_pc_maxbit+1) => (others => '0'),
		pc(e32_pc_maxbit downto 0) => f_pc,
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
end generate;


-- Decoder

decoder: entity work.eightthirtytwo_decode
port map(
	clk => clk,
	opcode => f_op,
	alu_func => f_alu_op,
	alu_reg1 => f_alu_reg1,
	alu_reg2 => f_alu_reg2,
	ex_op => f_ex_op,
	interruptable => f_interruptable
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
	sgn => flag_sgn,
	req => alu_req,

	q1 => alu_q1,
	q2 => alu_q2,
	carry => alu_carry,
	ack => alu_ack
);


-- Load/store

ls_req<=ls_req_r and not ls_ack;


-- Hazard / stall logic.
-- We don't yet attempt any results forwarding or instruction fusing.

-- f_op_valid:
-- If the opcode supplied for the current PC is invalid, we must block D and the transfer
-- to E - but E, M and W must operate as usual, filling up with bubbles.

-- hazard_tmp:
-- If the instruction being decoded requires tmp as either source we
-- block the transfer from D to E and the advance of PC
-- until any previous instruction writing to tmp has cleared the pipeline.
-- (If we don't implement ltmpinc or ltmp then nothing beyond M will write the regfile.)

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
-- (FIXME Can potentially make this finer-grained and match the actual register.)

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

-- Hazard - causes bubbles to be inserted at E.

hazard<=(not f_op_valid)
				or hazard_tmp
				or hazard_reg
				or hazard_pc
				or hazard_load
				or hazard_flags
				or e_pause_cond;

-- Stall - causes the entire pipeline to pause, without inserting bubbles.

stall<='1' when e_ex_op(e32_exb_waitalu)='1' and alu_ack='0'
	else '0';
				
-- Condition minterms:

-- FIXME - need to make cond NEX pause the CPU.

cond_minterms(3)<= flag_z and flag_c;
cond_minterms(2)<= (not flag_z) and flag_c;
cond_minterms(1)<= flag_z and (not flag_c);
cond_minterms(0)<= (not flag_z) and (not flag_c);

process(clk,reset_n,f_op_valid)
begin
	if reset_n='0' then
		f_pc<=(others=>'0');
		e_setpc<='1';
		ls_req_r<='0';
		ls_wr<='0';
		flag_cond<='0';
		flag_sgn<='0';
		flag_c<='0';
		flag_z<='0';
		d_ex_op<=e32_ex_bubble;
		e_ex_op<=e32_ex_bubble;
		m_ex_op<=e32_ex_bubble;
		e_continue<='0';
		flag_interrupting<='0';
		flag_halfword<='0';
		r_gpr7_readflags<='0';
	elsif rising_edge(clk) then
		e_setpc<='0';
		alu_req<='0';		

		-- If we have a hazard or we're blocked by conditional execution
		-- then we insert a bubble,
		-- otherwise advance the PC, forward context from D to E.

		-- We have a nasty hack here for postincrement.  Should find a better solution for this
		-- long-term.  In post-increment mode the ALU outputs the pre- and post-incremented
		-- address in q1 in successive cycles.  We need to use the first one to trigger the
		-- load/store operation and the second one to update the address register.
		
		if alu_ack='1' then
			e_continue<='0';
		end if;
		
		if e_setpc='1' then
			d_ex_op<=e32_ex_bubble;
		end if;
		
		if stall='0' and e_continue='0' then
		
			if e_continue='0' and (hazard='1') then
				e_ex_op<=e32_ex_bubble;
			else
	--			if e_continue='0' and (e_ex_op(e32_exb_waitalu)='0' or alu_ack='1') then
					if d_ex_op(e32_exb_postinc)='1' then
						e_continue<='1';
					end if;
					f_pc<=f_nextpc;
					alu_imm<=d_imm;
				
					alu_op<=d_alu_op;
					if d_alu_reg1(e32_regb_tmp)='1' then
						alu_d1<=r_tmp;
					else
						alu_d1<=r_gpr_q;
					end if;

					if d_alu_reg2(e32_regb_tmp)='1' then
						alu_d2<=r_tmp;
					else
						alu_d2<=r_gpr_q;
					end if;

					alu_req<=r_gpr7_readflags or (not flag_cond);

					if d_ex_op(e32_exb_sgn)='1' then
						flag_sgn<='1';
					end if;

					e_reg<=d_reg(2 downto 0);
					e_ex_op<=d_ex_op;

					-- Fetch to Decode

					d_imm <= f_op(5 downto 0);
					d_reg <= f_op(2 downto 0);
					d_alu_reg1<=f_alu_reg1;
					d_alu_reg2<=f_alu_reg2;

					d_ex_op<=f_ex_op;
					d_alu_op<=f_alu_op;

					-- Interrupt logic: FIXME - this slows down the ALU - can we move it to F?
					if interrupts=true then
						if f_interruptable='1' and interrupt='1'
									and (d_ex_op(e32_exb_q1toreg)='0' or d_reg/="111") -- Can't be about to write to r7
									and d_ex_op(e32_exb_cond)='0' and d_alu_op/=e32_alu_li and -- Can't be cond or a immediately previous li
										flag_interrupting='0' then
							flag_interrupting<='1';
							r_gpr7_readflags<='1';
							d_reg<="111"; -- PC
							d_alu_reg1<=e32_reg_gpr;
							d_alu_reg2<=e32_reg_gpr;
							d_alu_op<=e32_alu_xor;	-- Xor PC with itself; 0 -> PC, old PC -> tmp
							d_ex_op<=e32_ex_q1toreg or e32_ex_q2totmp or e32_ex_flags; -- and zero flag set
						end if;
					end if;

	--			end if;
			end if;
		end if;

		if interrupt='0' then
			flag_interrupting<='0';
		end if;

		if e_setpc='1' then -- Flush the pipeline //FIXME - should we flush E too?
			d_ex_op<=e32_ex_bubble;
			d_alu_op<=e32_alu_nop;
			r_gpr7_readflags<='0';
		end if;

		-- Mem stage

		-- Forward context from E to M
		m_reg<=e_reg;
		m_ex_op<=e_ex_op;


		-- Load / store operations.
			
		-- If we have a postinc operation we need to avoid triggering the load/store a
		-- second time, so we filter on ls_req='0'
		
		if m_ex_op(e32_exb_load)='1' and ls_req_r='0' then -- and  (m_ex_op(e32_exb_waitalu)='0' or alu_busy='1') then
			ls_addr<=alu_q1;
			ls_d<=alu_q2;
			ls_halfword<=m_ex_op(e32_exb_halfword) or flag_halfword;
			ls_byte<=m_ex_op(e32_exb_byte);
			ls_req_r<='1';
			flag_halfword<='0';
		end if;

		if m_ex_op(e32_exb_store)='1' and ls_req_r='0' then
			ls_addr<=alu_q1;
			ls_d<=alu_q2;
			ls_halfword<=m_ex_op(e32_exb_halfword) or flag_halfword;
			ls_byte<=m_ex_op(e32_exb_byte);
			ls_wr<='1';
			ls_req_r<='1';
			flag_halfword<='0';
		end if;


		-- Either output of the ALU can go to tmp.

		if m_ex_op(e32_exb_q1totmp)='1' then
			r_tmp<=alu_q1;
		elsif m_ex_op(e32_exb_q2totmp)='1' then
			r_tmp<=alu_q2;
		end if;

		
		-- Only the first output of the ALU can be written to a GPR
		-- but we need to ensure that it happens on the second cycle of
		-- a postincrement operation.

		if m_ex_op(e32_exb_q1toreg)='1' and (m_ex_op(e32_exb_postinc)='0' or alu_ack='0') then
			case m_reg(2 downto 0) is
				when "000" =>
					r_gpr0<=alu_q1;
				when "001" =>
					r_gpr1<=alu_q1;
				when "010" =>
					r_gpr2<=alu_q1;
				when "011" =>
					r_gpr3<=alu_q1;
				when "100" =>
					r_gpr4<=alu_q1;
				when "101" =>
					r_gpr5<=alu_q1;
				when "110" =>
					r_gpr6<=alu_q1;
				when "111" =>
					e_setpc<='1';
					f_pc<=alu_q1(e32_pc_maxbit downto 0);
					flag_z<=alu_q1(e32_fb_zero);
					flag_c<=alu_q1(e32_fb_carry);
--					flag_cond<=alu_q1(e32_fb_cond);
--					flag_sgn<=alu_q1(e32_fb_sgn);
				when others =>
					null;
			end case;
		end if;

		-- Record flags from ALU
		-- By doing this after saving registers we automatically get the zero flag
		-- set upon entering the interrupt routine.
		if m_ex_op(e32_exb_flags)='1' then
			flag_sgn<='0'; -- Any ALU op that sets flags will clear the sign modifier.
			if m_ex_op(e32_exb_halfword)='1' then	-- Modify the next load/store to operate on a halfword.
				flag_halfword<='1';
			end if;
			flag_c<=alu_carry;
			if alu_q1=X"00000000" then
				flag_z<='1';
			else
				flag_z<='0';
			end if;
		end if;

		-- Forward operation to the load/store receive stage.

		if ls_req_r='0' or ls_ack='1' then
			if m_ex_op(e32_exb_load)='1' or m_ex_op(e32_exb_store)='1' then
				w_ex_op<=m_ex_op;
			else
				w_ex_op<=e32_ex_bubble;
			end if;
		end if;

		if w_ex_op(e32_exb_store)='1' and ls_ack='1' then
			ls_req_r<='0';
			ls_wr<='0';
		end if;			

		if w_ex_op(e32_exb_load)='1' and ls_ack='1' then
			ls_req_r<='0';
			ls_wr<='0';
			r_tmp<=ls_q;
			if ls_q=X"00000000" then	-- Set Z flag
				flag_z<='1';
			else
				flag_z<='0';
			end if;
			flag_c<=ls_q(31);	-- Sign of the result to C
		end if;

		
		-- Conditional execution:
		-- If the cond flag is set, we replace anything in the E and M stages with bubbles.
		-- If we encounter a new cond instruction in the stream we forward it to the E stage.
		-- If we encounter an instruction writing to PC then we replace it with cond,
		-- which, since the operand will be "111", equates to cond EX, i.e. full execution.

		e_pause_cond<='0';
		if flag_cond='1' and r_gpr7_readflags='0' then	-- advance PC but replace instructions with bubbles
			e_ex_op<=e32_ex_bubble;
			m_ex_op<=e32_ex_bubble;
			if hazard='0' and (d_ex_op(e32_exb_cond)='1' or
					(d_ex_op(e32_exb_q1toreg)='1' and d_reg="111")) then -- Writing to PC?
				e_ex_op<=e32_ex_cond;
				e_reg<=d_reg;
				flag_cond<='0';
			end if;
		end if;

		if e_ex_op(e32_exb_cond)='1' then
			if (e_reg(1)&e_reg and cond_minterms) = "0000" then
				flag_cond<='1';
			else
				flag_cond<='0';
			end if;			
		end if;
		
	end if;

	
end process;


end architecture;

