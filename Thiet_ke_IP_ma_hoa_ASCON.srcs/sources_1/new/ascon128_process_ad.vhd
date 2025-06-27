library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ascon128_process_ad is
    port (
        clk      : in  std_logic;
        rst      : in  std_logic;
        start    : in  std_logic;
        ad_block : in  std_logic_vector(127 downto 0);
        state_i  : in  std_logic_vector(319 downto 0);
        state_o  : out std_logic_vector(319 downto 0);
        done     : out std_logic
    );
end entity;

architecture Behavioral of ascon128_process_ad is

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

    signal state_xored  : std_logic_vector(319 downto 0);
    signal perm_start   : std_logic := '0';
    signal perm_done    : std_logic;
    signal final_state  : std_logic_vector(319 downto 0);
    signal start_reg    : std_logic := '0';

begin

    -- X? l? AD và kh?i ð?ng phép bi?n ð?i
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                perm_start <= '0';
                done <= '0';
                start_reg <= '0';
            elsif start = '1' and start_reg = '0' then
                -- XOR ad_block vào 128 bit th?p c?a state
                state_xored(127 downto 0)   <= state_i(127 downto 0) xor ad_block;
                state_xored(319 downto 128) <= state_i(319 downto 128);
                perm_start <= '1';
                start_reg <= '1';
            elsif perm_done = '1' then
                done <= '1';
                perm_start <= '0';
            else
                done <= '0';
            end if;
        end if;
    end process;

    -- G?i permutation v?i 6 rounds (p_b)
    u_perm: ascon_permutation
        port map (
            clk      => clk,
            rst      => rst,
            start    => perm_start,
            state_i  => state_xored,
            rounds   => 6,
            state_o  => final_state,
            done     => perm_done
        );

    state_o <= final_state;

end architecture;
