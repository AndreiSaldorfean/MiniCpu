library ieee;
use ieee.std_logic_1164.all; --include arrays

entity cpu_entity is Port(
    Input : in std_logic_vector(7 downto 0);
    r_w : in std_logic;
    debug : in std_logic;
    nxt : in std_logic;
    prev : in std_logic;
    clk : in std_logic;
    output : out std_logic_vector( 3 downto 0)
);
end cpu_entity;

architecture cpu_arch of cpu_entity is
    type pc_action_t is (PC_NOP, PC_INCREMENT, PC_LOAD);
    type alu_src_t is (ALU_MEMORY, ALU_IMMEDIATE);
    type alu_action_t is (ALU_OP_LEFT, ALU_OP_RIGHT, ALU_OP_ADD, ALU_OP_SUB, ALU_OP_NOR);
    type a_action_t is (A_NOP, A_LOAD_ALU, A_LOAD_MEMORY, A_LOAD_IO);

    signal pc           : unsigned(11 downto 0) := (others => '0');
    signal a            : std_logic_vector(3 downto 0) := (others => '0');
    signal alu_right    : std_logic_vector(3 downto 0);
    signal alu_left_x   : unsigned(4 downto 0);
    signal alu_right_x  : unsigned(4 downto 0);
    signal alu_out      : unsigned(4 downto 0);

    signal pc_action    : pc_action_t;
    signal alu_src      : alu_src_t;
    signal alu_action   : alu_action_t;
    signal a_action     : a_action_t;
    signal mem_write_signal : std_logic := '0';
    signal io_read_signal   : std_logic := '0';
    signal io_write_signal  : std_logic := '0';
    signal prog_addr    : std_logic_vector(11 downto 0);
    signal mem_addr     : std_logic_vector(11 downto 0);
    signal prog_data    : std_logic_vector(7 downto 0);
    signal mem_data_in  : std_logic_vector(7 downto 0);
    signal mem_data_out : std_logic_vector(7 downto 0);
    signal io_addr      : std_logic_vector(11 downto 0);
    signal io_data_out  : std_logic_vector(7 downto 0);
    signal io_data_in   : std_logic_vector(7 downto 0);
    signal rst          : std_logic;



begin
    prog_addr <= std_logic_vector(pc);
    mem_addr <= "0000" & prog_data(7 downto 0); 
    io_addr <= "00000000" & prog_data(3 downto 0);
    io_data_out <= "0000" & a;
    mem_data_out <= "0000" & a;

    -- ALU logic
    with alu_src select
    alu_right <= prog_data(3 downto 0) when ALU_IMMEDIATE,
                 mem_data_in(3 downto 0) when ALU_MEMORY; 

    alu_left_x  <= unsigned('0' & a);
    alu_right_x <= unsigned('0' & alu_right);

    with alu_action select
        alu_out <= alu_left_x                     when ALU_OP_LEFT,
                   alu_right_x                    when ALU_OP_RIGHT,
                   (alu_left_x + alu_right_x)     when ALU_OP_ADD,
                   (alu_left_x - alu_right_x)     when ALU_OP_SUB,
                   not (alu_left_x or alu_right_x) when ALU_OP_NOR; 
    

    --MEMORY logic
    
    update_memory: process(clk, rst)
    begin
        if rst = '1' then
            pc <= (others => '0');
            a  <= (others => '0');
        elsif rising_edge(clk) then
            case a_action is
                when A_LOAD_ALU    => a <= std_logic_vector(alu_out(3 downto 0));
                when A_LOAD_MEMORY => a <= mem_data_in(3 downto 0);
                when A_LOAD_IO     => a <= io_data_in(3 downto 0);
 
                when A_NOP         => null;
            end case;

            case pc_action is
                when PC_INCREMENT => pc <= pc + 1;
                when PC_LOAD      => pc <= unsigned(prog_data & prog_data(3 downto 0));
                when PC_NOP       => null;
            end case;
        end if;
    end process update_memory;
    

end cpu_arch;
