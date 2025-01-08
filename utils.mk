circuit="code"
test_bench=$(circuit)_tb

all:

#-a analyze
#-e elaborate
#-r run

	ghdl -a $(circuit).vhd
	ghdl -a $(test_bench).vhd
	ghdl -e $(test_bench)
	ghdl -r $(test_bench) --vcd=$(circuit).vcd
	rm *.cf
	gtkwave $(circuit).vcd