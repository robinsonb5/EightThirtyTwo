library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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

signal f_pc : unsigned(31 downto 0);
signal f_op : std_logic_vector(7 downto 0);
signal f_op_valid : std_logic := '0' ;	-- Execute stage can use f_op


-- Decode stage signals:

signal d_stall : std_logic;
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


-- Execute stage signals:

signal e_stall : std_logic;
signal e_bubble : std_logic;
signal e_newpc : std_logic_vector(31 downto 0);
signal e_setpc : std_logic;

signal e_opcode : std_logic_vector(7 downto 0);
signal e_reg : std_logic_vector(2 downto 0);
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
signal s_readreg : std_logic;
signal s_writereg : std_logic;
signal s_writetmp : std_logic;
signal s_alu : std_logic;
signal s_loadstore : std_logic;
signal s_req : std_logic;
signal s_nextop : std_logic;

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

process(clk,reset_n,f_op_valid)
begin

-- Decode stage - combinatorial logic:

		d_bubble<=not f_op_valid;

		d_stall<='0';

		d_readreg<='0';
		d_writereg<='0';
		d_writetmp<='0';
		d_alu<='0';
		d_flags<='0';
		d_loadstore<='0';

		case d_opcode is
			when X"00" =>	-- cond
	
			when X"08" =>   -- mr
				if reg_busy='0' and tmp_busy='0' then
					d_writereg<='1';
				end if;
	
			when X"10" =>	-- sub
	
			when X"18" =>	-- cmp
	
			when X"20" =>	-- st
			
			when X"28" =>	-- stdec
	
			when X"30" =>	-- stbinc
	
			when X"38" =>	-- stmpdec
	
			when X"40" =>	-- and
				if reg_busy='0' and tmp_busy='0' and loadstore_busy='0' then
					d_writereg<='1';
					d_readreg<='1';
				else
					d_stall<='1';
					d_bubble<='1';
				end if;
	
			when X"48" =>	-- or
	
			when X"50" =>	-- xor

			when X"58" =>	-- shl

			when X"60" =>	-- shr

			when X"68" =>	-- ror

			when X"70" =>	-- sth

			when X"78" =>	-- mul
	
			when X"80" =>	-- exg
				if reg_busy='0' and tmp_busy='0' then
					d_readreg<='1';
					d_writereg<='1';
					d_writetmp<='1';
				else
					d_stall<='1';
					d_bubble<='1';
				end if;
	
			when X"88" =>	-- mt
	
			when X"90" =>	-- add

			when X"98" =>	-- addt

			when X"a0" =>	-- ld  - need to delay this if the previous ex op is writing to the register file.
				if reg_busy='0' and tmp_busy='0' then
					d_readreg<='1';
					d_writereg<='1';
					d_writetmp<='1';
					d_loadstore<='1';
				else
					d_stall<='1';
					d_bubble<='1';
				end if;

			when X"a8" =>	-- ldinc

			when X"b0" =>	-- ldbinc

			when X"b8" =>	-- ltmpinc

			when others =>
				null;

		end case;

		if d_opcode(7 downto 6)="11" then
			if tmp_busy='0' then
				d_writetmp<='1';
			else
				d_stall<='1';
				d_bubble<='1';
			end if;
		end if;



--		-- Execute stage



-- Need to determine stall status combinationally
-- Ideally, determine signals to forward to the Store stage combinationally as well.

