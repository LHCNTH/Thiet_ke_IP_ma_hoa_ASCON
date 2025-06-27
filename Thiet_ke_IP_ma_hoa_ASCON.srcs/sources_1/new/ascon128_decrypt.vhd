library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ascon128_decrypt is
    port (
        clk         : in  std_logic;
        rst         : in  std_logic;
        start       : in  std_logic;
        state_i     : in  std_logic_vector(319 downto 0);
        ciphertext  : in  std_logic_vector(127 downto 0);
        state_o     : out std_logic_vector(319 downto 0);
        plaintext   : out std_logic_vector(127 downto 0);
        done        : out std_logic
    );
end entity;

architecture Behavioral of ascon128_decrypt is

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

    signal state_temp   : std_logic_vector(319 downto 0);
    signal pt           : std_logic_vector(127 downto 0);
    signal perm_start   : std_logic := '0';
    signal perm_done    : std_logic := '0';
    signal start_reg    : std_logic := '0';
    signal final_state  : std_logic_vector(319 downto 0);

begin

    -- Gi?i m?: ciphertext xor state ? plaintext
    -- C?p nh?t l?i state b?ng cách XOR plaintext vào state
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state_temp  <= (others => '0');
                pt          <= (others => '0');
                perm_start  <= '0';
                start_reg   <= '0';
                done        <= '0';
            elsif start = '1' and start_reg = '0' then
                -- Tính plaintext = ciphertext XOR ph?n tr?ng thái
                pt <= ciphertext xor state_i(127 downto 0);

                -- C?p nh?t l?i tr?ng thái: XOR plaintext vào
                state_temp <= state_i;
                state_temp(127 downto 0) <= state_i(127 downto 0) xor pt;

                perm_start <= '1';
                start_reg  <= '1';
            elsif perm_done = '1' then
                done        <= '1';
                perm_start  <= '0';
                start_reg   <= '0';  -- cho phép gi?i m? kh?i ti?p theo n?u có
            else
                done        <= '0';
            end if;
        end if;
    end process;

    -- G?i permutation v?i 6 v?ng (p_b)
    u_perm: ascon_permutation
        port map (
            clk      => clk,
            rst      => rst,
            start    => perm_start,
            state_i  => state_temp,
            rounds   => 6,
            state_o  => final_state,
            done     => perm_done
        );

    plaintext <= pt;
    state_o   <= final_state;

end Behavioral;
