function gameMPG()
    
    version = '1.1';
    
    % Main figure for game
    
    player = [];
    player.name = [];
    player.colorfill = [];
    player.colorborder = [];
    player.hp = []; % Ranges from 0 (Dead) - 100 (Healthy)
    player.stma = []; % Ranges form 0 (Exhusted) - 30 (Energized)
    player.xp = []; % Currency within the game
    player.pos = []; % Player position on the map
    player.speed = [];
    
    game = [];
    game.time = []; % Time since beginning of game
    game.fps = []; % Framerate of figure
    game.running = []; % Terminates the run loop when zero
    game.mapx = []; % Width of the map
    game.mapy = []; % Height of the map
   
    ent(1) = struct('type','init','posx',0,'posy',0,'hp',0); % All world entities are stored in this var
    
    disp('----------------------------------');
    fprintf('Matlab Roleplaying Game (ver %s)\n',version)
    disp('©2017 Wyatt Phillips');
    disp('----------------------------------');
    
    % Load save if present
    if exist('game.mat', 'file')
        load('game.mat');
    else
        player.name = input('Please enter a nickname: ','s');
        
        disp('Enter a character color in the following format');
        disp('[x,x,x] - Red(0-1) Green(0-1) Blue(0-1)');
        disp('Red    >> [1,0,0]');
        disp('Blue   >> [0,0,1]');
        disp('Yellow >> [1,1,0]');
        player.colorfill = input('Fill Color: '); % -! Add check for valid matrix.
        player.colorborder = input('Border Color: '); % -! Add check for valid matrix.
        
        % Generating Game
        game.mapx = 128;
        game.mapy = 128;
        
        % Create Claracter
        player.hp = 100;
        player.stma = 30;
        player.xp = 0;
        player.pos = [70,25];
        player.speed = 2;
        
        %Generate Starting Entities
        for i = 1:5
            for j = 1:4
            ent = spawnCoin20(32+(16*i),110-(16*j),ent);
            end
        end
        ent = spawnCoin50(105,110,ent);
    end
    
    run(game,player,ent,version);
    
end

function run(game,player,ent,version)

    def_game = game;
    def_player = player;
    def_ent = ent;
    
    text = strcat(['MATLAB RPG (ver ',version,')']);
    win = figure('Name',text);
    game.running = 1;
    
    % Run Main Loop
    
    [win,game,player,ent] = render(win,game,player,ent);
    
    while game.running == 1
        % Key Watchdog
        waitforbuttonpress;
        button = get(win,'CurrentCharacter'); 
        if strcmp(button,'w')
        	player.pos(2) = player.pos(2) + player.speed;
            [player,ent] = checkCollisions(player,ent);
            [win,game,player,ent] = render(win,game,player,ent);
        end
        if strcmp(button,'a')
        	player.pos(1) = player.pos(1) - player.speed;
            [player,ent] = checkCollisions(player,ent);
            [win,game,player,ent] = render(win,game,player,ent);
        end
        if strcmp(button,'s')
        	player.pos(2) = player.pos(2) - player.speed;
            [player,ent] = checkCollisions(player,ent);
            [win,game,player,ent] = render(win,game,player,ent);
        end
        if strcmp(button,'d')
        	player.pos(1) = player.pos(1) + player.speed;
            [player,ent] = checkCollisions(player,ent);
            [win,game,player,ent] = render(win,game,player,ent);
        end
        if strcmp(button,'c')
            disp("Saving Preset...");
        	gameSave(def_game,def_player,def_ent);
        end
        if strcmp(button,'v')
            disp("Saving Game...");
        	gameSave(game,player,ent);
        end
        if strcmp(button,'k')
            disp("Save Detroyed...");
        	delete('game.mat')
        end
    end
    
    cleanup = onCleanup(@() gameShutdown(game,player,ent,win));
end

function [ent] = spawnCoin20(x,y,ent)
    ent;
    ent(end+1) = struct('type','coin20','posx',x,'posy',y,'hp',100);
end

function [ent] = spawnCoin50(x,y,ent)
    ent;
    ent(end+1) = struct('type','coin50','posx',x,'posy',y,'hp',100);
end

function [player,ent] = checkCollisions(player,ent)
    count = zeros(1,length(ent));
    for n = 1:length(ent)
        if player.pos(1) >= ent(n).posx-4 && player.pos(1) <= ent(n).posx+4 ...
        && player.pos(2) >= ent(n).posy-4 && player.pos(2) <= ent(n).posy+4 ...
        && ent(n).hp ~= 0
            ent(n).hp = 0;
            if strcmp(ent(n).type,'coin20')
                player.xp = player.xp + 20;
            elseif strcmp(ent(n).type,'coin50')
                player.xp = player.xp + 50;
            end
        end
        count(n) = ent(n).hp == 0;
    end
    if all(count)
        for j = 2:length(ent)
            ent(j).hp = 100;
        end
    end
end

function [win,game,player,ent] = render(win,game,player,ent)
    
    tic;
    
    clf(win);
    hold('on');
    
    xlim([0,game.mapx]);
    ylim([0,game.mapy]);
    
    plot(game.mapx,game.mapy,'o');
    
    % Render player
    plot(player.pos(1),player.pos(2),'o','MarkerFaceColor',player.colorfill,'MarkerEdgeColor',player.colorborder);
    
    % Render entities
    for i = 1:length(ent)
        if ent(i).hp ~= 0
            switch ent(i).type
                case 'coin20'
                    plot(ent(i).posx,ent(i).posy,'o','MarkerFaceColor',[1,.84,0],'MarkerEdgeColor',[.85,.65,.13]);
                case 'coin50'
                    plot(ent(i).posx,ent(i).posy,'o','MarkerFaceColor',[.86,.08,.24],'MarkerEdgeColor',[0,0,1]);
            end
        end
    end
    
    %Render Overlay GUI
    text(8,game.mapy-8,player.name,'Color','black','FontSize',14);
    txt = strcat(['HP: ',num2str(player.hp)]);
    text(8,game.mapy-16,txt,'Color','black','FontSize',10);
    txt = strcat(['Stamina: ',num2str(player.stma)]);
    text(8,game.mapy-22,txt,'Color','black','FontSize',10);
    txt = strcat(['XP: ',num2str(player.xp)]);
    text(8,10,txt,'Color','black','FontSize',10);
    
    game.fps = 1/toc;
end

function gameSave(game,player,ent)
    save('game.mat');
end