%% The scripttakes a 4 channel stack, where 4th channel is the DAPI staining, 
%% then extracts the mean of channel red which is the second channel and plots 
%% them on image and generated the excel file in separate folder for each file.



clear all
close all

clc

% Datahome='G:\Marie_Brainbow2\S�lection Shihav\Marie_brainbow8\Tiffv';
% Reshome='G:\Marie_Brainbow2\S�lection Shihav\Marie_brainbow8\ImageJ';
% Reshome2='G:\Marie_Brainbow2\S�lection Shihav\Marie_brainbow8\MATLAB';

% Datahome='/import/pr_ciltex/TEST_BRAINBOW/Tiff';
% Reshome='/import/pr_ciltex/TEST_BRAINBOW/Imagej2';
% Reshome2='/import/pr_ciltex/TEST_BRAINBOW/Process';

% Datahome=[cd filesep 'Dataset'];
% Reshome=[cd filesep 'DatasetR'];

Datahome=uigetdir(cd,'Please select the DATA Folder');
Reshome=uigetdir(cd,'Please select the RESULT Folder');

% addpath(['C:\Data 2016\fiji and shihav files\Nuclear Fluorescence intensity\Alice' filesep 'export_fig-master' filesep 'export_fig-master']);


Reshome2=Reshome;

d=dir(fullfile(Datahome,'*.tif*'));
Types={d.name};

BKA=[];

RAK=[];
GAK=[];
BAK=[];

for imgid=1:numel(Types)
       
     filename=Types{imgid};
     filename2=strrep(filename,'.tif','');     
        oriname=[Datahome filesep filename2 '.tif'];
         mkdir([[Reshome2 filesep filename2]]);
%      segname=[Reshome filesep filename2 '4-Watershed.tif'];
        
               info = imfinfo(oriname);
        num_images = numel(info);
        
        % Which channel used for DAPI / nucleus staining, if there are four
        % channel in the dataset.
     
        ImgGR=uint8([]);
        kn=1;
        for k = 4:4:num_images
            I = uint8(double(imread(oriname, k))/16);
              ImgGR(:,:,kn)=I;   
              kn=kn+1
        end

        ImgR=uint8([]);
        kn=1;
        for k = 2:4:num_images
           I = uint8(double(imread(oriname, k))/16);
              ImgR(:,:,kn)=I;   
              kn=kn+1
        end
        
        ImgG=uint8([]);
        kn=1;
        for k = 1:4:num_images
            I = uint8(double(imread(oriname, k))/16);
              ImgG(:,:,kn)=I;   
              kn=kn+1
        end
        
        ImgB=uint8([]);
        kn=1;
        for k = 3:4:num_images
             I = uint8(double(imread(oriname, k))/16);
              ImgB(:,:,kn)=I;   
              kn=kn+1
        end
       
  
[Img11r,zval11r]=max(ImgR,[],3);
[Img11g,zval11g]=max(ImgG,[],3);
[Img11b,zval11b]=max(ImgB,[],3);
[Img11gr,zval11gr]=max(ImgGR,[],3);


CO=uint8(cat(3,Img11r,Img11g,Img11b));
CGO=uint8(cat(3,Img11gr,Img11gr,Img11gr));
COF=CO+0.3*CGO;

imwrite(uint8(COF),[Reshome2 filesep filename2 filesep filename2 'Ori.png']);  
imwrite(uint8(CO),[Reshome2 filesep filename2 filesep filename2 'OriC.png']);
% 

close all               
img =double(ImgGR);
imgN = double(img-min(img(:)))/(max(img(:)-min(img(:))));

hG = fspecial('gaussian',[15 15],5); 
     imgN = imfilter(imgN,hG,'replicate'); 
% th1=graythresh(imgN);
% th2 = graythresh(imgN(imgN>th1));

% th1=0.25;
th2=0.075;

% cellMsk = imgN>th1;
bw = imgN>th2;

% bw2 = ~bwareaopen(~bw, 10);
% imshow(bw2)

D = -bwdist(~bw);
imshow(D,[])

Ld = watershed(D);
imshow(label2rgb(Ld))

bw2 = bw;
bw2(Ld == 0) = 0;
imshow(bw2)

mask = imextendedmin(D,2);
% imshowpair(bw,mask,'blend')

D2 = imimposemin(D,mask);
Ld2 = watershed(D2);
bw3 = bw;
bw3(Ld2 == 0) = 0;
imshow(bw3)

lblImg = bwlabel(bw3);
figure,imshow(label2rgb(lblImg,'jet','k','shuffle'));

figure
imshow(ImgGR)
               
        tol=0.05;
    
classmap=lblImg;
      
I2cpsegb=classmap>0;
     T1=im2bw(I2cpsegb);
                           T2=T1;
                           T3 = imclearborder(T2);
                           
% classmap4=classmap; 
classmap(T3==0)=0;
pcells=unique(classmap);

         for nk=2:length(pcells)            
            val=pcells(nk);            
            sizek=sum(sum(classmap==val));            
            if sizek<2000
                classmap(classmap==val)=0;
