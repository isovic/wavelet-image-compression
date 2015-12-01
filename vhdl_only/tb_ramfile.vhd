--------------------------------------------------------------------------------
-- Company: Ruder Boskovic Institute
-- Engineer: Ivan Sovic
--
-- Create Date:   18:00:57 03/26/2014
-- Design Name:   
-- Module Name:   tb_ramfile.vhd
-- Project Name:  wavelet
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ramfile
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb_ramfile IS
END tb_ramfile;
 
ARCHITECTURE behavior OF tb_ramfile IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ramfile
    PORT(
         clk : IN  std_logic;
         we : IN  std_logic;
         en : IN  std_logic;
         addr : IN  std_logic_vector(15 downto 0);
         dataIn : IN  std_logic_vector(7 downto 0);
         dataOut : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
	 
   --Inputs
   signal clk : std_logic := '0';
   signal we : std_logic := '0';
   signal en : std_logic := '0';
   signal addr : std_logic_vector(15 downto 0) := (others => '0');
   signal dataIn : std_logic_vector(7 downto 0) := (others => '0');

 	--Outputs
   signal dataOut : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ramfile PORT MAP (
          clk => clk,
          we => we,
          en => en,
          addr => addr,
          dataIn => dataIn,
          dataOut => dataOut
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;
		addr <= addr + '1';
		en <= '1';
		
      wait for clk_period*10;
		addr <= addr + '1';
		
      wait for clk_period*10;
		addr <= addr + '1';
		
      wait for clk_period*10;
		addr <= addr + '1';
		
      wait for clk_period*10;
		addr <= addr + '1';

      -- insert stimulus here 

      wait;
   end process;

END;
