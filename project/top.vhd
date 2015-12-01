----------------------------------------------------------------------------------
-- Company: Ruder Boskovic Institute
-- Engineer: Ivan Sovic
-- 
-- Create Date:    09:14:39 03/27/2014 
-- Design Name: 
-- Module Name:    top - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: Top-level design for testing the Wavelet Image Compression Component.
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

entity top is
	 Generic (	IMAGE_WIDTH : integer := 256;
					IMAGE_HEIGHT : integer := 256;
					ADDR_WIDTH : integer := 16
				);
    Port (	clk : in  std_logic;
				reset : in std_logic;
				
				outData : out std_logic_vector(7 downto 0);
				isFinishedProcessing : out std_logic;
				
				outDataReady : out std_logic;
				isFinishedTransmitting : out std_logic;
				requestNewData : in std_logic
	 );
end top;

architecture Behavioral of top is
	component ramfile is
		generic (RAM_SIZE : integer := 65536
					);
		port (clk  : in std_logic;
				we   : in std_logic;
				en   : in std_logic;
				addr : in std_logic_vector(15 downto 0);
				dataIn   : in std_logic_vector(7 downto 0);
				dataOut	: out std_logic_vector(7 downto 0));
	end component;
	
	component ramnormal is
		  generic (	RAM_SIZE : integer := 65536;
						ADDR_WIDTH : integer := 16
					);
			port (clk  : in std_logic;
				we   : in std_logic;
				en   : in std_logic;
				addr : in std_logic_vector((ADDR_WIDTH - 1) downto 0);
				dataIn   : in std_logic_vector(7 downto 0);
				dataOut	: out std_logic_vector(7 downto 0));
	end component;
	
	component waveleticc is
		 Generic (	IMAGE_WIDTH : integer := 256;
						IMAGE_HEIGHT : integer := 256;
						ADDR_WIDTH : integer := 16
					);
		 Port (	clk : in  std_logic;
					reset : in std_logic;
					
					ramInAddr : out STD_LOGIC_VECTOR((ADDR_WIDTH - 1) downto 0);
					ramInEn : out STD_LOGIC := '0';
					ramInData : in STD_LOGIC_VECTOR(7 downto 0);
					
					ramOutDataIn : out STD_LOGIC_VECTOR(7 downto 0);
					ramOutDataOut : in STD_LOGIC_VECTOR(7 downto 0);
					ramOutWe : out STD_LOGIC;
					ramOutAddr: out STD_LOGIC_VECTOR((ADDR_WIDTH - 1) downto 0);
					
					isFinishedCompressing : out STD_LOGIC;
					compressedDataSize : out STD_LOGIC_VECTOR((ADDR_WIDTH - 1) downto 0)
		 );
	end component;
	
	component transmitraw is
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
	end component;
	
	signal ramInAddr : STD_LOGIC_VECTOR((ADDR_WIDTH - 1) downto 0) := (others => '0');
	signal originalData : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
	signal enRamIn : STD_LOGIC := '0';
	
	signal ramOutDataIn : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
	signal ramOutDataOut : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
	signal weRamOut : STD_LOGIC := '0';
	
	signal transmitAddr : STD_LOGIC_VECTOR((ADDR_WIDTH - 1) downto 0) := (others => '0');
	signal addrOutMemCtrl : STD_LOGIC_VECTOR((ADDR_WIDTH - 1) downto 0) := (others => '0');
	signal ramOutAddr : STD_LOGIC_VECTOR((ADDR_WIDTH - 1) downto 0) := (others => '0');
	
	signal isFinishedCompressing : STD_LOGIC := '0';
	signal sigCompressedDataSize : STD_LOGIC_VECTOR((ADDR_WIDTH - 1) downto 0) := (others => '0');

begin
	wicc: component waveleticc	generic map (	IMAGE_WIDTH => IMAGE_WIDTH,
															IMAGE_HEIGHT => IMAGE_HEIGHT,
															ADDR_WIDTH => ADDR_WIDTH)
										port map (	clk => clk,
														reset => reset,
														ramInAddr => ramInAddr,
														ramInEn => enRamIn,
														ramInData => originalData,
														
														ramOutDataIn => ramOutDataIn,
														ramOutDataOut => ramOutDataOut,
														ramOutWe => weRamOut,
														ramOutAddr => addrOutMemCtrl,
														
														isFinishedCompressing => isFinishedCompressing,
														compressedDataSize => sigCompressedDataSize
													);
	
	ramIn: component ramfile	generic map (RAM_SIZE => (IMAGE_WIDTH*IMAGE_HEIGHT))
										port map (	clk => clk,
														we => '0',
														en => enRamIn,
														addr => ramInAddr,
														dataIn => x"00",
														dataOut => originalData);

	ramOut: component ramnormal generic map (	RAM_SIZE => 65536,
															ADDR_WIDTH => 16)
										port map (	clk => clk,
														we => weRamOut,
														en => '1',
														addr => ramOutAddr,
														dataIn => ramOutDataIn,
														dataOut => ramOutDataOut);

	transmitter: component transmitraw		generic map (	IMAGE_WIDTH => IMAGE_WIDTH,
																			IMAGE_HEIGHT => IMAGE_HEIGHT,
																			ADDR_WIDTH => ADDR_WIDTH)
														port map (	clk => clk,
																		en => isFinishedCompressing,
																		reset => reset,
																		request => requestNewData,
																		dataIn => ramOutDataOut,
																		ready => outDataReady,
																		done => isFinishedTransmitting,
																		address => transmitAddr,
																		stopAddress => sigCompressedDataSize,
																		dataOut => outData);

	ramOutAddr <= (addrOutMemCtrl) when (isFinishedCompressing = '0') else transmitAddr;
	isFinishedProcessing <= isFinishedCompressing;

end Behavioral;
