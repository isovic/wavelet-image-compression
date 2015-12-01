--------------------------------------------------------------------------------
-- Company: Ruder Boskovic Institute
-- Engineer: Ivan Sovic
--
-- Create Date:   10:38:45 07/29/2014
-- Design Name:   
-- Module Name:   tb_fifomem.vhd
-- Project Name:  wavelet
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: fifomem
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb_fifomem IS
END tb_fifomem;
 
ARCHITECTURE behavior OF tb_fifomem IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT fifomem
	 GENERIC (
        DATA_WIDTH: natural := 8;			-- Width of a single data register (i.e. a byte).
        FIFO_DEPTH: natural := 2			-- Number of data registers in the FIFO memory (i.e. the width of the image + 1).
    );
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
			we: in std_logic;
         dataIn : IN  std_logic_vector(7 downto 0);
			dataOutFirst: out std_logic_vector((DATA_WIDTH - 1) downto 0);
			dataOutLast: out std_logic_vector((DATA_WIDTH - 1) downto 0)
       );
    END COMPONENT;

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal dataIn : std_logic_vector(7 downto 0) := (others => '0');
	signal we : std_logic := '0';
	
 	--Outputs
   signal dataOutFirst : std_logic_vector(7 downto 0);
   signal dataOutLast : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: fifomem
	GENERIC MAP (DATA_WIDTH => 8, FIFO_DEPTH => 4)
	PORT MAP (
          clk => clk,
          reset => reset,
			 we => we,
          dataIn => dataIn,
          dataOutFirst => dataOutFirst,
          dataOutLast => dataOutLast
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
		variable dataCounter: integer := 1;
   begin
      -- hold reset state for 100 ns.
		reset <= '1';
      wait for 100 ns;	
		reset <= '0';
		we <= '1';
      
		wait for clk_period;
			dataIn <= std_logic_vector(to_unsigned(dataCounter, dataIn'length));
			dataCounter := dataCounter + 1;
		wait for clk_period;
			dataIn <= std_logic_vector(to_unsigned(dataCounter, dataIn'length));
			dataCounter := dataCounter + 1;
		wait for clk_period;
			dataIn <= std_logic_vector(to_unsigned(dataCounter, dataIn'length));
			dataCounter := dataCounter + 1;
		wait for clk_period;
			dataIn <= std_logic_vector(to_unsigned(dataCounter, dataIn'length));
			dataCounter := dataCounter + 1;
		wait for clk_period;
			dataIn <= std_logic_vector(to_unsigned(dataCounter, dataIn'length));
			dataCounter := dataCounter + 1;
		
      wait for clk_period*10;

      wait;
   end process;

END;
