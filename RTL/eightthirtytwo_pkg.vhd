library ieee;
use ieee.std_logic_1164.all;

package eightthirtytwo_pkg is

constant e32_op_cond : std_logic_vector(7 downto 0) := X"00";
 
constant e32_op_mr : std_logic_vector(7 downto 0) := X"08";
constant e32_op_sub : std_logic_vector(7 downto 0) := X"10";
constant e32_op_cmp : std_logic_vector(7 downto 0) := X"18";
constant e32_op_st : std_logic_vector(7 downto 0) := X"20";
constant e32_op_stdec : std_logic_vector(7 downto 0) := X"28";
constant e32_op_stbinc : std_logic_vector(7 downto 0) := X"30";
constant e32_op_stmpdec : std_logic_vector(7 downto 0) := X"38";
 
constant e32_op_and : std_logic_vector(7 downto 0) := X"40";
constant e32_op_or : std_logic_vector(7 downto 0) := X"48";
constant e32_op_xor : std_logic_vector(7 downto 0) := X"50";
constant e32_op_shl : std_logic_vector(7 downto 0) := X"58";
constant e32_op_shr : std_logic_vector(7 downto 0) := X"60";
constant e32_op_ror : std_logic_vector(7 downto 0) := X"68";
constant e32_op_sth : std_logic_vector(7 downto 0) := X"70";
constant e32_op_mul : std_logic_vector(7 downto 0) := X"78";

constant e32_op_exg : std_logic_vector(7 downto 0) := X"80";
constant e32_op_mt : std_logic_vector(7 downto 0) := X"88";
constant e32_op_add : std_logic_vector(7 downto 0) := X"90";
-- Add's behaviour is different for r7 - perhaps use a different mnemonic?
constant e32_op_addt : std_logic_vector(7 downto 0) := X"98";
constant e32_op_ld : std_logic_vector(7 downto 0) := X"a0";
constant e32_op_ldinc : std_logic_vector(7 downto 0) := X"a8";
constant e32_op_ldbinc : std_logic_vector(7 downto 0) := X"b0";
constant e32_op_ltmpinc : std_logic_vector(7 downto 0) := X"b8";
constant e32_op_li : std_logic_vector(7 downto 0) := X"c0";

-- Overloaded opcodes.  Mostly ops that make no sense when applied to R7

constant e32_op_sgn : std_logic_vector(7 downto 0) := X"17";
constant e32_op_ldt : std_logic_vector(7 downto 0) := X"a7";

-- Condional codes

constant e32_cond_nex : std_logic_vector(2 downto 0) := "000";
constant e32_cond_sgt : std_logic_vector(2 downto 0) := "001";
constant e32_cond_eq : std_logic_vector(2 downto 0) := "010";
constant e32_cond_ge : std_logic_vector(2 downto 0) := "011";
constant e32_cond_slt : std_logic_vector(2 downto 0) := "100";
constant e32_cond_neq : std_logic_vector(2 downto 0) := "101";
constant e32_cond_le : std_logic_vector(2 downto 0) := "110";
constant e32_cond_ex : std_logic_vector(2 downto 0) := "111";

-- ALU functions

constant e32_alu_and : std_logic_vector(2 downto 0) := "000";
constant e32_alu_or : std_logic_vector(2 downto 0) := "000";
constant e32_alu_xor : std_logic_vector(2 downto 0) := "000";
constant e32_alu_add : std_logic_vector(2 downto 0) := "000";
constant e32_alu_sub : std_logic_vector(2 downto 0) := "000";
constant e32_alu_mul : std_logic_vector(2 downto 0) := "000";

end package;

