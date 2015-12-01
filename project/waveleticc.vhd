----------------------------------------------------------------------------------
-- Company: Ruder Boskovic Institute
-- Engineer: Ivan Sovic
-- 
-- Create Date:    15:19:12 08/19/2014 
-- Design Name: 
-- Module Name:    waveleticc - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: Wavelet Image Compression Component.
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

entity waveleticc is
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
end waveleticc;

architecture Behavioral of waveleticc is
	
	component controlunit is
		Generic (	IMAGE_WIDTH : integer := 256;
						IMAGE_HEIGHT : integer := 256;
						ADDR_WIDTH : integer := 16
					);
		Port (	clk : in  STD_LOGIC;
					reset : in STD_LOGIC;
					addrIn : out  STD_LOGIC_VECTOR ((ADDR_WIDTH - 1) downto 0);
					enRamIn: out STD_LOGIC;
					resetFifoRow : out STD_LOGIC;
					weFifoRow : out STD_LOGIC;
					resetFifoColumn : out STD_LOGIC;
					weFifoColumn : out STD_LOGIC;
					isFinishedProcessing : out STD_LOGIC;
					rowReady : out STD_LOGIC;
					columnReady : out STD_LOGIC;
					readyForNextData : in STD_LOGIC
				);
	end component;
	
	component haarlp is
    Port ( x0 : in  std_logic_vector(7 downto 0);
			  x1 : in  std_logic_vector(7 downto 0);
           y : out std_logic_vector(7 downto 0));
	end component;
	
	component haarhp is
    Port ( x0 : in  std_logic_vector(7 downto 0);
			  x1 : in  std_logic_vector(7 downto 0);
           y : out std_logic_vector(7 downto 0));
	end component;
	
	component fifomem is
		 generic (
			  DATA_WIDTH: natural := 8;			-- Width of a single data register (i.e. a byte).
			  FIFO_DEPTH: natural := 2				-- Number of data registers in the FIFO memory (i.e. the width of the image + 1).
		 );
		 port (
			  clk: in std_logic;
			  reset: in std_logic;
			  we: in std_logic;
			  dataIn: in std_logic_vector((DATA_WIDTH - 1) downto 0);
			  dataOutFirst: out std_logic_vector((DATA_WIDTH - 1) downto 0);
			  dataOutLast: out std_logic_vector((DATA_WIDTH - 1) downto 0)
		 );
	end component;
	
	component memcontroler is
		Generic	(	THRESHOLD : integer := 10;
						DATA_WIDTH : integer := 8;
						ADDR_WIDTH : integer := 16;
						IMAGE_WIDTH : integer := 256;
						IMAGE_HEIGHT : integer := 256
					);
		Port	(	
					clk : in STD_LOGIC;
					en : in STD_LOGIC;
					reset : in  STD_LOGIC;
					
					inLL : in STD_LOGIC_VECTOR((DATA_WIDTH - 1) downto 0);
					inLH : in STD_LOGIC_VECTOR((DATA_WIDTH - 1) downto 0);
					inHL : in STD_LOGIC_VECTOR((DATA_WIDTH - 1) downto 0);
					inHH : in STD_LOGIC_VECTOR((DATA_WIDTH - 1) downto 0);
					
					rowReady : in STD_LOGIC;
					columnReady : in STD_LOGIC;
					
					address : out STD_LOGIC_VECTOR((ADDR_WIDTH - 1) downto 0);
					dataOut : out STD_LOGIC_VECTOR((DATA_WIDTH - 1) downto 0);
					dataIn : in STD_LOGIC_VECTOR((DATA_WIDTH - 1) downto 0);
					weOut : out STD_LOGIC;
					
					compressedDataSize : out STD_LOGIC_VECTOR((ADDR_WIDTH - 1) downto 0);
					
					cuFinishedProcessing : in STD_LOGIC;
					finishedCompressing : out STD_LOGIC;

					readyForNextData : out STD_LOGIC
				);
	end component;

	signal resetFifoRow : STD_LOGIC := '0';
	signal weFifoRow : STD_LOGIC := '0';
	signal resetFifoColumn : STD_LOGIC := '0';
	signal weFifoColumn : STD_LOGIC := '0';
	
	signal x0 : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
	signal x1 : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
	signal xL0 : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
	signal xL1 : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
	signal xH0 : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
	signal xH1 : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
	signal y0L : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
	signal y0H : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
	signal yLL : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
	signal yLH : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
	signal yHL : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
	signal yHH : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
	
	signal cuIsFinishedProcessing : STD_LOGIC := '0';
	signal sigCompressedDataSize : STD_LOGIC_VECTOR((ADDR_WIDTH - 1) downto 0);
	signal sigIsFinishedCompressing : STD_LOGIC := '0';
	signal rowReady, columnReady, readyForNextData : STD_LOGIC := '0';

