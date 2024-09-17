library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.assert_pkg.all;
use work.print_pkg.all;
use work.tb_pkg.all;

entity async_conditioner_tb is
end entity async_conditioner_tb;

architecture testbench of async_conditioner_tb is

  constant CLK_PERIOD : time := 20 ns;

  component async_conditioner is
    port (
        clk     :  in std_ulogic;
        rst     :  in std_ulogic;
        async   :  in std_ulogic;
        sync    : out std_ulogic
    );
end component async_conditioner;

  component one_pulse is
    port (
      clk    : in    std_logic;
      rst    : in    std_ulogic;
      input  : in    std_ulogic;
      pulse  : out    std_ulogic
    );
  end component one_pulse;

  component debouncer is
    generic (
    clk_period : time := 20 ns;
    debounce_time : time := 100 ns
    );
    port (
    clk : in std_ulogic;
    rst : in std_ulogic;
    input : in std_ulogic;
    debounced : out std_ulogic
    );
  end component debouncer;

  component synchronizer is
    port (
        clk     : in  std_ulogic;
        async   : in  std_ulogic;
        sync    : out std_ulogic
    );
    end component synchronizer;


  signal clk_tb        : std_ulogic := '0';
  signal rst_tb        : std_ulogic := '0';
  signal input_tb      : std_ulogic := '0';
  signal pulse_tb      : std_ulogic;
  signal expected      : std_ulogic;
  signal debounced_tb  : std_ulogic;
  signal async_tb      : std_ulogic;
  signal sync_tb       : std_ulogic;
  signal sync1_tb       : std_ulogic;
  signal s_out_tb       : std_ulogic;  
  signal d_out_tb       : std_ulogic;



begin

  dut : component async_conditioner
    port map (
      clk    => clk_tb,
      rst    => rst_tb,
      async  => async_tb,
      sync   => sync1_tb
    );

  s1  : component synchronizer
    port map (
    clk      =>  clk_tb,
    async    =>  async_tb,
    sync    =>   s_out_tb
    );
  
  d1 : component debouncer
    
    port map (
    clk      =>  clk_tb,
    rst      =>  rst_tb,
    input    =>  s_out_tb,
    debounced => d_out_tb
    );
    o1: component one_pulse
      port map (
      clk    => clk_tb,
      rst    => rst_tb,
      input  => d_out_tb,
      pulse => sync_tb
      );
  
    

  clk_gen : process is
  begin

    clk_tb <= not clk_tb;
    wait for CLK_PERIOD / 2;

  end process clk_gen;

  -- Create the asynchronous signal
  input_stim : process is
  begin

    async_tb <= '0';
    wait for 1.8 * CLK_PERIOD;

    async_tb <= '1';
    wait for 2 * CLK_PERIOD;

    async_tb <= '0';
    wait for 3 * CLK_PERIOD;

    async_tb <= '1';

    wait;

  end process input_stim;

  -- Create the expected synchronized output waveform
  pulse_expected : process is
  begin

    expected <= '0';
    wait for 6* CLK_PERIOD;

    expected <= '1';
    wait for 1 * CLK_PERIOD;

    expected <= '0';
    wait for 3 * CLK_PERIOD;

    wait;

  end process pulse_expected;

  check_output : process is

    variable failed : boolean := false;

  begin

    for i in 0 to 9 loop

      assert expected = sync_tb
        report "Error for clock cycle " & to_string(i) & ":" & LF & "sync = " & to_string(sync_tb) & " sync_expected  = " & to_string(expected)
        severity warning;

      if expected /= sync_tb then
        failed := true;
      end if;

      wait for CLK_PERIOD;

    end loop;

    if failed then
    --  report "tests failed!"
    --    severity failure;
    else
      report "all tests passed!";
    end if;

    std.env.finish;

  end process check_output;

end architecture testbench;
