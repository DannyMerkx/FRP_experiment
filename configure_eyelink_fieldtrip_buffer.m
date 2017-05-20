bs_addpath();
% read eyelink specific blocksettings
bs=bs_get_blockvalue('srresearch_eyelink1000.blk');
% make them persistent in bs_get_blockvalue function
bs_get_blockvalue(bs);

device = 'srresearch_eyelink1000';
url = 'buffer://localhost:1971';
reference = 'eyelink';
outputfilename = []; % generated based on date and time
% just to pass BS stuff
dsprops.eyelink.reference = reference;
propDataSource(dsprops,'set');

% configure eyelink streaming to fieldtrip buffer
configureFieldtripBuffer(device,url,reference,outputfilename)
