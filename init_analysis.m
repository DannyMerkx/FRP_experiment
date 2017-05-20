function init_analysis

global code_root; code_root = '\\DISKSTATION\Danny\Documents\Studie\KI\Scriptie\bci_code.git'; %root directory for code
global data_root; data_root = '\\DISKSTATION\Danny\Documents\Studie\KI\Scriptie\bci_code.git'; %root directory for data

warning off;

%Add standard paths
cd(fullfile(code_root,'own_experiments','visual','neglect_project','Common','analysis'));
fprintf('Adding common functions from %s...\n',pwd);
setpaths(code_root,'jf_bci','fieldtrip','classification','buffer_bci');
addpath(genpath(pwd));

%add paths for this specific experiment
disp('Adding eyelink code...');
addpath(fullfile(code_root,'toolboxes','brainstream','resources','devices','eyelink'));
fld = fullfile(code_root,'own_experiments','visual','neglect_project','FRP_recancellation','analysis');
fprintf('Adding own functions from %s...\n',fld);
addpath(genpath(fld));
cd(fld);

warning on;


