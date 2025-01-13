library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu_entity is Port(
    byte_word    : in unsigned(7 downto 0);
    alu_output   : out unsigned(4 downto 0);
    r_w          : in std_logic;
    load         : in std_logic;
    cnt_down     : in std_logic;
    cnt_up       : in std_logic;
    debug        : in std_logic;
    step         : in std_logic;
    internal_clk : in std_logic
);
end cpu_entity;

architecture cpu_arch of cpu_entity is

  -- Accumulator register
  signal cp         : std_logic := '0';
  signal acc_data   : unsigned(4 downto 0);
  -- ALU
  signal alu_left   : unsigned(4 downto 0);
  signal alu_right  : unsigned(4 downto 0);
  signal alu_action : unsigned(2 downto 0) := "000";

  -- PC
  signal sel : std_logic_vector(1 downto 0);
  signal pc_clk : std_logic := '0';
  signal q : unsigned( 7 downto 0);

  signal reset          : std_logic := '0';
  signal mem_addr       : unsigned(7 downto 0) := (others => '0');
  signal mem_data       : unsigned(7 downto 0):= (others => '0');
  signal operand        : unsigned(2 downto 0):= (others => '0');
  signal imm            : unsigned(4 downto 0):= (others => '0');

begin

  ram : process(q,debug,r_w)
    begin
    mem_addr<=q;
    if debug = '1' then
      if not r_w ='1' then
        mem_data<=byte_word;
      end if;
    end if;
    operand <= byte_word(7 downto 5);
    imm <= byte_word(4 downto 0);
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
        q <= "00000000";
    end case;
  end if;
  end process pc;

  debugger: process(internal_clk, debug,step)
  begin
    pc_clk <= (internal_clk and not debug) or (step and internal_clk) or (debug and step); -- NEEDS FIX
  end process debugger;

  -- acumulator : process(cp)
  --   begin
  --       acc_data <= imm;
  -- end process acumulator;

  alu: process(alu_action)
    begin

    case alu_action is
      when "001" =>
          alu_left <= acc_data;
          alu_right <= imm;
          alu_output <= alu_left + alu_right;
      when "010" =>
          alu_left <= acc_data;
          alu_right <= imm;
          alu_output <= alu_left nand alu_right;
      when "011" =>
          alu_left <= acc_data;
          alu_right <= imm;
          alu_output <= alu_left xor alu_right;
      when "100" =>
          alu_right <= imm;
          alu_output <= not alu_right;
      when "101" =>
          alu_right <= imm;
          alu_output <= alu_right sll 1;
      when "110" =>
          alu_right <= imm;
          alu_output <= alu_right srl 1;
      when others =>
          alu_left <= "00000";
          alu_right <= "00000";
          alu_output <= "00000";
    end case;
  end process alu;

  decoder: process(operand,imm,debug) begin

    if debug = '0' then
      case operand(2 downto 0) is
        -- LD
        when "000" =>
          -- cp <= '1';
          acc_data <= imm;
          reset <= '0';
        -- ADD
        when "001" =>
          alu_action <= "001";
          reset <= '0';
          cp <= '0';
        -- NAND
        when "010" =>
          alu_action <= "010";
          reset <= '0';
          cp <= '0';
        -- XOR
        when "011" =>
          alu_action <= "011";
          reset <= '0';
          cp <= '0';
        -- NOT
        when "100" =>
          alu_action <= "100";
          reset <= '0';
          cp <= '0';
        -- LSH
        when "101" =>
          alu_action <= "101";
          reset <= '0';
          cp <= '0';
        -- RSH
        when "110" =>
          alu_action <= "110";
          reset <= '0';
          cp <= '0';
        -- HALT
        when "111" =>
        -- HALT PC LOGIC
          reset <= '1';
          cp <= '0';
        when others =>
          reset <= '0';
          cp <= '0';
      end case;
    end if;

  end process decoder;

end cpu_arch;
