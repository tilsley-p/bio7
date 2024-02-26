savelog.choice = input('save new design? yes (1), no(0)? : ');

if savelog.choice == 1
    savelog.date = date;
    savelog.acq_choice = input('save as acq-MRI (1) or acq-test(0)? : ');

    if savelog.acq_choice == 1
        savelog.name = 'execution/task-faces_acq-MRI_design.mat';
    elseif savelog.acq_choice == 0
        savelog.name = 'execution/task-faces_acq-test_design.mat';
    end

    if isfile(savelog.name)
        savelog.archive_choice = input('experiment design already exists, archive old design? yes (1), no(0): ');

        if savelog.archive_choice == 1
            savelog.archived_file = char(['archive/' (savelog.name(11:end-4)) '_' date '.mat']);
            movefile(savelog.name,string(savelog.archived_file));
        else
        end
    else    
    end
    save(savelog.name);
else
    disp('run save_design when ready to save')
end