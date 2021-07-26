library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_unsigned.all ;

entity dffx is

	port ( resetN : in  std_logic ;
		   clk 	  : in  std_logic ;
		   rx     : in  std_logic ;
	       rxs    : out std_logic ) ;
		   
end dffx;

architecture arc_dffx of dffx is

begin

	process ( resetN, clk )
	
	begin
	
		if resetN = '0' then
		   rxs <= '1' ;
		elsif rising_edge(clk) then
		   rxs <= rx ;
		end if ;
		
	end process;
	
end arc_dffx;