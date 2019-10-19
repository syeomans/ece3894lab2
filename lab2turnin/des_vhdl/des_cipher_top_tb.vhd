-----------------------------------------------------------------------------------------------------------------------
-- Author:          Yu-Cheng Chen, ychen414@gatech.edu
--
-- Create Date:     16:43:30 09/02/2019
-- Module Name:     des_cipher_top_tb.vhd
-- Project Name:    des_cipher
-- Description:
--
--      Testbench for the des_cipher_top engine.
--      This is the testbench for the des_cipher_top engine. It exercises all the input control signals and error generation,
--      and tests the des_cipher_top engine.
--
-- Copyright: Georgia Institute of Technology 2019
--
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
--
--  Project structure:
--
--  |- des_cipher_top.vhd
--    |- des_top.vhd
--      |- block_top.vhd
--        |- add_key.vhd
--        |
--        |- add_left.vhd
--        |
--        |- e_expansion_function.vhd
--        |
--        |- p_box.vhd
--        |
--        |- s_box.vhd
--            |- s1_box.vhd
--            |- s2_box.vhd
--            |- s3_box.vhd
--            |- s4_box.vhd
--            |- s5_box.vhd
--            |- s6_box.vhd
--            |- s7_box.vhd
--            |- s8_box.vhd
--    |- key_schedule.vhd
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity des_cipher_top_tb is
    Generic (
        CLK_PERIOD : time := 10 ns                     -- clock period (default 100MHz)
    );
end des_cipher_top_tb;

architecture behavior of des_cipher_top_tb is

    --=============================================================================================
    -- Constants
    --=============================================================================================
    -- clock period
    constant CLOCK_PERIOD : time := CLK_PERIOD;          -- clock

    --=============================================================================================
    -- Signals
    --=============================================================================================
    --- clock and reset signals ---
    signal clock            : std_logic := '1';                 -- 100MHz clock
    signal reset            : std_logic := '1';                 -- reset active high
    --- input data ---
    signal key_in           : std_logic_vector (0 to 63);   -- key input
    signal data_in          : std_logic_vector (0 to 63);   -- data input
    --- control signals ---
    signal funct_select     : std_logic;                        -- function select: '1' = encryption, '0' = decryption
    signal lddata           : std_logic;                        -- data strobe (active high)
    signal core_busy        : std_logic;
    signal des_out_rdy      : std_logic;
    --- output data ---
    signal data_out         : std_logic_vector (0 to 63);   -- data output

