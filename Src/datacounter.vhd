library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_unsigned.all ;

entity datacounter is

	port ( resetN     : in    std_logic 				   ;
		   clk 	      : in    std_logic 				   ;
		   ena_dcount : in    std_logic                    ;
	       clr_dcount : in    std_logic                    ;
	       eoc        : out   std_logic                    ;
		   dcount     : inout std_logic_vector(2 downto 0) ) ;
		   
end datacounter;

architecture arc_datacounter of datacounter is

begin

	process ( resetN, clk )
	
	begin
	
		if resetN = '0' then
		   dcount <= ( others => '0' ) ;
		elsif rising_edge(clk) then
		   if clr_dcount = '1' then
		      dcount <= ( others => '0' ) ;
		   elsif ena_dcount = '1' then
		      dcount <= dcount + 1;
		   end if ;
		end if ;
		
	end process;
	
	eoc <= '1' when ( dcount = "111" ) else '0' ;
	
end arc_datacounter;