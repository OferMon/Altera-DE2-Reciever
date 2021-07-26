library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_unsigned.all ;

entity outpipe is

	port ( resetN    : in  std_logic 				    ;
		   clk 	     : in  std_logic 				    ;
		   ena_dout  : in  std_logic 				    ;
		   din	     : in  std_logic_vector(7 downto 0)	;	
		   dout 	 : out std_logic_vector(7 downto 0) ) ;
		   
end outpipe;

architecture arc_outpipe of outpipe is

begin

	process ( resetN, clk )
	
	begin
	
	   if resetN = '0' then
	      dout <= ( others => '0' ) ;
	   elsif rising_edge(clk) then
	      if ena_dout = '1' then
		     dout <= din ;
		  end if;
	   end if ;
	   
	end process ;
	
end arc_outpipe;