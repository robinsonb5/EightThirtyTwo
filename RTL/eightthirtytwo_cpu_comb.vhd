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

signal alu_ack : std_logic;

-- Fetch stage signals:

signal f_pc : unsigned(31 downto 0);
signal f_op : std_logic_vector(7 downto 0);
signal f_op_valid : std_logic := '0' ;	-- Execute stage can use f_op


-- Decode stage signals:

--signal d_stall : std_logic;
signal d_bubble : std_logic;
signal d_immediatestreak : std_logic;
signal d_opcode : std_logic_vector(7 downto 0);
signal d_reg : std_logic_vector(2 downto 0);
signal d_readreg : std_logic;
signal d_writereg : std_logic;
signal d_writetmp : std_logic;
signal d_alu : std_logic;
signal d_flags : std_logic;
signal d_loadstore : std_logic;

signal d_regpc : std_logic;
signal d_setpc : std_logic;


-- Execute stage signals:

signal e_stall : std_logic;
signal e_bubble : std_logic;
signal e_newpc : std_logic_vector(31 downto 0);
signal e_setpc : std_logic;

signal e_opcode : std_logic_vector(7 downto 0);
signal e_reg : std_logic_vector(2 downto 0);
signal e_regpc : std_logic;
signal e_readreg : std_logic;
signal e_writereg : std_logic;
signal e_writetmp : std_logic;
signal e_alu : std_logic;
signal e_flags : std_logic;
signal e_loadstore : std_logic;
signal e_nextop : std_logic;

-- Store stage signals

signal s_stall : std_logic;
signal s_bubble : std_logic;
signal es_bubble : std_logic;

signal s_opcode : std_logic_vector(7 downto 0);
signal s_reg : std_logic_vector(2 downto 0);
signal s_regpc : std_logic;
signal s_readreg : std_logic;
signal s_writereg : std_logic;
signal s_writetmp : std_logic;
signal s_writeflags : std_logic;
signal s_alu : std_logic;
signal s_loadstore : std_logic;
signal s_req : std_logic;
signal s_nextop : std_logic;
signal s_waitloadstore : std_logic;
signal s_waitalu : std_logic;

-- Busy signals
signal reg_busy : std_logic;
signal tmp_busy : std_logic;
signal alu_busy : std_logic;
signal loadstore_busy : std_logic;

begin

reg_busy<='1' when s_writereg='1' or e_writereg='1' or s_readreg='1' or s_writereg='1' else '0';
tmp_busy<='1' when s_writetmp='1' or e_writetmp='1' else '0';
alu_busy<='1' when s_alu='1' or e_alu='1' else '0';
loadstore_busy<='1' when s_loadstore='1' or e_loadstore='1' else '0';

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

ls_req<=ls_req_r and not ls_ack;

d_opcode<=f_op(7 downto 3) & "000";
d_reg<=f_op(2 downto 0);


-- Condition minterms:

cond_minterms(3)<= flag_z and flag_c;
cond_minterms(2)<= (not flag_z) and flag_c;
cond_minterms(1)<= flag_z and (not flag_c);
cond_minterms(0)<= (not flag_z) and (not flag_c);

-- Decode stage, combinational logic:

d_regpc <='1' when d_opcode(7 downto 6)/="11" and d_reg="111" else '0';
d_setpc <= d_regpc and d_writereg;

d_readreg<='1' when
	d_opcode=e32_op_and or
	d_opcode=e32_op_exg or
	d_opcode=e32_op_ld
	else '0';

d_writereg<='1' when
	d_opcode=e32_op_mr or
	(d_opcode=e32_op_exg and d_regpc='0') or
	d_opcode=e32_op_and or
	d_opcode=e32_op_or or
	d_opcode=e32_op_xor or
	d_opcode=e32_op_add or
	d_opcode=e32_op_addt or
	d_opcode=e32_op_sub or
	d_opcode=e32_op_mul
	else '0';

