# Overview 

A simple implementation of a weight stationary systolic array multiplier. My goal for this project is to be able to run a useful neural net on my chip(whatever useful might mean). Due to the limited amount of space that I have, I will need to break up large matrices into many smaller ones. This will make my chip very slow. 


# Tapeout

My goal is to submit this to GFMPW-1. Otherwise, I will try to submit this to TinyTapeout.

# TODO

- [ ] Implement a state machine to handle data loading, processing, etc...
- [ ] Implement a block matrix multiplier
- [ ] Make a comprehensive testing suite for the multiplier and adder
- [ ] Make a comprehensive testing suite for the systolic array
- [ ] Think about the memory chache architecture
- [ ] Test on FPGA
- [ ] Add [Tinygrad](https://github.com/tinygrad/tinygrad) support???