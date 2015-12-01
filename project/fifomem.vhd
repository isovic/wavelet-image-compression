----------------------------------------------------------------------------------
-- Company: Ruder Boskovic Institute
-- Engineer: Ivan Sovic
-- 
-- Create Date:    23:35:22 07/28/2014 
-- Design Name: 
-- Module Name:    fifomem - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: Implementation of an n-bit shift register, which provides output of the first and last element in the chain. Synthesis will produce distributed RAM.
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

entity fifomem is
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
end fifomem;

architecture RTL of fifomem is
	type ramtype is array(0 to (FIFO_DEPTH - 1)) of std_logic_vector((DATA_WIDTH - 1) downto 0);    

	signal RAM : ramtype := (others => (others => '0'));

begin
	process (clk, reset)
	begin
		if reset = '1' then
			RAM <= (others => (others => '0'));
		elsif rising_edge(clk) then
			if we = '1' then
				RAM <= dataIn & RAM(0 to (FIFO_DEPTH - 2));
			end if;
		end if;
	end process;
	
	dataOutFirst <= RAM(0);
	dataOutLast <= RAM(FIFO_DEPTH - 1);
end RTL;
