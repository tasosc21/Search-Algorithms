clc;
clear;
close all;
format compact;

dbstop if error;
dbstop if warning;

% --- Set of nodes
NodesList={'S';'A';'B';'C';'D';'E';'F';'G1';'G2';'G3'};

% --- Link weights between nodes
LinksList={
    'S','A',5
    'S','B',9
    'S','D',6
    'A','B',3
    'A','G1',9
    'B','A',2
    'B','C',1
    'C','S',6
    'C','F',7
    'C','G2',5
    'D','S',1
    'D','C',2
    'D','E',2
    'E','G3',7
    'F','D',2
    'F','G3',8
    };

% --- Starting node
Start={'S'};
% --- Goal node(s) = where h equals zero
Goal={'G1', 'G2', 'G3'};

% --- Initialise open and closed lists
OpenList={};
ClosedList={};

% --- Prepare array T
n=length(NodesList);
gList=[0;inf(n-1,1)];
ParentList=repmat({''},n,1);

T=table(gList,ParentList,'RowNames',NodesList,'VariableNames',{'g','parent'});

% --- Make the start vertex current
c=Start;

% --- Calculate f value for start vertex (f = g + h, where g = 0)
g=table2array(T(c,'g'));

%--Displays Frontier & Selection for Starting Node
fprintf('Frontier:\n   %s(%d,-)\n',cell2mat(Start),T{c,'g'}) 
fprintf('Selection:\n   %s\n\n',cell2mat(Start))

% --- while current vertex is not the destination
while ~ismember(Goal,c)    
    % --- for each vertex adjacent to current
    AdjNodesG=LinksList(strcmp(LinksList(:,1),c),2:3);
    for i=1:size(AdjNodesG,1)
        v=AdjNodesG(i,1);
        % --- if vertex not in closed list then
        if ~ismember(v,ClosedList)
            % --- Calculate distance from start (g)
            g_this=AdjNodesG{i,2};
            g_parent=table2array(T(c,'g'));
            g=g_parent+g_this;    
            g_current=table2array(T(v,'g'));

            % --- If new g value < existing g then
            if g<g_current
            % --- If vertex not in open list then add it
                if ~ismember(v,OpenList)
                    OpenList=[OpenList,v];
                end
                % --- Update f value
                T(v,'g')=array2table(g);
                
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
    [~,SortIdx]=sortrows(table2array(T(OpenList,{'g'})));
    % [~,SortIdx]=sortrows(table2array(T(OpenList,{'f','h'}))); % use this if there are equal f values and want to sub-sort by h values
    c=OpenList(SortIdx(1));


    %--Displays Frontier & Selection for new nodes
    fprintf("Frontier:\n")
    for i = 1:size(OpenList,2)
        fprintf('   %s(%d,%s)\n',OpenList{1,i},T{OpenList{1,i},'g'},cell2mat(T{OpenList{1,i},'parent'}))   
    end 
    fprintf('Selection:\n   %s\n\n',cell2mat(c))
           

    
    % ---     END WHILE   
end
Cost=table2array(T(c,'g'));
Path=c;
while ~isempty(cell2mat(table2array(T(c,'parent'))))
    Path=[table2array(T(c,'parent')) Path];
    c=table2array(T(c,'parent'));
end


disp('Finished!')
fprintf('Path: ')
for i = 1:size(Path,2)-1
    fprintf('%s -> ',cell2mat(Path(1,i)))
end
fprintf('%s\n', cell2mat(Path(1,end)))

fprintf('Cost: %d', Cost)



