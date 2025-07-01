--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

--entity ascon_top is
--    port (
--        clk         : in  std_logic;
--        rst         : in  std_logic;
--        start       : in  std_logic;
--        key         : in  std_logic_vector(127 downto 0);
--        nonce       : in  std_logic_vector(127 downto 0);
--        plaintext   : in  std_logic_vector(127 downto 0);
--        associated_data : in  std_logic_vector(127 downto 0);
--        done        : out std_logic;
--        ciphertext  : out std_logic_vector(127 downto 0);
--        tag         : out std_logic_vector(127 downto 0)
--    );
--end entity;

--architecture Behavioral of ascon_top is

--    -- Declare component entities
--    component ascon128_init
--        port (
--            clk     : in  std_logic;
--            rst     : in  std_logic;
--            start   : in  std_logic;
--            key     : in  std_logic_vector(127 downto 0);
--            nonce   : in  std_logic_vector(127 downto 0);
--            state_o : out std_logic_vector(319 downto 0);
--            done    : out std_logic
--        );
--    end component;
    
--    component ascon128_process_ad
--        port (
--            clk      : in  std_logic;
--            rst      : in  std_logic;
--            start    : in  std_logic;
--            ad_block : in  std_logic_vector(127 downto 0);
--            state_i  : in  std_logic_vector(319 downto 0);
--            state_o  : out std_logic_vector(319 downto 0);
--            done     : out std_logic
--        );
--    end component;


--    component ascon128_plaintext
--        port (
--            clk     : in  std_logic;
--            rst     : in  std_logic;
--            start   : in  std_logic;
--            state_i : in  std_logic_vector(319 downto 0);
--            plaintext : in std_logic_vector(127 downto 0);
--            state_o : out std_logic_vector(319 downto 0);
--            ciphertext : out std_logic_vector(127 downto 0);
--            done    : out std_logic
--        );
--    end component;

--    component ascon128_final
--        port (
--            clk     : in  std_logic;
--            rst     : in  std_logic;
--            start   : in  std_logic;
--            state_i : in  std_logic_vector(319 downto 0);
--            tag     : out std_logic_vector(127 downto 0);
--            done    : out std_logic
--        );
--    end component;

--    -- Signals
--    signal state_0, state_1, state_2 : std_logic_vector(319 downto 0);
--    signal done_init, done_encrypt, done_final : std_logic;
--    signal start_encrypt, start_final : std_logic := '0';
    
--    signal state_ad      : std_logic_vector(319 downto 0);
--    signal done_ad       : std_logic;
--    signal start_ad      : std_logic := '0';
    

--begin

--    -- Instance 1: Initialization
--    u_init: ascon128_init
--        port map (
--            clk     => clk,
--            rst     => rst,
--            start   => start,
--            key     => key,
--            nonce   => nonce,
--            state_o => state_0,
--            done    => done_init
--        );
    
--    -- AD
--    u_ad: ascon128_process_ad
--        port map (
--            clk      => clk,
--            rst      => rst,
--            start    => start_ad,
--            ad_block => associated_data,
--            state_i  => state_0,
--            state_o  => state_ad,
--            done     => done_ad
--        );

--    -- Instance 3: Plaintext encryption
--    u_encrypt: ascon128_plaintext
--        port map (
--            clk        => clk,
--            rst        => rst,
--            start      => start_encrypt,
--            state_i    => state_ad,
--            plaintext  => plaintext,
--            state_o    => state_1,
--            ciphertext => ciphertext,
--            done       => done_encrypt
--        );

--    -- Instance 4: Finalization
--    u_final: ascon128_final
--        port map (
--            clk     => clk,
--            rst     => rst,
--            start   => start_final,
--            state_i => state_1,
--            tag     => tag,
--            done    => done_final
--        );

--    -- Control process
--    process(clk)
--    begin
--        if rising_edge(clk) then
--            if rst = '1' then
--                start_ad      <= '0';
--                start_encrypt <= '0';
--                start_final   <= '0';
--                done          <= '0';
--            else
--                if done_init = '1' then
--                    start_ad <= '1';
--                end if;
--                if done_ad = '1' then
--                    start_ad <= '0';
--                    start_encrypt <= '1';
--                end if;
--                if done_encrypt = '1' then
--                    start_encrypt <= '0';
--                    start_final <= '1';
--                end if;
--                if done_final = '1' then
--                    start_final <= '0';
--                    done <= '1';
--                end if;
--            end if;
--        end if;
--    end process;

