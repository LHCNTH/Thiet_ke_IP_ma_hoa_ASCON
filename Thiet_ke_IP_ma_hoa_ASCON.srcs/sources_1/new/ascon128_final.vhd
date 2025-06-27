library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ascon128_final is
    port (
        clk     : in  std_logic;
        rst     : in  std_logic;
        start   : in  std_logic;
        state_i : in  std_logic_vector(319 downto 0);
        tag     : out std_logic_vector(127 downto 0);
        done    : out std_logic
    );
end entity;

architecture Behavioral of ascon128_final is

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

    signal perm_start   : std_logic := '0';
    signal perm_done    : std_logic;
    signal start_reg    : std_logic := '0';
    signal final_state  : std_logic_vector(319 downto 0);

begin

    -- Control logic ð? g?i permutation
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                perm_start <= '0';
                start_reg <= '0';
                done <= '0';
                tag <= (others => '0');
            elsif start = '1' and start_reg = '0' then
                perm_start <= '1';
                start_reg <= '1';
            elsif perm_done = '1' then
                tag <= final_state(127 + 128 downto 128);  -- l?y t? state(255 downto 128)
                done <= '1';
                perm_start <= '0';
            else
                done <= '0';
            end if;
        end if;
    end process;

    -- G?i ascon_permutation v?i 12 rounds
    u_perm: ascon_permutation
        port map (
            clk      => clk,
            rst      => rst,
            start    => perm_start,
            state_i  => state_i,
            rounds   => 12,
            state_o  => final_state,
            done     => perm_done
        );

end Behavioral;
