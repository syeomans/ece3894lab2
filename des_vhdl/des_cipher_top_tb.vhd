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
    -- This testbench exercises the DES toplevel with the 2 test vectors.
    --
    tb1 : process is
    begin
        reset <= '1';
        wait for CLOCK_PERIOD; -- wait until reset completes
        reset <= '0';
        -------------------------------------------------------------------------------------------
        -- test vector 1
        -- msg := "abc"
        -- expected ciphertext:= X"334C2268D120DFC3"
        key_in            <= X"1234567812345678";
        funct_select      <= '1';
        data_in           <= X"6162630000000000";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        -- expected: X"334C2268D120DFC3"
        assert data_out = X"334C2268D120DFC3" report "test #1 failed" severity error;
        
        -------------------------------------------------------------------------------------------
        wait for CLOCK_PERIOD*5;
        reset <= '1';
        wait for CLOCK_PERIOD;
        reset <= '0';
        -- test vector 2
        -- msg := X"334C2268D120DFC3"""
        -- expected plaintext:= X"6162630000000000"
        key_in            <= X"1234567812345678";
        funct_select      <= '0';
        data_in           <= X"334C2268D120DFC3";
        lddata            <= '1';
        wait until des_out_rdy = '1';

        -- expected: X"6162630000000000"
        assert data_out = X"6162630000000000" report "test #2 failed" severity error;
        
        -------------------------------------------------------------------------------------------

        reset <= '1';
        wait; -- stop simulation
    end process tb1;
    --  End Test Bench 
END;
