library ieee;
use ieee.std_logic_1164.all;

package tb_pkg is
    constant CLK_PERIOD : time := 20 ns;
    constant COMBINATIONAL_DELAY : time := 1 ns;

    procedure wait_for_clock_edge(signal clk: in std_ulogic);

end package;

package body tb_pkg is

    procedure wait_for_clock_edge(signal clk: in std_ulogic) is
    begin
        wait until rising_edge(clk);
        wait for COMBINATIONAL_DELAY;
    end procedure;

end package body;