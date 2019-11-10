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

type e32_regfile is record
	tmp : std_logic_vector(31 downto 0);

	gpr_a : std_logic_vector(2 downto 0);
	gpr_q : std_logic_vector(31 downto 0);
	gpr0 : std_logic_vector(31 downto 0);
	gpr1 : std_logic_vector(31 downto 0);
	gpr2 : std_logic_vector(31 downto 0);
	gpr3 : std_logic_vector(31 downto 0);
	gpr4 : std_logic_vector(31 downto 0);
	gpr5 : std_logic_vector(31 downto 0);
	gpr6 : std_logic_vector(31 downto 0);
	gpr7 : std_logic_vector(31 downto 0);

-- The upper two bits of r7 will read as flags when and only when servicing an
-- interrupt, avoiding the need to save the flags separately; they're baked into
-- the return address.
	gpr7_flags : std_logic_vector(31 downto e32_pc_maxbit+1);
	gpr7_readflags : std_logic;

-- Status and condition flags
	flag_z : std_logic;
	flag_c : std_logic;
	flag_cond : std_logic;
	flag_sgn : std_logic;
	flag_interrupting : std_logic;
	flag_halfword : std_logic;

end record;

signal regfile : e32_regfile;

-- Status flags.  Z and C are used for conditional execution.

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

type e32_thread is record
	pc : std_logic_vector(e32_pc_maxbit downto 0);
	nextpc : std_logic_vector(e32_pc_maxbit downto 0);
	op : std_logic_vector(7 downto 0);
	op_valid : std_logic;
	-- Fetch stage signals, decoded combinationally.
	alu_op : std_logic_vector(e32_alu_maxbit downto 0);
	alu_reg1 : std_logic_vector(e32_reg_maxbit downto 0);
	alu_reg2 : std_logic_vector(e32_reg_maxbit downto 0);
	ex_op : std_logic_vector(e32_ex_maxbit downto 0);
	-- Decode stage signals, used for hazard calcs.
	d_imm : std_logic_vector(5 downto 0);
	d_reg : e32_reg;
	d_alu_op : std_logic_vector(e32_alu_maxbit downto 0);
	d_alu_reg1 : std_logic_vector(e32_reg_maxbit downto 0);
	d_alu_reg2 : std_logic_vector(e32_reg_maxbit downto 0);
	d_ex_op : e32_ex;
	-- Other signals
	interruptable : std_logic;
	hazard : std_logic;
end record;

signal thread : e32_thread;

-- Decode stage signals:



-- Execute stage signals:

signal e_continue : std_logic; -- Used to stretch postinc operations over two cycles.
signal e_reg : e32_reg;
signal e_ex_op : e32_ex;
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

signal m_reg : e32_reg;
signal m_ex_op : e32_ex;


-- Writeback stage signals
-- In fact writeback to registers is done at the M stage;
-- W only has to write the result of load operations to the temp register.

signal w_ex_op : e32_ex;


-- hazard / stall signals

signal stall : std_logic;

begin


-- Register file logic:

thread.nextpc<=std_logic_vector(unsigned(thread.pc)+1);
regfile.gpr_a<=thread.d_reg;

regfile.gpr7_flags(e32_fb_zero)<=regfile.flag_z;
regfile.gpr7_flags(e32_fb_carry)<=regfile.flag_c;
--regfile.gpr7_flags(e32_fb_cond)<=regfile.flag_cond;
--regfile.gpr7_flags(e32_fb_sgn)<=regfile.flag_sgn;
regfile.gpr7(e32_pc_maxbit downto 0)<=thread.pc;
regfile.gpr7(31 downto e32_pc_maxbit+1)<=regfile.gpr7_flags when regfile.gpr7_readflags='1' else (others => '0');
-- regfile.gpr7(29 downto e32_pc_maxbit+1)<=(others=>'X');

with regfile.gpr_a select regfile.gpr_q <=
	regfile.gpr0 when "000",
	regfile.gpr1 when "001",
	regfile.gpr2 when "010",
	regfile.gpr3 when "011",
	regfile.gpr4 when "100",
	regfile.gpr5 when "101",
	regfile.gpr6 when "110",
	regfile.gpr7 when "111",
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
		pc(e32_pc_maxbit downto 0) => thread.pc,
		pc_req => e_setpc,
		opcode => thread.op,
		opcode_valid => thread.op_valid,

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
		pc(e32_pc_maxbit downto 0) => thread.pc,
		pc_req => e_setpc,
		opcode => thread.op,
		opcode_valid => thread.op_valid,

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
	opcode => thread.op,
	alu_func => thread.alu_op,
	alu_reg1 => thread.alu_reg1,
	alu_reg2 => thread.alu_reg2,
	ex_op => thread.ex_op,
	interruptable => thread.interruptable
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
	sgn => regfile.flag_sgn,
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

-- thread.op_valid:
-- If the opcode supplied for the current PC is invalid, we must block D and the transfer
-- to E - but E, M and W must operate as usual, filling up with bubbles.


