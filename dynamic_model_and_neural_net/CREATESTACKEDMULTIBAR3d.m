% modified from:
% Author: Prabhu M on 10/04/2015
% Institution: Dept. of Civil Engineering, Indian Institute of Technology Madras 
% Email: prabhu.mu@outlook.com
function h= CREATESTACKEDMULTIBAR3d(x,y,zl,zu,width,facecol)
%CREATESTACKEDMULTIBAR3d 
%   This function creates a 3d bar chart with option to stack data
%   Input:
%   x, y: matrices of the mean x and y bin values 
%   zl and zu: define the lower and the upper coord of the zdata
%   Note: Define zldata as a zero column vector for the first (or lower)
%   group of the stacks and pass the incremental zvalues in subsequent
%   iteration with 'hold on' option enabled
%   col - define the range of data 
%   width - width of the bars (0 to 1)
%   nset - 'n' color sets for each of the stack level
%% Example
% clear all;
% clc;
% close all
% 
% ngroups=5; 
% x = 0:0.1:1; y=0:0.2:1; z=rand(numel(x), numel(y), ngroups);
% % get bin averages of m and r
% [y1,x1]=meshgrid(y,x);
% z1=zeros(size(z,1),size(z,2));    % initial 'zldata'
% for i1=1:ngroups
%     z2=z1;
%     z1=z1+squeeze(z(:,:,i1));
%     h(i1)=CREATESTACKEDMULTIBAR3d(x1, y1, z2, z1, i1.*ones(numel(z1(:)),1), 0.8, ngroups);
%     hold on
% end
% set(gca,'ydir','reverse')
% annotation(gcf,'textbox',[0.71 0.098 0.2 0.038],'String',{'xlabel'},'LineStyle','none');
% annotation(gcf,'textbox',[0.12 0.14 0.2 0.038],'String',{'ylabel'},'LineStyle','none');
% annotation(gcf,'textbox',[0.06 0.5 0.2 0.038],'String',{'zlabel'},'LineStyle','none');
% alpha(0.9); % set transparency
% legend(h, 'zg1','zg2','zg3','zg4','zg5');
% axis  tight square;
% view(3);
% grid on; box on;
%% assign default values for undeclared parameters
if nargin<=5
    width=0.2;
    nset = 1;
end
% Set bar width smaller than the divisions
if (x(2,1)-x(1,1))<=width||(y(1,2)-y(1,1))<=width
   width=min(x(2,1)-x(1,1),y(1,2)-y(1,1)).*0.9;
end
x=x(:); y= y(:); zl=zl(:);  zu=zu(:);
nx=length(x);
%% scale the bar width to make them look square
mx=max(x)-min(x);
my=max(y)-min(y);
if mx<=my
    sx=width/2; % half-width of the bar
    sy=sx*my/mx;
else
    sy=width/2; % half-width of the bar
    sx=sy*my/mx;
end
%% Set colormap definition for the groups
% rescaling color scale, if needed for 1 z group but varying x groups 
% csl=coords(:,5).*floor(length(cm)/length(unique(x(:,1))));
% csl=col.*floor(length(cm)/nset);
%% plot the bars
for i=1:nx
    
    x1=x(i); y1=y(i); zl1=zl(i); zu1=zu(i);
    % set vertices
    verts=[x1-sx y1-sy zl1
        x1-sx y1+sy zl1
        x1+sx y1-sy zl1
        x1+sx y1+sy zl1
        x1-sx y1-sy zu1
        x1-sx y1+sy zu1
        x1+sx y1-sy zu1
        x1+sx y1+sy zu1
        ];
    % set faces
    faces=[1 2 6 5;
        3 1 5 7;
        4 3 7 8;
        2 4 8 6;
        5 6 8 7;
        1 2 4 3];
    
    patchinfo.Vertices = verts;
    patchinfo.Faces = faces;
    
    patchinfo.FaceColor = facecol;
    h=patch(patchinfo,'CDataMapping','scaled','Edgecolor','k');
    hold on;
    box on;
    grid on;
end