library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;  -- Add this for numeric conversions
use ieee.math_real.all;

entity LED_patterns is 
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
        LED_reg          : in  std_logic_Vector(7 downto 0);
        LED              : out std_logic_Vector(7 downto 0)
    );
end entity LED_patterns;

architecture LED_patterns_arch of LED_patterns is


    --base period math
    constant N_BITS_SYS_CLK_FREQ : natural := natural(ceil(log2(real(1 sec/ system_clock_period))));
    constant SYS_CLK_FREQ : unsigned(N_BITS_SYS_CLK_FREQ - 1 downto 0) := to_unsigned((1 sec / system_clock_period), N_BITS_SYS_CLK_FREQ);
    constant N_BITS_CLK_CYCLES_FULL : natural := N_BITS_SYS_CLK_FREQ + 8;
    constant N_BITS_CLK_CYCLES : natural := N_BITS_SYS_CLK_FREQ +4 ;
    signal period_base_clk_full_prec : unsigned(N_BITS_CLK_CYCLES_FULL - 1 downto 0);
    signal period_base_clk : unsigned(26 - 1 downto 0);

    --State Machine
    type state_type is (state0, state1, state2, state3, state4, display);
    signal state : state_type := state0;
    signal prev_state : state_type;


    --clkgen


    component clk_gen is 
    port(
        clk              : in  std_logic;
        rst              : in  std_logic;
        base_count       : in  unsigned(25 downto 0);
        clk_gen_base     : out std_logic;
        clk_gen_double   : out std_logic;
        clk_gen_quad     : out std_logic;
        clk_gen_half     : out std_logic;
        clk_gen_oct      : out std_logic;
        clk_gen_quint    : out std_logic  
        );
    end component clk_gen;

    component async_conditioner is
        port (
            clk     :  in std_ulogic;
            rst     :  in std_ulogic;
            async   :  in std_ulogic;
            sync    : out std_ulogic
        );
    end component async_conditioner;

    component timed_counter is 
        generic(
            clk_period : time := 20 ns;
            count_time : time := 1 sec
        );
        port(
            clk     : in   std_ulogic;
            enable  : in   boolean;
            done    : out  boolean
        );
    end component timed_counter;


    signal led7 : std_logic := '0';
    signal pat0 : std_logic_vector(6 downto 0) := "1000000";
    signal pat1 : std_logic_vector(6 downto 0) := "0000011";
    signal pat2 : natural := 0;
    signal pat3 : natural := 127;
    signal pat4 : std_logic_vector(6 downto 0) := "1010101";

    signal PB_sync : std_logic := '0';

    signal enable : boolean := false;
    signal done   : boolean := false;

    signal base_clk         : std_logic := '0';
    signal double_clk       : std_logic := '0';
    signal quad_clk         : std_logic := '0';
    signal half_clk         : std_logic := '0';
    signal oct_clk          : std_logic := '0';
    signal quint_clk        : std_logic := '0';
    

    begin
        --base math
        period_base_clk_full_prec <= SYS_CLK_FREQ * base_period;
        --period_base_clk <= period_base_clk_full_prec(N_BITS_CLK_CYCLES - 1 downto 4);
        period_base_clk <= "10111110101111000010000000";
    

        --clkgen
        clk_generator : component clk_gen
            port map (
                clk => clk,
                rst => rst,
                base_count => period_base_clk,
                clk_gen_base => base_clk,
                clk_gen_double => double_clk,
                clk_gen_quad   => quad_clk, 
                clk_gen_half   => half_clk,
                clk_gen_oct    => oct_clk,
                clk_gen_quint  => quint_clk

            );

        pb_conditioner  : component async_conditioner 
            port map (
                clk => clk,
                rst => rst, 
                async => PB,
                sync  => PB_sync
            );

        counter : component timed_counter
            port map (
                clk => clk,
                enable => enable,
                done => done
            );

        led7_gen : process(base_clk,rst)
            begin
                if rising_edge(base_clk) then
                    led7<= not led7;
                end if;
        end process led7_gen;

        pattern0 : process(double_clk)
            begin
                if rising_edge(double_clk) then
                    pat0 <= pat0(0) & pat0(6 downto 1);    
                end if;
            end process pattern0;
        
        pattern1 : process(quad_clk)
            begin
                if rising_edge(quad_clk) then
                    pat1 <= pat1(5 downto 0) & pat1(6);    
                end if;
        end process pattern1;
    
        pattern2 : process(half_clk)
        begin
            if rising_edge(half_clk) then
                if pat2 = 127 then
                    pat2 <= 0;
                else
                    pat2 <= pat2 +1;
                end if;
            end if;
        end process pattern2;

        pattern3 : process(oct_clk)
        begin
            if rising_edge(oct_clk) then
                if pat3 = 0 then
                    pat3 <= 127;
                else
                    pat3 <= pat3 -1;
                end if;
            end if;
        end process pattern3;

        pattern4 : process(quint_clk)
            begin
                if rising_edge(quint_clk) then
                    pat4<= not pat4;
                end if;
        end process pattern4;

        state_logic : process(clk,rst, PB_sync)
            begin
                if rst = '1' then
                    state <= state0;
                elsif rising_edge(clk) then 
                    case state is
                        when state0 =>
                            prev_state <= state0;
                            if PB_sync = '1' then
                                state <= display;
                            end if;
                        
                        when state1 =>
                              prev_state <= state1;
                            if PB_sync = '1' then
                                state <= display;
                    
                            end if;
                        when state2 =>
                              prev_state <= state2;
                            if PB_sync = '1' then
                                state <= display;
                    
                            end if;
                        when state3 =>
                              prev_state <= state3;
                            if PB_sync = '1' then
                                state <= display;
                            end if;
                        when state4 =>
                            prev_state <= state4;
                            if PB_sync = '1' then
                                state <= display;
                            end if;

                        when display =>
                              enable <= true;
                              if done = true then
                                enable <= false;
                                if sw = "0000" then
                                    state <= state0;
                                elsif sw = "0001" then
                                    state <= state1;
                                elsif sw = "0010" then
                                    state <= state2;
                                elsif sw = "0011" then
                                    state <= state3;
                                elsif sw = "0100" then
                                    state <= state4;
                                else 
                                    state <= prev_state;
                                end if;

                        
                              end if;
                        when others =>
                            state <= prev_state;
                    end case;
                end if;
        end process;

        output_logic : process(clk, state)
            begin
                if rising_edge(clk) then
                  case state is 
                    when state0 =>
                        LED(7 downto 0) <= led7 & pat0;
                    when state1 =>
                        LED(7 downto 0) <= led7 & pat1;
                    when state2 =>
                        LED(7 downto 0) <= led7 & std_logic_vector(to_unsigned(pat2, 7));
                    when state3 =>
                        LED(7 downto 0) <= led7 & std_logic_vector(to_unsigned(pat3, 7));
                    when state4 =>
                        LED(7 downto 0) <= led7 & pat4;
                    when display =>
                        LED(7 downto 0) <= "0000" & SW;
                    when others => 
                        LED(7 downto 0) <= "11111111";
                  end case;
                end if;
        end process;



        
        


end architecture LED_patterns_arch;