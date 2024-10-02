library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;  -- Add this for numeric conversions
use ieee.math_real.all;

entity clk_gen is 
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
end entity clk_gen;

architecture clk_gen_arch of clk_gen is

    signal base_counter   : natural := 0;
    signal double_counter : natural := 0;
    signal quad_counter   : natural := 0;
    signal half_counter   : natural := 0;
    signal oct_counter    : natural := 0;
    signal quint_counter  : natural := 0;

    signal base_int   : std_logic := '0';
    signal double_int : std_logic := '0';  --twice as quick so divide by 2
    signal quad_int   : std_logic := '0';
    signal half_int   : std_logic := '0';
    signal oct_int    : std_logic := '0';
    signal quint_int  : std_logic := '0';

    begin

        clk_gen_base   <= base_int;
        clk_gen_double <= double_int;
        clk_gen_quad   <= quad_int;
        clk_gen_half   <= half_int;
        clk_gen_oct    <= oct_int;
        clk_gen_quint  <= quint_int;

        base : process(clk, rst)
        begin
            if rising_edge(clk) then
                if (base_counter < base_count/2) then
                    base_counter <= base_counter + 1;
                else 
                    base_counter <= 0;
                    base_int <= not base_int;
            
                end if;
            end if;
        end process;

        double : process(clk, rst)
        begin
            if rising_edge(clk) then
                if (double_counter < base_count/4) then
                    double_counter <= double_counter + 1;
                else 
                    double_counter <= 0;
                    double_int <= not double_int;
            
                end if;
            end if;
        end process;

        quad : process(clk, rst)
        begin
            if rising_edge(clk) then
                if (quad_counter < base_count/8) then
                    quad_counter <= quad_counter + 1;
                else 
                    quad_counter <= 0;
                    quad_int <= not quad_int;
            
                end if;
            end if;
        end process;

        half : process(clk, rst)
        begin
            if rising_edge(clk) then
                if (half_counter < base_count) then
                    half_counter <= half_counter + 1;
                else 
                    half_counter <= 0;
                    half_int <= not half_int;
            
                end if;
            end if;
        end process;

        oct : process(clk, rst)
        begin
            if rising_edge(clk) then
                if (oct_counter < base_count/16) then
                    oct_counter <= oct_counter + 1;
                else 
                    oct_counter <= 0;
                    oct_int <= not oct_int;
            
                end if;
            end if;
        end process;

        quint : process(clk, rst)
        begin
            if rising_edge(clk) then
                if (quint_counter < base_count/10) then
                    quint_counter <= quint_counter + 1;
                else 
                    quint_counter <= 0;
                    quint_int <= not quint_int;
            
                end if;
            end if;
        end process;

    end architecture clk_gen_arch;