-- Hazard - causes bubbles to be inserted at E.

hazard1 : entity work.eightthirtytwo_hazard
port map(
	valid => thread.op_valid,
	d_ex_op=>thread.d_ex_op,
	d_reg=>thread.d_reg,
	d_alu_reg1=>thread.d_alu_reg1,
	d_alu_reg2=>thread.d_alu_reg2,
	e_ex_op=>e_ex_op,
	e_reg=>e_reg,
	m_ex_op=>m_ex_op,
	m_reg=>m_reg,
	w_ex_op=>w_ex_op,
	hazard => thread.hazard
);

-- Stall - causes the entire pipeline to pause, without inserting bubbles.

stall<='1' when e_ex_op(e32_exb_waitalu)='1' and alu_ack='0'
	else '0';
				
-- Condition minterms:

-- FIXME - need to make cond NEX pause the CPU,
-- or perhaps remap it somehow to "carry set, zero don't care"?

cond_minterms(3)<= regfile.flag_z and regfile.flag_c;
cond_minterms(2)<= (not regfile.flag_z) and regfile.flag_c;
cond_minterms(1)<= regfile.flag_z and (not regfile.flag_c);
cond_minterms(0)<= (not regfile.flag_z) and (not regfile.flag_c);

process(clk,reset_n,thread.op_valid)
begin
	if reset_n='0' then
		thread.pc<=(others=>'0');
		e_setpc<='1';
		ls_req_r<='0';
		ls_wr<='0';
		regfile.flag_cond<='0';
		regfile.flag_sgn<='0';
		regfile.flag_c<='0';
		regfile.flag_z<='0';
		thread.d_ex_op<=e32_ex_bubble;
		e_ex_op<=e32_ex_bubble;
		m_ex_op<=e32_ex_bubble;
		e_continue<='0';
		regfile.flag_interrupting<='0';
		regfile.flag_halfword<='0';
		regfile.gpr7_readflags<='0';
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
		-- We use the "continue" signal to prevent a bubble overwriting the op before the
		-- register update is complete.
		
		if alu_ack='1' then
			e_continue<='0';
		end if;
		
		if e_setpc='1' then
			thread.d_ex_op<=e32_ex_bubble;
		end if;
		
		if stall='0' and e_continue='0' then
		
			if thread.hazard='1' then
				e_ex_op<=e32_ex_bubble;
			else
				if thread.d_ex_op(e32_exb_postinc)='1' then
					e_continue<='1';
				end if;
				thread.pc<=thread.nextpc;
				alu_imm<=thread.d_imm;
			
				alu_op<=thread.d_alu_op;
				if thread.d_alu_reg1(e32_regb_tmp)='1' then
					alu_d1<=regfile.tmp;
				else
					alu_d1<=regfile.gpr_q;
				end if;

				if thread.d_alu_reg2(e32_regb_tmp)='1' then
					alu_d2<=regfile.tmp;
				else
					alu_d2<=regfile.gpr_q;
				end if;

				alu_req<=regfile.gpr7_readflags or (not regfile.flag_cond);

				if thread.d_ex_op(e32_exb_sgn)='1' then
					regfile.flag_sgn<='1';
				end if;

				e_reg<=thread.d_reg(2 downto 0);
				e_ex_op<=thread.d_ex_op;

				-- Fetch to Decode

				thread.d_imm <= thread.op(5 downto 0);
				thread.d_reg <= thread.op(2 downto 0);
				thread.d_alu_reg1<=thread.alu_reg1;
				thread.d_alu_reg2<=thread.alu_reg2;

				thread.d_ex_op<=thread.ex_op;
				thread.d_alu_op<=thread.alu_op;

				-- Conditional execution:
				-- If the cond flag is set, we replace anything in the E and M stages with bubbles.
				-- If we encounter a new cond instruction in the stream we forward it to the E stage.
				-- If we encounter an instruction writing to PC then we replace it with cond,
				-- which, since the operand will be "111", equates to "cond EX", i.e. full execution.

				if regfile.flag_cond='1' and regfile.gpr7_readflags='0' then	-- advance PC but replace instructions with bubbles
					e_ex_op<=e32_ex_bubble;
