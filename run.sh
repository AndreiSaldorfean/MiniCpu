if [ "$1" = "c" ]; then
    if [ ! -d build ]; then
        mkdir build
    fi
    ghdl -a src/alu.vhd
    ghdl -a src/alu_tb.vhd
    ghdl -e alu_entity_tb
    ghdl -r alu_entity_tb --vcd=build/alu_tb.vcd
else
    gtkwave build/alu_tb.vcd
fi