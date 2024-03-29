clear all;
close all;
s = serial('COM16', 'BaudRate', 1562500);
%1562500

%%Input Image

InImage_color=imread('lossy.jpg');
InImage=rgb2gray(InImage_color);
%InImage=imread('white256.bmp');
%subplot(2,3,1),imshow(InImage),title('Original');
figure,imshow(InImage),title('Original');

InImage_matlab=double(InImage);

%Prepare Input Image for transmission
InImageD=double(InImage);
InImageArray=InImageD(:);


%Preparing appending dataset
[row,col]=size(InImage);
i=0;j=0;
wo=0;
col_2=row/2;
offset=12;
k1=1;k2=2;k3=1;
div=k1+k2+k3;
temp=0;
data=double([row;col;i;j;wo;col_2;offset;k1;k2;k3;div;temp]);


%Transmitting dataset
x=[data;InImageArray];

N=length(x);
a=zeros(N,1);


fopen(s);
disp('Port Open');

for i=1:N
   fwrite(s,x(i),'uint8');
end

disp('Write Done');
for i=1:N
   a(i,1)=fread(s,1);
end

fclose(s);

%Processing for out Image
OutImage=[a(14:N);a(1)];
OutImage=OutImage';
outImage=OutImage;
MatLab_OutImge=zeros(row/2,col/2);
% wo=1;
% for i=1:2:row
%     for j=1:2:col
%         MatLab_OutImge(wo)=InImage_matlab(i,j);
%         wo=wo+1;
%     end
% end

Result=reshape(uint8(OutImage),[row,col]);
%subplot(2,3,5),imshow(Result),title('FPGA Filtered');
figure,imshow(Result),title('FPGA Filtered');


MatLab_OutImge=Result(2:2:end,2:2:end);%HDL real
OutImage_HDL=MatLab_OutImge;
%figure, imshow(OutImage);
%Reshaped_Result=reshape(uint8(MatLab_OutImge),[row/2,col/2]);

%subplot(2,3,6),imshow(OutImage_HDL),,title('FPGA DOWNSAMPLED');
figure,imshow(OutImage_HDL),,title('FPGA DOWNSAMPLED');


MatLab_OutImage=zeros(row/2,col/2);
%MatLab_FilterImage=zeros(row,col);

for j=2:col-1
    temp=InImage_matlab(1,j);
    for i=2:row-1
        total=0;
        total=total+temp*k1;
        total=total+InImage_matlab(i,j)*k2;
        total=total+InImage_matlab(i+1,j)*k3;
        temp=InImage_matlab(i,j);
        InImage_matlab(i,j)=floor(total/div);
    end
end
MatLab_FilterImage_y=InImage_matlab;

for i=2:row-1
    temp=InImage_matlab(i,1);
    for j=2:col-1
        total=0;
        total=total+temp*k1;
        total=total+InImage_matlab(i,j)*k2;
        total=total+InImage_matlab(i,j+1)*k3;
        temp=InImage_matlab(i,j);
        InImage_matlab(i,j)=floor(total/div);
    end
end


MatLab_FilterImage=InImage_matlab;

%wo=1;
%
% for i=1:2:row
%     for j=1:2:col
%         MatLab_OutImage(wo)=InImage_matlab(i,j);
%         wo=wo+1;
%     end
% end
MatLab_Filter_show=reshape(uint8(MatLab_FilterImage),[row,col]);
%subplot(2,3,2),imshow(MatLab_Filter_show),title('Matlab Filterd');
figure,imshow(MatLab_Filter_show),title('Matlab Filterd');

MatLab_OutImage=MatLab_FilterImage(2:2:end,2:2:end);
MatLab_Reshaped_Result=reshape(uint8(MatLab_OutImage),[row/2,col/2]);
%subplot(2,3,3), imshow(MatLab_Reshaped_Result),title('MatLab Downsampled');
figure, imshow(MatLab_Reshaped_Result),title('MatLab Downsampled');

%figure,imshow(MatLab_Reshaped_Result);
Difference=MatLab_Filter_show-Result;
Error=MatLab_Reshaped_Result-OutImage_HDL;
Squared_Error=Error.*Error;

Sum_Square_error=sum(sum(Squared_Error));
mean_sqrt_error=sqrt(Sum_Square_error*(row*col));

mean_square_error_presentage=mean_sqrt_error*(100/255);

disp('mean square error ');
mean_square_error_presentage

disp('Zero Error Pixels :-')
Myzero=zeros(row/2,col/2);
No_Error_zero=sum(sum(Error==Myzero))/(row*col/4)

disp('One Error Pixels :- ')
Myone=ones(row/2,col/2);
No_Error_one=sum(sum(Error==Myone))/(row*col/4)

disp('Total Error : -')
No_Error_one+No_Error_zero

disp('Error greater than 1') 
 sum(sum(Myone<Error))


