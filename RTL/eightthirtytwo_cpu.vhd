library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.eightthirtytwo_pkg.all;

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

signal r_gpr_a : std_logic_vector(2 downto 0);
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

signal f_nextop : std_logic;
signal f_pc : std_logic_vector(31 downto 0);
signal f_op : std_logic_vector(7 downto 0);
signal f_prevop : std_logic_vector(7 downto 0);
signal f_op_valid : std_logic := '0' ;	-- Execute stage can use f_op


-- Decode stage signals:

signal d_immediatestreak : std_logic;
signal d_opcode : std_logic_vector(7 downto 0);
signal d_reg : std_logic_vector(2 downto 0);


-- Execute stage signals:

signal e_newpc : std_logic_vector(31 downto 0);
signal e_setpc : std_logic;

signal e_opcode : std_logic_vector(7 downto 0);
signal e_reg : std_logic_vector(2 downto 0);
signal e_writereg : std_logic;
signal e_writetmp : std_logic;
signal e_alu : std_logic;
signal e_flags : std_logic;
signal e_loadstore : std_logic;
signal e_req : std_logic;
signal e_nextop : std_logic;

-- Store stage signals

signal s_opcode : std_logic_vector(7 downto 0);
signal s_reg : std_logic_vector(2 downto 0);
signal s_writereg : std_logic;
signal s_writetmp : std_logic;
signal s_alu : std_logic;
signal s_loadstore : std_logic;
signal s_req : std_logic;
signal s_nextop : std_logic;

-- Busy signals

signal regbusy : std_logic;
signal tmpbusy : std_logic;
signal alubusy : std_logic;
signal lsbusy : std_logic;

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

ls_req<=ls_req_r and not ls_ack;

-- Execute stage


d_opcode<=f_op(7 downto 3) & "000" when f_nextop='1' else f_prevop(7 downto 3) & "000";
d_reg<=f_op(2 downto 0) when f_nextop='1' else f_prevop(2 downto 0);

