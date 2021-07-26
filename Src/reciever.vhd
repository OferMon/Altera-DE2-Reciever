package uart_constants is

   constant clockfreq  : integer := 25000000 ;
   constant baud       : integer := 115200   ;
   constant t1_count   : integer := clockfreq / baud ; -- 217
   constant t2_count   : integer := t1_count / 2     ; -- 108

end uart_constants ;

-------------------------------------------------------------------------------------

use work.uart_constants.all ;
library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_unsigned.all ;

entity reciever is

    port ( resetN     : in  std_logic                    ;
           clk        : in  std_logic                    ;
           rx         : in  std_logic                    ;
           read_dout  : in  std_logic                    ;
           rx_ready   : out std_logic                    ;
           dout_new   : out std_logic                    ;
           dout_ready : out std_logic                    ;
		   dout       : out std_logic_vector(7 downto 0) ) ;
		   
end reciever ;

architecture arc_reciever of reciever is

   component timer is
   
        port ( resetN : in    std_logic 					  ;
   		       clk 	  : in    std_logic 					  ;
   		       te     : in    std_logic 					  ;
   		       t1     : out   std_logic 					  ;
   		       t2     : out   std_logic 					  ;
   		       tcount : inout std_logic_vector ( 8 downto 0 ) ) ;
   		   
   end component timer ;
   
   component inpipe is

	    port ( resetN    : in    std_logic 				      ;
	    	   clk 	     : in    std_logic 				      ;
	    	   ena_shift : in    std_logic 				      ;
	    	   din	     : in    std_logic					  ;
	    	   dint 	 : inout std_logic_vector(7 downto 0) ) ;
		   
   end component inpipe;
   
   component outpipe is

	    port ( resetN   : in  std_logic 				   ;
	    	   clk 	    : in  std_logic 				   ;
			   ena_dout : in  std_logic 				   ;
	    	   din	    : in  std_logic_vector(7 downto 0) ;
	    	   dout 	: out std_logic_vector(7 downto 0) ) ;
		   
   end component outpipe;
   
   component dffx is

	    port ( resetN : in  std_logic ;
	    	   clk 	  : in  std_logic ;
	    	   rx     : in  std_logic ;
	    	   rxs    : out std_logic ) ;
		   
   end component dffx;
   
   component srffx is

	    port ( resetN : in  std_logic ;
	    	   clk 	  : in  std_logic ;
	    	   s 	  : in  std_logic ;
	    	   r      : in  std_logic ;
	    	   q      : out std_logic ) ;
		   
   end component srffx;
   
   component datacounter is

	    port ( resetN     : in    std_logic 				   ;
	    	   clk 	      : in    std_logic 				   ;
	    	   ena_dcount : in    std_logic                    ;
	           clr_dcount : in    std_logic                    ;
	           eoc        : out   std_logic                    ;
	    	   dcount     : inout std_logic_vector(2 downto 0) ) ;
		   
   end component datacounter;
   
   -- timer            floor(log2(t1_count)) downto 0
   signal tcount : std_logic_vector(8 downto 0) ;
   signal te     : std_logic ; -- Timer_Enable/!reset
   signal t1     : std_logic ; -- end of one time slot
   signal t2     : std_logic ; -- half of one time slot

   -- data counter
   signal dcount     : std_logic_vector(2 downto 0) ; -- data counter
   signal ena_dcount : std_logic                    ; -- enable this counter
   signal clr_dcount : std_logic                    ; -- clear this counter
   signal eoc        : std_logic                    ; -- end of count (7)

   -- internal shift register
   signal dint      : std_logic_vector(7 downto 0) ;
   signal ena_shift : std_logic                    ; -- enable shift register
   
   -- output register
   signal ena_dout  : std_logic                    ; -- enable shift register
   
   -- input flip-flop
   signal rxs  : std_logic                    ; -- enable shift register

  -- state machine
   type state is
   ( idle       ,
     start_wait ,
     start_chk  ,
     data_wait  ,
     data_chk   ,
     data_count ,
     stop_chk   ,
     update_out ,
     tell_out   ,
     break_wait ,
     stop_wait  ) ;

    signal present_state , next_state : state ;

