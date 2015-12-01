----------------------------------------------------------------------------------
-- Company: Ruder Boskovic Institute
-- Engineer: Ivan Sovic
-- 
-- Create Date:    10:50:14 03/27/2014 
-- Design Name: 
-- Module Name:    haarhp - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: Haar high-pass wavelet filter.
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

entity haarhp is
    Port ( x0 : in  std_logic_vector(7 downto 0);
			  x1 : in  std_logic_vector(7 downto 0);
           y : out std_logic_vector(7 downto 0));
end haarhp;

architecture Behavioral of haarhp is

begin
	y <= std_logic_vector(to_unsigned(((conv_integer(x0) - conv_integer(x1)) / 2), 8));
end Behavioral;
