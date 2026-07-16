## Sequential Logic Plus SPI peripheral


Mostly some work to practise sequential logic, some Hardware thinking and 
all builds up into an SPI peripheral that we could reuse down the line. 

### Interesting Parts 

The edge detector in the top level took 2 hours to figure out, one needs to 
consider the states of the various signals and understand what the circuit 
will do at what time. 


### Realizations 
Perhaps this would have been fixed way faster if I knew how to cosimulate with 
COCOTB, mocking the other modules could have shown a waveform that would have
made this quite simple to fix
