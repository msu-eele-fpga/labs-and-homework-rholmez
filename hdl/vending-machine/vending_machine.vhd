library ieee;
use ieee.std_logic_1164.all;

entity vending_machine is
    port (
    clk      : in std_ulogic;
    rst      : in std_ulogic;
    nickel   : in std_ulogic;
    dime     : in std_ulogic;
    dispense : out std_ulogic;
    amount   : out natural range 0 to 15);
end entity vending_machine;

architecture vending_machine_arch of vending_machine is

    type state_type is (idle, c5,c10, c15);
    signal state : state_type;

    begin
    state_logic : process(clk, rst)
        begin
        if rst = '1' then
            state <= idle;
        elsif rising_edge(clk) then
            case state is
                when idle =>
                    state <= c10 when dime = '1' else 
                             c5 when nickel = '1' else 
                             --c15 when dime = '1' and nickel = '1' else 
                             idle;
                
                when c5 =>
                    state <= c15 when dime = '1' else
                             c10 when nickel = '1' else
                             c5;
                when c10 =>
                    state <= c15 when dime = '1' else 
                             c15 when nickel = '1' else 
                             c10;
                when c15 => 
                    state <= idle;
                when others =>
                    state <= idle;
            end case;
        end if;
    end process state_logic;

    output_logic : process(state, nickel, dime)
        begin
        case state is
            when idle =>
                amount <= 0;
                dispense <= '0';
            when c5 =>
                amount <= 5;
                dispense <= '0';
            when c10 =>
                amount <= 10;
                dispense <= '0';
            when c15 =>
                amount <= 15;
                dispense <= '1';
            when others =>
                amount <= 0;
                dispense <= '0';
        end case;
    end process output_logic;

end architecture vending_machine_arch;
    