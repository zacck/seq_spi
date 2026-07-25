import cocotb 
import os 
import random 
import sys 
from math import log 
import logging 
from pathlib import Path 
from cocotb.clock import Clock 
from cocotb.triggers import Timer, ClockCycles, RisingEdge, FallingEdge, ReadOnly
from cocotb.utils import get_sim_time as gst 
from cocotb.runner import get_runner
test_file = os.path.basename(__file__).replace(".py", "")

@cocotb.test()
async def test_a(dut):
    """a cocotb test for the spi top"""
    dut._log.info("Starting...")
    cocotb.start_soon(Clock(dut.clk_100mhz, 10, units="ns").start())
    dut._log.info("Holding Reset ...")
    dut.sys_rst.value = 1
    await ClockCycles(dut.clk_100mhz, 3)
    await FallingEdge(dut.clk_100mhz)
    dut._log.info("Setting reset to 0")
    dut.sys_rst.value = 0
    await ClockCycles(dut.clk_100mhz, 3000)
    

def spi_top_runner():
    """ Simulate the top using the python runner."""
    hdl_toplevel_lang = os.getenv("HDL_TOPLEVEL_LANG", "verilog")
    sim = os.getenv("SIM", "verilator")
    proj_path  = Path(__file__).resolve().parent.parent
    sys.path.append(str(proj_path / "sim" / "model"))
    sources = [proj_path / "hdl" / "top_level.sv"]
    sources += [proj_path / "hdl" / "bto7s.sv" ]
    sources += [proj_path / "hdl" / "counter.sv" ]
    sources += [proj_path / "hdl" / "debounce.sv" ]
    sources += [proj_path / "hdl" / "evt_counter.sv" ]
    sources += [proj_path / "hdl" / "pwm.sv" ]
    sources += [proj_path / "hdl" / "rgb_controller.sv" ]
    sources += [proj_path / "hdl" / "seven_segment_controller.sv" ]
    sources += [proj_path / "hdl" / "spi_con.sv" ]
    build_test_args = ["-Wall"]
    parameters = {'ADC_READ_PERIOD':20, 'ADC_DATA_WIDTH': 17, 'ADC_DATA_CLK_PERIOD':10}
    sys.path.append(str(proj_path / "sim"))
    hdl_toplevel = "top_level"
    runner = get_runner(sim)
    runner.build(
            sources=sources,
            hdl_toplevel=hdl_toplevel, 
            always=True, 
            build_args=build_test_args, 
            parameters=parameters, 
            timescale=('1ns','1ps'),
            waves=True
    )
    run_test_args = []
    runner.test(
            hdl_toplevel=hdl_toplevel,
            test_module=test_file, 
            test_args=run_test_args,
            waves=True
    )

if __name__== "__main__":
    spi_top_runner()

