----------------------------------------------------------------------------------
-- Company: Ruder Boskovic Institute
-- Engineer: Ivan Sovic
-- 
-- Create Date:    16:43:56 07/31/2014 
-- Design Name: 
-- Module Name:    transmitraw - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: An extra utility component used for transmitting the values of the output RAM. This
-- component is used for evaluation purposes in the testbench, but is also synthesizable and can be
-- used to stream the data when the compression process is over.
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

entity transmitraw is
	Generic (	IMAGE_WIDTH : integer := 256;
					IMAGE_HEIGHT : integer := 256;
					ADDR_WIDTH : integer := 16
				);
    Port ( clk : in  STD_LOGIC;
			  en : in STD_LOGIC;
           reset : in  STD_LOGIC;
           request : in  STD_LOGIC;
           dataIn : in  STD_LOGIC_VECTOR (7 downto 0);
			  
			  ready : out  STD_LOGIC;
			  done : out STD_LOGIC;
			  address : out STD_LOGIC_VECTOR ((ADDR_WIDTH - 1) downto 0);
			  stopAddress : in STD_LOGIC_VECTOR((ADDR_WIDTH - 1) downto 0);
           dataOut : out  STD_LOGIC_VECTOR (7 downto 0));
end transmitraw;

architecture Behavioral of transmitraw is
	type states is (	stateReset, stateWaitForRequest, stateStream, stateStream2,
							stateWaitForRequestNext, stateWaitForRequestNext2,
							stateFinished, stateFinished2);
	signal currentState : states := stateReset;
	signal nextState : states := stateReset;
	
	signal sigDataOut : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
	signal sigAddress : STD_LOGIC_VECTOR ((ADDR_WIDTH - 1) downto 0) := (others => '0');
	signal sigReady : STD_LOGIC := '0';
	signal sigDone : STD_LOGIC := '0';
	
	constant totalNumPixels : integer := IMAGE_WIDTH * IMAGE_HEIGHT;
	
	signal numSentPixels : integer := 0;
	
begin
	-- Synchronous process of the state machine.
	process (clk, reset, nextState)
	begin
		if reset = '1' then
			currentState <= stateReset;
		elsif rising_edge(clk) then
			if en = '1' then
				-- Perform all synchronous signal changes. These are changes that
				-- cannot be performed in the combinational process because they
				-- would infer the usage of implicit latches. Example of such a signal
				-- is sigAddress which counts the current address of the pixel to be
				-- transmitted.
				if (currentState = stateReset) then								-- Reset all the counters to zero.
					sigAddress <= (others => '0');
					sigDataOut <= (others => '0');
					numSentPixels <= 0;
				elsif (currentState = stateWaitForRequestNext2) then		-- Increase the address for the data to be sent.
					sigAddress <= sigAddress + 1;
				elsif (currentState = stateStream2) then						-- Set the data to be output to the output data bus,
																							-- and count the number of sent pixels.
					sigDataOut <= dataIn;
					numSentPixels <= numSentPixels + 1;
				end if;
				
				currentState <= nextState;
			end if;
		end if;
	end process;
	
	-- Combinational process of the state machine.
	process (currentState, request, numSentPixels, sigAddress, stopAddress)
	begin
		-- Set the default values for the signals in order to avoid generating latches.
		nextState <= stateReset;
		sigReady <= '0';
		sigDone <= '0';

		case currentState is
			when stateReset =>										-- Reset the state machine.
				nextState <= stateWaitForRequest;
			
			when stateWaitForRequest =>							-- Wait until the first data byte is requested.
				if request = '1' then
					nextState <= stateStream;
				else
					nextState <= stateWaitForRequest;
				end if;

			when stateStream =>										-- Start the streaming of the new data byte.
				nextState <= stateStream2;
			when stateStream2 =>
				nextState <= stateWaitForRequestNext;			-- After the data has been set to the output bus, jump to the waiting state again.

			when stateWaitForRequestNext =>						-- Waiting state almost the same as stateWaitForRequest, but this state
																			-- also sets the sigReady signal to notify the outside devices that the data
																			-- byte is ready, and also increases the count of currently sent data bytes.
				sigReady <= '1';
				
				if numSentPixels = totalNumPixels or sigAddress = (stopAddress - 1) then
					nextState <= stateFinished;
				elsif request = '1' then
					nextState <= stateWaitForRequestNext2;
				else
					nextState <= stateWaitForRequestNext;
				end if;
			when stateWaitForRequestNext2 =>						-- When a new data byte has been requested, this state is jumped to.
				nextState <= stateStream;
			
			-- Since the results are obtained on the rising edge of the sigReady signal,
			-- we must first clear the last obtained byte of data. We do this by
			-- resetting and then setting the sigReady signal to give away one
			-- last rising edge.
			when stateFinished =>									-- When all data bytes have been sent, loop in the finished state.
				sigReady <= '1';
				sigDone <= '1';
				nextState <= stateFinished2;
			when stateFinished2 =>									-- When all data bytes have been sent, loop in the finished state.
				sigDone <= '1';
				nextState <= stateFinished2;
			end case;
	end process;
	
	-- Set the output signals to their current values.
	done <= sigDone;
	ready <= sigReady;
	address <= sigAddress;
	dataOut <= sigDataOut;

end Behavioral;
