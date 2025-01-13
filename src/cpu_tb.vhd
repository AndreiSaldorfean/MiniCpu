library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu_tb is
end cpu_tb;

architecture testbench of cpu_tb is

  -- Component declaration for the unit under test (UUT)
  component cpu_entity
    port (
      byte_word  : in unsigned(7 downto 0); -- instruction word
      r_w        : in std_logic;            -- read/!write
      load       : in std_logic;
      cnt_down   : in std_logic;
      cnt_up     : in std_logic;
      debug      : in std_logic;
      step       : in std_logic;
      alu_output     : out unsigned(4 downto 0);
      internal_clk : in std_logic
    );
  end component;

  -- Testbench signals
  signal tb_byte_word : unsigned(7 downto 0) := (others => '0');
  signal tb_r_w       : std_logic := '0';
  signal tb_load      : std_logic := '0';
  signal tb_cnt_down  : std_logic := '0';
  signal tb_cnt_up    : std_logic := '0';
  signal tb_debug     : std_logic := '0';
  signal tb_step      : std_logic := '0';
  signal tb_output    : unsigned(4 downto 0);
  signal tb_internal_clk: std_logic := '0';

  -- Clock generation
  signal clk          : std_logic := '0';

begin


  -- Instantiate the Unit Under Test (UUT)
  uut: cpu_entity
    port map (
      byte_word  => tb_byte_word,
      r_w        => tb_r_w,
      load       => tb_load,
      cnt_down   => tb_cnt_down,
      cnt_up     => tb_cnt_up,
      debug      => tb_debug,
      step       => tb_step,
      alu_output     => tb_output,
      internal_clk => tb_internal_clk
    );

  -- Clock generation for 10 MHz
  clk_process : process
  begin
    tb_internal_clk <= '0';
    wait for 50 ns;
    tb_internal_clk <= '1';
    wait for 50 ns;
  end process clk_process;

  process
  begin
    -- Init memory
    tb_debug <= '1';
    tb_r_w <= '0';
    tb_load <= '0';
    tb_cnt_down <= '0';
    tb_cnt_up <= '0';
    tb_step <= '0';
    wait for 10 ns;

    tb_cnt_up <= '1';
    wait for 10 ns;
    tb_byte_word <= "00000101"; -- LD 5
    wait for 10 ns;
    tb_step <= '1';
    wait for 10 ns;
    tb_debug <= '0';
    wait for 10 ns;
    tb_step <= '0';
    wait for 50 ns;
    tb_debug <= '1';
    wait for 10 ns;
    tb_byte_word <= "00100010"; -- ADD 2
    wait for 10 ns;
    tb_step <= '1';
    wait for 10 ns;
    tb_debug <= '0';
    report "Simulation complete" severity note;
    wait;  -- Stop simulation
  end process;
end testbench;