begin

   -------------------
   -- state machine --
   -------------------
   process ( clk , resetN )
   
   begin
     
      if resetN = '0' then
	     present_state <= idle ;
      elsif rising_edge(clk) then
	     present_state <= next_state ;
	  end if ;
	  
   end process ;
   
   process ( present_state, rxs , t1, t2, eoc )
   
   begin
   
   rx_ready   <= '0' ;
   te         <= '0' ;
   ena_dcount <= '0' ;
   clr_dcount <= '0' ;
   ena_shift  <= '0' ;
   ena_dout   <= '0' ;
   dout_new   <= '0' ;
   
   next_state <= idle ;
   
   case present_state is
   
      when idle =>
	  
	     rx_ready <= '1' ;
		 clr_dcount <= '1' ;
	     if rxs = '0' then
		    next_state <= start_wait ;
		 else
		    next_state <= idle ;
		 end if ;
			
	  when start_wait =>
	     
		 te <= '1' ;
		 if t2 = '1' then
		    next_state <= start_chk ;
		 elsif t2 = '0' then
		    next_state <= start_wait ;
		 else
		    next_state <= idle ;
		 end if ;
			
	  when start_chk =>
	     
		 if rxs = '0' then
		    next_state <= data_wait ;
		 else
		    next_state <= idle ;
		 end if ;

      when data_wait =>
	     
		 te <= '1' ;
		 if t1 = '1' then
		    next_state <= data_chk ;
		 elsif t1 = '0' then
		    next_state <= data_wait ;
		 else
		    next_state <= idle ;
		 end if ;
		
	  when data_chk =>
	     
		 ena_shift <= '1' ;
		 if eoc = '1' then
		    next_state <= stop_wait ;
		 elsif eoc = '0' then
		    next_state <= data_count ;
		 else
		    next_state <= idle ;
		 end if ;
			
	  when data_count =>
	     
		 ena_dcount <= '1' ;
		 next_state <= data_wait ;
		 
	  when stop_wait =>
	     
		 te <= '1' ;
         if t1 = '1' then
		    next_state <= stop_chk ;
		 elsif t1 = '0' then
		    next_state <= stop_wait ;
		 else
		    next_state <= idle ;
		 end if ;
		 
	  when stop_chk =>
	     
         if rxs = '1' then
		    next_state <= update_out ;
		 elsif rxs = '0' then
		    next_state <= break_wait ;
		 else
		    next_state <= idle ;
		 end if ;
		 
	  when break_wait =>
	     
         if rxs = '0' then
		    next_state <= break_wait ;
		 else
		    next_state <= idle ;
		 end if ;
			 
	  when update_out =>
	     
		 ena_dout <= '1' ;
		 next_state <= tell_out ;
	
	  when tell_out =>
	     
		 dout_new <= '1' ;
		 next_state <= idle ;
		 
	  when others =>
		
		 next_state <= idle ;
		 
	end case ;
   
   end process ;
   
   -----------
   -- timer --
   -----------
   u0: timer
       port map(resetN, clk, te, t1, t2, tcount) ;
	   
   ------------------
   -- data counter --
   ------------------
   u1: datacounter
       port map(resetN, clk, ena_dcount, clr_dcount, eoc, dcount) ;

   --------------------
   -- internal shift register --
   --------------------
   u2: inpipe
       port map(resetN, clk, ena_shift, rxs, dint) ;
	   
   --------------------
   -- out shift register --
   --------------------
   u3: outpipe
       port map(resetN, clk, ena_dout, dint, dout) ;
	   	
   ----------------------
   -- output flip-flop --
   ----------------------
   u4: srffx
       port map(resetN, clk, ena_dout, read_dout, dout_ready) ;  

   ----------------------
   -- input flip-flop --
   ----------------------
   u5: dffx
       port map(resetN, clk, rx, rxs) ;

end arc_reciever ;