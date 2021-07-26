transcript off
echo "------- START OF MACRO -------"
onerror abort

vcom reciever.vhd
vcom tb_reciever.vhd
vsim tb_reciever

restart -force
noview *

add wave resetN
add wave clk
add wave rx        
add wave read_dout 
add wave rx_ready  
add wave dout_new  
add wave dout_ready
add wave dout      
add wave                 /tb_reciever/eut/present_state
add wave                 /tb_reciever/eut/clr_dcount
add wave                 /tb_reciever/eut/ena_dcount
add wave -radix unsigned /tb_reciever/eut/dcount
add wave                 /tb_reciever/eut/eoc
add wave                 /tb_reciever/eut/te
add wave -radix unsigned /tb_reciever/eut/tcount
add wave                 /tb_reciever/eut/t1
add wave                 /tb_reciever/eut/t2
add wave                 /tb_reciever/eut/rxs
add wave                 /tb_reciever/eut/ena_shift
add wave                 /tb_reciever/eut/ena_dout
add wave                 /tb_reciever/eut/dint
add wave                 dout
add wave -radix ascii    dout

run 650000 ns

wave zoomfull
echo "------- END OF MACRO -------"
echo "The time now is $now [ string trim $resolution 01 ] "