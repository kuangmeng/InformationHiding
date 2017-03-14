BMP = imread('yo.bmp');
[height,width,channels] = size(BMP);
%转化成灰度图
gray = rgb2gray(BMP);
imshow(gray);
%8X8进行DCT变换并写回
for i =1:floor(height/8)
    for j =1:floor(width/8)
        tmp = gray(8*(i-1)+1:8*i,8*(j-1)+1:j*8);
        tmp = dct2(tmp);
        for m =1:8
            for n =1:8
                gray(8*(i-1)+m,8*(j-1)+n) = tmp(m,n);
            end
        end
    end
end
%量化表
Format = [16,11,10,16,24,40,51,61;
          12,12,14,19,26,58,60,55;
          14,13,16,24,40,57,69,56;
          14,17,22,29,51,87,80,62;
          18,22,37,56,68,109,103,77;
          24,35,55,64,81,104,113,92;
          49,64,78,87,103,121,120,101;
          72,92,95,98,112,100,103,99];
 AfterFmt = gray;
 %量化
 for i=1:floor(height/8)*8
     if(mod(i,8) == 0)
         tmpi = 8;
     else
         tmpi = mod(i,8);
     end
     for j=1:floor(width/8)*8
         if(mod(j,8) == 0)
             tmpj = 8;
         else
             tmpj = mod(j,8);
         end
         AfterFmt(i,j) = round(gray(i,j)/Format(tmpi,tmpj));
     end
 end
 %F3隐写
 Secret = '00011110110';
 LEN = length(Secret);
 index = 1;
 for i =1:floor(height/8)
    for j =1:floor(width/8)
        tmp = AfterFmt(8*(i-1)+1:8*i,8*(j-1)+1:j*8);
        if index <= LEN
            for m =1:8
                for n =1:8
                    if abs(tmp(m,n)) == 1
                        if Secret(index) == 0
                            tmp(m,n) = 0
                        else 
                            index = index + 1;
                        end
                    elseif mod(abs(tmp(m,n)),2) == 0 && tmp(m,n) ~= 0
                        if Secret(index) == 1
                            index = index+1;
                            if tmp(m,n)<0
                                tmp(m,n) = tmp(m,n) - 1;
                            else
                                tmp(m,n) = tmp(m,n) + 1;
                            end
                        else
                            index = index+1;
                        end
                    elseif mod(abs(tmp(m,n)),2) == 1 && abs(tmp(m,n)) ~= 1
                        if Secret(index) == 0
                            index = index+1;
                            if(tmp(m,n)<0)
                                tmp(m,n) = tmp(m,n) + 1;
                            else
                                tmp(m,n) = tmp(m,n) - 1;
                            end
                        else
                            index = index+1;
                        end
                    end
                end
            end
        end
        for m =1:8
            for n =1:8
                AfterFmt(8*(i-1)+m,8*(j-1)+n) = tmp(m,n);
            end
        end
    end
 end
%提取信息并还原图像矩阵
str = '';
index = 1;
 for i =1:floor(height/8)
    for j =1:floor(width/8)
        tmp = AfterFmt(8*(i-1)+1:8*i,8*(j-1)+1:j*8);
        if index <= LEN
            for m =1:8
                for n =1:8
                    if mod(abs(tmp(m,n)),2) == 0 && tmp(m,n) ~= 0
                        str = strcat(str,'0');
                        index = index + 1;
                        if tmp(m,n) > 0
                            tmp(m,n) = tmp(m,n) + 1;
                        else
                            tmp(m,n) = tmp(m,n) - 1;
                        end
                    elseif mod(abs(tmp(m,n)),2) == 1
                        str = strcat(str,'1');
                        index = index + 1;
                        if tmp(m,n) > 0
                            tmp(m,n) = tmp(m,n) - 1;
                        else
                            tmp(m,n) = tmp(m,n) + 1;
                        end
                    end 
                end
            end
        end
        for m =1:8
            for n =1:8
                AfterFmt(8*(i-1)+m,8*(j-1)+n) = tmp(m,n);
            end
        end
    end
 end
%反量化
 for i=1:floor(height/8)*8
     if(mod(i,8) == 0)
         tmpi = 8;
     else
         tmpi = mod(i,8);
     end
     for j=1:floor(width/8)*8
         if(mod(j,8) == 0)
             tmpj = 8;
         else
             tmpj = mod(j,8);
         end
         gray(i,j) = AfterFmt(i,j)*Format(tmpi,tmpj);
     end
 end
 %8X8进行IDCT变换并写回
for i =1:floor(height/8)
    for j =1:floor(width/8)
        tmp = gray(8*(i-1)+1:8*i,8*(j-1)+1:j*8);
        tmp = idct2(tmp);
        for m =1:8
            for n =1:8
                gray(8*(i-1)+m,8*(j-1)+n) = tmp(m,n);
            end
        end
    end
end
imshow(gray);
 