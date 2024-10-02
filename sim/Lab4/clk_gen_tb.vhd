library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;  -- Add this for numeric conversions
use work.print_pkg.all;
use work.assert_pkg.all;
use work.tb_pkg.all;
use ieee.math_real.all;

entity clk_gen_tb is
end entity;

architecture clk_gen_tb_arch of clk_gen_tb is

    constant CLK_PERIOD : time := 20 ns;

    signal clk_tb              : std_logic := '0';
    signal rst_tb              : std_logic := '0';
    signal base_count_tb       : unsigned(6 downto 0) := "1100100";--"10111110101111000010000000";
    signal clk_gen_base_tb     : std_logic;
    signal clk_gen_double_tb   : std_logic;
    signal clk_gen_quad_tb     : std_logic;
    signal clk_gen_half_tb     : std_logic;
    signal clk_gen_oct_tb      : std_logic;

    component clk_gen is 
    port(
        clk              : in  std_logic;
        rst              : in  std_logic;
        base_count       : in  unsigned(6 downto 0);
        clk_gen_base     : out std_logic;
        clk_gen_double   : out std_logic;
        clk_gen_quad     : out std_logic;
        clk_gen_half     : out std_logic;
        clk_gen_oct      : out std_logic
        );
    end component clk_gen;


    begin

        clk_gen_comp : component clk_gen
            port map (
                clk            => clk_tb,
                rst            => rst_tb,
                base_count     => base_count_tb,
                clk_gen_base   => clk_gen_base_tb,
                clk_gen_double => clk_gen_double_tb,
                clk_gen_quad   => clk_gen_quad_tb, 
                clk_gen_half   => clk_gen_half_tb,
                clk_gen_oct    => clk_gen_oct_tb
            );


        clk : process is
            begin
          
              clk_tb <= not clk_tb;
              wait for CLK_PERIOD / 2;
              
        end process clk;

end architecture clk_gen_tb_arch;