--					m_ex_op<=e32_ex_bubble;
					if thread.hazard='0' and (thread.d_ex_op(e32_exb_cond)='1' or
							(thread.d_ex_op(e32_exb_q1toreg)='1' and thread.d_reg="111")) then -- Writing to PC?
						e_ex_op<=e32_ex_cond;
						e_reg<=thread.d_reg;
						regfile.flag_cond<='0';
					end if;
				end if;

				-- Interrupt logic:
				if interrupts=true then
					if thread.interruptable='1' and interrupt='1'
								and (thread.d_ex_op(e32_exb_q1toreg)='0' or thread.d_reg/="111") -- Can't be about to write to r7
								and thread.d_ex_op(e32_exb_cond)='0' and thread.d_alu_op/=e32_alu_li and -- Can't be cond or a immediately previous li
									regfile.flag_interrupting='0' then
						regfile.flag_interrupting<='1';
						regfile.gpr7_readflags<='1';
						thread.d_reg<="111"; -- PC
						thread.d_alu_reg1<=e32_reg_gpr;
						thread.d_alu_reg2<=e32_reg_gpr;
						thread.d_alu_op<=e32_alu_xor;	-- Xor PC with itself; 0 -> PC, old PC -> tmp
						thread.d_ex_op<=e32_ex_q1toreg or e32_ex_q2totmp or e32_ex_flags; -- and zero flag set
					end if;
				end if;
			end if;
		end if;

		if interrupt='0' then
			regfile.flag_interrupting<='0';
		end if;

		if e_setpc='1' then -- Flush the pipeline //FIXME - should we flush E too?
			thread.d_ex_op<=e32_ex_bubble;
			thread.d_alu_op<=e32_alu_nop;
			regfile.gpr7_readflags<='0';
		end if;

		-- Mem stage

		-- Forward context from E to M
		m_reg<=e_reg;
		if	regfile.flag_cond='1' and regfile.gpr7_readflags='0' then
			m_ex_op<=e32_ex_bubble;
		else
			m_ex_op<=e_ex_op;
		end if;

		-- Load / store operations.
			
		-- If we have a postinc operation we need to avoid triggering the load/store a
		-- second time, so we filter on ls_req='0'
		
		if m_ex_op(e32_exb_load)='1' and ls_req_r='0' then
			ls_addr<=alu_q1;
			ls_d<=alu_q2;
			ls_halfword<=m_ex_op(e32_exb_halfword) or regfile.flag_halfword;
			ls_byte<=m_ex_op(e32_exb_byte);
			ls_req_r<='1';
			regfile.flag_halfword<='0';
		end if;

		if m_ex_op(e32_exb_store)='1' and ls_req_r='0' then
			ls_addr<=alu_q1;
			ls_d<=alu_q2;
			ls_halfword<=m_ex_op(e32_exb_halfword) or regfile.flag_halfword;
			ls_byte<=m_ex_op(e32_exb_byte);
			ls_wr<='1';
			ls_req_r<='1';
			regfile.flag_halfword<='0';
		end if;


		-- Either output of the ALU can go to tmp.

		if m_ex_op(e32_exb_q1totmp)='1' then
			regfile.tmp<=alu_q1;
		elsif m_ex_op(e32_exb_q2totmp)='1' then
			regfile.tmp<=alu_q2;
		end if;

		
		-- Only the first output of the ALU can be written to a GPR
		-- but we need to ensure that it happens on the second cycle of
		-- a postincrement operation.

		if m_ex_op(e32_exb_q1toreg)='1' and (m_ex_op(e32_exb_postinc)='0' or alu_ack='0') then
			case m_reg(2 downto 0) is
				when "000" =>
					regfile.gpr0<=alu_q1;
				when "001" =>
					regfile.gpr1<=alu_q1;
				when "010" =>
					regfile.gpr2<=alu_q1;
				when "011" =>
					regfile.gpr3<=alu_q1;
				when "100" =>
					regfile.gpr4<=alu_q1;
				when "101" =>
					regfile.gpr5<=alu_q1;
				when "110" =>
					regfile.gpr6<=alu_q1;
				when "111" =>
					e_setpc<='1';
					thread.pc<=alu_q1(e32_pc_maxbit downto 0);
					regfile.flag_z<=alu_q1(e32_fb_zero);
					regfile.flag_c<=alu_q1(e32_fb_carry);
				when others =>
					null;
			end case;
		end if;

		-- Record flags from ALU
		-- By doing this after saving registers we automatically get the zero flag
		-- set upon entering the interrupt routine.
		if m_ex_op(e32_exb_flags)='1' then
			regfile.flag_sgn<='0'; -- Any ALU op that sets flags will clear the sign modifier.
			if m_ex_op(e32_exb_halfword)='1' then	-- Modify the next load/store to operate on a halfword.
				regfile.flag_halfword<='1';
			end if;
			regfile.flag_c<=alu_carry;
			if alu_q1=X"00000000" then
				regfile.flag_z<='1';
			else
				regfile.flag_z<='0';
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
			regfile.tmp<=ls_q;
			if ls_q=X"00000000" then	-- Set Z flag
				regfile.flag_z<='1';
			else
				regfile.flag_z<='0';
			end if;
			regfile.flag_c<=ls_q(31);	-- Sign of the result to C
		end if;

		if e_ex_op(e32_exb_cond)='1' then
			if (e_reg(1)&e_reg and cond_minterms) = "0000" then
				regfile.flag_cond<='1';
			else
				regfile.flag_cond<='0';
			end if;			
		end if;
		
	end if;

	
end process;


end architecture;

