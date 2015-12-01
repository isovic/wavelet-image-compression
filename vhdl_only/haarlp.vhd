----------------------------------------------------------------------------------
-- Company: Ruder Boskovic Institute
-- Engineer: Ivan Sovic
-- 
-- Create Date:    15:00:42 03/27/2014 
-- Design Name: 
-- Module Name:    haarlp - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: Haar low-pass wavelet filter.
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
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity haarlp is
    Port ( x0 : in  std_logic_vector(7 downto 0);
			  x1 : in  std_logic_vector(7 downto 0);
           y : out std_logic_vector(7 downto 0));
end haarlp;

architecture Behavioral of haarlp is

begin
	y <= std_logic_vector(to_unsigned(((conv_integer(x0) + conv_integer(x1)) / 2), 8));
end Behavioral;

