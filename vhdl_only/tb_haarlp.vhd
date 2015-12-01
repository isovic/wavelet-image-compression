--------------------------------------------------------------------------------
-- Company: Ruder Boskovic Institute
-- Engineer: Ivan Sovic
--
-- Create Date:   15:03:41 03/27/2014
-- Design Name:   
-- Module Name:   tb_haarlp.vhd
-- Project Name:  wavelet
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: haarlp
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb_haarlp IS
END tb_haarlp;
 
ARCHITECTURE behavior OF tb_haarlp IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT haarlp
    PORT(
         x0 : IN  std_logic_vector(7 downto 0);
         x1 : IN  std_logic_vector(7 downto 0);
         y : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal x0 : std_logic_vector(7 downto 0) := (others => '0');
   signal x1 : std_logic_vector(7 downto 0) := (others => '0');

 	--Outputs
   signal y : std_logic_vector(7 downto 0);
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
   constant clock_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: haarlp PORT MAP (
          x0 => x0,
          x1 => x1,
          y => y
        );

--   -- Clock process definitions
--   <clock>_process :process
--   begin
--		<clock> <= '0';
--		wait for <clock>_period/2;
--		<clock> <= '1';
--		wait for <clock>_period/2;
--   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

		x0 <= x"02";
		x1 <= x"00";
      wait for clock_period;
		
		x0 <= x"03";
		x1 <= x"02";
      wait for clock_period;
		
		x0 <= x"07";
		x1 <= x"03";
      wait for clock_period;
		
		x0 <= x"12";
		x1 <= x"07";
      wait for clock_period;
		
		x0 <= x"FA";
		x1 <= x"12";
      wait for clock_period;
		
		x0 <= x"00";
		x1 <= x"FA";
      wait for clock_period;
		
		x0 <= x"20";
		x1 <= x"00";
      wait for clock_period;
		
		x0 <= x"00";
		x1 <= x"00";
      wait for clock_period;
		x0 <= x"FF";
		x1 <= x"00";
      wait for clock_period;
		x0 <= x"FF";
		x1 <= x"FF";
      wait for clock_period;

      wait for clock_period*10;
      -- insert stimulus here 

      wait;
   end process;

END;