d_writetmp<='1' when
	d_opcode(7 downto 6)="11" or -- li
	d_opcode=e32_op_and or
	d_opcode=e32_op_exg or
	d_opcode=e32_op_ld
	else '0';

d_loadstore<='1' when
	d_opcode=e32_op_ld
	else '0';

d_alu<='1' when
	d_opcode=e32_op_and
	else '0';


--d_stall<='1' when (d_writetmp='1' and tmp_busy='1') or (d_writereg='1' and reg_busy='1')
--	else '0';


-- Execute stage, combinational logic:
-- These signals indicate what has to happen in the load/store stage; if they don't collide
-- with what's currently happening in the load/store stage then we don't need to stall.

e_regpc <='1' when e_opcode(7 downto 6)/="11" and e_reg="111" else '0';

e_readreg<='1' when
	e_opcode=e32_op_and or
	e_opcode=e32_op_exg
	else '0';

e_writereg<='1' when
	(e_opcode=e32_op_exg and e_regpc='0') or
	e_opcode=e32_op_and or
	e_opcode=e32_op_or or
	e_opcode=e32_op_xor or
	e_opcode=e32_op_add or
	e_opcode=e32_op_addt or
	e_opcode=e32_op_sub or
	e_opcode=e32_op_mul
	else '0';

e_writetmp<='1' when
	e_opcode=e32_op_exg or
	e_opcode=e32_op_ld
	else '0';

e_loadstore<='1' when
	e_opcode=e32_op_ld
	else '0';

e_alu<='1' when
	e_opcode=e32_op_and
	else '0';


-- Load/Store stage, combinational logic:

s_regpc<='1' when s_reg="111" else '0';

s_readreg<='0' when
	s_opcode=e32_op_and or
	s_opcode=e32_op_or or
	s_opcode=e32_op_xor or
	s_opcode=e32_op_exg
	else '0';

s_writereg<='1' when
	(s_opcode=e32_op_exg and s_regpc='0') or
	s_opcode=e32_op_and or
	s_opcode=e32_op_or or
	s_opcode=e32_op_xor or
	s_opcode=e32_op_add or
	s_opcode=e32_op_addt or
	s_opcode=e32_op_sub or
	s_opcode=e32_op_mul
	else '0';

s_writetmp<='1' when
	s_opcode=e32_op_exg or
	s_opcode=e32_op_ld
	else '0';

s_writeflags<='1' when
	s_opcode=e32_op_and or
	s_opcode=e32_op_or or
	s_opcode=e32_op_xor or
	s_opcode=e32_op_add or
	s_opcode=e32_op_addt or
	s_opcode=e32_op_sub or
	s_opcode=e32_op_cmp or
	s_opcode=e32_op_mul
	else '0';

s_loadstore<='1' when
	s_opcode=e32_op_ld
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
	s_opcode=e32_op_ldinc
	else '0';

s_waitalu<='1' when
	s_opcode=e32_op_add or
	s_opcode=e32_op_addt or
	s_opcode=e32_op_sub or
	s_opcode=e32_op_cmp or
	s_opcode=e32_op_mul
	else '0';

s_stall <='1' when
	(s_waitloadstore='1' and ls_ack='0') or
	(s_waitalu='1' and alu_ack='0')
	else '0';

d_bubble<=not f_op_valid;


-- synchronous logic

	
process(clk,reset_n,f_op_valid)
begin 

	if reset_n='0' then
		f_pc <= (others=>'0');
		e_setpc <='1';
		flag_z<='0';
		flag_c<='0';
		flag_sgn<='0';
		flag_cond<='0';
	elsif rising_edge(clk) then

		e_setpc<='0';
		r_gpr_wr<='0';

--		-- Execute stage

		e_stall<='0';
		e_bubble<='0';

		-- This only needs to wait if the store stage is doing something that blocks the execute stage.

		if d_bubble='0' and s_stall='0' then
