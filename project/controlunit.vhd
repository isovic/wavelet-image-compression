----------------------------------------------------------------------------------
-- Company: Ruder Boskovic Institute
-- Engineer: Ivan Sovic
-- 
-- Create Date:    14:05:53 07/29/2014 
-- Design Name: 
-- Module Name:    controlunit - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: Implements a state machine which accesses and streams data from the input ROM.
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity controlunit is
	Generic (	IMAGE_WIDTH : integer := 256;
					IMAGE_HEIGHT : integer := 256;
					ADDR_WIDTH : integer := 16
				);
	Port (		clk : in  STD_LOGIC;
					reset : in STD_LOGIC;
					
					addrIn : out  STD_LOGIC_VECTOR ((ADDR_WIDTH - 1) downto 0);
					
					enRamIn : out STD_LOGIC;
					
					resetFifoRow : out STD_LOGIC;
					weFifoRow : out STD_LOGIC;
					resetFifoColumn : out STD_LOGIC;
					weFifoColumn : out STD_LOGIC;
					
--					isStreamingData : out STD_LOGIC;
					isFinishedProcessing : out STD_LOGIC;
					
					rowReady : out STD_LOGIC;
					columnReady : out STD_LOGIC;
					readyForNextData : in STD_LOGIC
					);
end controlunit;

architecture Behavioral of controlunit is
	type states is (stateReset, stateReset2, stateStream, stateStream0, stateStream1, stateStream2, stateStream3, stateNewRow, stateNewRow2, stateFinished);
	signal currentState : states := stateReset;
	signal nextState : states := stateReset;

	signal sigAddrIn : STD_LOGIC_VECTOR((ADDR_WIDTH - 1) downto 0) := (others => '0');
	signal sigEnRamIn : STD_LOGIC := '0';
	signal sigResetFifoRow, sigWeFifoRow, sigResetFifoColumn, sigWeFifoColumn : STD_LOGIC := '0';
	signal sigIsFinishedProcessing : STD_LOGIC := '0';
	
	signal numPixels : STD_LOGIC_VECTOR((ADDR_WIDTH - 1) downto 0) := (others => '0');
	signal totalNumPixels : STD_LOGIC_VECTOR((ADDR_WIDTH - 1) downto 0) := (others => '0');
	signal numRows : integer := 0;
	
	signal sigRowReady : STD_LOGIC := '0';
	signal sigColumnReady : STD_LOGIC := '1';
	
