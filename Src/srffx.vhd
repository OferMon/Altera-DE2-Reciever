library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_unsigned.all ;

entity srffx is

	port ( resetN : in  std_logic ;
		   clk 	  : in  std_logic ;
		   s 	  : in  std_logic ;
		   r      : in  std_logic ;	   
		   q      : out std_logic ) ;	
		   
end srffx;

architecture arc_srffx of srffx is

begin

	process ( resetN, clk )
	
	begin
	
		if resetN = '0' then
		   q <= '0' ;
		elsif rising_edge(clk) then
		   if s = '1' then
			  q <= '1' ;
		   elsif r = '1' then
		      q <= '0' ;
		   end if ;
		end if ;
		
	end process;
	
end arc_srffx;