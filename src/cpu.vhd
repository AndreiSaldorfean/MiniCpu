library ieee;
use ieee.std_logic_1164.all; --include arrays
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
entity cpu_entity is Port(
    Input : in std_logic_vector(7 downto 0);
    r_w : in std_logic;
    debug : in std_logic;
    nxt : in std_logic;
    prev : in std_logic;
    clk : in std_logic;
    output : out std_logic_vector( 4 downto 0)
);
end cpu_entity;

architecture cpu_arch of cpu_entity is
  type alu_action_t is
  (
    ALU_OP_LEFT,
    ALU_OP_RIGHT,
    ALU_OP_ADD,
    ALU_OP_NAND,
    ALU_OP_XOR,
    ALU_OP_NOT,
    ALU_OP_LSH,
    ALU_OP_RSH
  );

  type alu_src_t is
  (
    ALU_IMMEDIATE,
    ALU_ACCUMULATOR
  );

  signal operand : std_logic_vector(2 downto 0);
  signal imm : std_logic_vector(4 downto 0);
  signal a : std_logic_vector(4 downto 0);
  signal alu : alu_action_t;
  signal alu_left : std_logic_vector(4 downto 0);
  signal alu_right : std_logic_vector(4 downto 0);
begin

  alu_left  <= a;

  with alu select
     output <=  (alu_left)  +     (alu_right)  when ALU_OP_ADD,
                (alu_left)  nand  (alu_right)  when ALU_OP_NAND,
                (alu_left)  nor   (alu_right)  when ALU_OP_XOR,
                not (alu_left)                 when ALU_OP_NOT,
                (alu_left)  nor (alu_right)    when ALU_OP_LSH,
                (alu_left)  nor (alu_right)    when ALU_OP_RSH;

  decoder: process(operand) begin

    case operand(2 downto 0) is
      -- LD
      when "000" =>
        a <= operand;
        alu_left <= a;
      -- ADD
      when "001" =>
        alu_right <= imm;
        alu <= ALU_OP_ADD;
      -- NAND
      when "010" =>
        alu_right <= imm;
        alu <= ALU_OP_NAND;
      -- XOR
      when "011" =>
        alu_right <= imm;
        alu <= ALU_OP_XOR;
      -- NOT
      when "100" =>
        alu_right <= imm;
        alu <= ALU_OP_NOT;
      -- LSH
      when "101" =>
        alu_right <= imm;
        alu <= ALU_OP_LSH;
      -- RSH
      when "110" =>
        alu_right <= imm;
        alu <= ALU_OP_RSH;
      -- HALT
      when "111" =>
      -- HALT PC LOGIC
      when others =>
    end case;

  end process decoder;

end cpu_arch;