%                 Imgsegk(Imgsegk==val)=0;
                
            end
            nk 
         end
% classmap((T2-T3)==1)=classmap4((T2-T3)==1);         
classmap2=classmap;
figure,imshow(label2rgb(classmap2,'jet','k','shuffle'));

classmapk=classmap2;
I2cpsegb=classmapk>0;
     T1=im2bw(I2cpsegb);
                           T2=T1;
                           T3 = imclearborder(T2);
                           
classmap4=classmapk; 
%classmap4(T3==0)=0;
classmap5=classmap4;
pcells=unique(classmap4);
se = ones(3); 
sek = ones(3); 


for nid=2:length(pcells)
       
        label = pcells(nid); 
object = classmap4 == label;
ownA=sum(sum(object));

neighbours = imdilate(object, se) & ~object;
neighbourLabels = unique(classmap4(neighbours));
neighbourLabels(1)=[];

if ~isempty(neighbourLabels)
    if ownA<7000
        
    areak=[];
    for kin=1:length(neighbourLabels)
    
    areak(kin)=sum(sum(classmap4==neighbourLabels(kin) | classmap4==label));
    end
    [areak,kin]=min(areak);
    
    block=classmap4==neighbourLabels(kin) | classmap4==label;
    [X,Y]=find(block==1);
    
    [CH,Ak]= convhull(X,Y);
    
    
            if ((Ak-areak)/Ak) <tol
                
                ownA
                
                ND=max([label neighbourLabels(kin)]);
                
                object2 = classmap4 == neighbourLabels(kin);

                classmap5(object2)=ND;
                 classmap5(object)=ND;

                middle = imdilate(object2, sek) & imdilate(object, sek);
                classmap5(middle)=ND;
                
            end
    end
end
nid

end

figure,imshow(label2rgb(classmap5,'jet','k','shuffle'));

classmap5b=imerode(imfill(classmap5,'holes'),ones(7,7));
% classmap5(classmap5b==0)=0;
classmap5=classmap5b;

imwrite(uint8(classmap5),[Reshome2 filesep filename2 filesep filename2 'Classmap.png']); 

pcells=unique(classmap5);
LABEL=classmap5;
se=ones(3);
         for nk=2:length(pcells)            
            val=pcells(nk); 

                              object = LABEL == val;
                              objectcore=imerode(object, se);
                              objectbor=(object-objectcore)>0;
                         LABEL(objectbor)=0;
         end

 LABEL = bwlabel(LABEL, 8);
pcells=unique(LABEL);
objectbor_map=zeros(size(LABEL));
se=ones(3);
         for nk=2:length(pcells)            
            val=pcells(nk); 

                              object = LABEL == val;
                              objectcore=imdilate(object, se);
                              objectbor=(objectcore-object)>0;
                       objectbor_map(objectbor)=1;
                             
         end
   LCOLOR5=CO;                                    
mult=[1 1 1];
                          for ind=1:3
                          col_img2a=mult(ind)*LCOLOR5(:,:,ind);
%                           col_img2a(LABEL==0)=0;  
                          col_img2a(objectbor_map==1)=255;    
                          Compb(:,:,ind)=col_img2a;
                          end   

imwrite(uint8(Compb),[Reshome2 filesep filename2 filesep filename2 'OverlayM.png']); 


addpath([cd filesep 'export_fig-master' filesep 'export_fig-master']);
% imgid
% LABEL=classmap5;
pcells=unique(LABEL);
% CA=[];

% ImgR=LCOLOR5(:,:,1);
% ImgG=LCOLOR5(:,:,2);
% ImgB=LCOLOR5(:,:,3);

id=1;
CA=[];
         for nk=2:length(pcells)          
            val=pcells(nk);
           
object3d=LABEL == val;
                RA=1*double(ImgR(object3d));
                 GA=1*double(ImgG(object3d));
                  BA=1*double(ImgB(object3d));     
             
                   object = LABEL == val;         
                              s = regionprops(object,'centroid');
                             cent=s.Centroid;
                              cent=fliplr(double(round(cent)));
                              CA(id,10:11)=cent;
            
            CA(id,1:4)=[id mean(RA) median(RA) std(RA)]; 
          id=id+1
         end 
         CA1=CA;
 save([Reshome2 filesep filename2 filesep filename2 'CA1.mat'],'CA1');  
 
COK(:,:,1)=1*CO(:,:,1);
COK(:,:,2)=1*CO(:,:,2);
COK(:,:,3)=1*CO(:,:,3);
LABELM=LABEL; 
 
  figure
  SH=-30;
  imshow(imresize(0.75*Compb,2));hold on
