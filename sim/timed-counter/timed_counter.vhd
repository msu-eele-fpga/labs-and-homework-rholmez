library ieee;
use ieee.std_logic_1164.all;

entity timed_counter is 
generic(
    clk_period : time;
    count_time : time
);
port(
    clk     : in   std_ulogic;
    enable  : in   boolean;
    done    : out  boolean
);
end entity timed_counter;

architecture timed_counter_arch of timed_counter is
    
    constant COUNTER_LIMIT : natural := (count_time / clk_period);
    signal counter : natural range 0 to COUNTER_LIMIT+10;
    begin

        process(clk)
        begin
            if rising_edge(clk) then
                if (enable = true) then 
                    if (counter < COUNTER_LIMIT) then
                        counter <= counter +1;
                        done <= false;
                    else
                        done <= true;
                        counter <= 0;
                    end if;
                else
                    counter <= 0;
                    done <= false;
                end if;
            end if;
        end process;
end architecture timed_counter_arch;