## Sequential Logic Plus SPI peripheral


Mostly some work to practise sequential logic, some Hardware thinking and 
all builds up into an SPI peripheral that we could reuse down the line. 

### Interesting Parts 

The edge detector in the top level took 2 hours to figure out, one needs to 
consider the states of the various signals and understand what the circuit 
will do at what time. 

Added a seven segment controller for the digits on the board, at first this appeared 
difficult as you are handed a 32 bits of input and you need to use them in 4 bit parts
simple in implementation but a tad hard to think of a software dud


Implemented a SPI Controller Peripheral 
Interestingly this one was simple, I had to be careful with how I was using my dclk signal.
This really helped my intuition with doing things in parallel, plus doing some math in verilog 
bitwise integer division is feeling good and we can send messages to and fro.

### Realizations 
Perhaps this would have been fixed way faster if I knew how to cosimulate with 
COCOTB, mocking the other modules could have shown a waveform that would have
made this quite simple to fix

The new seven segment controller sort of introduces cosimulation, how to do assertions and 
where to do them should be the next thing to learn.

The modules are getting to a complexity where It would be advantageous to have a formal verification
test prior to running the application.
Additionally I do like this separation of verification and synthesization code


My SPI test seems to be a little broken I send a different value from the one I am observing it could 
be the bitshifting in the test that is breaking the value, however the value I send it the one I see in data_in 
so this works for now.


I notice that I am reusing a lot of my modules from my previous projects, I wonder if I can build a library of modules
such a way that I can have it included in the folder and since synth only builds the modules pulled into the top level 
we can have them be used as needed?

