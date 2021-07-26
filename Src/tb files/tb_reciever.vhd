library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_unsigned.all ;

entity tb_reciever is

end tb_reciever ;

architecture arc_tb_reciever of tb_reciever is

   component reciever
   
        port ( resetN     : in  std_logic                    ;
               clk        : in  std_logic                    ;
               rx         : in  std_logic                    ;
               read_dout  : in  std_logic                    ;
               rx_ready   : out std_logic                    ;
               dout_new   : out std_logic                    ;
			   dout_ready : out std_logic                    ;
			   dout       : out std_logic_vector(7 downto 0) ) ;
			 
   end component ;
   
   signal resetN     : std_logic ; -- actual resetN (active low)
   signal clk        : std_logic ; -- actual clock
   signal rx         : std_logic ; -- actual send enable
   signal dout_new   : std_logic ; -- actual send enable
   signal dout_ready : std_logic ; -- actual send enable
   signal read_dout  : std_logic ; -- actual parallel in
   signal rx_ready   : std_logic ; -- from hardware transmitter to receiver
   signal dout       : std_logic_vector(7 downto 0) ; -- int Parallel output
   
begin 

   -- reciever instantiation (named association)
   eut: reciever
        port map ( resetN     => resetN     ,
                   clk        => clk        ,
                   rx         => rx         ,
                   read_dout  => read_dout  ,
                   rx_ready   => rx_ready   ,
                   dout_new   => dout_new   ,
				   dout_ready => dout_ready ,
				   dout       => dout       ) ;
				   
   -- Clock process (50 MHz)
   process
   
   begin
   
      clk <= '0' ;  wait for 20 ns ;
      clk <= '1' ;  wait for 20 ns ;
	  
   end process ;   
   
   -- Active low reset pulse
   resetN <= '0' , '1' after 40 ns ;

   -- reciever activation & test vectors process
   process
      
	  constant baud : real := 115200.0 ;
	  constant dt   : time := 1 sec * (1.0 / baud) ;
      variable d    : std_logic_vector(7 downto 0) ;
	  
   begin
   
      -- wait for end of async reset
      -- din <= "XXXXXXXX" ; write_din <= '0' ;  
      wait for 40 ns ;
	  
      -----------------------------------------  vector 1
      report "recieving the H character (01001000b=48h=72d)" ; 
      read_dout <= '0' ;
	  d := "00000000" + character'pos('H') ;
	  rx <= '1' ; wait for dt ;
	  rx <= '0' ; wait for dt ;
	  for i in 0 to 7 loop
	     rx <= d(i) ; wait for dt ;
	  end loop ;
	  rx <= '1' ; wait for dt ;
	  wait for 100 us;
	  read_dout <= '1' ; wait for dt;
      assert d = dout report "bad transmission #1" severity error ;
	  
      -----------------------------------------  vector 2   
	  report "recieving the H character (01001000b=48h=72d)" ; 	  
	  read_dout <= '0' ;	  
      d := "00000000" + character'pos('i') ;
	  rx <= '0' ; wait for dt ;
	  for i in 0 to 7 loop
	     rx <= d(i) ; wait for dt ;
	  end loop ;
	  rx <= '1' ; wait for dt ;
	  wait for 100 us; 
	  assert d = dout report "bad transmission #2" severity error ;
	  
      -----------------------------------------  vector 3
	  report "sending the CR character (00001101=0Dh=13d)" ; 
      d := "00000000" + character'pos(CR) ;  
	  rx <= '0' ; wait for dt ;
	  for i in 0 to 7 loop
	     rx <= d(i) ; wait for dt ;
	  end loop ;
	  rx <= '0' ; wait for dt ;
	  wait for 50 us; 
	  
      -----------------------------------------  vector 4
	  report "testing short start pulse" ;
	  d := "00000000" + character'pos(LF) ;
      rx <= '1' ; wait for dt ;
      rx <= '0' ; wait for dt/4 ;
      rx <= '1' ; wait for dt ;
	  wait for 100 us; 
	  assert dout /= "00000000" report "bad transmission #4" severity error ;
	  
      -----------------------------------------      
      assert false report "end of test vectors" severity note ;
      wait ;
	  
   end process ;
   
end arc_tb_reciever ;
        