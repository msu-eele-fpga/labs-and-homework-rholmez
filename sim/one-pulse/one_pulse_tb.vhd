library ieee;
use ieee.std_logic_1164.all;

entity one_pulse_tb is
end entity one_pulse_tb;

architecture testbench of one_pulse_tb is

  constant CLK_PERIOD : time := 10 ns;

  component one_pulse is
    port (
      clk    : in    std_logic;
      rst    : in    std_ulogic;
      input  : in    std_ulogic;
      pulse  : out    std_ulogic
    );
  end component one_pulse;

  signal clk_tb        : std_ulogic := '0';
  signal rst_tb        : std_ulogic := '0';
  signal input_tb      : std_ulogic := '0';
  signal pulse_tb      : std_ulogic;
  signal expected      : std_ulogic;

begin

  dut : component one_pulse
    port map (
      clk    => clk_tb,
      rst    => rst_tb,
      input  => input_tb,
      pulse => pulse_tb
    );

  clk_gen : process is
  begin

    clk_tb <= not clk_tb;
    wait for CLK_PERIOD / 2;

  end process clk_gen;

  -- Create the asynchronous signal
  input_stim : process is
  begin

    input_tb <= '0';
    wait for 2 * CLK_PERIOD;

    input_tb <= '1';
    wait for 2 * CLK_PERIOD;

    input_tb <= '0';
    wait for 3 * CLK_PERIOD;

    input_tb <= '1';

    wait;

  end process input_stim;

  -- Create the expected synchronized output waveform
  pulse_expected : process is
  begin

    expected <= '0';
    wait for 3* CLK_PERIOD;

    expected <= '1';
    wait for 1 * CLK_PERIOD;

    expected <= '0';
    wait for 4 * CLK_PERIOD;

    expected <= '1';
    wait for 1 * CLK_PERIOD;

    expected <= '0';
    wait for 1 * CLK_PERIOD;


    wait;

  end process pulse_expected;

  check_output : process is

    variable failed : boolean := false;

  begin

    for i in 0 to 9 loop

      assert expected = pulse_tb
        report "Error for clock cycle " & to_string(i) & ":" & LF & "sync = " & to_string(pulse_tb) & " sync_expected  = " & to_string(expected)
        severity warning;

      if expected /= pulse_tb then
        failed := true;
      end if;

      wait for CLK_PERIOD;

    end loop;

    if failed then
      report "tests failed!"
        severity failure;
    else
      report "all tests passed!";
    end if;

    std.env.finish;

  end process check_output;

end architecture testbench;
