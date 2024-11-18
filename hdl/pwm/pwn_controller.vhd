library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;
use ieee.math_real.all;

entity pwm_controller is
    port (
        clk : in std_logic;
        rst : in std_logic;
        -- PWM repetition period in milliseconds;
        -- datatype (W.F) is individually assigned
        period : in unsigned(32 - 1 downto 0);
        -- PWM duty cycle between [0 1]; out-of-range values are hard-limited
        -- datatype (W.F) is individually assigned
        duty_cycle : in std_logic_vector(18 - 1 downto 0);
        output : out std_logic
    );
end entity pwm_controller;

architecture pwm_controller_arch of pwm_controller is

    constant  CLK_period : time := 20 ns;


    signal count: unsigned(32 - 1 downto 0) :=  (others => '0');

--------------from lab 4 ------------

    constant N_BITS_SYS_CLK_FREQ : natural := natural(ceil(log2(real(1 ms /  CLK_period))));
    constant SYS_CLK_FREQ : unsigned(N_BITS_SYS_CLK_FREQ - 1 downto 0) := to_unsigned((1 ms /  CLK_period), N_BITS_SYS_CLK_FREQ);
    constant N_BITS_CLK_CYCLES_FULL : natural := N_BITS_SYS_CLK_FREQ + 32;
    constant N_BITS_CLK_CYCLES : natural := N_BITS_SYS_CLK_FREQ + 7;
    signal period_clk_full_prec : unsigned(N_BITS_CLK_CYCLES_FULL - 1 downto 0);
    signal period_clk : unsigned(N_BITS_CLK_CYCLES - 1 downto 0);

-------------------------------

    --Duty Cycle Conversions
    --    calculates the sizes of the signals needed

    constant DUTY_COUNT_BITS_FULL : natural := N_BITS_CLK_CYCLES_FULL + 18;
    constant DUTY_COUNT_BITS : natural := N_BITS_CLK_CYCLES_FULL + 1;
    signal duty_count_full_prec : unsigned(DUTY_COUNT_BITS_FULL - 1 downto 0);
    signal duty_count : unsigned(23 downto 0);
    signal duty_cycle_scaled : unsigned(17 downto 0);

    begin

        period_clk_full_prec <= SYS_CLK_FREQ * period;

        -- gets rip of fractional bits
        period_clk <= period_clk_full_prec(N_BITS_CLK_CYCLES_FULL - 1 downto 25);

      -- Duty Cycle Calculations 

        duty_cycle_scaled <= unsigned(duty_cycle);
        duty_count_full_prec <= period_clk_full_prec * duty_cycle_scaled;
        duty_count <= duty_count_full_prec(DUTY_COUNT_BITS_FULL - 1 downto 25+17);

        PWM : process(clk)
        begin
            if rising_edge(clk) then
                if rst = '1' then
                    count <= (others => '0');
                    output <= '0';
                else

                    if count < period_clk then
                        count <= count + 1;
                    elsif count >= period_clk then
                        count <= (others => '0');
                    else 
                        count <= (others => '0');
                        
                    end if;
                    
                    if count < duty_count then
                        output <= '1';
                    else
                        output <= '0';
                    end if;

                end if;
            end if;
        end process;
end architecture ; -- pwm_controller