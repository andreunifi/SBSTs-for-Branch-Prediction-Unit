// -f sim.working/../netlist.f -> -f sim.working/0.f
-f sim.working/0.f
// +timescale+override+1ns/1ps -> -override_timescale=1ns/1ps
-override_timescale=1ns/1ps
// +top+wallypipelinedcore+strobe -> -top wallypipelinedcore+strobe
-top wallypipelinedcore+strobe
// +sv -> -sverilog
-sverilog
// +notimingchecks -> +notimingcheck
+notimingcheck
// +notimingchecks -> -zoix=notimingchecks
-zoix=notimingchecks
// +define+ZOIX -> +define+ZOIX
+define+ZOIX
// +define+TOPLEVEL=wallypipelinedcore -> +define+TOPLEVEL=wallypipelinedcore
+define+TOPLEVEL=wallypipelinedcore
// +suppress+cell -> -zoix=suppress+cell
-zoix=suppress+cell
// +delay_mode_fault -> -zoix=delay_mode_fault
-zoix=delay_mode_fault
// +verbose+undriven -> -zoix=verbose+undriven
-zoix=verbose+undriven
// -l zoix_compile.log -> -l zoix_compile.log
-l zoix_compile.log
//  -> -Xzoixdbg=0x200
-Xzoixdbg=0x200
// Default simulator name -> -o zoix.sim
-o zoix.sim
// Default csrc name -> -Mdir=sim.csrc
-Mdir=sim.csrc
//  -> -zoix=arglistfile+./sim.working/zoixarglist.txt
-zoix=arglistfile+./sim.working/zoixarglist.txt