begin
	cu: component controlunit	generic map (	IMAGE_WIDTH => IMAGE_WIDTH,
														IMAGE_HEIGHT => IMAGE_HEIGHT,
														ADDR_WIDTH => ADDR_WIDTH)
									port map (	clk => clk,
													reset => reset,
													addrIn => ramInAddr,
													enRamIn => ramInEn,
													resetFifoRow => resetFifoRow,
													weFifoRow => weFifoRow,
													resetFifoColumn => resetFifoColumn,
													weFifoColumn => weFifoColumn,
													isFinishedProcessing => cuIsFinishedProcessing,
													rowReady => rowReady,
													columnReady => columnReady,
													readyForNextData => readyForNextData);
														
	fifoRow: component fifomem	generic map (	DATA_WIDTH => 8,
															FIFO_DEPTH => 2)
										port map		(	clk => clk,
															reset => resetFifoRow,
															we => weFifoRow,
															dataIn => ramInData,
															dataOutFirst => x0,
															dataOutLast => x1);
															
	fifoColumnW: component fifomem	generic map (	DATA_WIDTH => 8,
																	FIFO_DEPTH => (IMAGE_WIDTH + 1))
												port map		(	clk => clk,
																	reset => resetFifoColumn,
																	we => weFifoColumn,
																	dataIn => y0L,
																	dataOutFirst => xL0,
																	dataOutLast => xL1);
																
	fifoColumnH: component fifomem	generic map (	DATA_WIDTH => 8,
																	FIFO_DEPTH => (IMAGE_WIDTH + 1))
												port map		(	clk => clk,
																	reset => resetFifoColumn,
																	we => weFifoColumn,
																	dataIn => y0H,
																	dataOutFirst => xH0,
																	dataOutLast => xH1);
															
	W0L: component haarlp port map (	x0 => x0,
												x1 => x1,
												y => y0L);
												
	WLL: component haarlp port map (	x0 => xL0,
												x1 => xL1,
												y => yLL);
												
	WLH: component haarhp port map (	x0 => xL0,
												x1 => xL1,
												y => yLH);
												
												
	W0H: component haarhp port map (	x0 => x0,
												x1 => x1,
												y => y0H);
												
	WHL: component haarlp port map (	x0 => xH0,
												x1 => xH1,
												y => yHL);
												
	WHH: component haarhp port map (	x0 => xH0,
												x1 => xH1,
												y => yHH);

	compressor: component memcontroler generic map	(	THRESHOLD => 10,
																DATA_WIDTH => 8,
																ADDR_WIDTH => 16,
																IMAGE_WIDTH => 256,
																IMAGE_HEIGHT => 256)
											port map		(	clk => clk,
																en => '1',
																reset => reset,
																inLL => yLL,
																inLH => yLH,
																inHL => yHL,
																inHH => yHH,
																rowReady => rowReady,
																columnReady => columnReady,
																address => ramOutAddr,
																dataOut => ramOutDataIn,
																dataIn => ramOutDataOut,
																weOut => ramOutWe,
																compressedDataSize => sigCompressedDataSize,
																cuFinishedProcessing => cuIsFinishedProcessing,
																finishedCompressing => sigIsFinishedCompressing,
																readyForNextData => readyForNextData);


	isFinishedCompressing <= sigIsFinishedCompressing;
	compressedDataSize <= sigCompressedDataSize when (sigIsFinishedCompressing = '1') else (others => '0');

end Behavioral;
