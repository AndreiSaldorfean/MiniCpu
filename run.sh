if [ "$1" = "c" ]; then
    if [ ! -d build ]; then
        mkdir build
    fi
    ghdl -a src/cpu.vhd
    ghdl -a src/cpu_tb.vhd
    ghdl -e cpu_entity_tb
    ghdl -r cpu_entity_tb --vcd=build/cpu_tb.vcd
    mv *.cf build
else
    gtkwave build/cpu_tb.vcd
fi
