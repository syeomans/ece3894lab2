---------------------------------------------------------------------
--				(c) Copyright 2006, CoreTex Systems, LLC					 --
--		                   www.coretexsys.com                        --    
--                                                            		 --
--		This source file may be used and distributed without         --
--		restriction provided that this copyright statement is not    --
--		removed from the file and that any derivative work contains  --
--		the original copyright notice and the associated disclaimer. --
--                                                            		 --
--		    THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY      --
--		EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED    --
--		TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS    --
--		FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR       --
--		OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,          --
--		INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES     --
--		(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE    --
--		GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR         --
--		BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF   --
--		LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT   --
--		(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT   --
--		OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE          --
--		POSSIBILITY OF SUCH DAMAGE.                                  --
--																						 --
---------------------------------------------------------------------

----------------------------------------------------------------------

-- Project structure: 

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

----------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
--
-- Title       : p_box
-- Company     : CoreTex Systems, LLC
--
---------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity p_box is
port(
    		x0_in: in std_logic_vector(3 downto 0);
			x1_in: in std_logic_vector(3 downto 0);
			x2_in: in std_logic_vector(3 downto 0);
			x3_in: in std_logic_vector(3 downto 0);
			x4_in: in std_logic_vector(3 downto 0);
			x5_in: in std_logic_vector(3 downto 0);
			x6_in: in std_logic_vector(3 downto 0);
			x7_in: in std_logic_vector(3 downto 0);
			x_out: out std_logic_vector(0 to 31)
 	);
end p_box;

architecture Behavioral of p_box is

signal x_in: std_logic_vector(0 to 31);

begin

		x_in 	<= x0_in & x1_in & x2_in & x3_in & x4_in & x5_in & x6_in & x7_in;
		x_out <= x_in(15) & x_in(6) & x_in(19) & x_in(20) & x_in(28) & x_in(11) & 
					x_in(27) & x_in(16) & x_in(0) & x_in(14) & x_in(22) & x_in(25) & 
					x_in(4) & x_in(17) & x_in(30) & x_in(9) & x_in(1) & x_in(7) & 
					x_in(23) & x_in(13) & x_in(31) & x_in(26) & x_in(2) & x_in(8) & 
					x_in(18) & x_in(12) & x_in(29) & x_in(5) & x_in(21) & x_in(10) & 
					x_in(3) & x_in(24);

end Behavioral;
