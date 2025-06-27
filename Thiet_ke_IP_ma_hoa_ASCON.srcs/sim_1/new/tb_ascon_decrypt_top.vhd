library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

entity tb_ascon_decrypt_top is
end entity;

architecture sim of tb_ascon_decrypt_top is
    component ascon_decrypt_top
        port (
            clk         : in  std_logic;
            rst         : in  std_logic;
            start       : in  std_logic;
            key         : in  std_logic_vector(127 downto 0);
            nonce       : in  std_logic_vector(127 downto 0);
            ciphertext  : in  std_logic_vector(127 downto 0);
            received_tag: in  std_logic_vector(127 downto 0);
            done        : out std_logic;
            plaintext_out : out std_logic_vector(127 downto 0);
            valid       : out std_logic
        );
    end component;

    signal clk, rst, start, done : std_logic := '0';
    signal key, nonce : std_logic_vector(127 downto 0);
    signal ciphertext, received_tag : std_logic_vector(127 downto 0);
    signal plaintext_out : std_logic_vector(127 downto 0);
    signal valid : std_logic;

begin
    -- Clock generation
    clk_proc : process
    begin
        while true loop
            clk <= '0'; wait for 5 ns;
            clk <= '1'; wait for 5 ns;
        end loop;
    end process;

    -- Instantiate DUT
    dut: ascon_decrypt_top
        port map (
            clk => clk,
            rst => rst,
            start => start,
            key => key,
            nonce => nonce,
            ciphertext => ciphertext,
            received_tag => received_tag,
            done => done,
            plaintext_out => plaintext_out,
            valid => valid
        );

    -- Stimulus
    stim_proc: process
    begin
        rst <= '1'; wait for 20 ns;
        rst <= '0'; wait for 10 ns;

        ------------------------------------------------
        -- TEST CASE #1: GI?I M?
        key       <= x"000102030405060708090A0B0C0D0E0F";
        nonce     <= x"00000000000000000000000000000000";

        -- C?n s?a l?i giá tr? này b?ng ðúng ciphertext & tag thu ðý?c t? tb_ascon_top
        ciphertext   <= x"112331475163718F91A3B1C7D1E3F100"; -- Thay th? ðúng
        received_tag <= x"000102030405060708090A0B0C0D0E0F"; -- Thay th? ðúng

        start <= '1'; wait for 10 ns; start <= '0';
        wait until done = '1';

        report "TEST #1";
        report "Plaintext_out: " & to_hstring(to_bitvector(plaintext_out));
        report "Successful " & std_logic'image(valid);
        
        wait;
    end process;

end architecture;
