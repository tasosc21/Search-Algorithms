clc;
clear;
close all;
format compact;

dbstop if error;
dbstop if warning;

% --- Set of nodes
NodesList={'Arad';'Bucharest';'Craiova';'Dobreta';'Eforie';'Fagaras';...
    'Giurgiu';'Hirsova';'Iasi';'Lugoj';'Mehadia';'Neamt';'Oradea';'Pitesti';'Rimnicu Vilcea';...
    'Sibiu';'Timisoara';'Urziceni';'Vaslui';'Zerind'};
% --- Heuristic function values
hList=[366;0;160;242;161;178;77;151;226;244;241;234;380;100;193;253;329;80;199;374];

% --- Link weights between nodes
LinksList= {    
    'Oradea'	'Zerind'	71
    'Oradea'	'Sibiu'	151
    'Zerind'	'Arad'	75
    'Arad'	'Sibiu'	140
    'Arad'	'Timisoara'	118
    'Timisoara'	'Lugoj'	111
    'Lugoj'	'Mehadia'	70
    'Mehadia'	'Dobreta'	75
    'Dobreta'	'Craiova'	120
    'Craiova'	'Pitesti'	138
    'Craiova'	'Rimnicu Vilcea'	146
    'Rimnicu Vilcea'	'Sibiu'	80
    'Rimnicu Vilcea'	'Pitesti'	97
    'Sibiu'	'Fagaras'	99
    'Fagaras'	'Bucharest'	211
    'Pitesti'	'Bucharest'	101
    'Bucharest'	'Giurgiu'	90
    'Bucharest'	'Urziceni'	85
    'Urziceni'	'Hirsova'	98
    'Urziceni'	'Vaslui'	142
    'Hirsova'	'Eforie'	86
    'Vaslui'	'Iasi'	92
    'Iasi'	'Neamt'	87
    };

% --- Starting node
Start={'Arad'};
% --- Goal node(s) = where h equals zero
Goal=NodesList(hList==0);

% --- Initialise open and closed lists
OpenList={};
ClosedList={};

% --- Prepare array T
n=length(NodesList);
gList=zeros(n,1);
fList=Inf(n,1); % Inf denotes a scalar representation of positive infinity
ParentList=repmat({''},n,1);

T=table(gList,hList,fList,ParentList,'RowNames',NodesList,'VariableNames',{'g','h','f','parent'});

% --- Make the start vertex current
c=Start;

% --- Calculate f value for start vertex (f = g + h, where g = 0)
g=table2array(T(c,'g'));
h=table2array(T(c,'h'));
f=g+h;
T(c,'f')=array2table(f);

T(c,'f')=array2table(table2array(T(c,'g'))+table2array(T(c,'h')));

%--Displays Frontier & Selection for Starting Node
fprintf('Frontier:\n   %s(%d,-)\n',cell2mat(c),T{c,'f'}) 
fprintf('Selection:\n   %s\n\n',cell2mat(c))

% --- while current vertex is not the destination
while ~ismember(Goal,c)
    % --- for each vertex adjacent to current
    AdjNodesG=[LinksList(strcmp(LinksList(:,1),c),2:3);LinksList(strcmp(LinksList(:,2),c),[1,3])];
    for i=1:size(AdjNodesG,1)
        v=AdjNodesG(i,1);
        % --- if vertex not in closed list then
        if ~ismember(v,ClosedList)
            % --- Calculate distance from start (g)
            g_this=AdjNodesG{i,2};
            g_parent=table2array(T(c,'g'));
            g=g_parent+g_this;
            % --- Calculate heuristic distance to destination (h)
            h=table2array(T(v,'h'));
            % --- Calculate f value (f = g + h)
            f=g+h;
            % --- If new f value < existing f then
            f_current=table2array(T(v,'f'));
            if f<f_current
            % --- If vertex not in open list then add it
                if ~ismember(v,OpenList)
                    OpenList=[OpenList,v];
                end
                % --- Update f value
                T(v,'g')=array2table(g);
                T(v,'f')=array2table(f);
                % --- Set parent to be the current vertex
                T(v,'parent')=c;
            end
        end
    end
    % --- Add current vertex to closed list
    ClosedList=[ClosedList,c];
    % --- Remove current vertex from open list
    OpenList=setdiff(OpenList,c);
    % --- Find vertex with lowest f value from open list and make it new current
    [~,SortIdx]=sortrows(table2array(T(OpenList,{'f'})));
    % [~,SortIdx]=sortrows(table2array(T(OpenList,{'f','h'}))); % use this if there are equal f values and want to sub-sort by h values
    c=OpenList(SortIdx(1));

    %--Displays Frontier & Selection for new node
    fprintf("Frontier:\n")
    for i = 1:size(OpenList,2)
        fprintf('   %s(%d,%s)\n',OpenList{1,i},T{OpenList{1,i},'f'},cell2mat(T{OpenList{1,i},'parent'}))   
    end 
    fprintf('Selection:\n   %s\n\n',cell2mat(c))
   
    % ---     END WHILE
end
Cost=table2array(T(c,'f'));
Path=c;
while ~isempty(cell2mat(table2array(T(c,'parent'))))
    Path=[table2array(T(c,'parent')) Path];
    c=table2array(T(c,'parent'));
end


%--Displays Path & Cost
disp('Finished!')
fprintf('Path: ')
for i = 1:size(Path,2)-1
    fprintf('%s -> ',cell2mat(Path(1,i)))
end
fprintf('%s\n', cell2mat(Path(1,end)))
fprintf('Cost: %d', Cost)



