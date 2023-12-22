How does this chip work?


For now, this is nothing more than a matrix multiplier. Keep in mind that we can not load a full matrix into the chip at once, so we have to load it in pieces. The pieces that we load are further sliced into smaller pieces using block_get module. They two pieces are multiplied using the block.v module, and the results are accumulated using the block_add. 