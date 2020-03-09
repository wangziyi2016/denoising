function [xrange, yrange,flag,mask]=GetLungBoundryOneSlice(ref3d,whichslice,whichside,threshold,predefinedMask)

%Get the boundary on one slice
%ref3d: 3D lung image
%whichslice: the slice to work on
%threshold: distinguish lung tissue from non-lung tissue


mask=ref3d(:,:,whichslice)<threshold;

if(~exist('predefinedMask','var'))
    projection=sum(ref3d<threshold,3);
    %projection(projection~=max(projection(:)))=0;
else
    projection=predefinedMask;
end

[dimy,dimx]=size(mask);

%find all possible boundaries
allboundary1=bwperim(mask);
allboundary=zeros(size(allboundary1));
allboundary(10:end-10,10:end-10)=allboundary1(10:end-10,10:end-10);
clear allboundary1;


%find the boundary of chest wall
mask2=zeros(size(mask));
while 1
    for jj=0:50% range of search
        thefirst=find(allboundary(floor(dimy/2)+jj,:));
        if isempty(thefirst)
            continue;  
        end
        boundary=bwtraceboundary(allboundary,[floor(dimy/2)+jj, thefirst(1)],'nw');
        for boundaryindex=1:length(boundary)
            allboundary(boundary(boundaryindex,1),boundary(boundaryindex,2))=0;
        end
        if(length(boundary)<100)%the region is too small
            continue;
        end

        mask1=roipoly(uint8(mask),boundary(:,2),boundary(:,1));
        boundary1=bwperim(mask1);
        mask1=mask1-boundary1;
        if sum(mask1(:))~=0
            boundary1=bwperim(mask1);
            mask1=mask1-boundary1;
            
            break;
        end
    end
    if(jj==50)
        break;
    end


    %exclude the chest wall from mask, 3 is picked by experience
    for jj=1:3
        boundary1=bwperim(mask1);
        mask1=mask1-boundary1;
    end
    mask2=mask2+mask1;

end
%get the exact lung mask
mask2(mask2>0)=1;
mask=mask.*mask2;
%projection=mask.*projection;
projection=mask.*projection;
projection(projection~=max(projection(:)))=0;

goback=1;
while(goback)
    goback=0;
    if(sum(projection(:)))
        [value,center]=max(sum(projection,2));
    else
        center=dimy/2;
    end
    %
    % if(center<51)
    %     center=51;
    % end
    %
    % if(center>dimy-49)
    %     center=dimy-49;
    % end
    if(center<51 || center>dimy-49)
        mask=mask*0;
        return;
    end
    allboundary=bwperim(mask);

    %get part of the lung with less fracture boundary
    mask_narrowed=mask(center-50:center+49,:);
    mask_narrowed_sum=sum(mask_narrowed,1);



    mask_narrowed(mask_narrowed_sum>0)=1;
    theleft=find(mask_narrowed_sum,1,'first');
    theright=find(mask_narrowed_sum,1,'last');
    maskleft=zeros(size(mask));
    maskright=zeros(size(mask));
    for jj=theleft:dimx/2
        leftpoint(1)=center;
        leftpoint(2)=jj;
        try
            temp1=bwtraceboundary(allboundary,leftpoint,'w');
        catch
            try
                temp1=bwtraceboundary(allboundary,leftpoint,'e');
            catch
                try
                    temp1=bwtraceboundary(allboundary,leftpoint,'n');
                catch

                    temp1=bwtraceboundary(allboundary,leftpoint,'s');

                end

            end
        end
        if(isempty(temp1))
            continue;
        end
        maskleft=roipoly(uint8(mask),temp1(:,2),temp1(:,1));
        if(sum(maskleft(:))>0.1*sum(mask(:)))
            break;
        end
    end
    
    for jj=theright:-1:dimx/2
        rightpoint(1)=center;
        rightpoint(2)=jj;
        try
            temp1=bwtraceboundary(allboundary,rightpoint,'e');
        catch
            try
                temp1=bwtraceboundary(allboundary,rightpoint,'w');
            catch

                try
                    temp1=bwtraceboundary(allboundary,rightpoint,'s');
                catch
                    temp1=bwtraceboundary(allboundary,rightpoint,'n');
                end
            end
        end
            
        if(isempty(temp1))
            continue;
        end
        maskright=roipoly(uint8(mask),temp1(:,2),temp1(:,1));
        if(sum(maskright(:))>0.1*sum(mask(:)))
            break;
        end
        
    end

%     for jj=1:theright-dimx/2
%         rightpoint(2)=theright-jj;
%         tt=find(mask(center-50:center+49,theright-jj),1,'first')+center-51;
%         if(~isempty(tt)&& tt~=(center-50) && tt~=(center+49))
%             rightpoint(1)=tt;
%             temp1=bwtraceboundary(allboundary,rightpoint,'n');
%             maskright=roipoly(uint8(mask),temp1(:,2),temp1(:,1));
%             if(sum(maskright(:))>0.1*sum(mask(:)))
% 
%                 break;
%             end
%         end
% 
%     end


    leftvalue=ref3d(:,:,whichslice).*double(maskleft);
    meanleft=mean(leftvalue(leftvalue>0));
    rightvalue=ref3d(:,:,whichslice).*double(maskright);
    meanright=mean(rightvalue(rightvalue>0));

    if(meanright<200)
        mask(maskright>0)=0;
        goback=1;
        clear maskright;
    end

    if(meanleft<200)
        mask(maskleft>0)=0;
        goback=1;
        clear maskleft;
    end
    projection=mask;

end
mask=(maskright==1)| (maskleft==1);
if sum(mask(:))==0
    xrange=[1 dimy/2 dimy];
    yrange=[1 dimy];
    flag=0;
    return;
end

SumOfColumn=sum(mask,1);
clear index;
index=zeros(1,length(SumOfColumn));
index(find(SumOfColumn==0))=1;
clear indexdiff;
indexdiff=find(abs(diff(index))==1);
xrange(1)=indexdiff(1);
xrange(3)=indexdiff(end);

center=round((xrange(1)+xrange(3))/2);
radius=round((xrange(3)-xrange(1))/4);
clear index;
val=min(SumOfColumn(center-radius:center+radius));
index=find(SumOfColumn(center-radius:center+radius)==val);
xrange(2)=round(sum(index)/length(index))+center-radius;



SumOfRow=sum(mask(:,xrange(1):xrange(3)),2);
index=find(diff(SumOfRow));
yrange=[index(1),index(end)];
flag=1;

xrange=xrange+[-10 0 10];
yrange=yrange+[-10 10];

if whichside==1
    mask(yrange(1):yrange(2),xrange(1):xrange(2))=0;
else
    mask(yrange(1):yrange(2),xrange(2):xrange(3))=0;    
end

if(sum(mask(:)))
    flag=1;
else 
    flag=0;
end
% xboundary=find(abs(diff(sum(mask)>0)));
% yboundary=find(abs(diff(sum(mask,2)>0)));