process(clk,reset_n,f_op_valid)
begin
	if reset_n='0' then
		e_newpc<=X"00000000";
		e_setpc<='1';
		e_writereg<='0';
		e_writetmp<='0';
		e_alu<='0';
		e_flags<='0';
		e_loadstore<='0';
		f_nextop<='1';
		ls_req_r<='0';
	elsif rising_edge(clk) then

		e_setpc<='0';

		if f_nextop='1' then
			f_prevop<=f_op;
		end if;

		-- Decode stage

		if f_op_valid='1' then
			f_nextop<='0';
			d_immediatestreak<='0';

			e_opcode<=d_opcode;
			e_req<='0';

			if e_nextop='1' then
				e_writereg<='0';
				e_writetmp<='0';
				e_alu<='0';
				e_flags<='0';
				e_loadstore<='0';
			end if;

			if e_nextop='1' then
				case d_opcode is
					when e32_op_cond =>	-- cond
			
					when e32_op_mr =>
						if e_nextop='1' then
							e_opcode<=d_opcode;
							e_reg<=d_reg;
							e_writereg<='1';
							e_req<='1';
							f_nextop<='1';
						end if;
			
					when e32_op_sub =>	-- sub
			
					when e32_op_cmp =>	-- cmp
			
					when e32_op_st =>	-- st
					
					when e32_op_stdec =>	-- stdec
			
					when e32_op_stbinc =>	-- stbinc
			
					when e32_op_stmpdec =>	-- stmpdec
			
					when e32_op_and =>	-- and
						if e_writetmp='1' or s_writetmp='1' then
							f_nextop<='0';
						else

						end if;
			
					when e32_op_or =>	-- or
			
					when e32_op_xor =>	-- xor

					when e32_op_shl =>	-- shl

					when e32_op_shr =>	-- shr

					when e32_op_ror =>	-- ror

					when e32_op_sth =>	-- sth

					when e32_op_mul =>	-- mul
			
					when e32_op_exg =>	-- exg
						if e_nextop='1' then
							r_gpr_a<=d_reg;
							e_opcode<=d_opcode;
							e_reg<=d_reg;
							e_writereg<='1';
							e_writetmp<='1';
							e_req<='1';
							f_nextop<='1';
						end if;
			
					when e32_op_mt =>	-- mt
			
					when e32_op_add =>	-- add

					when e32_op_addt =>	-- addt

					when e32_op_ld =>	-- ld  - need to delay this if the previous ex op is writing to the register file.
						if e_nextop='1' and e_writereg='0' then
							r_gpr_a<=d_reg;
							e_opcode<=d_opcode;
							e_reg<=d_reg;
							e_writetmp<='1';
							e_req<='1';
							f_nextop<='1';
						end if;

					when e32_op_ldinc =>	-- ldinc

					when e32_op_ldbinc =>	-- ldbinc

					when e32_op_ltmpinc =>	-- ltmpinc

					when others =>
						null;

				end case;
			end if;

			if f_op(7 downto 6)="11" then
				if (e_nextop='1' or e_writetmp='0') then -- li
					d_immediatestreak<='1';
					if d_immediatestreak='1' then	-- shift existing value six bits left...
						r_tmp<=r_tmp(25 downto 0) & f_op(5 downto 0);
					else
							-- Write lowest six bits of immediate value, sign extended.
						if f_op(5)='1' then
							r_tmp(31 downto 5)<=(others=>'1');
						else
							r_tmp(31 downto 5)<=(others=>'0');
						end if;
						r_tmp(5 downto 0)<=f_op(5 downto 0);
					end if;
					f_nextop<='1';
				end if;

			end if;
		end if;

		-- Execute stage

		s_req<='0';
		r_gpr_wr<='0';
		e_nextop<='1';
		if e_req='1' then

			case e_opcode is
				when e32_op_cond =>	-- cond
				
				when e32_op_mr =>	-- mr
					r_gpr_d<=r_tmp;
					r_gpr_a<=e_reg;
					r_gpr_wr<='1';
					e_nextop<='1';
				
				when e32_op_sub =>	-- sub
				
				when e32_op_cmp =>	-- cmp
				
				when e32_op_st =>	-- st
						
				when e32_op_stdec =>	-- stdec
				
				when e32_op_stbinc =>	-- stbinc
				
				when e32_op_stmpdec =>	-- stmpdec
				
				when e32_op_and =>	-- and
				
				when e32_op_or =>	-- or
				
				when e32_op_xor =>	-- xor

				when e32_op_shl =>	-- shl

				when e32_op_shr =>	-- shr

				when e32_op_ror =>	-- ror

				when e32_op_sth =>	-- sth

				when e32_op_mul =>	-- mul
				
				when e32_op_exg =>	-- exg
					r_tmp<=r_gpr_q;
					r_gpr_d<=r_tmp;
					r_gpr_a<=e_reg;
					r_gpr_wr<='1';
					e_nextop<='1';
				
				when e32_op_mt =>	-- mt
				
				when e32_op_add =>	-- add

				when e32_op_addt =>	-- addt

				when e32_op_ld =>	-- ld
					ls_addr<=r_gpr_q;
					ls_byte<='0';
					ls_halfword<='0';
					ls_wr<='0';
					ls_req_r<='1';
					s_opcode<=e_opcode;
					s_writetmp<='1';
					s_req<='1';


				when e32_op_ldinc =>	-- ldinc

				when e32_op_ldbinc =>	-- ldbinc

				when e32_op_ltmpinc =>	-- ltmpinc

				when others =>
					null;

			end case;

		end if;

		-- Load/store stage

		s_nextop<='1';
		if s_req='1' then

			case s_opcode is		
				when e32_op_sub =>	-- sub
				
				when e32_op_cmp =>	-- cmp
				
				when e32_op_st =>	-- st
						
				when e32_op_stdec =>	-- stdec
				
				when e32_op_stbinc =>	-- stbinc
				
				when e32_op_stmpdec =>	-- stmpdec
				
				when e32_op_and =>	-- and
				
				when e32_op_or =>	-- or
				
				when e32_op_xor =>	-- xor

				when e32_op_shl =>	-- shl

				when e32_op_shr =>	-- shr

				when e32_op_ror =>	-- ror

				when e32_op_sth =>	-- sth

				when e32_op_mul =>	-- mul

				when e32_op_add =>	-- add

				when e32_op_addt =>	-- addt

				when e32_op_ld =>	-- ld
					if ls_ack='1' then
						r_tmp<=ls_q;
						ls_req_r<='0';
					else
						s_nextop<='0';
						s_req<='1';
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


-- Store stage



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
