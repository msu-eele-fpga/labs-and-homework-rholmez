library ieee;
use ieee.std_logic_1164.all;
use work.print_pkg.all;
use ieee.numeric_std.all;  -- Add this for numeric conversions
use work.assert_pkg.all;
use work.tb_pkg.all;

entity LED_patterns_tb is
end entity LED_patterns_tb;

architecture LED_patterns_tb_arch of LED_patterns_tb is

    constant CLK_PERIOD : time := 20 ns;

    signal clk_tb             : std_logic := '0';
    signal rst_tb             : std_logic := '0';
    signal PB_tb              : std_logic := '0';
    signal SW_tb              : std_logic_vector(3 downto 0) := "0100";
    signal HPS_LED_control_tb : boolean := false;
    signal base_period_tb     : unsigned(7 downto 0) := "00010000";
    signal LED_reg_tb         : std_logic_vector(7 downto 0);
    signal LED_tb             : std_logic_vector(7 downto 0);

    

    
    component LED_patterns is 
    generic(
        system_clock_period : time := 20 ns
    );
    port(
        clk              : in  std_logic;
        rst              : in  std_logic;
        PB               : in  std_logic;
        SW               : in  std_logic_vector(3 downto 0);
        HPS_LED_control  : in  boolean;
        base_period      : in  unsigned(7 downto 0);
        LED_reg          : in  std_logic_vector(7 downto 0);
        LED              : out std_logic_vector(7 downto 0)  
    );
    end component LED_patterns;


    begin

        LED : component LED_patterns
            port map (
                clk              =>  clk_tb,   
                rst              =>  rst_tb,              
                PB               =>  PB_tb,
                SW               =>  SW_tb,
                HPS_LED_control  =>  HPS_LED_control_tb,
                base_period      =>  base_period_tb,
                LED_reg          =>  LED_reg_tb,
                LED              =>  LED_tb
            );

        clk_gen : process is
            begin
          
              clk_tb <= not clk_tb;
              wait for CLK_PERIOD / 2;
              
        end process clk_gen;

        pb_sim : process is
            begin
                wait for 20.1 *  CLK_PERIOD;

                PB_tb <= '1';
                wait for 1 * CLK_PERIOD;

                PB_tb <= '0';
                wait for 1.4 * CLK_PERIOD;

                PB_tb <= '1';
                wait for 1 * CLK_PERIOD;

                PB_tb <= '0';
                wait for 100 * CLK_PERIOD;

        end process pb_sim;


               

end architecture LED_patterns_tb_arch;