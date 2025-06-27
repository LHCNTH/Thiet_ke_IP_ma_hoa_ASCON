library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ascon128_init is
    port (
        clk     : in  std_logic;
        rst     : in  std_logic;
        start   : in  std_logic;
        key     : in  std_logic_vector(127 downto 0);
        nonce   : in  std_logic_vector(127 downto 0);
        state_o : out std_logic_vector(319 downto 0);
        done    : out std_logic
    );
end entity;

architecture Behavioral of ascon128_init is

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

    signal init_state      : std_logic_vector(319 downto 0);
    signal permuted_state  : std_logic_vector(319 downto 0);
    signal perm_start      : std_logic := '0';
    signal perm_done       : std_logic := '0';
    signal init_done       : std_logic := '0';
    signal start_reg       : std_logic := '0';

begin

    -- T?o tr?ng thái ban ð?u t? IV || Key || Nonce
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                init_state <= (others => '0');
                perm_start <= '0';
                init_done <= '0';
                start_reg <= '0';
            elsif start = '1' and start_reg = '0' then
                --  IV || Key || Nonce 
                init_state(319 downto 256) <= x"80400c0600000000" xor key(127 downto 64);
                init_state(255 downto 128) <= key xor nonce;
                init_state(127 downto 0)   <= nonce xor key;

                perm_start <= '1';
                start_reg <= '1';
            elsif perm_done = '1' then
                init_done <= '1';
                perm_start <= '0';
            end if;
        end if;
    end process;

    -- G?i ascon_permutation v?i 12 v?ng
    u_perm: ascon_permutation
        port map (
            clk      => clk,
            rst      => rst,
            start    => perm_start,
            state_i  => init_state,
            rounds   => 12,
            state_o  => permuted_state,
            done     => perm_done
        );

    state_o <= permuted_state;
    done    <= init_done;

end Behavioral;
