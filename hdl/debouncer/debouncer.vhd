library ieee;
use ieee.std_logic_1164.all;
use work.print_pkg.all;
use work.assert_pkg.all;
use work.tb_pkg.all;

entity debouncer is
    generic (
    clk_period : time := 20 ns;
    debounce_time : time
    );
    port (
    clk : in std_ulogic;
    rst : in std_ulogic;
    input : in std_ulogic;
    debounced : out std_ulogic
    );
end entity debouncer;

architecture debouncer_arch of debouncer is
    type state_type is(idle, d1, d2);
    signal state : state_type;



    signal hold_signal: std_logic := '0';

    
    signal done   : boolean;

    constant COUNTER_LIMIT : natural := (debounce_time / clk_period);
    signal counter : natural;

    begin

    state_logic : process(clk,rst)
        begin
        
        if rst = '1' then
            state <= idle;
        elsif rising_edge(clk) then
            
            case state is

                when idle => 
                counter <= 0;
                    state <= d1 when input = '1' else
                             idle;
                    

                when d1 =>
                    if (counter < COUNTER_LIMIT-1) then
                        counter <= counter +1;
                        done <= false;
                    elsif(counter = COUNTER_LIMIT-1) then
                        done <= true;
                        counter <= 0;
                        state <= d2 when input = '0' else
                                 d1;
                    else
                        counter <= 0;
                    end if;
                    
                
                    
                    
                when d2 => 
                    if (counter < COUNTER_LIMIT-1) then
                       counter <= counter +1;
                       done <= false;
                    elsif(counter = COUNTER_LIMIT-1) then
                        done <= true;
                        counter <= 0;
                        state <= idle;
                    else 
                        counter <= 0;
                    end if;

                when others =>
                    done <= false;
                    counter <= 0;
                    
            end case;
        end if;
    end process;

    output_logic : process(state)
    begin
        case state is
            when idle =>
                debounced <= input;
            when d1 =>
                debounced <= '1';
            when d2 => 
                debounced <= '0';
            when others =>
                debounced <= input;
        end case;
    end process;
    
    
    

end architecture debouncer_arch;