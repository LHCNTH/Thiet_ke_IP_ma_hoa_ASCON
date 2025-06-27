library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity tb_ascon_permutation is
end entity;

architecture sim of tb_ascon_permutation is

    -- Component declaration
    component ascon_permutation
        port (
            clk      : in  std_logic;
            rst      : in  std_logic;
            start    : in  std_logic;
            state_i  : in  std_logic_vector(319 downto 0);
            rounds   : in  integer range 1 to 12;
            state_o  : out std_logic_vector(319 downto 0);
            done     : out std_logic
        );
    end component;

    -- Signal declarations
    signal clk        : std_logic := '0';
    signal rst        : std_logic := '0';
    signal start      : std_logic := '0';
    signal done       : std_logic;
    signal state_i    : std_logic_vector(319 downto 0);
    signal state_o    : std_logic_vector(319 downto 0);
    signal rounds     : integer := 12;

begin

    -- Clock generation
    clk_process : process
    begin
        while true loop
            clk <= '0'; wait for 5 ns;
            clk <= '1'; wait for 5 ns;
        end loop;
    end process;

    -- Instantiate DUT
    uut: ascon_permutation
        port map (
            clk      => clk,
            rst      => rst,
            start    => start,
            state_i  => state_i,
            rounds   => rounds,
            state_o  => state_o,
            done     => done
        );

    -- Stimulus process
    stim_proc : process
    begin
        -- Reset
        rst <= '1';
        wait for 20 ns;
        rst <= '0';
        wait for 10 ns;

        -- Gán state ð?u vào m?u (có th? thay ð?i)
        state_i <= x"000102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F2021222324252627";

        -- Start permutation
        start <= '1';
        wait for 10 ns;
        start <= '0';

        -- Ch? ð?n khi xong
        wait until done = '1';

        -- In k?t qu?
        report "==== Permutation 12 rounds completed ====";
        report "Input state : " & to_hstring(to_bitvector(state_i));
        report "Output state: " & to_hstring(to_bitvector(state_o));

        wait;
    end process;

end architecture;