m=2;
     for zin=1:size(CA,1)       

         text(m*CA(zin,11)+0,m*CA(zin,10)+SH-0,num2str(zin),'FontSize',12,'FontName','Times','Color',[1 1 1],'HorizontalAlignment','center','VerticalAlignment', 'top');
                          text(m*CA(zin,11)+0,m*CA(zin,10)+SH,[char(10) num2str(round((CA(zin,2))))],'FontSize',12,'FontName','Times','Color',[1 .75 0.75],'HorizontalAlignment','center','VerticalAlignment', 'top');
      
%         text(m*CA(zin,11)+0,m*CA(zin,10)+SH,[char(10) char(10) '(' num2str(round((CA(zin,4)))) ',' num2str(round((CA(zin,5)))) ','...
%           num2str(round((CA(zin,6)))) ')'],'FontSize',10,'FontName','Times','Color',[.65 .95 0.65],'HorizontalAlignment','center','VerticalAlignment', 'top');
%       
%               text(m*CA(zin,11)+0,m*CA(zin,10)+SH,[char(10) char(10) char(10) '(' num2str(round((CA(zin,7)))) ',' num2str(round((CA(zin,8)))) ','...
%           num2str(round((CA(zin,9)))) ')'],'FontSize',10,'FontName','Times','Color',[.95 .65 0.65],'HorizontalAlignment','center','VerticalAlignment', 'top');
      
     end

     axis equal
   
 set(gca,'XTick',[]) % Remove the ticks in the x axis!
set(gca,'YTick',[]) % Remove the ticks in the y axis
set(gca,'Position',[0 0 1 1]) % Make the axes occupy the hole figure    
   
    ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
                                            set(gcf,'PaperPositionMode','auto')
  
  export_fig([Reshome2 filesep filename2 filesep filename2 '_method1'],'-a2', '-m2','-png', '-r300');
  
  mult=[1 0 0];
    for ind=1:3
%         if ind==1
                          col_img2a=mult(ind)*LCOLOR5(:,:,ind);
%         else 
%             col_img2a=mult(ind)*LCOLOR5(:,:,ind)*0;
%         end
% %                           col_img2a(LABEL==0)=0;  
                          col_img2a(objectbor_map==1)=255;    
                          Compc(:,:,ind)=col_img2a;
    end   
  
   figure
  SH=-30;
  imshow(imresize(0.75*Compc,2));hold on
m=2;
     for zin=1:size(CA,1)       

         text(m*CA(zin,11)+0,m*CA(zin,10)+SH-0,num2str(zin),'FontSize',12,'FontName','Times','Color',[1 1 1],'HorizontalAlignment','center','VerticalAlignment', 'top');
                          text(m*CA(zin,11)+0,m*CA(zin,10)+SH,[char(10) num2str(round((CA(zin,2))))],'FontSize',12,'FontName','Times','Color',[1 .75 0.75],'HorizontalAlignment','center','VerticalAlignment', 'top');
      
%         text(m*CA(zin,11)+0,m*CA(zin,10)+SH,[char(10) char(10) '(' num2str(round((CA(zin,4)))) ',' num2str(round((CA(zin,5)))) ','...
%           num2str(round((CA(zin,6)))) ')'],'FontSize',10,'FontName','Times','Color',[.65 .95 0.65],'HorizontalAlignment','center','VerticalAlignment', 'top');
%       
%               text(m*CA(zin,11)+0,m*CA(zin,10)+SH,[char(10) char(10) char(10) '(' num2str(round((CA(zin,7)))) ',' num2str(round((CA(zin,8)))) ','...
%           num2str(round((CA(zin,9)))) ')'],'FontSize',10,'FontName','Times','Color',[.95 .65 0.65],'HorizontalAlignment','center','VerticalAlignment', 'top');
      
     end

     axis equal
   
 set(gca,'XTick',[]) % Remove the ticks in the x axis!
set(gca,'YTick',[]) % Remove the ticks in the y axis
set(gca,'Position',[0 0 1 1]) % Make the axes occupy the hole figure    
   
    ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
                                            set(gcf,'PaperPositionMode','auto')
  
  export_fig([Reshome2 filesep filename2 filesep filename2 '_method2'],'-a2', '-m2','-png', '-r300'); 
  

%   LCOLORk=imread([Reshome2 filesep filename2 filesep filename2 '_method1' '.png']);
%   LCOLORk=LCOLORk(:,228:size(LCOLORk,2)-227,:);
%   Imk2=imresize(LCOLORk,[2*size(LABELM,1) 2*size(LABELM,2)]);
%   imwrite(uint8(Imk2),[Reshome2 filesep filename2 filesep filename2 '_method1' '.png']);
  
    resfile3 = [Reshome2 filesep filename2 filesep 'method1.xlsx'];
if exist(resfile3, 'file')==2
delete(resfile3);
end
MATN=round(CA1(:,1:4));
B = cell(size(MATN,1),size(MATN,2));
for ii=1:size(MATN,1)
for jj=1:size(MATN,2)
B(ii,jj) = {MATN(ii,jj)};
end
end
A = {'Cell ID', 'R mean', 'R median', 'R STD'};
C=[A;B];
xlswrite(resfile3,C,1,'A1')
close all
end