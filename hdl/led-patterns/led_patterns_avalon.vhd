library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;  -- Add this for numeric conversions
use ieee.math_real.all;
-- test;

entity led_patterns_avalon is
    port( 
        clk : in std_ulogic;
        rst : in std_ulogic;

        --avalon memory-mapped slave interface
        avs_read      : in   std_logic;
        avs_write     : in   std_logic;
        avs_address   : in   std_logic_vector(1 downto 0);
        avs_readdata  : out  std_logic_vector(31 downto 0);
        avs_writedata : in   std_logic_vector(31 downto 0);

        --external I/O
        push_button : in    std_logic;
        switches    : in    std_logic_vector(3 downto 0);
        led         : out   std_logic_vector(7 downto 0)
    );
end entity led_patterns_avalon;

architecture led_patterns_avalon_arch of led_patterns_avalon is

    signal HPS_LED_control : std_logic := '0';
    signal base_period     : unsigned(7 downto 0) := "00010000";
    signal LED_reg         : std_logic_vector(7 downto 0) := "00000000";

    component LED_patterns is
        port(
        clk              : in  std_logic;
        rst              : in  std_logic;
        PB               : in  std_logic;
        SW               : in  std_logic_vector(3 downto 0);
        HPS_LED_control  : in  std_logic;
        base_period      : in  unsigned(7 downto 0);
        LED_reg          : in  std_logic_Vector(7 downto 0);
        LED              : out std_logic_Vector(7 downto 0)
        );
    end component LED_patterns;

    begin

        led_pat : component LED_patterns
            port map(
                clk             => clk,
                rst             => rst, 
                PB              => push_button,
                SW              => switches, 
                HPS_LED_control => HPS_LED_control,
                base_period     => base_period,
                LED_reg         => LED_reg,
                LED             => LED
            );

        avalon_register_read : process(clk)
        begin
            if rising_edge(clk) and avs_read = '1' then
                case avs_address is
                    when "00" => avs_readdata <= "0000000000000000000000000000000" & HPS_LED_control;
                    when "01" => avs_readdata <= "000000000000000000000000" & std_logic_vector(base_period);
                    when "10" => avs_readdata <= "000000000000000000000000" & LED_reg;
                    when others => avs_readdata <= (others => '0'); -- return zeros for  unused registers
                end case;
            end if;
        end process;

        avalon_register_write : process(clk,rst)
        begin
            if rst ='1' then
                HPS_LED_control <= '1';
                base_period     <= "00010000";
                LED_reg         <= "00000000";
            elsif rising_edge(clk) and avs_write = '1' then
                case avs_address is 
                    when "00" => HPS_LED_control <= avs_writedata(0);
                    when "01" => base_period     <= unsigned(avs_writedata(7 downto 0));
                    when "10" => LED_reg         <= avs_writedata(7 downto 0);
                    when others => null;
                end case;
            end if;
        end process; 


end architecture led_patterns_avalon_arch;

