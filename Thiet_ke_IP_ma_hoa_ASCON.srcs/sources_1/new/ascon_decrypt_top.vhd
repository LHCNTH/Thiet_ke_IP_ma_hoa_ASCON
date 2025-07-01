--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

--entity ascon_decrypt_top is
--    port (
--        clk           : in  std_logic;
--        rst           : in  std_logic;
--        start         : in  std_logic;
--        key           : in  std_logic_vector(127 downto 0);
--        nonce         : in  std_logic_vector(127 downto 0);
--        associated_data : in std_logic_vector(127 downto 0);
--        ciphertext    : in  std_logic_vector(127 downto 0);
--        received_tag  : in  std_logic_vector(127 downto 0);
--        done          : out std_logic;
--        plaintext_out : out std_logic_vector(127 downto 0);
--        valid         : out std_logic
--    );
--end entity;

--architecture Behavioral of ascon_decrypt_top is

--    -- Component declarations
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

--    component ascon128_decrypt
--        port (
--            clk         : in  std_logic;
--            rst         : in  std_logic;
--            start       : in  std_logic;
--            state_i     : in  std_logic_vector(319 downto 0);
--            ciphertext  : in  std_logic_vector(127 downto 0);
--            state_o     : out std_logic_vector(319 downto 0);
--            plaintext   : out std_logic_vector(127 downto 0);
--            done        : out std_logic
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
--    signal state_0, state_ad, state_1 : std_logic_vector(319 downto 0);
--    signal done_init, done_ad, done_decrypt, done_final : std_logic;
--    signal start_ad, start_decrypt, start_final : std_logic := '0';
--    signal tag_generated : std_logic_vector(127 downto 0);

--begin

--    -- Initialization
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

--    -- Process Associated Data
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

--    -- Decrypt
--    u_decrypt: ascon128_decrypt
--        port map (
--            clk         => clk,
--            rst         => rst,
--            start       => start_decrypt,
--            state_i     => state_ad,
--            ciphertext  => ciphertext,
--            state_o     => state_1,
--            plaintext   => plaintext_out,
--            done        => done_decrypt
--        );

--    -- Finalization
--    u_final: ascon128_final
--        port map (
--            clk     => clk,
--            rst     => rst,
--            start   => start_final,
--            state_i => state_1,
--            tag     => tag_generated,
--            done    => done_final
--        );

--    -- Control FSM
--    process(clk)
--    begin
--        if rising_edge(clk) then
--            if rst = '1' then
--                start_ad <= '0';
--                start_decrypt <= '0';
--                start_final <= '0';
--                done <= '0';
--                valid <= '0';
--            else
--                if done_init = '1' then
--                    start_ad <= '1';
--                end if;
--                if done_ad = '1' then
--                    start_ad <= '0';
--                    start_decrypt <= '1';
--                end if;
--                if done_decrypt = '1' then
--                    start_decrypt <= '0';
--                    start_final <= '1';
--                end if;
--                if done_final = '1' then
--                    start_final <= '0';
--                    done <= '1';
--                    if tag_generated = received_tag then
--                        valid <= '1';
--                    else
--                        valid <= '0';
--                    end if;
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

entity ascon_decrypt_top is
    port (
        clk   : in  std_logic;
        rst   : in  std_logic;
        start : in  std_logic;
        done  : out std_logic
    );
end entity;

architecture Behavioral of ascon_decrypt_top is

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

    component ascon128_decrypt
        port (
            clk        : in  std_logic;
            rst        : in  std_logic;
            start      : in  std_logic;
            state_i    : in  std_logic_vector(319 downto 0);
            ciphertext : in  std_logic_vector(127 downto 0);
            state_o    : out std_logic_vector(319 downto 0);
            plaintext  : out std_logic_vector(127 downto 0);
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

    signal key, nonce, ad_block, ciphertext, plaintext, tag_generated, received_tag : std_logic_vector(127 downto 0);
    signal state_0, state_ad, state_1 : std_logic_vector(319 downto 0);
    signal done_init, done_ad, done_decrypt, done_final : std_logic;
    signal start_ad, start_decrypt, start_final : std_logic := '0';
    signal valid : std_logic := '0';

begin
    -- D? li?u test c? ð?nh
    key          <= x"000102030405060708090A0B0C0D0E0F";
    nonce        <= x"BBAA99887766554433221100FFEEDDCC";
    ad_block     <= x"AABBCCDDEEFF00112233445566778899";
    ciphertext   <= x"00326412C8FA24DA80B2E492487AA45A";  
    received_tag <= x"BBAB9B8B736353433B2B1B0BF3E3D3C3";  

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

    u_decrypt: ascon128_decrypt
        port map (
            clk        => clk,
            rst        => rst,
            start      => start_decrypt,
            state_i    => state_ad,
            ciphertext => ciphertext,
            state_o    => state_1,
            plaintext  => plaintext,
            done       => done_decrypt
        );

    u_final: ascon128_final
        port map (
            clk     => clk,
            rst     => rst,
            start   => start_final,
            state_i => state_1,
            tag     => tag_generated,
            done    => done_final
        );

    -- FSM
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                start_ad      <= '0';
                start_decrypt <= '0';
                start_final   <= '0';
                done          <= '0';
                valid         <= '0';
            else
                if done_init = '1' then
                    start_ad <= '1';
                end if;
                if done_ad = '1' then
                    start_ad <= '0';
                    start_decrypt <= '1';
                end if;
                if done_decrypt = '1' then
                    start_decrypt <= '0';
                    start_final <= '1';
                end if;
                if done_final = '1' then
                    start_final <= '0';
                    done <= '1';

                    if tag_generated = received_tag then
                        valid <= '1';
                    else
                        valid <= '0';
                    end if;

                    -- synthesis translate_off
                    report "ASCON Decryption Done!" severity note;
                    report "Plaintext: " & to_hstring(to_bitvector(plaintext));
                    report "Tag Match : " & std_logic'image(valid);
                    -- synthesis translate_on
                end if;
            end if;
        end if;
    end process;

end Behavioral;
