library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_unsigned.all ;

entity inpipe is

	port ( resetN    : in    std_logic 				      ;
		   clk 	     : in    std_logic 				      ;
		   ena_shift : in    std_logic 				      ;
		   din	     : in    std_logic                    ;
		   dint 	 : inout std_logic_vector(7 downto 0) ) ;
		   
end inpipe;

architecture arc_inpipe of inpipe is

begin

	process ( resetN, clk )
	
	begin
	
	   if resetN = '0' then
	      dint <= ( others => '0' ) ;
	   elsif rising_edge(clk) then
		  if ena_shift = '1' then
		     dint <= din & dint( 7 downto 1 ) ;
		  end if ;
	   end if ;
	   
	end process ;
	
end arc_inpipe;