begin
	-- Synchronous process of the state machine.
	process (clk, reset, nextState)
	begin
		if reset = '1' then
			currentState <= stateReset;
		elsif rising_edge(clk) then
			-- Perform all synchronous signal changes. These are changes that
			-- cannot be performed in the combinational process because they
			-- would infer the usage of implicit latches. Example of such a signal
			-- is sigAddrIn which counts the current address of the pixel to be
			-- analyzed.
			if currentState = stateReset then				-- Reset all signals used for counting to zero.
				numPixels <= (others => '0');
				totalNumPixels <= (others => '0');
				sigColumnReady <= '1';
				sigRowReady <= '0';
				numRows <= 0;
				sigAddrIn <= (others => '0');

			elsif currentState = stateStream0 then			-- Increase the counts of pixels, numPixels counts the number of pixels
																		-- processed in the current row, while totalNumPixels counts the overall
																		-- pixels of the image processed so far.
				numPixels <= numPixels + 1;
				totalNumPixels <= totalNumPixels + 1;
				sigColumnReady <= not sigColumnReady;		-- This signal is used for decimating columns (every other pixel is not
																		-- taken into account, or in other words, only when sigColumnReady is high
																		-- the signal will be processed by the memcontroler).
				
			elsif currentState = stateStream3 then			-- Increase the current address for reading input data.
				sigAddrIn <= sigAddrIn + 1;

			elsif currentState = stateNewRow then			-- If the end of the row has been hit, clear the numPixels count and increase
																		-- the count of rows processed (numRows).
				numRows <= numRows + 1;
				numPixels <= (others => '0');
				sigColumnReady <= '0';
				sigRowReady <= not sigRowReady;				-- This signal is used for decimating rows (every other row is not
																		-- taken into account, or in other words, only when sigColumnReady is high
																		-- the signal will be processed by the memcontroler).
			
			elsif currentState = stateFinished then		-- If we have finished processing the input data, drive the ready signals low.
				sigRowReady <= '0';
				sigColumnReady <= '0';
			end if;
			
			
			
			-- Change the current state
			currentState <= nextState;
			
		end if;
	end process;
	
	-- Combinational process of the state machine.
	process (currentState, numPixels, numRows, readyForNextData)
	begin
		-- Set the default values for the signals in order to avoid generating latches.
		nextState <= stateReset;
		sigEnRamIn <= '0';
		sigResetFifoRow <= '0';
		sigWeFifoRow <= '0';
		sigResetFifoColumn <= '0';
		sigWeFifoColumn <= '0';
		sigIsFinishedProcessing <= '0';
				
		case currentState is
			-- Initialize all components of the design.
			when stateReset =>						-- Drive reset signals high.
				sigResetFifoRow <= '1';
				sigResetFifoColumn <= '1';
				nextState <= stateReset2;
			when stateReset2 =>						-- Lower the reset signals.
				nextState <= stateStream;
			
			-- Wait until the memcontroler component (which stores
			-- current decomposition values to memory) returns
			-- readyForNextData signal.
			when stateStream =>						-- Wait for ready signal to start streaming.
				if readyForNextData = '1' then
					nextState <= stateStream0;
				else
					nextState <= stateStream;
				end if;
			-- Start streaming new pixel of the image from input
			-- through FIFO memories and wavelet filters.
			when stateStream0 =>						-- Start streaming. Enable the input ROM.
				sigEnRamIn <= '1';
				nextState <= stateStream1;
			
			when stateStream1 =>						-- Enable writing new data to the FIFO row component.
				sigEnRamIn <= '1';
				sigWeFifoRow <= '1';
				nextState <= stateStream2;
				
			when stateStream2 =>						-- Disable writing data to the FIFO row component, and
															-- enable writing the filtered data to the FIFO column component.
				sigEnRamIn <= '1';
				sigWeFifoColumn <= '1';
				nextState <= stateStream3;
				
			when stateStream3 =>						-- Disable writing to all FIFO memories.
				sigEnRamIn <= '1';
				
				-- Check if we have reached the end of the row. In this case, the FIFO row component needs
				-- to be reset, because otherwise we would filter the last pixel of the current line and
				-- the first pixel of the next line together (would produce an errouneous signal).
				if numPixels = (IMAGE_WIDTH) then
					nextState <= stateNewRow;
				else
					nextState <= stateStream;
				end if;
				
			when stateNewRow =>						-- If we ran into the end of the row, reset the FIFO row component.
				sigEnRamIn <= '1';
				sigResetFifoRow <= '1';
				nextState <= stateNewRow2;
				
			when stateNewRow2 =>						-- Return the reset signal for the FIFO row component back to inactive state.
				sigEnRamIn <= '1';
				
				-- Check if we have reached the end of the image.
				if numRows = IMAGE_HEIGHT then
					nextState <= stateFinished;
				else
					nextState <= stateStream;
				end if;
				
			when stateFinished =>					-- If the entire image has been processed, loop indefinetly.
				sigIsFinishedProcessing <= '1';
				nextState <= stateFinished;

			end case;
	end process;
	
	-- Set the output signals to their current values.
	addrIn <= sigAddrIn;
	enRamIn <= sigEnRamIn;
	resetFifoRow <= sigResetFifoRow;
	weFifoRow <= sigWeFifoRow;
	resetFifoColumn <= sigResetFifoColumn;
	weFifoColumn <= sigWeFifoColumn;
	isFinishedProcessing <= sigIsFinishedProcessing;
	
	rowReady <= sigRowReady;
	columnReady <= sigColumnReady;
end Behavioral;
