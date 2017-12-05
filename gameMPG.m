function gameMPG()
    
    version = '1.0';
    
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
   
    ent(1) = struct('type','init','posx',0,'posy',0,'hp',100); % All world entities are stored in this var
    
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
        player.pos = [game.mapx/2,game.mapy/2];
        player.speed = 4;
        
        %Generate Starting Entities
        
    end
    
    run(game,player,ent,version);
    
end

function run(game,player,ent,version)

    text = strcat(['MATLAB RPG (ver ',version,')']);
    win = figure('Name',text);
    game.running = 1;
    
    % Run Main Loop
    
    [win,game,player,ent] = render(win,game,player,ent);
    
    while game.running == 1
        waitforbuttonpress;
        button = get(win,'CurrentCharacter'); 
        if strcmp(button,'w')
        	player.pos(2) = player.pos(2) + player.speed;
            render(win,game,player,ent);
        end
        if strcmp(button,'a')
        	player.pos(1) = player.pos(1) - player.speed;
            render(win,game,player,ent);
        end
        if strcmp(button,'s')
        	player.pos(2) = player.pos(2) - player.speed;
            render(win,game,player,ent);
        end
        if strcmp(button,'d')
        	player.pos(1) = player.pos(1) + player.speed;
            render(win,game,player,ent);
        end
        if strcmp(button,'v')
        	gameSave(game,player,ent);
        end
        if strcmp(button,'k')
            disp("Save Detroyed...");
        	delete('game.mat')
        end
    end
    
    cleanup = onCleanup(@() gameShutdown(game,player,ent,win));
end

function spawnCoin20(x,y)
    ent;
    ent(end+1) = struct('type','coin20','posx',x,'posy',y,'hp',100);
end

function spawnCoin50(x,y)
    ent;
    ent(end+1) = struct('type','coin50','posx',x,'posy',y,'hp',100);
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
    disp("Saving Game...");
    save('game.mat');
end