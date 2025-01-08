-- Test bench script
library ieee;
use ieee.std_logic_1164.all; --include arrays

entity cpu_tb is Port(
    Input : in std_logic_vector(7 downto 0);
    r_w : in std_logic;
    debug : in std_logic;
    nxt : in std_logic;
    prev : in std_logic;
    clk : in std_logic;
    output : out std_logic_vector( 3 downto 0)
);
end cpu_tb;

architecture cpu_arch_tb of cpu_tb is

begin

end cpu_arch_tb;