library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu_entity is Port(
    Input  : in std_logic_vector(7 downto 0); --instruction word
    r_w    : in std_logic; --read/!write
    load    : in std_logic;
    cnt_down: in std_logic;
    cnt_up  : in std_logic;
    debug  : in std_logic;
    step    : in std_logic;
    output : out unsigned(3 downto 0)
);
end cpu_entity;

architecture cpu_arch of cpu_entity is

  -- Accumulator register
  signal cp             : std_logic;
  signal acc_data_in    : unsigned(4 downto 0);
  signal acc_data_out   : unsigned(4 downto 0);
  -- ALU
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

  signal alu_left   : unsigned(4 downto 0);
  signal alu_right  : unsigned(4 downto 0);
  signal alu_action : alu_action_t;
  -- Decoder
  signal do : unsigned(7 downto 0);
  signal di : unsigned(2 downto 0);
  -- PC
  signal sel : std_logic_vector(1 downto 0);
  signal pc_clk : std_logic;
  signal q : unsigned( 7 downto 0);

  signal internal_clk : std_logic;
  signal reset : std_logic;
  -- RAM 2K x 8 Static RAM
  signal instruction_mode : unsigned(7 downto 0);
  signal pc: unsigned(7 downto 0);
  signal mem_addr : unsigned(10 downto 0);
  signal mem_data : unsigned(7 downto 0);
  signal operand        : unsigned(2 downto 0);
  signal imm            : unsigned(4 downto 0);

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

  end process ram;

  encoder: process(cnt_down, cnt_up, load, reset)
  begin
    if load = '0' then
      if    cnt_down = '0' and cnt_up = '0' and reset = '0' then
        sel <= "00";
      elsif cnt_down = '0' and cnt_up = '0' and reset = '1' then
        sel <= "00";
        reset <= '0';
      elsif cnt_down = '0' and cnt_up = '1' and reset = '0' then
        sel <= "11";
      elsif cnt_down = '0' and cnt_up = '1' and reset = '1' then
        sel <= "00";
        reset <= '0';
      elsif cnt_down = '1' and cnt_up = '0' and reset = '0' then
        sel <= "01";
      elsif cnt_down = '1' and cnt_up = '0' and reset = '1' then
        sel <= "00";
        reset <= '0';
      elsif cnt_down = '1' and cnt_up = '1' and reset = '0' then
        sel <= "00";
      elsif cnt_down = '1' and cnt_up = '1' and reset = '1' then
        sel <= "00";
        reset <= '0';
      end if;
  else
      sel <= "00";
  end if;
  end process encoder;

  pc: process(pc_clk, sel)
  begin
    if rising_edge(pc_clk) then
    case sel is
      when "00" =>
        q <= "00000000";
      when "01" =>
        -- count down
        q <= q - 1;
      -- when "10" =>; 
        -- load
      when "11" =>
        -- count up
        q <= q + 1;
      when others =>
    end case;
  end if;
  end process pc;

  debugger: process(internal_clk, debug,step)
  begin
    pc_clk <= (internal_clk and not debug) or (step and internal_clk) or (step and internal_clk);
  end process debugger;

  acumulator : process(cp)
    begin
      if rising_edge(cp) then
        acc_data_in <= imm;
        acc_data_out <= acc_data_in;
        cp <= '0';
      end if;
  end process acumulator;

  alu: process(alu_left,alu_right)
    begin

    case alu_action is
      when ALU_OP_ADD =>
          alu_left <= acc_data_out;
          alu_right <= imm;
          output <= alu_left + alu_right;
      when ALU_OP_NAND =>
          alu_left <= acc_data_out;
          alu_right <= imm;
          output <= alu_left nand alu_right;
      when ALU_OP_XOR =>
          alu_left <= acc_data_out;
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

  -- d1-d6 are the same as alu_action
  decoder: process(di) begin

    case di(2 downto 0) is
      -- LD
      when "000" =>
        cp <= '1';
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
        reset <= '1';
      when others =>
    end case;

  end process decoder;
  di <= operand;
  cp <= do(0);

end cpu_arch;
