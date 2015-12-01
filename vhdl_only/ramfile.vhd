----------------------------------------------------------------------------------
-- Company: Ruder Boskovic Institute
-- Engineer: Ivan Sovic
-- 
-- Create Date:    15:59:36 03/26/2014 
-- Design Name: 
-- Module Name:    ramfile - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
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
use std.textio.all;

entity ramfile is
	generic (RAM_SIZE : integer := 65536
				);
	port (clk  : in std_logic;
			we   : in std_logic;
			en   : in std_logic;
			addr : in std_logic_vector(15 downto 0);
			dataIn   : in std_logic_vector(7 downto 0);
			dataOut	: out std_logic_vector(7 downto 0));
end ramfile;



-- The following code will infer a Single port Block RAM and initialize it using a FILE

architecture Behavioral of ramfile is
    type ramtype is array(0 to (RAM_SIZE - 1)) of std_logic_vector(7 downto 0);    
    
	 impure function ramLoad (ram_file_name : in string) return ramtype is                                                   
       FILE ram_file      : text is in ram_file_name;                       
       variable line_name : line;
		 variable temp_bv   : bit_vector(7 downto 0);
       variable temp_ram  : ramtype;
    begin
		for I in ramtype'range loop
           readline (ram_file, line_name);
           read (line_name, temp_bv);
			  temp_ram(I) := to_stdlogicvector(temp_bv);
       end loop;
		 return temp_ram;
	 end function;

    signal RAM : ramtype := ramLoad("../data/lena256bw.txt");
	 
begin
    process (clk)                                                
    begin
		 if clk'event and clk = '1' then
			if EN = '1' then
				if WE = '1' then
					RAM(conv_integer(addr)) <= dataIn;
				end if;
				dataOut <= RAM(conv_integer(addr)) ;
			end if;     
       end if;                                                      
    end process;  

end Behavioral;

