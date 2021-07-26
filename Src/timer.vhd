use work.uart_constants.all ;
library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_unsigned.all ;

entity timer is

    port ( resetN : in    std_logic 					  ;
		   clk 	  : in    std_logic 					  ;
		   te     : in    std_logic 					  ;
		   t1     : out   std_logic 					  ;
		   t2     : out   std_logic 					  ;
		   tcount : inout std_logic_vector ( 8 downto 0 ) ) ;
		   
end timer ;

architecture arc_timer of timer is
   
begin

   process ( clk , resetN )
   
   begin
   
      if resetN = '0' then
	     tcount <= ( others => '0' ) ;
      elsif rising_edge(clk) then
	     if te = '1' then
		    if tcount /= t1_count then
			   tcount <= tcount + 1 ;
			end if ;
		 else
		    tcount <= ( others => '0' ) ;
		 end if ;
	  end if ;
	  
   end process ;
   
   t1 <= '1' when ( t1_count <= tcount ) else '0' ;
   t2 <= '1' when ( t2_count = tcount ) else '0' ;
   
end arc_timer ;