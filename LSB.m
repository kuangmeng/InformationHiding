road = input('输入载体图片路径:','s');
BMP = imread(strcat('/Users/kuangmeng/Documents/MATLAB/SecretInBMP/init/',road));
[height,width,channels] = size(BMP);
%转化成灰度图
gray = rgb2gray(BMP);
subplot(121),
imshow(gray),
title('原图像');
fprintf('可写入信息位数：%d位！\n',height*width);
%LSB隐写
s = input('输入隐藏信息或文件:','s');
if strfind(s,'.')
    f=fopen(strcat('/Users/kuangmeng/Documents/MATLAB/SecretInBMP/init/',s),'rb');
    [a,count]=fread(f);
    fclose(f);
    SD=dec2bin(a);
    Secret='';
    for i = 1:floor(length(SD)/8)
        for j = 1:8
             Secret=strcat(Secret,SD(i,j));
        end
    end
 else
     Secret = s;
 end
 LEN = length(Secret);
 fprintf('待嵌入信息位数：%d位！\n',LEN);
 if LEN <= height*width
    for i =1:height
        for j = 1:width
            if((i-1)*width+j<=LEN)
                if Secret((i-1)*width+j) == '1'
                    if mod(gray(i,j),2) == 0
                        gray(i,j) = gray(i,j)+1;
                    end
                else
                    if mod(gray(i,j),2) == 1
                        gray(i,j) = gray(i,j)-1;
                    end
                end
            end
        end
    end
    subplot(122),
    imshow(gray),
    title('嵌入后');
    fprintf('*****信息隐写成功！*****\n\n*****下面开始解密！*****\n');
    %提取信息
    str = '';
    for i =1:height
        for j = 1:width
            if((i-1)*width+j<=LEN)
                if mod(gray(i,j),2) == 0
                    str = strcat(str,'0');
                else
                    str = strcat(str,'1');
                end
            end
        end
    end
    if ~strcmpi(str,'')
        if strfind(s,'.')
            for i = 1:floor(str/8)
                for j =1:8
                    SD(i,j)=str((i-1)*8+j);
                end
            end
            origin=bin2dec(SD);
            writeback=fopen(strcat('/Users/kuangmeng/Documents/MATLAB/SecretInBMP/final/',s),'wb');
            fwrite(writeback,origin);
            fprintf('文件写入成功：%s\n',s);
        else
            fprintf('提取到的信息：%s\n',str);
        end
    end
 end

 