tow_dir = fileparts(which(mfilename));
tow_datafile = fullfile(tow_dir, 'tow_data.mat');

if exist(tow_datafile, 'file')
    load(tow_datafile);
    
else
    [~,pix,xticks,yticks] = parse_img_by_color(fullfile(tow_dir, 'img', 'Fig1_marked.png'), 'g');
    tow_fig1_brain_weight = 0.5*10.^(0+(pix{2} - xticks{2}(1))./mean(diff(xticks{2})));
    tow_fig1_neuron_dens  = 3E3*10.^(0+(yticks{1}(end) - pix{1})./mean(diff(yticks{1})));
    
    vars = who('tow_*');
    save(tow_datafile, vars{:});
end;
