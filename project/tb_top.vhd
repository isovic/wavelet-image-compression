--------------------------------------------------------------------------------
-- Company: Ruder Boskovic Institute
-- Engineer: Ivan Sovic
--
-- Create Date:   09:35:29 03/27/2014
-- Design Name:   
-- Module Name:   tb_top.vhd
-- Project Name:  wavelet
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: top
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.std_logic_textio.all;
USE STD.textio.all;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb_top IS
END tb_top;
 
ARCHITECTURE behavior OF tb_top IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT top
		 Generic (	IMAGE_WIDTH : integer := 256;
						IMAGE_HEIGHT : integer := 256;
						ADDR_WIDTH : integer := 16
					);
		 Port (	clk : in  std_logic;
					reset : in std_logic;
					requestNewData : in std_logic;
					
					outData : out std_logic_vector(7 downto 0);
					isFinishedProcessing : out std_logic;
					outDataReady : out std_logic;
					isFinishedTransmitting : out std_logic
		 );
    END COMPONENT;

   --Inputs
   signal clk : std_logic := '0';
	signal reset : std_logic := '0';
	signal requestNewData : std_logic := '0';

 	--Outputs
   signal outData : std_logic_vector(7 downto 0) := (others => '0');
	signal outDataReady : std_logic := '0';
	signal isFinishedTransmitting : std_logic := '0';
	signal isFinishedProcessing : std_logic := '0';
	
   -- Clock period definitions
   constant clk_period : time := 10 ns;
	
BEGIN

	-- Instantiate the Unit Under Test (UUT)
   uut: top GENERIC MAP (
								IMAGE_WIDTH => 256,
								IMAGE_HEIGHT => 256,
								ADDR_WIDTH => 16)
				PORT MAP (
								clk => clk,
								reset => reset,
								outData => outData,
								isFinishedProcessing => isFinishedProcessing,
								outDataReady => outDataReady,
								isFinishedTransmitting => isFinishedTransmitting,
								requestNewData => requestNewData
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
		reset <= '1';
      -- hold reset state for 100 ns.
      wait for 100 ns;
		reset <= '0';
		
		wait until isFinishedProcessing'event and isFinishedProcessing = '1';

      wait;
   end process;
	
	-- Simulate for 7000.00us in order to write the entire memory to file.
	writeToDisk: process
		file ramOutFile: TEXT open WRITE_MODE is "../data/compressed.out";
		variable myLine : LINE;
		variable myOutputLine : LINE;
	begin
			if isFinishedProcessing = '1' then
				wait for clk_period;
				requestNewData <= '1';
				
				wait until rising_edge(outDataReady);
				write(myOutputLine, conv_integer(outData));
				writeline(ramOutFile, myOutputLine);
				requestNewData <= '0';

				if isFinishedTransmitting = '1' then
					wait;
				end if;
			end if;
			
		wait for clk_period;
	end process;

END;
