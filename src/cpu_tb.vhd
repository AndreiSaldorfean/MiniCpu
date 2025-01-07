library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_cpu_entity is
end tb_cpu_entity;

architecture behavior of tb_cpu_entity is

  -- Component declaration for the cpu_entity
  component cpu_entity
    Port(
      Input  : in std_logic_vector(7 downto 0);
      r_w    : in std_logic;
      debug  : in std_logic;
      nxt    : in std_logic;
      prev   : in std_logic;
      clk    : in std_logic;
      output : out unsigned(4 downto 0)
    );
  end component;

  -- Signal declarations for the testbench
  signal Input      : std_logic_vector(7 downto 0) := (others => '0');
  signal r_w        : std_logic := '0';
  signal debug      : std_logic := '0';
  signal nxt        : std_logic := '0';
  signal prev       : std_logic := '0';
  signal clk        : std_logic := '0';
  signal output     : unsigned(4 downto 0);

  -- Clock period
  constant clk_period : time := 10 ns;

begin

  -- Instantiate the cpu_entity
  uut: cpu_entity
    port map (
      Input => Input,
      r_w   => r_w,
      debug => debug,
      nxt   => nxt,
      prev  => prev,
      clk   => clk,
      output => output
    );

  -- Clock generation
  clk_process : process
  begin
    clk <= '0';
    wait for clk_period / 2;
    clk <= '1';
    wait for clk_period / 2;
  end process clk_process;

  -- Stimulus process to apply test vectors
  stim_proc: process
  begin
    -- Test ADD operation (ALU_OP_ADD)
    Input <= "00000001"; -- Example input
    r_w   <= '0';
    nxt   <= '1'; -- Assuming 'nxt' triggers some action
    wait for clk_period;

    -- Test NAND operation (ALU_OP_NAND)
    Input <= "00000010";
    nxt   <= '0';
    wait for clk_period;

    -- Test XOR operation (ALU_OP_XOR)
    Input <= "00000011";
    nxt   <= '1';
    wait for clk_period;

    -- Test NOT operation (ALU_OP_NOT)
    Input <= "00000100";
    nxt   <= '0';
    wait for clk_period;

    -- Test LSH operation (ALU_OP_LSH)
    Input <= "00000101";
    nxt   <= '1';
    wait for clk_period;

    -- Test RSH operation (ALU_OP_RSH)
    Input <= "00000110";
    nxt   <= '0';
    wait for clk_period;

    -- Halt logic (optional, depending on your design)
    Input <= "00000111";
    nxt   <= '1';
    wait for clk_period;

    -- End of test sequence
    wait;
  end process stim_proc;

end behavior;

