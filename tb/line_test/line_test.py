import cocotb

from cocotb.triggers import Timer

@cocotb.test()
async def test_straight_line(dut):
    input = (0,0,1,1)

    for i in range(4):
        dut.i_port.value = input[i]
        await Timer(1, 'ns')
        assert dut.o_port.value == input[i], f"Error at iteration {i}"

    pass