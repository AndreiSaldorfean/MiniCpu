library ieee;
use ieee.std_logic_1164.all;  --include arrays
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity cpu_entity is
  Port(
    Input  : in  std_logic_vector(7 downto 0);  -- Opcode + Immediate
    r_w    : in  std_logic;
    debug  : in  std_logic;
    nxt    : in  std_logic;
    prev   : in  std_logic;
    clk    : in  std_logic;
    output : out std_logic_vector(4 downto 0)
  );
end cpu_entity;

architecture cpu_arch of cpu_entity is
  type alu_action_t is (
    ALU_OP_LEFT,
    ALU_OP_RIGHT,
    ALU_OP_ADD,
    ALU_OP_NAND,
    ALU_OP_XOR,
    ALU_OP_NOT,
    ALU_OP_LSH,
    ALU_OP_RSH
  );

  signal operand   : std_logic_vector(2 downto 0);
  signal imm       : std_logic_vector(4 downto 0);
  signal a         : std_logic_vector(4 downto 0) := (others => '0');
  signal alu       : alu_action_t := ALU_OP_ADD;
  signal alu_left  : std_logic_vector(4 downto 0);
  signal alu_right : std_logic_vector(4 downto 0) := (others => '0');

begin

  -- Extract fields from Input
  operand <= Input(7 downto 5);
  imm     <= Input(4 downto 0);

  -- ALU Operation
  alu_left <= a;

  with alu select
    output <= std_logic_vector(unsigned(alu_left) + unsigned(alu_right))   when ALU_OP_ADD,
              std_logic_vector(unsigned(alu_left) nand unsigned(alu_right)) when ALU_OP_NAND,
              std_logic_vector(unsigned(alu_left) xor unsigned(alu_right))  when ALU_OP_XOR,
              std_logic_vector(not unsigned(alu_left))              when ALU_OP_NOT,
              std_logic_vector(shift_left(unsigned(alu_left), 1)) when ALU_OP_LSH,
              std_logic_vector(shift_right(unsigned(alu_left), 1)) when ALU_OP_RSH,
              (others => '0') when others;  -- Default case

  -- Sequential Decoder Logic
  decoder: process(clk)
  begin
    if rising_edge(clk) then
      case operand is
        when "000" => -- LD: Load immediate value into register `a`
          a <= imm;
        when "001" => -- ADD: Perform addition
          alu_right <= imm;
          alu <= ALU_OP_ADD;
          a <= output; -- Store result back into `a`
        when "010" => -- NAND: Perform bitwise NAND
          alu_right <= imm;
          alu <= ALU_OP_NAND;
          a <= output;
        when "011" => -- XOR: Perform bitwise XOR
          alu_right <= imm;
          alu <= ALU_OP_XOR;
          a <= output;
        when "100" => -- NOT: Perform bitwise NOT
          alu_right <= (others => '0'); -- Ensure alu_right is initialized to zero
          alu <= ALU_OP_NOT;
          a <= output;
        when "101" => -- LSH: Logical shift left
          alu_right <= (others => '0'); -- Initialize alu_right to zero
          alu <= ALU_OP_LSH;
          a <= output;
        when "110" => -- RSH: Logical shift right
          alu_right <= (others => '0'); -- Initialize alu_right to zero
          alu <= ALU_OP_RSH;
          a <= output;
        when "111" => -- HALT: Stop operations (no action)
          null;
        when others =>
          null; -- Default case
      end case;
    end if;
  end process;

end cpu_arch;
