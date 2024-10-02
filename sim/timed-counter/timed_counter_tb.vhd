library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;  -- Add this for numeric conversions
use work.print_pkg.all;
use work.assert_pkg.all;
use work.tb_pkg.all;

entity timed_counter_tb is
end entity timed_counter_tb;

architecture testbench of timed_counter_tb is

	component timed_counter is
	  generic (
	    clk_period : time;
	    count_time : time
	  );
	  port (
	    clk : in std_ulogic;
	    enable : in boolean;
	    done : out boolean
	  );
	end component timed_counter;

	signal clk_tb : std_ulogic := '0';

	signal enable_100ns_tb : boolean := false;
	signal done_100ns_tb : boolean;

	signal enable_240ns_tb : boolean := false;
	signal done_240ns_tb : boolean;

	

	constant HUNDRED_NS : time := 100 ns;
	constant TwoForty_ns : time := 240 ns;

	procedure predict_counter_done (
	    constant count_time : in time;
	    signal enable : in boolean;
	    signal done : in boolean;
	    constant count_iter : in natural
	) is

	begin

	  if enable then
	    if count_iter < (count_time / CLK_PERIOD) then
	      assert_false(done, "counter not done");
	    else
	      assert_true(done, "counter is done");
	    end if;
	  else
	    assert_false(done, "counter not enabled");
	  end if;

	end procedure predict_counter_done;


   begin

	dut_100ns_counter : component timed_counter
	  generic map (
	    clk_period => CLK_PERIOD,
	    count_time => HUNDRED_NS
	  )
	  port map (
	    clk => clk_tb,
	    enable => enable_100ns_tb,
	    done => done_100ns_tb
	  );
	  dut_240ns_counter : component timed_counter
	  generic map (
	    clk_period => CLK_PERIOD,
	    count_time => TwoForty_NS
	  )
	  port map (
	    clk => clk_tb,
	    enable => enable_240ns_tb,
	    done => done_240ns_tb
	  );

	clk_tb <= not clk_tb after CLK_PERIOD / 2;

	stimuli_and_checker : process is
	begin

	  -- test 100 ns timer when it's enabled
	  print("testing 100 ns timer: enabled");
	  wait_for_clock_edge(clk_tb);
	  enable_100ns_tb <= true;

	  -- loop for the number of clock cylces that is equal to the timer's period
	for i in 0 to (HUNDRED_NS / CLK_PERIOD) loop
	  wait_for_clock_edge(clk_tb);
	  predict_counter_done(HUNDRED_NS, enable_100ns_tb, done_100ns_tb, i);
	end loop;
	-- add other test cases here

	-- test to make sure done doesnt get asserted when enable is false
	print("test to make sure done doesnt get asserted when enable is false");
	wait_for_clock_edge(clk_tb);
	enable_100ns_tb <= false;

	-- loop for the number of clock cylces that is equal to the timer's period
  for i in 0 to (HUNDRED_NS*2 / CLK_PERIOD) loop
	wait_for_clock_edge(clk_tb);
	predict_counter_done(HUNDRED_NS*2, enable_100ns_tb, done_100ns_tb, i);
  end loop;
  -- add other test cases here

  -- test to make sure done doesnt get asserted when enable is false
	print("test 200ns counter with enable");
	wait_for_clock_edge(clk_tb);
	enable_100ns_tb <= true;

	-- loop for the number of clock cylces that is equal to the timer's period
	for x in 0 to 1 loop
  		for i in 0 to (HUNDRED_NS / CLK_PERIOD) loop
			wait_for_clock_edge(clk_tb);
			predict_counter_done(HUNDRED_NS, enable_100ns_tb, done_100ns_tb, i);
  		end loop;
	end loop;

	enable_100ns_tb <= false;

----------------- testing 240ns counter------------------------

	-- test 100 ns timer when it's enabled
	print("testing 240 ns timer: enabled");
	wait_for_clock_edge(clk_tb);
	enable_240ns_tb <= true;

	-- loop for the number of clock cylces that is equal to the timer's period
  for i in 0 to (TwoForty_ns / CLK_PERIOD) loop
	wait_for_clock_edge(clk_tb);
	predict_counter_done(TwoForty_ns, enable_240ns_tb, done_240ns_tb, i);
  end loop;

  -- test 240 ns timer when it's disabled twice
	print("testing 240 ns timer x2: disabled");
	wait_for_clock_edge(clk_tb);
	enable_240ns_tb <= false;

	-- loop for the number of clock cylces that is equal to the timer's period
  for i in 0 to (TwoForty_ns*2 / CLK_PERIOD) loop
	wait_for_clock_edge(clk_tb);
	predict_counter_done(TwoForty_ns*2, enable_240ns_tb, done_240ns_tb, i);
  end loop;

  -- test 240 ns timer enabled, x2 so 480 timer
	print("testing 480 ns timer : enable");
	wait_for_clock_edge(clk_tb);
	enable_240ns_tb <= true;

	-- loop for the number of clock cylces that is equal to the timer's period
	for x in 0 to 1 loop
    	for i in 0 to (TwoForty_ns / CLK_PERIOD) loop
			wait_for_clock_edge(clk_tb);
			predict_counter_done(TwoForty_ns, enable_240ns_tb, done_240ns_tb, i);
    	end loop;
	end loop;
  



	-- testbench is done :)
	std.env.finish;

    end process stimuli_and_checker;

end architecture testbench;
