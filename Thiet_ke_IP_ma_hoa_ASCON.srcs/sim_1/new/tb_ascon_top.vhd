library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity tb_ascon_top is
end entity;

architecture sim of tb_ascon_top is
    component ascon_top
        port (
            clk         : in  std_logic;
            rst         : in  std_logic;
            start       : in  std_logic;
            key         : in  std_logic_vector(127 downto 0);
            nonce       : in  std_logic_vector(127 downto 0);
            plaintext   : in  std_logic_vector(127 downto 0);
            associated_data : in  std_logic_vector(127 downto 0);
            done        : out std_logic;
            ciphertext  : out std_logic_vector(127 downto 0);
            tag         : out std_logic_vector(127 downto 0)
        );
    end component;

    signal clk, rst, start, done : std_logic := '0';
    signal key, nonce, plaintext, a_data : std_logic_vector(127 downto 0);
    signal ciphertext, tag : std_logic_vector(127 downto 0);

begin
    -- Clock
    clk_proc : process
    begin
        while true loop
            clk <= '0'; wait for 5 ns;
            clk <= '1'; wait for 5 ns;
        end loop;
    end process;

    -- Instantiate DUT
    dut: ascon_top
        port map (
            clk => clk,
            rst => rst,
            start => start,
            key => key,
            nonce => nonce,
            plaintext => plaintext,
            associated_data => a_data,
            done => done,
            ciphertext => ciphertext,
            tag => tag
        );

    -- Stimulus
    stim_proc: process
    begin
        rst <= '1'; wait for 20 ns;
        rst <= '0'; wait for 10 ns;

        ------------------------------------------------
        -- TEST CASE #1
        key       <= x"000102030405060708090A0B0C0D0E0F";
        nonce     <= x"00000000000000000000000000000000";
        plaintext <= x"112233445566778899AABBCCDDEEFF00";
        a_data    <= x"00000000000000000000000000000000";
        start <= '1'; wait for 10 ns; start <= '0';
        wait until done = '1';
        report "TEST #1";
        report "Ciphertext: " & to_hstring(to_bitvector(ciphertext));
        report "Tag: " & to_hstring(to_bitvector(tag));
        wait until done = '0';  -- <<< CH? done tr? v? '0' trý?c khi test ti?p
    
        wait;
    end process;

end architecture;