--end Behavioral;





library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;

entity ascon_top is
    port (
        clk   : in  std_logic;
        rst   : in  std_logic;
        start : in  std_logic;
        done  : out std_logic
    );
end entity;

architecture Behavioral of ascon_top is

    component ascon128_init
        port (
            clk     : in  std_logic;
            rst     : in  std_logic;
            start   : in  std_logic;
            key     : in  std_logic_vector(127 downto 0);
            nonce   : in  std_logic_vector(127 downto 0);
            state_o : out std_logic_vector(319 downto 0);
            done    : out std_logic
        );
    end component;

    component ascon128_process_ad
        port (
            clk      : in  std_logic;
            rst      : in  std_logic;
            start    : in  std_logic;
            ad_block : in  std_logic_vector(127 downto 0);
            state_i  : in  std_logic_vector(319 downto 0);
            state_o  : out std_logic_vector(319 downto 0);
            done     : out std_logic
        );
    end component;

    component ascon128_plaintext
        port (
            clk        : in  std_logic;
            rst        : in  std_logic;
            start      : in  std_logic;
            state_i    : in  std_logic_vector(319 downto 0);
            plaintext  : in  std_logic_vector(127 downto 0);
            state_o    : out std_logic_vector(319 downto 0);
            ciphertext : out std_logic_vector(127 downto 0);
            done       : out std_logic
        );
    end component;

    component ascon128_final
        port (
            clk     : in  std_logic;
            rst     : in  std_logic;
            start   : in  std_logic;
            state_i : in  std_logic_vector(319 downto 0);
            tag     : out std_logic_vector(127 downto 0);
            done    : out std_logic
        );
    end component;

    signal key, nonce, plaintext, ciphertext, tag : std_logic_vector(127 downto 0);
    signal ad_block : std_logic_vector(127 downto 0);

    signal state_0, state_ad, state_1 : std_logic_vector(319 downto 0);
    signal done_init, done_ad, done_encrypt, done_final : std_logic;
    signal start_ad, start_encrypt, start_final : std_logic := '0';

begin
    -- Gán d? li?u test c? ð?nh bên trong
    key       <= x"000102030405060708090A0B0C0D0E0F";
    nonce     <= x"BBAA99887766554433221100FFEEDDCC";
    plaintext <= x"112233445566778899AABBCCDDEEFF00";
    ad_block  <= x"AABBCCDDEEFF00112233445566778899";

    -- Init
    u_init: ascon128_init
        port map (
            clk     => clk,
            rst     => rst,
            start   => start,
            key     => key,
            nonce   => nonce,
            state_o => state_0,
            done    => done_init
        );

    u_ad: ascon128_process_ad
        port map (
            clk      => clk,
            rst      => rst,
            start    => start_ad,
            ad_block => ad_block,
            state_i  => state_0,
            state_o  => state_ad,
            done     => done_ad
        );

    u_encrypt: ascon128_plaintext
        port map (
            clk        => clk,
            rst        => rst,
            start      => start_encrypt,
            state_i    => state_ad,
            plaintext  => plaintext,
            state_o    => state_1,
            ciphertext => ciphertext,
            done       => done_encrypt
        );

    u_final: ascon128_final
        port map (
            clk     => clk,
            rst     => rst,
            start   => start_final,
            state_i => state_1,
            tag     => tag,
            done    => done_final
        );

    -- FSM
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                start_ad      <= '0';
                start_encrypt <= '0';
                start_final   <= '0';
                done          <= '0';
            else
                if done_init = '1' then
                    start_ad <= '1';
                end if;
                if done_ad = '1' then
                    start_ad <= '0';
                    start_encrypt <= '1';
                end if;
                if done_encrypt = '1' then
                    start_encrypt <= '0';
                    start_final <= '1';
                end if;
                if done_final = '1' then
                    start_final <= '0';
                    done <= '1';
                
                    -- synthesis translate_off
                    report "ASCON Encryption Done!" severity note;
                    report "Ciphertext: " & to_hstring(to_bitvector(ciphertext));
                    report "Tag       : " & to_hstring(to_bitvector(tag));
                    -- synthesis translate_on
                end if;

            end if;
        end if;
    end process;

end Behavioral;