begin

    --=============================================================================================
    -- INSTANTIATION FOR THE DEVICE UNDER TEST
    --=============================================================================================
	Inst_des_cipher_top_dut: entity work.des_cipher_top
        port map(
            --
            -- Core Interface
            --
            key_in            => key_in,            -- input for key

            function_select   => funct_select,      -- function	select: '1' = encryption, '0' = decryption

            data_in           => data_in,           -- input for data

            data_out          => data_out,          -- output for data

            lddata            => lddata,            -- data strobe (active high)
            core_busy         => core_busy,         -- active high when encrypting/decryption data
            des_out_rdy       => des_out_rdy,       -- active high when encryption/decryption of data is done

            reset             => reset,             -- active high
            clock             => clock              -- master clock

        );

    --=============================================================================================
    -- CLOCK GENERATION
    --=============================================================================================
    clock_proc: process is
    begin
        loop
            clock <= not clock;
            wait for CLOCK_PERIOD / 2;
        end loop;
    end process clock_proc;
    --=============================================================================================
    -- TEST BENCH STIMULI
    --=============================================================================================
    -- ONLY FIRST TRIPLE ENCRYPTION AND TRIPLE DECRYPTION ARE COMMENTED.
    -- The rest of the test cases are completed the same way, so the comments would be the same
    tb1 : process is
    begin
        reset <= '1';
        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
    -- Used key 1 with data in to complete first round of triple des encryption
        key_in            <= X"626c697a7a617264";
        funct_select      <= '1';
        data_in           <= X"6163746976697479";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"6d9119c669310aec" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
	-- Used key 2 on dataout1 from first round to get second round output of triple des encryption
        key_in            <= X"736b69706a61636b";
        funct_select      <= '1';
        data_in           <= X"6d9119c669310aec";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"6ce9f7362ef6450a" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
	-- Used key 3 on dataout2 from second round to get final output of triple des encryption
        key_in            <= X"6a756d706f666673";
        funct_select      <= '1';
        data_in           <= X"6ce9f7362ef6450a";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"1ea1789cd57b3af8" report "test #1 failed" severity error;

        -------------------------------------------------------------------------------------------
        wait for CLOCK_PERIOD*5;
        reset <= '1';
        wait for CLOCK_PERIOD;
        reset <= '0';
        -----------------------------
	-- Used key 3 on output from final triple des encryption to get round one decryption
        key_in            <= X"6a756d706f666673";
        funct_select      <= '0';
        data_in           <= X"1ea1789cd57b3af8";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"6ce9f7362ef6450a" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
	-- Used key 2 on output from first round of decryption to get second round of triple des decryption
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"736b69706a61636b";
        funct_select      <= '0';
        data_in           <= X"6ce9f7362ef6450a";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"6d9119c669310aec" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
	-- Used key1 on output from second round of decryption to get third and final round or triple des decryption
		-- Note that the original input data_in matches the ciphertext decryption shown below as data_out
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"626c697a7a617264";
        funct_select      <= '0';
        data_in           <= X"6d9119c669310aec";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"6163746976697479" report "test #2 failed" severity error;

        -------------------------------------------------------------------------------------------
        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"626c697a7a617264";
        funct_select      <= '1';
        data_in           <= X"6a617a7a69657374";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"eeea69156ff89f02" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"736b69706a61636b";
        funct_select      <= '1';
        data_in           <= X"eeea69156ff89f02";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"518723a4a7b86cee" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6a756d706f666673";
        funct_select      <= '1';
        data_in           <= X"518723a4a7b86cee";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"a1a95b7cde509981" report "test #1 failed" severity error;

        -------------------------------------------------------------------------------------------
        wait for CLOCK_PERIOD*5;
        reset <= '1';
        wait for CLOCK_PERIOD;
        reset <= '0';
        -----------------------------
        key_in            <= X"6a756d706f666673";
        funct_select      <= '0';
        data_in           <= X"a1a95b7cde509981";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"518723a4a7b86cee" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"736b69706a61636b";
        funct_select      <= '0';
        data_in           <= X"518723a4a7b86cee";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"eeea69156ff89f02" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"626c697a7a617264";
        funct_select      <= '0';
        data_in           <= X"eeea69156ff89f02";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"6a617a7a69657374" report "test #2 failed" severity error;

        -------------------------------------------------------------------------------------------
        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"626c697a7a617264";
        funct_select      <= '1';
        data_in           <= X"62757a7a776f7264";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"9c137625bdaf9e2a" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"736b69706a61636b";
        funct_select      <= '1';
        data_in           <= X"9c137625bdaf9e2a";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"b91c0fd6ac8b7a74" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6a756d706f666673";
        funct_select      <= '1';
        data_in           <= X"b91c0fd6ac8b7a74";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"f11774f67e1b8b97" report "test #1 failed" severity error;

        -------------------------------------------------------------------------------------------
        wait for CLOCK_PERIOD*5;
        reset <= '1';
        wait for CLOCK_PERIOD;
        reset <= '0';
        -----------------------------
        key_in            <= X"6a756d706f666673";
        funct_select      <= '0';
        data_in           <= X"f11774f67e1b8b97";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"b91c0fd6ac8b7a74" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"736b69706a61636b";
        funct_select      <= '0';
        data_in           <= X"b91c0fd6ac8b7a74";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"9c137625bdaf9e2a" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"626c697a7a617264";
        funct_select      <= '0';
        data_in           <= X"9c137625bdaf9e2a";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"62757a7a776f7264" report "test #2 failed" severity error;

        -------------------------------------------------------------------------------------------
        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"626c697a7a617264";
        funct_select      <= '1';
        data_in           <= X"537461726275636b";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"2ea7641b231e2879" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"736b69706a61636b";
        funct_select      <= '1';
        data_in           <= X"2ea7641b231e2879";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"212e398775687b48" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6a756d706f666673";
        funct_select      <= '1';
        data_in           <= X"212e398775687b48";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"e154bb59340b14ee" report "test #1 failed" severity error;

        -------------------------------------------------------------------------------------------
        wait for CLOCK_PERIOD*5;
        reset <= '1';
        wait for CLOCK_PERIOD;
        reset <= '0';
        -----------------------------
        key_in            <= X"6a756d706f666673";
        funct_select      <= '0';
        data_in           <= X"e154bb59340b14ee";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"212e398775687b48" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"736b69706a61636b";
        funct_select      <= '0';
        data_in           <= X"212e398775687b48";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"2ea7641b231e2879" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"626c697a7a617264";
        funct_select      <= '0';
        data_in           <= X"2ea7641b231e2879";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"537461726275636b" report "test #2 failed" severity error;

        -------------------------------------------------------------------------------------------
        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"626c697a7a617264";
        funct_select      <= '1';
        data_in           <= X"666c61706a61636b";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"fe5999073209146a" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"736b69706a61636b";
        funct_select      <= '1';
        data_in           <= X"fe5999073209146a";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"0798386ea5eb6ec5" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6a756d706f666673";
        funct_select      <= '1';
        data_in           <= X"0798386ea5eb6ec5";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"aa459237f19d0390" report "test #1 failed" severity error;

        -------------------------------------------------------------------------------------------
        wait for CLOCK_PERIOD*5;
        reset <= '1';
        wait for CLOCK_PERIOD;
        reset <= '0';
        -----------------------------
        key_in            <= X"6a756d706f666673";
        funct_select      <= '0';
        data_in           <= X"aa459237f19d0390";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"0798386ea5eb6ec5" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"736b69706a61636b";
        funct_select      <= '0';
        data_in           <= X"0798386ea5eb6ec5";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"fe5999073209146a" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"626c697a7a617264";
        funct_select      <= '0';
        data_in           <= X"fe5999073209146a";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"666c61706a61636b" report "test #2 failed" severity error;

        -------------------------------------------------------------------------------------------
        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"626c697a7a617264";
        funct_select      <= '1';
        data_in           <= X"6b69636b6261636b";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"d2bb0344aa0d2934" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"736b69706a61636b";
        funct_select      <= '1';
        data_in           <= X"d2bb0344aa0d2934";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"e10c991abfd129e6" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6a756d706f666673";
        funct_select      <= '1';
        data_in           <= X"e10c991abfd129e6";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"59ccbc0d61ff3d7c" report "test #1 failed" severity error;

        -------------------------------------------------------------------------------------------
        wait for CLOCK_PERIOD*5;
        reset <= '1';
        wait for CLOCK_PERIOD;
        reset <= '0';
        -----------------------------
        key_in            <= X"6a756d706f666673";
        funct_select      <= '0';
        data_in           <= X"59ccbc0d61ff3d7c";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"e10c991abfd129e6" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"736b69706a61636b";
        funct_select      <= '0';
        data_in           <= X"e10c991abfd129e6";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"d2bb0344aa0d2934" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"626c697a7a617264";
        funct_select      <= '0';
        data_in           <= X"d2bb0344aa0d2934";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"6b69636b6261636b" report "test #2 failed" severity error;

        -------------------------------------------------------------------------------------------
        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"626c697a7a617264";
        funct_select      <= '1';
        data_in           <= X"6261636b7061636b";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"ca16f578a083ad54" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"736b69706a61636b";
        funct_select      <= '1';
        data_in           <= X"ca16f578a083ad54";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"52a2b71be0104ffb" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6a756d706f666673";
        funct_select      <= '1';
        data_in           <= X"52a2b71be0104ffb";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"ece0643312c5aeb7" report "test #1 failed" severity error;

        -------------------------------------------------------------------------------------------
        wait for CLOCK_PERIOD*5;
        reset <= '1';
        wait for CLOCK_PERIOD;
        reset <= '0';
        -----------------------------
        key_in            <= X"6a756d706f666673";
        funct_select      <= '0';
        data_in           <= X"ece0643312c5aeb7";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"52a2b71be0104ffb" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"736b69706a61636b";
        funct_select      <= '0';
        data_in           <= X"52a2b71be0104ffb";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"ca16f578a083ad54" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"626c697a7a617264";
        funct_select      <= '0';
        data_in           <= X"ca16f578a083ad54";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"6261636b7061636b" report "test #2 failed" severity error;

        -------------------------------------------------------------------------------------------
        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"626c697a7a617264";
        funct_select      <= '1';
        data_in           <= X"70697a7a65726961";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"19164857b1ed1eed" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"736b69706a61636b";
        funct_select      <= '1';
        data_in           <= X"19164857b1ed1eed";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"eb7f29dea8894356" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6a756d706f666673";
        funct_select      <= '1';
        data_in           <= X"eb7f29dea8894356";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"03e0a63e0346a485" report "test #1 failed" severity error;

        -------------------------------------------------------------------------------------------
        wait for CLOCK_PERIOD*5;
        reset <= '1';
        wait for CLOCK_PERIOD;
        reset <= '0';
        -----------------------------
        key_in            <= X"6a756d706f666673";
        funct_select      <= '0';
        data_in           <= X"03e0a63e0346a485";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"eb7f29dea8894356" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"736b69706a61636b";
        funct_select      <= '0';
        data_in           <= X"eb7f29dea8894356";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"19164857b1ed1eed" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"626c697a7a617264";
        funct_select      <= '0';
        data_in           <= X"19164857b1ed1eed";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"70697a7a65726961" report "test #2 failed" severity error;

        -------------------------------------------------------------------------------------------
        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"626c697a7a617264";
        funct_select      <= '1';
        data_in           <= X"6a69756a69747375";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"261259ae6709b30b" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"736b69706a61636b";
        funct_select      <= '1';
        data_in           <= X"261259ae6709b30b";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"9d28f46ef665d4c3" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6a756d706f666673";
        funct_select      <= '1';
        data_in           <= X"9d28f46ef665d4c3";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"f137700522b89653" report "test #1 failed" severity error;

        -------------------------------------------------------------------------------------------
        wait for CLOCK_PERIOD*5;
        reset <= '1';
        wait for CLOCK_PERIOD;
        reset <= '0';
        -----------------------------
        key_in            <= X"6a756d706f666673";
        funct_select      <= '0';
        data_in           <= X"f137700522b89653";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"9d28f46ef665d4c3" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"736b69706a61636b";
        funct_select      <= '0';
        data_in           <= X"9d28f46ef665d4c3";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"261259ae6709b30b" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"626c697a7a617264";
        funct_select      <= '0';
        data_in           <= X"261259ae6709b30b";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"6a69756a69747375" report "test #2 failed" severity error;

        -------------------------------------------------------------------------------------------
        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"626c697a7a617264";
        funct_select      <= '1';
        data_in           <= X"717569786f746963";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"267bb4e213e9cb6c" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"736b69706a61636b";
        funct_select      <= '1';
        data_in           <= X"267bb4e213e9cb6c";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"f3e8da0a0f30847d" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6a756d706f666673";
        funct_select      <= '1';
        data_in           <= X"f3e8da0a0f30847d";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"0bc9bc3f241d2eeb" report "test #1 failed" severity error;

        -------------------------------------------------------------------------------------------
        wait for CLOCK_PERIOD*5;
        reset <= '1';
        wait for CLOCK_PERIOD;
        reset <= '0';
        -----------------------------
        key_in            <= X"6a756d706f666673";
        funct_select      <= '0';
        data_in           <= X"0bc9bc3f241d2eeb";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"f3e8da0a0f30847d" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"736b69706a61636b";
        funct_select      <= '0';
        data_in           <= X"f3e8da0a0f30847d";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"267bb4e213e9cb6c" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"626c697a7a617264";
        funct_select      <= '0';
        data_in           <= X"267bb4e213e9cb6c";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"717569786f746963" report "test #2 failed" severity error;

        -------------------------------------------------------------------------------------------
        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6d6178696d697a65";
        funct_select      <= '1';
        data_in           <= X"6163746976697479";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"3a830584d27ad91d" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"656e67696e656572";
        funct_select      <= '1';
        data_in           <= X"3a830584d27ad91d";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"36ba84046c083718" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6c616e7465726e73";
        funct_select      <= '1';
        data_in           <= X"36ba84046c083718";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"0a8c6904306aee28" report "test #1 failed" severity error;

        -------------------------------------------------------------------------------------------
        wait for CLOCK_PERIOD*5;
        reset <= '1';
        wait for CLOCK_PERIOD;
        reset <= '0';
        -----------------------------
        key_in            <= X"6c616e7465726e73";
        funct_select      <= '0';
        data_in           <= X"0a8c6904306aee28";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"36ba84046c083718" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"656e67696e656572";
        funct_select      <= '0';
        data_in           <= X"36ba84046c083718";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"3a830584d27ad91d" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"6d6178696d697a65";
        funct_select      <= '0';
        data_in           <= X"3a830584d27ad91d";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"6163746976697479" report "test #2 failed" severity error;

        -------------------------------------------------------------------------------------------
        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6d6178696d697a65";
        funct_select      <= '1';
        data_in           <= X"6a617a7a69657374";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"bda4bad4688b7560" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"656e67696e656572";
        funct_select      <= '1';
        data_in           <= X"bda4bad4688b7560";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"9f03d527883f18aa" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6c616e7465726e73";
        funct_select      <= '1';
        data_in           <= X"9f03d527883f18aa";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"0dad8d15473c0225" report "test #1 failed" severity error;

        -------------------------------------------------------------------------------------------
        wait for CLOCK_PERIOD*5;
        reset <= '1';
        wait for CLOCK_PERIOD;
        reset <= '0';
        -----------------------------
        key_in            <= X"6c616e7465726e73";
        funct_select      <= '0';
        data_in           <= X"0dad8d15473c0225";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"9f03d527883f18aa" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"656e67696e656572";
        funct_select      <= '0';
        data_in           <= X"9f03d527883f18aa";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"bda4bad4688b7560" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"6d6178696d697a65";
        funct_select      <= '0';
        data_in           <= X"bda4bad4688b7560";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"6a617a7a69657374" report "test #2 failed" severity error;

        -------------------------------------------------------------------------------------------
        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6d6178696d697a65";
        funct_select      <= '1';
        data_in           <= X"62757a7a776f7264";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"f095bb0f072faec2" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"656e67696e656572";
        funct_select      <= '1';
        data_in           <= X"f095bb0f072faec2";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"8c1447dbe402c120" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6c616e7465726e73";
        funct_select      <= '1';
        data_in           <= X"8c1447dbe402c120";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"d6b3d6c4b4702741" report "test #1 failed" severity error;

        -------------------------------------------------------------------------------------------
        wait for CLOCK_PERIOD*5;
        reset <= '1';
        wait for CLOCK_PERIOD;
        reset <= '0';
        -----------------------------
        key_in            <= X"6c616e7465726e73";
        funct_select      <= '0';
        data_in           <= X"d6b3d6c4b4702741";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"8c1447dbe402c120" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"656e67696e656572";
        funct_select      <= '0';
        data_in           <= X"8c1447dbe402c120";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"f095bb0f072faec2" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"6d6178696d697a65";
        funct_select      <= '0';
        data_in           <= X"f095bb0f072faec2";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"62757a7a776f7264" report "test #2 failed" severity error;

        -------------------------------------------------------------------------------------------
        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6d6178696d697a65";
        funct_select      <= '1';
        data_in           <= X"537461726275636b";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"ee92bbaac381752e" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"656e67696e656572";
        funct_select      <= '1';
        data_in           <= X"ee92bbaac381752e";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"bbb07aa5a5888be3" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6c616e7465726e73";
        funct_select      <= '1';
        data_in           <= X"bbb07aa5a5888be3";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"7f90ff2088feeeb2" report "test #1 failed" severity error;

        -------------------------------------------------------------------------------------------
        wait for CLOCK_PERIOD*5;
        reset <= '1';
        wait for CLOCK_PERIOD;
        reset <= '0';
        -----------------------------
        key_in            <= X"6c616e7465726e73";
        funct_select      <= '0';
        data_in           <= X"7f90ff2088feeeb2";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"bbb07aa5a5888be3" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"656e67696e656572";
        funct_select      <= '0';
        data_in           <= X"bbb07aa5a5888be3";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"ee92bbaac381752e" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"6d6178696d697a65";
        funct_select      <= '0';
        data_in           <= X"ee92bbaac381752e";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"537461726275636b" report "test #2 failed" severity error;

        -------------------------------------------------------------------------------------------
        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6d6178696d697a65";
        funct_select      <= '1';
        data_in           <= X"666c61706a61636b";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"2ca582e5976851e5" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"656e67696e656572";
        funct_select      <= '1';
        data_in           <= X"2ca582e5976851e5";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"5d361dc51bc01031" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6c616e7465726e73";
        funct_select      <= '1';
        data_in           <= X"5d361dc51bc01031";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"03153c080ccccc0e" report "test #1 failed" severity error;

        -------------------------------------------------------------------------------------------
        wait for CLOCK_PERIOD*5;
        reset <= '1';
        wait for CLOCK_PERIOD;
        reset <= '0';
        -----------------------------
        key_in            <= X"6c616e7465726e73";
        funct_select      <= '0';
        data_in           <= X"03153c080ccccc0e";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"5d361dc51bc01031" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"656e67696e656572";
        funct_select      <= '0';
        data_in           <= X"5d361dc51bc01031";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"2ca582e5976851e5" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"6d6178696d697a65";
        funct_select      <= '0';
        data_in           <= X"2ca582e5976851e5";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"666c61706a61636b" report "test #2 failed" severity error;

        -------------------------------------------------------------------------------------------
        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6d6178696d697a65";
        funct_select      <= '1';
        data_in           <= X"6b69636b6261636b";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"aa9160e33bba4153" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"656e67696e656572";
        funct_select      <= '1';
        data_in           <= X"aa9160e33bba4153";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"dce51b1da8021ee4" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6c616e7465726e73";
        funct_select      <= '1';
        data_in           <= X"dce51b1da8021ee4";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"878e5df291fd800e" report "test #1 failed" severity error;

        -------------------------------------------------------------------------------------------
        wait for CLOCK_PERIOD*5;
        reset <= '1';
        wait for CLOCK_PERIOD;
        reset <= '0';
        -----------------------------
        key_in            <= X"6c616e7465726e73";
        funct_select      <= '0';
        data_in           <= X"878e5df291fd800e";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"dce51b1da8021ee4" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"656e67696e656572";
        funct_select      <= '0';
        data_in           <= X"dce51b1da8021ee4";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"aa9160e33bba4153" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"6d6178696d697a65";
        funct_select      <= '0';
        data_in           <= X"aa9160e33bba4153";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"6b69636b6261636b" report "test #2 failed" severity error;

        -------------------------------------------------------------------------------------------
        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6d6178696d697a65";
        funct_select      <= '1';
        data_in           <= X"6261636b7061636b";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"bfde88762be7ac83" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"656e67696e656572";
        funct_select      <= '1';
        data_in           <= X"bfde88762be7ac83";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"d53bc72abb83a64a" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6c616e7465726e73";
        funct_select      <= '1';
        data_in           <= X"d53bc72abb83a64a";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"4bea733d82ec7e13" report "test #1 failed" severity error;

        -------------------------------------------------------------------------------------------
        wait for CLOCK_PERIOD*5;
        reset <= '1';
        wait for CLOCK_PERIOD;
        reset <= '0';
        -----------------------------
        key_in            <= X"6c616e7465726e73";
        funct_select      <= '0';
        data_in           <= X"4bea733d82ec7e13";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"d53bc72abb83a64a" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"656e67696e656572";
        funct_select      <= '0';
        data_in           <= X"d53bc72abb83a64a";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"bfde88762be7ac83" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"6d6178696d697a65";
        funct_select      <= '0';
        data_in           <= X"bfde88762be7ac83";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"6261636b7061636b" report "test #2 failed" severity error;

        -------------------------------------------------------------------------------------------
        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6d6178696d697a65";
        funct_select      <= '1';
        data_in           <= X"70697a7a65726961";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"b8d57097775af2f2" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"656e67696e656572";
        funct_select      <= '1';
        data_in           <= X"b8d57097775af2f2";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"9d14879e34f6cde5" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6c616e7465726e73";
        funct_select      <= '1';
        data_in           <= X"9d14879e34f6cde5";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"92839cd601d4c629" report "test #1 failed" severity error;

        -------------------------------------------------------------------------------------------
        wait for CLOCK_PERIOD*5;
        reset <= '1';
        wait for CLOCK_PERIOD;
        reset <= '0';
        -----------------------------
        key_in            <= X"6c616e7465726e73";
        funct_select      <= '0';
        data_in           <= X"92839cd601d4c629";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"9d14879e34f6cde5" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"656e67696e656572";
        funct_select      <= '0';
        data_in           <= X"9d14879e34f6cde5";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"b8d57097775af2f2" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"6d6178696d697a65";
        funct_select      <= '0';
        data_in           <= X"b8d57097775af2f2";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"70697a7a65726961" report "test #2 failed" severity error;

        -------------------------------------------------------------------------------------------
        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6d6178696d697a65";
        funct_select      <= '1';
        data_in           <= X"6a69756a69747375";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"f0de212985fe3ec7" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"656e67696e656572";
        funct_select      <= '1';
        data_in           <= X"f0de212985fe3ec7";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"7dbe4da77f40fab4" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6c616e7465726e73";
        funct_select      <= '1';
        data_in           <= X"7dbe4da77f40fab4";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"5ac57f69a3020e91" report "test #1 failed" severity error;

        -------------------------------------------------------------------------------------------
        wait for CLOCK_PERIOD*5;
        reset <= '1';
        wait for CLOCK_PERIOD;
        reset <= '0';
        -----------------------------
        key_in            <= X"6c616e7465726e73";
        funct_select      <= '0';
        data_in           <= X"5ac57f69a3020e91";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"7dbe4da77f40fab4" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"656e67696e656572";
        funct_select      <= '0';
        data_in           <= X"7dbe4da77f40fab4";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"f0de212985fe3ec7" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"6d6178696d697a65";
        funct_select      <= '0';
        data_in           <= X"f0de212985fe3ec7";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"6a69756a69747375" report "test #2 failed" severity error;

        -------------------------------------------------------------------------------------------
        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6d6178696d697a65";
        funct_select      <= '1';
        data_in           <= X"717569786f746963";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"0a06cbcaae9cf2e9" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"656e67696e656572";
        funct_select      <= '1';
        data_in           <= X"0a06cbcaae9cf2e9";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"427e69fab18bad6e" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6c616e7465726e73";
        funct_select      <= '1';
        data_in           <= X"427e69fab18bad6e";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"3b986c8966e14845" report "test #1 failed" severity error;

        -------------------------------------------------------------------------------------------
        wait for CLOCK_PERIOD*5;
        reset <= '1';
        wait for CLOCK_PERIOD;
        reset <= '0';
        -----------------------------
        key_in            <= X"6c616e7465726e73";
        funct_select      <= '0';
        data_in           <= X"3b986c8966e14845";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"427e69fab18bad6e" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"656e67696e656572";
        funct_select      <= '0';
        data_in           <= X"427e69fab18bad6e";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"0a06cbcaae9cf2e9" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"6d6178696d697a65";
        funct_select      <= '0';
        data_in           <= X"0a06cbcaae9cf2e9";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"717569786f746963" report "test #2 failed" severity error;

        -------------------------------------------------------------------------------------------
        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6c656e736c657373";
        funct_select      <= '1';
        data_in           <= X"6163746976697479";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"af3c2a31117b7161" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"696c6c7573696f6e";
        funct_select      <= '1';
        data_in           <= X"af3c2a31117b7161";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"e0be86f4d6c4baee" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"696e73756c616e74";
        funct_select      <= '1';
        data_in           <= X"e0be86f4d6c4baee";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"f522711688cc0941" report "test #1 failed" severity error;

        -------------------------------------------------------------------------------------------
        wait for CLOCK_PERIOD*5;
        reset <= '1';
        wait for CLOCK_PERIOD;
        reset <= '0';
        -----------------------------
        key_in            <= X"696e73756c616e74";
        funct_select      <= '0';
        data_in           <= X"f522711688cc0941";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"e0be86f4d6c4baee" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"696c6c7573696f6e";
        funct_select      <= '0';
        data_in           <= X"e0be86f4d6c4baee";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"af3c2a31117b7161" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"6c656e736c657373";
        funct_select      <= '0';
        data_in           <= X"af3c2a31117b7161";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"6163746976697479" report "test #2 failed" severity error;

        -------------------------------------------------------------------------------------------
        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6c656e736c657373";
        funct_select      <= '1';
        data_in           <= X"6a617a7a69657374";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"2e90678ed98c2886" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"696c6c7573696f6e";
        funct_select      <= '1';
        data_in           <= X"2e90678ed98c2886";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"9a77cba242854a3f" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"696e73756c616e74";
        funct_select      <= '1';
        data_in           <= X"9a77cba242854a3f";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"26a5023966309b2c" report "test #1 failed" severity error;

        -------------------------------------------------------------------------------------------
        wait for CLOCK_PERIOD*5;
        reset <= '1';
        wait for CLOCK_PERIOD;
        reset <= '0';
        -----------------------------
        key_in            <= X"696e73756c616e74";
        funct_select      <= '0';
        data_in           <= X"26a5023966309b2c";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"9a77cba242854a3f" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"696c6c7573696f6e";
        funct_select      <= '0';
        data_in           <= X"9a77cba242854a3f";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"2e90678ed98c2886" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"6c656e736c657373";
        funct_select      <= '0';
        data_in           <= X"2e90678ed98c2886";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"6a617a7a69657374" report "test #2 failed" severity error;

        -------------------------------------------------------------------------------------------
        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6c656e736c657373";
        funct_select      <= '1';
        data_in           <= X"62757a7a776f7264";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"127b98ead2003753" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"696c6c7573696f6e";
        funct_select      <= '1';
        data_in           <= X"127b98ead2003753";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"a2d4b0bac40d29d8" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"696e73756c616e74";
        funct_select      <= '1';
        data_in           <= X"a2d4b0bac40d29d8";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"7ab40eb5eb312d0b" report "test #1 failed" severity error;

        -------------------------------------------------------------------------------------------
        wait for CLOCK_PERIOD*5;
        reset <= '1';
        wait for CLOCK_PERIOD;
        reset <= '0';
        -----------------------------
        key_in            <= X"696e73756c616e74";
        funct_select      <= '0';
        data_in           <= X"7ab40eb5eb312d0b";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"a2d4b0bac40d29d8" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"696c6c7573696f6e";
        funct_select      <= '0';
        data_in           <= X"a2d4b0bac40d29d8";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"127b98ead2003753" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"6c656e736c657373";
        funct_select      <= '0';
        data_in           <= X"127b98ead2003753";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"62757a7a776f7264" report "test #2 failed" severity error;

        -------------------------------------------------------------------------------------------
        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6c656e736c657373";
        funct_select      <= '1';
        data_in           <= X"537461726275636b";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"4a1c90fac8f71ec2" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"696c6c7573696f6e";
        funct_select      <= '1';
        data_in           <= X"4a1c90fac8f71ec2";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"59af7933a2b17a95" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"696e73756c616e74";
        funct_select      <= '1';
        data_in           <= X"59af7933a2b17a95";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"85a73454448a82bf" report "test #1 failed" severity error;

        -------------------------------------------------------------------------------------------
        wait for CLOCK_PERIOD*5;
        reset <= '1';
        wait for CLOCK_PERIOD;
        reset <= '0';
        -----------------------------
        key_in            <= X"696e73756c616e74";
        funct_select      <= '0';
        data_in           <= X"85a73454448a82bf";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"59af7933a2b17a95" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"696c6c7573696f6e";
        funct_select      <= '0';
        data_in           <= X"59af7933a2b17a95";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"4a1c90fac8f71ec2" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"6c656e736c657373";
        funct_select      <= '0';
        data_in           <= X"4a1c90fac8f71ec2";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"537461726275636b" report "test #2 failed" severity error;

        -------------------------------------------------------------------------------------------
        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6c656e736c657373";
        funct_select      <= '1';
        data_in           <= X"666c61706a61636b";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"45f1bc43e4bf5050" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"696c6c7573696f6e";
        funct_select      <= '1';
        data_in           <= X"45f1bc43e4bf5050";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"767774cd68556d22" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"696e73756c616e74";
        funct_select      <= '1';
        data_in           <= X"767774cd68556d22";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"c9006e8183568660" report "test #1 failed" severity error;

        -------------------------------------------------------------------------------------------
        wait for CLOCK_PERIOD*5;
        reset <= '1';
        wait for CLOCK_PERIOD;
        reset <= '0';
        -----------------------------
        key_in            <= X"696e73756c616e74";
        funct_select      <= '0';
        data_in           <= X"c9006e8183568660";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"767774cd68556d22" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"696c6c7573696f6e";
        funct_select      <= '0';
        data_in           <= X"767774cd68556d22";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"45f1bc43e4bf5050" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"6c656e736c657373";
        funct_select      <= '0';
        data_in           <= X"45f1bc43e4bf5050";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"666c61706a61636b" report "test #2 failed" severity error;

        -------------------------------------------------------------------------------------------
        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6c656e736c657373";
        funct_select      <= '1';
        data_in           <= X"6b69636b6261636b";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"45e5a8363e99266e" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"696c6c7573696f6e";
        funct_select      <= '1';
        data_in           <= X"45e5a8363e99266e";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"3b8f9393f24e1c17" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"696e73756c616e74";
        funct_select      <= '1';
        data_in           <= X"3b8f9393f24e1c17";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"183bddeb355272a0" report "test #1 failed" severity error;

        -------------------------------------------------------------------------------------------
        wait for CLOCK_PERIOD*5;
        reset <= '1';
        wait for CLOCK_PERIOD;
        reset <= '0';
        -----------------------------
        key_in            <= X"696e73756c616e74";
        funct_select      <= '0';
        data_in           <= X"183bddeb355272a0";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"3b8f9393f24e1c17" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"696c6c7573696f6e";
        funct_select      <= '0';
        data_in           <= X"3b8f9393f24e1c17";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"45e5a8363e99266e" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"6c656e736c657373";
        funct_select      <= '0';
        data_in           <= X"45e5a8363e99266e";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"6b69636b6261636b" report "test #2 failed" severity error;

        -------------------------------------------------------------------------------------------
        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6c656e736c657373";
        funct_select      <= '1';
        data_in           <= X"6261636b7061636b";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"b5a54ddd6774084c" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"696c6c7573696f6e";
        funct_select      <= '1';
        data_in           <= X"b5a54ddd6774084c";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"2730b186fcade210" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"696e73756c616e74";
        funct_select      <= '1';
        data_in           <= X"2730b186fcade210";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"68579014c0e8c19b" report "test #1 failed" severity error;

        -------------------------------------------------------------------------------------------
        wait for CLOCK_PERIOD*5;
        reset <= '1';
        wait for CLOCK_PERIOD;
        reset <= '0';
        -----------------------------
        key_in            <= X"696e73756c616e74";
        funct_select      <= '0';
        data_in           <= X"68579014c0e8c19b";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"2730b186fcade210" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"696c6c7573696f6e";
        funct_select      <= '0';
        data_in           <= X"2730b186fcade210";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"b5a54ddd6774084c" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"6c656e736c657373";
        funct_select      <= '0';
        data_in           <= X"b5a54ddd6774084c";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"6261636b7061636b" report "test #2 failed" severity error;

        -------------------------------------------------------------------------------------------
        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6c656e736c657373";
        funct_select      <= '1';
        data_in           <= X"70697a7a65726961";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"2490732982a368b9" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"696c6c7573696f6e";
        funct_select      <= '1';
        data_in           <= X"2490732982a368b9";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"a8ced371d594562a" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"696e73756c616e74";
        funct_select      <= '1';
        data_in           <= X"a8ced371d594562a";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"efa93f6a61b1eac8" report "test #1 failed" severity error;

        -------------------------------------------------------------------------------------------
        wait for CLOCK_PERIOD*5;
        reset <= '1';
        wait for CLOCK_PERIOD;
        reset <= '0';
        -----------------------------
        key_in            <= X"696e73756c616e74";
        funct_select      <= '0';
        data_in           <= X"efa93f6a61b1eac8";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"a8ced371d594562a" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"696c6c7573696f6e";
        funct_select      <= '0';
        data_in           <= X"a8ced371d594562a";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"2490732982a368b9" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"6c656e736c657373";
        funct_select      <= '0';
        data_in           <= X"2490732982a368b9";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"70697a7a65726961" report "test #2 failed" severity error;

        -------------------------------------------------------------------------------------------
        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6c656e736c657373";
        funct_select      <= '1';
        data_in           <= X"6a69756a69747375";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"6e965ffaf31b2371" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"696c6c7573696f6e";
        funct_select      <= '1';
        data_in           <= X"6e965ffaf31b2371";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"97126ad548b9064b" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"696e73756c616e74";
        funct_select      <= '1';
        data_in           <= X"97126ad548b9064b";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"e25c34ffebb27e1b" report "test #1 failed" severity error;

        -------------------------------------------------------------------------------------------
        wait for CLOCK_PERIOD*5;
        reset <= '1';
        wait for CLOCK_PERIOD;
        reset <= '0';
        -----------------------------
        key_in            <= X"696e73756c616e74";
        funct_select      <= '0';
        data_in           <= X"e25c34ffebb27e1b";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"97126ad548b9064b" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"696c6c7573696f6e";
        funct_select      <= '0';
        data_in           <= X"97126ad548b9064b";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"6e965ffaf31b2371" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"6c656e736c657373";
        funct_select      <= '0';
        data_in           <= X"6e965ffaf31b2371";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"6a69756a69747375" report "test #2 failed" severity error;

        -------------------------------------------------------------------------------------------
        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6c656e736c657373";
        funct_select      <= '1';
        data_in           <= X"717569786f746963";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"4976ed0da2a3de3a" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"696c6c7573696f6e";
        funct_select      <= '1';
        data_in           <= X"4976ed0da2a3de3a";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"a56efa2a1d22bb9f" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"696e73756c616e74";
        funct_select      <= '1';
        data_in           <= X"a56efa2a1d22bb9f";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"bf3540177ec11ed0" report "test #1 failed" severity error;

        -------------------------------------------------------------------------------------------
        wait for CLOCK_PERIOD*5;
        reset <= '1';
        wait for CLOCK_PERIOD;
        reset <= '0';
        -----------------------------
        key_in            <= X"696e73756c616e74";
        funct_select      <= '0';
        data_in           <= X"bf3540177ec11ed0";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"a56efa2a1d22bb9f" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"696c6c7573696f6e";
        funct_select      <= '0';
        data_in           <= X"a56efa2a1d22bb9f";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"4976ed0da2a3de3a" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"6c656e736c657373";
        funct_select      <= '0';
        data_in           <= X"4976ed0da2a3de3a";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"717569786f746963" report "test #2 failed" severity error;

        -------------------------------------------------------------------------------------------
        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6e617574696c7573";
        funct_select      <= '1';
        data_in           <= X"6163746976697479";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"18971bd0697b12d4" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"696e7374616c6c73";
        funct_select      <= '1';
        data_in           <= X"18971bd0697b12d4";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"fa79f3ab1d8659a5" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6c6f6e656c696572";
        funct_select      <= '1';
        data_in           <= X"fa79f3ab1d8659a5";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"b40e581a99eef616" report "test #1 failed" severity error;

        -------------------------------------------------------------------------------------------
        wait for CLOCK_PERIOD*5;
        reset <= '1';
        wait for CLOCK_PERIOD;
        reset <= '0';
        -----------------------------
        key_in            <= X"6c6f6e656c696572";
        funct_select      <= '0';
        data_in           <= X"b40e581a99eef616";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"fa79f3ab1d8659a5" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"696e7374616c6c73";
        funct_select      <= '0';
        data_in           <= X"fa79f3ab1d8659a5";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"18971bd0697b12d4" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"6e617574696c7573";
        funct_select      <= '0';
        data_in           <= X"18971bd0697b12d4";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"6163746976697479" report "test #2 failed" severity error;

        -------------------------------------------------------------------------------------------
        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6e617574696c7573";
        funct_select      <= '1';
        data_in           <= X"6a617a7a69657374";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"6c69fe7b0c6a9edb" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"696e7374616c6c73";
        funct_select      <= '1';
        data_in           <= X"6c69fe7b0c6a9edb";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"2903fa8fbfe23461" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6c6f6e656c696572";
        funct_select      <= '1';
        data_in           <= X"2903fa8fbfe23461";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"963c3dfbb90ced98" report "test #1 failed" severity error;

        -------------------------------------------------------------------------------------------
        wait for CLOCK_PERIOD*5;
        reset <= '1';
        wait for CLOCK_PERIOD;
        reset <= '0';
        -----------------------------
        key_in            <= X"6c6f6e656c696572";
        funct_select      <= '0';
        data_in           <= X"963c3dfbb90ced98";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"2903fa8fbfe23461" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"696e7374616c6c73";
        funct_select      <= '0';
        data_in           <= X"2903fa8fbfe23461";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"6c69fe7b0c6a9edb" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"6e617574696c7573";
        funct_select      <= '0';
        data_in           <= X"6c69fe7b0c6a9edb";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"6a617a7a69657374" report "test #2 failed" severity error;

        -------------------------------------------------------------------------------------------
        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6e617574696c7573";
        funct_select      <= '1';
        data_in           <= X"62757a7a776f7264";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"5464a1dfbba019bf" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"696e7374616c6c73";
        funct_select      <= '1';
        data_in           <= X"5464a1dfbba019bf";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"5fcf10a3f00087b5" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6c6f6e656c696572";
        funct_select      <= '1';
        data_in           <= X"5fcf10a3f00087b5";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"1e4d5a59ff68075b" report "test #1 failed" severity error;

        -------------------------------------------------------------------------------------------
        wait for CLOCK_PERIOD*5;
        reset <= '1';
        wait for CLOCK_PERIOD;
        reset <= '0';
        -----------------------------
        key_in            <= X"6c6f6e656c696572";
        funct_select      <= '0';
        data_in           <= X"1e4d5a59ff68075b";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"5fcf10a3f00087b5" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"696e7374616c6c73";
        funct_select      <= '0';
        data_in           <= X"5fcf10a3f00087b5";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"5464a1dfbba019bf" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"6e617574696c7573";
        funct_select      <= '0';
        data_in           <= X"5464a1dfbba019bf";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"62757a7a776f7264" report "test #2 failed" severity error;

        -------------------------------------------------------------------------------------------
        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6e617574696c7573";
        funct_select      <= '1';
        data_in           <= X"537461726275636b";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"f69a07977be88dd5" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"696e7374616c6c73";
        funct_select      <= '1';
        data_in           <= X"f69a07977be88dd5";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"8c9f1ef496aa92e5" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6c6f6e656c696572";
        funct_select      <= '1';
        data_in           <= X"8c9f1ef496aa92e5";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"347b003b6d17a084" report "test #1 failed" severity error;

        -------------------------------------------------------------------------------------------
        wait for CLOCK_PERIOD*5;
        reset <= '1';
        wait for CLOCK_PERIOD;
        reset <= '0';
        -----------------------------
        key_in            <= X"6c6f6e656c696572";
        funct_select      <= '0';
        data_in           <= X"347b003b6d17a084";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"8c9f1ef496aa92e5" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"696e7374616c6c73";
        funct_select      <= '0';
        data_in           <= X"8c9f1ef496aa92e5";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"f69a07977be88dd5" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"6e617574696c7573";
        funct_select      <= '0';
        data_in           <= X"f69a07977be88dd5";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"537461726275636b" report "test #2 failed" severity error;

        -------------------------------------------------------------------------------------------
        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6e617574696c7573";
        funct_select      <= '1';
        data_in           <= X"666c61706a61636b";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"77c553ca96655464" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"696e7374616c6c73";
        funct_select      <= '1';
        data_in           <= X"77c553ca96655464";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"f2be4b960565288b" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6c6f6e656c696572";
        funct_select      <= '1';
        data_in           <= X"f2be4b960565288b";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"8c43097f4e52e54e" report "test #1 failed" severity error;

        -------------------------------------------------------------------------------------------
        wait for CLOCK_PERIOD*5;
        reset <= '1';
        wait for CLOCK_PERIOD;
        reset <= '0';
        -----------------------------
        key_in            <= X"6c6f6e656c696572";
        funct_select      <= '0';
        data_in           <= X"8c43097f4e52e54e";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"f2be4b960565288b" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"696e7374616c6c73";
        funct_select      <= '0';
        data_in           <= X"f2be4b960565288b";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"77c553ca96655464" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"6e617574696c7573";
        funct_select      <= '0';
        data_in           <= X"77c553ca96655464";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"666c61706a61636b" report "test #2 failed" severity error;

        -------------------------------------------------------------------------------------------
        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6e617574696c7573";
        funct_select      <= '1';
        data_in           <= X"6b69636b6261636b";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"b561267dbd1f83e4" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"696e7374616c6c73";
        funct_select      <= '1';
        data_in           <= X"b561267dbd1f83e4";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"353ea93e7ce1590f" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6c6f6e656c696572";
        funct_select      <= '1';
        data_in           <= X"353ea93e7ce1590f";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"165d83a0b7bd704c" report "test #1 failed" severity error;

        -------------------------------------------------------------------------------------------
        wait for CLOCK_PERIOD*5;
        reset <= '1';
        wait for CLOCK_PERIOD;
        reset <= '0';
        -----------------------------
        key_in            <= X"6c6f6e656c696572";
        funct_select      <= '0';
        data_in           <= X"165d83a0b7bd704c";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"353ea93e7ce1590f" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"696e7374616c6c73";
        funct_select      <= '0';
        data_in           <= X"353ea93e7ce1590f";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"b561267dbd1f83e4" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"6e617574696c7573";
        funct_select      <= '0';
        data_in           <= X"b561267dbd1f83e4";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"6b69636b6261636b" report "test #2 failed" severity error;

        -------------------------------------------------------------------------------------------
        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6e617574696c7573";
        funct_select      <= '1';
        data_in           <= X"6261636b7061636b";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"47aca5f665b013ec" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"696e7374616c6c73";
        funct_select      <= '1';
        data_in           <= X"47aca5f665b013ec";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"794564b70d5cfc6a" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6c6f6e656c696572";
        funct_select      <= '1';
        data_in           <= X"794564b70d5cfc6a";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"7f3a78dd04abf6b8" report "test #1 failed" severity error;

        -------------------------------------------------------------------------------------------
        wait for CLOCK_PERIOD*5;
        reset <= '1';
        wait for CLOCK_PERIOD;
        reset <= '0';
        -----------------------------
        key_in            <= X"6c6f6e656c696572";
        funct_select      <= '0';
        data_in           <= X"7f3a78dd04abf6b8";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"794564b70d5cfc6a" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"696e7374616c6c73";
        funct_select      <= '0';
        data_in           <= X"794564b70d5cfc6a";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"47aca5f665b013ec" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"6e617574696c7573";
        funct_select      <= '0';
        data_in           <= X"47aca5f665b013ec";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"6261636b7061636b" report "test #2 failed" severity error;

        -------------------------------------------------------------------------------------------
        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6e617574696c7573";
        funct_select      <= '1';
        data_in           <= X"70697a7a65726961";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"d8499bbb8b50dcad" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"696e7374616c6c73";
        funct_select      <= '1';
        data_in           <= X"d8499bbb8b50dcad";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"c8a1c2440c970f5f" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6c6f6e656c696572";
        funct_select      <= '1';
        data_in           <= X"c8a1c2440c970f5f";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"f613ea4b16d251c7" report "test #1 failed" severity error;

        -------------------------------------------------------------------------------------------
        wait for CLOCK_PERIOD*5;
        reset <= '1';
        wait for CLOCK_PERIOD;
        reset <= '0';
        -----------------------------
        key_in            <= X"6c6f6e656c696572";
        funct_select      <= '0';
        data_in           <= X"f613ea4b16d251c7";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"c8a1c2440c970f5f" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"696e7374616c6c73";
        funct_select      <= '0';
        data_in           <= X"c8a1c2440c970f5f";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"d8499bbb8b50dcad" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"6e617574696c7573";
        funct_select      <= '0';
        data_in           <= X"d8499bbb8b50dcad";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"70697a7a65726961" report "test #2 failed" severity error;

        -------------------------------------------------------------------------------------------
        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6e617574696c7573";
        funct_select      <= '1';
        data_in           <= X"6a69756a69747375";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"ef500b6722684dba" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"696e7374616c6c73";
        funct_select      <= '1';
        data_in           <= X"ef500b6722684dba";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"549390c198e2372d" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6c6f6e656c696572";
        funct_select      <= '1';
        data_in           <= X"549390c198e2372d";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"b7311ef9db1b42e1" report "test #1 failed" severity error;

        -------------------------------------------------------------------------------------------
        wait for CLOCK_PERIOD*5;
        reset <= '1';
        wait for CLOCK_PERIOD;
        reset <= '0';
        -----------------------------
        key_in            <= X"6c6f6e656c696572";
        funct_select      <= '0';
        data_in           <= X"b7311ef9db1b42e1";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"549390c198e2372d" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"696e7374616c6c73";
        funct_select      <= '0';
        data_in           <= X"549390c198e2372d";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"ef500b6722684dba" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"6e617574696c7573";
        funct_select      <= '0';
        data_in           <= X"ef500b6722684dba";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"6a69756a69747375" report "test #2 failed" severity error;

        -------------------------------------------------------------------------------------------
        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6e617574696c7573";
        funct_select      <= '1';
        data_in           <= X"717569786f746963";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"09481fb5330cce2b" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"696e7374616c6c73";
        funct_select      <= '1';
        data_in           <= X"09481fb5330cce2b";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"9194dc71bc4b8faa" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6c6f6e656c696572";
        funct_select      <= '1';
        data_in           <= X"9194dc71bc4b8faa";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"c4fdc5453ac735cc" report "test #1 failed" severity error;

        -------------------------------------------------------------------------------------------
        wait for CLOCK_PERIOD*5;
        reset <= '1';
        wait for CLOCK_PERIOD;
        reset <= '0';
        -----------------------------
        key_in            <= X"6c6f6e656c696572";
        funct_select      <= '0';
        data_in           <= X"c4fdc5453ac735cc";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"9194dc71bc4b8faa" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"696e7374616c6c73";
        funct_select      <= '0';
        data_in           <= X"9194dc71bc4b8faa";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"09481fb5330cce2b" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"6e617574696c7573";
        funct_select      <= '0';
        data_in           <= X"09481fb5330cce2b";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"717569786f746963" report "test #2 failed" severity error;

        -------------------------------------------------------------------------------------------
        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6261746874696d65";
        funct_select      <= '1';
        data_in           <= X"6163746976697479";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"ae273f8c56f56f8e" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6e6174696f6e616c";
        funct_select      <= '1';
        data_in           <= X"ae273f8c56f56f8e";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"0b07fac65107203b" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"73656c6c6f757473";
        funct_select      <= '1';
        data_in           <= X"0b07fac65107203b";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"6eb6499a238d2bdf" report "test #1 failed" severity error;

        -------------------------------------------------------------------------------------------
        wait for CLOCK_PERIOD*5;
        reset <= '1';
        wait for CLOCK_PERIOD;
        reset <= '0';
        -----------------------------
        key_in            <= X"73656c6c6f757473";
        funct_select      <= '0';
        data_in           <= X"6eb6499a238d2bdf";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"0b07fac65107203b" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"6e6174696f6e616c";
        funct_select      <= '0';
        data_in           <= X"0b07fac65107203b";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"ae273f8c56f56f8e" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"6261746874696d65";
        funct_select      <= '0';
        data_in           <= X"ae273f8c56f56f8e";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"6163746976697479" report "test #2 failed" severity error;

        -------------------------------------------------------------------------------------------
        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6261746874696d65";
        funct_select      <= '1';
        data_in           <= X"6a617a7a69657374";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"faa47252bb43efd6" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6e6174696f6e616c";
        funct_select      <= '1';
        data_in           <= X"faa47252bb43efd6";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"4e9f5112db35463d" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"73656c6c6f757473";
        funct_select      <= '1';
        data_in           <= X"4e9f5112db35463d";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"af8cbccf5ae032cc" report "test #1 failed" severity error;

        -------------------------------------------------------------------------------------------
        wait for CLOCK_PERIOD*5;
        reset <= '1';
        wait for CLOCK_PERIOD;
        reset <= '0';
        -----------------------------
        key_in            <= X"73656c6c6f757473";
        funct_select      <= '0';
        data_in           <= X"af8cbccf5ae032cc";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"4e9f5112db35463d" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"6e6174696f6e616c";
        funct_select      <= '0';
        data_in           <= X"4e9f5112db35463d";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"faa47252bb43efd6" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"6261746874696d65";
        funct_select      <= '0';
        data_in           <= X"faa47252bb43efd6";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"6a617a7a69657374" report "test #2 failed" severity error;

        -------------------------------------------------------------------------------------------
        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6261746874696d65";
        funct_select      <= '1';
        data_in           <= X"62757a7a776f7264";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"1a45a29699de5d9d" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6e6174696f6e616c";
        funct_select      <= '1';
        data_in           <= X"1a45a29699de5d9d";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"1ae853c54f4af342" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"73656c6c6f757473";
        funct_select      <= '1';
        data_in           <= X"1ae853c54f4af342";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"376a2b88bf3060ea" report "test #1 failed" severity error;

        -------------------------------------------------------------------------------------------
        wait for CLOCK_PERIOD*5;
        reset <= '1';
        wait for CLOCK_PERIOD;
        reset <= '0';
        -----------------------------
        key_in            <= X"73656c6c6f757473";
        funct_select      <= '0';
        data_in           <= X"376a2b88bf3060ea";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"1ae853c54f4af342" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"6e6174696f6e616c";
        funct_select      <= '0';
        data_in           <= X"1ae853c54f4af342";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"1a45a29699de5d9d" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"6261746874696d65";
        funct_select      <= '0';
        data_in           <= X"1a45a29699de5d9d";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"62757a7a776f7264" report "test #2 failed" severity error;

        -------------------------------------------------------------------------------------------
        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6261746874696d65";
        funct_select      <= '1';
        data_in           <= X"537461726275636b";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"e003dc6fb6452543" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6e6174696f6e616c";
        funct_select      <= '1';
        data_in           <= X"e003dc6fb6452543";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"87a529a0c6811ca5" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"73656c6c6f757473";
        funct_select      <= '1';
        data_in           <= X"87a529a0c6811ca5";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"c217101b3fef7484" report "test #1 failed" severity error;

        -------------------------------------------------------------------------------------------
        wait for CLOCK_PERIOD*5;
        reset <= '1';
        wait for CLOCK_PERIOD;
        reset <= '0';
        -----------------------------
        key_in            <= X"73656c6c6f757473";
        funct_select      <= '0';
        data_in           <= X"c217101b3fef7484";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"87a529a0c6811ca5" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"6e6174696f6e616c";
        funct_select      <= '0';
        data_in           <= X"87a529a0c6811ca5";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"e003dc6fb6452543" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"6261746874696d65";
        funct_select      <= '0';
        data_in           <= X"e003dc6fb6452543";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"537461726275636b" report "test #2 failed" severity error;

        -------------------------------------------------------------------------------------------
        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6261746874696d65";
        funct_select      <= '1';
        data_in           <= X"666c61706a61636b";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"06b5b4e455f2adb4" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6e6174696f6e616c";
        funct_select      <= '1';
        data_in           <= X"06b5b4e455f2adb4";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"8e2d20c2b41cd3bf" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"73656c6c6f757473";
        funct_select      <= '1';
        data_in           <= X"8e2d20c2b41cd3bf";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"8403503f62bb0869" report "test #1 failed" severity error;

        -------------------------------------------------------------------------------------------
        wait for CLOCK_PERIOD*5;
        reset <= '1';
        wait for CLOCK_PERIOD;
        reset <= '0';
        -----------------------------
        key_in            <= X"73656c6c6f757473";
        funct_select      <= '0';
        data_in           <= X"8403503f62bb0869";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"8e2d20c2b41cd3bf" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"6e6174696f6e616c";
        funct_select      <= '0';
        data_in           <= X"8e2d20c2b41cd3bf";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"06b5b4e455f2adb4" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"6261746874696d65";
        funct_select      <= '0';
        data_in           <= X"06b5b4e455f2adb4";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"666c61706a61636b" report "test #2 failed" severity error;

        -------------------------------------------------------------------------------------------
        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6261746874696d65";
        funct_select      <= '1';
        data_in           <= X"6b69636b6261636b";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"503819915bf426a7" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6e6174696f6e616c";
        funct_select      <= '1';
        data_in           <= X"503819915bf426a7";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"16da0a4a6b9fb703" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"73656c6c6f757473";
        funct_select      <= '1';
        data_in           <= X"16da0a4a6b9fb703";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"40bcd1a23a65334e" report "test #1 failed" severity error;

        -------------------------------------------------------------------------------------------
        wait for CLOCK_PERIOD*5;
        reset <= '1';
        wait for CLOCK_PERIOD;
        reset <= '0';
        -----------------------------
        key_in            <= X"73656c6c6f757473";
        funct_select      <= '0';
        data_in           <= X"40bcd1a23a65334e";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"16da0a4a6b9fb703" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"6e6174696f6e616c";
        funct_select      <= '0';
        data_in           <= X"16da0a4a6b9fb703";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"503819915bf426a7" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"6261746874696d65";
        funct_select      <= '0';
        data_in           <= X"503819915bf426a7";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"6b69636b6261636b" report "test #2 failed" severity error;

        -------------------------------------------------------------------------------------------
        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6261746874696d65";
        funct_select      <= '1';
        data_in           <= X"6261636b7061636b";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"a3d9ddda854c96ab" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6e6174696f6e616c";
        funct_select      <= '1';
        data_in           <= X"a3d9ddda854c96ab";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"7a0ddd7fafb5f46d" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"73656c6c6f757473";
        funct_select      <= '1';
        data_in           <= X"7a0ddd7fafb5f46d";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"55191594918a37d9" report "test #1 failed" severity error;

        -------------------------------------------------------------------------------------------
        wait for CLOCK_PERIOD*5;
        reset <= '1';
        wait for CLOCK_PERIOD;
        reset <= '0';
        -----------------------------
        key_in            <= X"73656c6c6f757473";
        funct_select      <= '0';
        data_in           <= X"55191594918a37d9";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"7a0ddd7fafb5f46d" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"6e6174696f6e616c";
        funct_select      <= '0';
        data_in           <= X"7a0ddd7fafb5f46d";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"a3d9ddda854c96ab" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"6261746874696d65";
        funct_select      <= '0';
        data_in           <= X"a3d9ddda854c96ab";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"6261636b7061636b" report "test #2 failed" severity error;

        -------------------------------------------------------------------------------------------
        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6261746874696d65";
        funct_select      <= '1';
        data_in           <= X"70697a7a65726961";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"f6c65b342b2dce30" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6e6174696f6e616c";
        funct_select      <= '1';
        data_in           <= X"f6c65b342b2dce30";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"8838c3858a5a4588" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"73656c6c6f757473";
        funct_select      <= '1';
        data_in           <= X"8838c3858a5a4588";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"9536924bd6633013" report "test #1 failed" severity error;

        -------------------------------------------------------------------------------------------
        wait for CLOCK_PERIOD*5;
        reset <= '1';
        wait for CLOCK_PERIOD;
        reset <= '0';
        -----------------------------
        key_in            <= X"73656c6c6f757473";
        funct_select      <= '0';
        data_in           <= X"9536924bd6633013";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"8838c3858a5a4588" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"6e6174696f6e616c";
        funct_select      <= '0';
        data_in           <= X"8838c3858a5a4588";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"f6c65b342b2dce30" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"6261746874696d65";
        funct_select      <= '0';
        data_in           <= X"f6c65b342b2dce30";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"70697a7a65726961" report "test #2 failed" severity error;

        -------------------------------------------------------------------------------------------
        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6261746874696d65";
        funct_select      <= '1';
        data_in           <= X"6a69756a69747375";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"4e64c25e0f04fed5" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6e6174696f6e616c";
        funct_select      <= '1';
        data_in           <= X"4e64c25e0f04fed5";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"4778fdc7d583c0c5" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"73656c6c6f757473";
        funct_select      <= '1';
        data_in           <= X"4778fdc7d583c0c5";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"56704db7b42a43b0" report "test #1 failed" severity error;

        -------------------------------------------------------------------------------------------
        wait for CLOCK_PERIOD*5;
        reset <= '1';
        wait for CLOCK_PERIOD;
        reset <= '0';
        -----------------------------
        key_in            <= X"73656c6c6f757473";
        funct_select      <= '0';
        data_in           <= X"56704db7b42a43b0";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"4778fdc7d583c0c5" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"6e6174696f6e616c";
        funct_select      <= '0';
        data_in           <= X"4778fdc7d583c0c5";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"4e64c25e0f04fed5" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"6261746874696d65";
        funct_select      <= '0';
        data_in           <= X"4e64c25e0f04fed5";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"6a69756a69747375" report "test #2 failed" severity error;

        -------------------------------------------------------------------------------------------
        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6261746874696d65";
        funct_select      <= '1';
        data_in           <= X"717569786f746963";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"307be3badcae0301" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"6e6174696f6e616c";
        funct_select      <= '1';
        data_in           <= X"307be3badcae0301";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"c917a3d57005ccdc" report "test #1 failed" severity error;



        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -----------------------------
        key_in            <= X"73656c6c6f757473";
        funct_select      <= '1';
        data_in           <= X"c917a3d57005ccdc";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"0c430d63e1ae5543" report "test #1 failed" severity error;

        -------------------------------------------------------------------------------------------
        wait for CLOCK_PERIOD*5;
        reset <= '1';
        wait for CLOCK_PERIOD;
        reset <= '0';
        -----------------------------
        key_in            <= X"73656c6c6f757473";
        funct_select      <= '0';
        data_in           <= X"0c430d63e1ae5543";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"c917a3d57005ccdc" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"6e6174696f6e616c";
        funct_select      <= '0';
        data_in           <= X"c917a3d57005ccdc";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"307be3badcae0301" report "test #2 failed" severity error;



        wait for CLOCK_PERIOD*5;
        reset <= '1';
        -----------------------------
        wait for CLOCK_PERIOD;
        reset <= '0';
        key_in            <= X"6261746874696d65";
        funct_select      <= '0';
        data_in           <= X"307be3badcae0301";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        assert data_out = X"717569786f746963" report "test #2 failed" severity error;

        -------------------------------------------------------------------------------------------
        reset <= '1';
                wait; -- stop simulation
            end process tb1;
            --  End Test Bench
        END;