-- Instead of forwarding the signals, try deriving them in combinational logic since they don't necessarily
-- need to last the full length of the pipeline.
	
	if reset_n='0' then
		e_readreg<='0';
		e_writereg<='0';
		e_writetmp<='0';
		e_alu<='0';
		e_loadstore<='0';
		e_bubble<='0';
		e_stall<='0';

		s_readreg<='0';
		s_writereg<='0';
		s_writetmp<='0';
		s_alu<='0';
		s_loadstore<='0';
		s_bubble<='0';
		s_stall<='0';

		f_pc <= (others=>'0');
		e_setpc <='1';
		es_bubble<='0';
	elsif rising_edge(clk) then

			e_setpc<='0';
			r_gpr_wr<='0';

			e_stall<='0';	-- Need to hold off the following if we're doing a multicycle operation
			e_bubble<=d_bubble;
			e_opcode<=d_opcode;
			e_reg<=d_reg;
			if d_bubble='0' then
				f_pc <= f_pc+1;
			end if;

			-- Execute load immediate...

			if e_bubble='0' then
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
						when X"00" =>	-- cond
		
						when X"08" =>	-- mr
							r_gpr_d<=r_tmp;
							r_gpr_a<=e_reg;
							r_gpr_wr<='1';
		
						when X"10" =>	-- sub
		
						when X"18" =>	-- cmp
		
						when X"20" =>	-- st
				
						when X"28" =>	-- stdec
		
						when X"30" =>	-- stbinc
		
						when X"38" =>	-- stmpdec
		
						when X"40" =>	-- and
		
						when X"48" =>	-- or
		
						when X"50" =>	-- xor

						when X"58" =>	-- shl

						when X"60" =>	-- shr

						when X"68" =>	-- ror

						when X"70" =>	-- sth

						when X"78" =>	-- mul
		
						when X"80" =>	-- exg
							r_gpr_a<=e_reg;
		
						when X"88" =>	-- mt
		
						when X"90" =>	-- add

						when X"98" =>	-- addt

						when X"a0" =>	-- ld
							r_gpr_a<=e_reg;

						when X"a8" =>	-- ldinc

						when X"b0" =>	-- ldbinc

						when X"b8" =>	-- ltmpinc

						when others =>
							null;

					end case;

				end if;

			end if;

		end if;

		
		--		-- Load/store stage

		-- Figure out how to escape the stall stage.

		
		s_bubble<=es_bubble;
		s_opcode<=e_opcode;
		s_reg<=e_reg;

		if s_bubble='0' then

			-- FIXME - derive these combinationally.
			s_writereg<=e_writereg;
			s_readreg<=e_readreg;
			s_writetmp<=e_writetmp;
			s_loadstore<=e_loadstore;

			case s_opcode is		
				when X"10" =>	-- sub
			
				when X"18" =>	-- cmp
			
				when X"20" =>	-- st
					
				when X"28" =>	-- stdec
			
				when X"30" =>	-- stbinc
			
				when X"38" =>	-- stmpdec
			
				when X"40" =>	-- and
			
				when X"48" =>	-- or
			
				when X"50" =>	-- xor

				when X"58" =>	-- shl

				when X"60" =>	-- shr

				when X"68" =>	-- ror

				when X"70" =>	-- sth

				when X"78" =>	-- mul

				when X"80" =>	-- exg - write to both tmp and regfile
					r_tmp<=r_gpr_q;
					r_gpr_d<=r_tmp;
--					r_gpr_a<=e_reg; -- should already be set.  No instruction touches more than one register.
					r_gpr_wr<='1';

				when X"90" =>	-- add

				when X"98" =>	-- addt

				when X"a0" =>	-- ld
					ls_addr<=r_gpr_q;
					ls_byte<='0';
					ls_halfword<='0';
					ls_wr<='0';
					ls_req_r<='1';

					if ls_ack='1' then
						r_tmp<=ls_q;
						ls_req_r<='0';
						s_stall<='0';
					else
						s_stall<='1';
					end if;

				when X"a8" =>	-- ldinc

				when X"b0" =>	-- ldbinc

				when X"b8" =>	-- ltmpinc

				when others =>
					null;

			end case;

		end if;

		es_bubble<='0';

		-- Execute stage, combinational.

			case e_opcode is
				when X"00" =>	-- cond
		
				when X"08" =>	-- mr
					es_bubble<='1';	 -- Nothing for store stage to do.
		
				when X"10" =>	-- sub
		
				when X"18" =>	-- cmp
		
				when X"20" =>	-- st
				
				when X"28" =>	-- stdec
		
				when X"30" =>	-- stbinc
		
				when X"38" =>	-- stmpdec
		
				when X"40" =>	-- and
		
				when X"48" =>	-- or
		
				when X"50" =>	-- xor

				when X"58" =>	-- shl

				when X"60" =>	-- shr

				when X"68" =>	-- ror

				when X"70" =>	-- sth

				when X"78" =>	-- mul
		
				when X"80" =>	-- exg
					e_writereg<='1';
					e_writetmp<='1';
					es_bubble<='1';	 -- Nothing for store stage to do.
		
				when X"88" =>	-- mt
		
				when X"90" =>	-- add

				when X"98" =>	-- addt

				when X"a0" =>	-- ld
					e_writereg<='1';
					e_readreg<='1';
					e_writetmp<='1';
					e_loadstore<='1';

				when X"a8" =>	-- ldinc

				when X"b0" =>	-- ldbinc

				when X"b8" =>	-- ltmpinc

				when others =>
					null;

			end case;




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
