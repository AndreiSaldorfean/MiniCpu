library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu_entity is Port(
    Input  : in std_logic_vector(7 downto 0); --instruction word
    r_w    : in std_logic; --read/!write
    debug  : in std_logic; --debug mode
    step   : in std_logic; --step into memory location
    count  : in std_logic; --count upwards/downwards
    output : out unsigned(4 downto 0) --instruction output
);
end cpu_entity;

architecture cpu_arch of cpu_entity is
  type alu_action_t is
  (
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

  signal operand    : unsigned(2 downto 0);
  signal a          : unsigned(4 downto 0);
  signal imm        : unsigned(4 downto 0);
  signal alu_left   : unsigned(4 downto 0);
  signal alu_right  : unsigned(4 downto 0);
  signal alu_action : alu_action_t;
--================================================
-- 2K x 8 Static RAM
  signal instruction_mode : unsigned(7 downto 0);
  signal pc: unsigned(7 downto 0);
  signal mem_addr : unsigned(10 downto 0);
  signal mem_data : unsigned(7 downto 0);

begin

  ram : process(clk,debug,r_w)
    begin
      if rising_edge(clk) then
        mem_addr<=pc;
        if debug = '1' then
          if r_w ='1' then
            Input<=mem_data;
          elsif r_w='0' then
            mem_data<=Input;
          end if;
        end if;
      end if;

  end process ram;

  program_counter : process(clk,debug,step,count)
    begin
      if rising_edge(clk) then
        if debug = '1' then
            if step = '1' then
                if count = '1' then
                    pc <= pc + 1;
                elsif count = '0' then
                    pc <= pc - 1;
                end if;
            end if;
        end if;
    end if;
  end process program_counter;

  acumulator : process(clk)
    begin
  end process acumulator;

  alu: process(alu_left,alu_right)
    begin

    case alu_action is
      when ALU_OP_ADD =>
          alu_left <= a;
          alu_right <= imm;
          output <= alu_left + alu_right;
      when ALU_OP_NAND =>
          alu_left <= a;
          alu_right <= imm;
          output <= alu_left nand alu_right;
      when ALU_OP_XOR =>
          alu_left <= a;
          alu_right <= imm;
          output <= alu_left xor alu_right;
      when ALU_OP_NOT =>
          alu_right <= imm;
          output <= not alu_right;
      when ALU_OP_LSH =>
          alu_right <= imm;
          output <= alu_right sll 1;
      when ALU_OP_RSH =>
          alu_right <= imm;
          output <= alu_right srl 1;
    end case;
  end process alu;

  decoder: process(operand) begin

    case operand(2 downto 0) is
      -- LD
      when "000" =>
        a <= operand;
        alu_left <= a;
      -- ADD
      when "001" =>
        alu_action <= ALU_OP_ADD;
      -- NAND
      when "010" =>
        alu_action <= ALU_OP_NAND;
      -- XOR
      when "011" =>
        alu_action <= ALU_OP_XOR;
      -- NOT
      when "100" =>
        alu_action <= ALU_OP_NOT;
      -- LSH
      when "101" =>
        alu_action <= ALU_OP_LSH;
      -- RSH
      when "110" =>
        alu_action <= ALU_OP_RSH;
      -- HALT
      when "111" =>
      -- HALT PC LOGIC
      when others =>
    end case;

  end process decoder;
end cpu_arch;
