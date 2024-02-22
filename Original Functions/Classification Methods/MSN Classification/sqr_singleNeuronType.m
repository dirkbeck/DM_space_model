function [Type, HalfPeakTime, MeanMedianRatio, FiringRate] = sqr_singleNeuronType(sessionDir, tetrode, cellnum, neuronTypeDataFile)

tetrodefile=fullfile(sessionDir,strcat(tetrode,'.mat'));
tetrodeinfo=fullfile(sessionDir,strcat(tetrode,'_info.mat'));
tetrodeMat=load(tetrodefile);
infoMat = load(tetrodeinfo);
load(neuronTypeDataFile);


list=tetrodeMat.output(:,1);
tstamps=list(tetrodeMat.output(:,2)==cellnum);
FiringRate=1/mean(diff(tstamps));
MedianISI=median(diff(tstamps));
mat=infoMat.means{1,cellnum};
%matrix size
k=size(mat);
if k(1)==150
    k = k([2,1]);
end
mat = reshape(mat,k(1),150);
HalfPeakTime=1;
for i=1:k(1)
    if mat(i,47)>mat(HalfPeakTime,47)
        HalfPeakTime=i;
    end
end
            
%peak
L=mat(HalfPeakTime,:);
%half-peak
md=L(1,47)/2;
            
%the first value over the rise_time
half_th1=find(mat(HalfPeakTime,:)>md, 1);
y1=mat(HalfPeakTime,half_th1);
%the last value before the rise_time
half_th2=half_th1-1;
y2=mat(HalfPeakTime,half_th2);
            
%cross point #1
inter1=(y1-md)*half_th2/(y1-y2)+(md-y2)*half_th1/(y1-y2);
            
%the last value before the fall_time
half_th3=find(mat(HalfPeakTime,:)>md, 1,'last');
y3=mat(HalfPeakTime,half_th3);
%the first value over the fall_time
half_th4=half_th3+1;
y4=mat(HalfPeakTime,half_th4);
            
%cross point #2
inter2=(y3-md)*half_th4/(y3-y4)+(md-y4)/(y3-y4)*half_th3;

HalfPeakTime=(inter2-inter1)/150;
MeanMedianRatio=log(1/FiringRate/MedianISI);

if HalfPeakTime<0.133 
    mahaldis=mahal([HalfPeakTime MeanMedianRatio FiringRate],Training2); 
    clusternum=cluster(GT,[HalfPeakTime/0.14 MeanMedianRatio/7 FiringRate/40]);
    if clusternum==1 && (mahaldis<=12 || FiringRate>20) && 1/FiringRate/MedianISI<3.5 && HalfPeakTime<0.1; 
        Type=1;
    elseif clusternum==2 ||clusternum==4
        Type=3;
    elseif clusternum==3
        if HalfPeakTime<0.12 || FiringRate<2.5
            Type=4;
        elseif FiringRate<9 && 1/FiringRate/MedianISI<3.5
            Type=2;
        else
            Type=0;
        end
    else 
        Type=0;
    end
    
else 
    if FiringRate>2.5 && 1/FiringRate/MedianISI<3.5 && FiringRate<9
        Type=2;
    elseif FiringRate<=2.5
        Type=5;
    else
        Type=0;      
    end
end
    