--			e_bubble<=d_bubble;
			e_opcode<=d_opcode;
			e_reg<=d_reg;
			f_pc <= f_pc+1;
		end if;


		-- Execute load immediate...

		if e_bubble='0' and s_stall='0' then
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
	
					when e32_op_cmp =>	-- cmp
	
					when e32_op_st =>	-- st
			
					when e32_op_stdec =>	-- stdec
	
					when e32_op_stbinc =>	-- stbinc
	
					when e32_op_stmpdec =>	-- stmpdec
	
					when e32_op_and =>	-- and
						r_gpr_a<=e_reg;
	
					when e32_op_or =>	-- or
						r_gpr_a<=e_reg;
	
					when e32_op_xor =>	-- xor
						r_gpr_a<=e_reg;

					when e32_op_shl =>	-- shl

					when e32_op_shr =>	-- shr

					when e32_op_ror =>	-- ror

					when e32_op_sth =>	-- sth

					when e32_op_mul =>	-- mul
	
					when e32_op_exg =>	-- exg
						if e_regpc='1' then
							f_pc<=unsigned(r_tmp);
							r_tmp<=std_logic_vector(f_pc+1);
							e_bubble<='1';
						else
							r_gpr_a<=e_reg;
						end if;
	
					when e32_op_mt =>	-- mt
	
					when e32_op_add =>	-- add

					when e32_op_addt =>	-- addt

					when e32_op_ld =>	-- ld
						r_gpr_a<=e_reg;

					when e32_op_ldinc =>	-- ldinc

					when e32_op_ldbinc =>	-- ldbinc

					when e32_op_ltmpinc =>	-- ltmpinc

					when others =>
						null;

				end case;

			end if;

		end if;
	

		--		-- Load/store stage

		es_bubble<='0';
		if s_stall='0' then
			s_bubble<=es_bubble;
			s_opcode<=e_opcode;
			s_reg<=e_reg;
		end if;

		if s_bubble='0' then

			case s_opcode is		
				when e32_op_sub =>	-- sub
			
				when e32_op_cmp =>	-- cmp
			
				when e32_op_st =>	-- st
					
				when e32_op_stdec =>	-- stdec
			
				when e32_op_stbinc =>	-- stbinc
			
				when e32_op_stmpdec =>	-- stmpdec
			
				when e32_op_and =>	-- and
					r_gpr_d<=r_tmp and r_gpr_q;
					r_gpr_wr<='1';
					if (r_tmp and r_gpr_q)=X"00000000" then
						flag_z<='1';
					else
						flag_z<='0';
					end if;
			
				when e32_op_or =>	-- or
					r_gpr_d<=r_tmp or r_gpr_q;
					r_gpr_wr<='1';
					if (r_tmp or r_gpr_q)=X"00000000" then
						flag_z<='1';
					else
						flag_z<='0';
					end if;
			
				when e32_op_xor =>	-- xor
					r_gpr_d<=r_tmp xor r_gpr_q;
					r_gpr_wr<='1';
					if (r_tmp xor r_gpr_q)=X"00000000" then
						flag_z<='1';
					else
						flag_z<='0';
					end if;

				when e32_op_shl =>	-- shl

				when e32_op_shr =>	-- shr

				when e32_op_ror =>	-- ror

				when e32_op_sth =>	-- sth

				when e32_op_mul =>	-- mul

				when e32_op_exg =>	-- exg - write to both tmp and regfile
					r_tmp<=r_gpr_q;
					r_gpr_d<=r_tmp;
					r_gpr_wr<='1';

				when e32_op_mt =>	-- mt

				when e32_op_add =>	-- add

				when e32_op_addt =>	-- addt

				when e32_op_ld =>	-- ld
					ls_addr<=r_gpr_q;
					ls_byte<='0';
					ls_halfword<='0';
					ls_wr<='0';
					ls_req_r<='1';

					if ls_ack='1' then
						r_tmp<=ls_q;
						ls_req_r<='0';
					end if;

				when e32_op_ldinc =>	-- ldinc

				when e32_op_ldbinc =>	-- ldbinc

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
