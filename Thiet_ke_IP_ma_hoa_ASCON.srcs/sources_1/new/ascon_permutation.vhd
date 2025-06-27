library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ascon_permutation is
    port (
        clk      : in  std_logic;
        rst      : in  std_logic;
        start    : in  std_logic;
        state_i  : in  std_logic_vector(319 downto 0);
        rounds   : in  integer range 1 to 12;
        state_o  : out std_logic_vector(319 downto 0);
        done     : out std_logic
    );
end entity;

architecture Behavioral of ascon_permutation is

    signal round_cnt : integer range 0 to 12 := 0;
    signal state_reg : std_logic_vector(319 downto 0);
    signal busy      : std_logic := '0';

    -- Dummy round constants for illustration (real ones should be used)
    type rc_array is array (0 to 11) of std_logic_vector(63 downto 0);
    constant RC : rc_array := (
        x"000000000000000f", x"000000000000000e", x"000000000000000d", x"000000000000000c",
        x"000000000000000b", x"000000000000000a", x"0000000000000009", x"0000000000000008",
        x"0000000000000007", x"0000000000000006", x"0000000000000005", x"0000000000000004"
    );

begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                round_cnt <= 0;
                busy <= '0';
                done <= '0';
                state_reg <= (others => '0');
            elsif start = '1' and busy = '0' then
                busy <= '1';
                round_cnt <= 0;
                done <= '0';
                state_reg <= state_i;
            elsif busy = '1' then
                -- Apply a dummy transformation per round (replace with real permutation logic)
                state_reg(63 downto 0) <= state_reg(63 downto 0) xor RC(round_cnt);
                round_cnt <= round_cnt + 1;

                if round_cnt = rounds - 1 then
                    busy <= '0';
                    done <= '1';
                end if;
            else
                done <= '0';
            end if;
        end if;
    end process;

    state_o <= state_reg;

end Behavioral;
