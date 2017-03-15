road = input('��������ͼƬ·��:','s');
BMP = imread(strcat('/Users/kuangmeng/Documents/MATLAB/SecretInBMP/init/',road));
[height,width,channels] = size(BMP);
%ת���ɻҶ�ͼ
gray = rgb2gray(BMP);
%8X8����DCT�任��д��
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
%������
Format = [16,11,10,16,24,40,51,61;
          12,12,14,19,26,58,60,55;
          14,13,16,24,40,57,69,56;
          14,17,22,29,51,87,80,62;
          18,22,37,56,68,109,103,77;
          24,35,55,64,81,104,113,92;
          49,64,78,87,103,121,120,101;
          72,92,95,98,112,100,103,99];
%����
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
         tmpk = round(gray(i,j)/Format(tmpi,tmpj));
         gray(i,j) = tmpk;
     end
end
%�жϿ���д����λ��
sizes = 0;
for i = 1:floor(height/8)*8
    for j = 1:floor(width/8)*8
        if(gray(i,j) ~= 0)
            sizes = sizes + 1;
        end
    end
end
fprintf('����Ƕ����Ϣλ����%dλ��\n',sizes); 
 %F3��д
 s = input('����������Ϣ���ļ�:','s');
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
 fprintf('��Ƕ����Ϣλ����%dλ��\n',LEN);
 if LEN <= sizes
    choice = input('ѡ����д��ʽ����1��JSTEG��д��2��F3��д��','s');
 end
 index = 1;
 if choice == '1'
     for i =1:floor(height/8)
        for j =1:floor(width/8)
            tmp = gray(8*(i-1)+1:8*i,8*(j-1)+1:j*8);
            for m =1:8
                for n =1:8
                    if (abs(tmp(m,n)) ~= 1 && mod(abs(tmp(m,n)),2) == 1 && index <=LEN)
                        if Secret(index) == '0'
                            if tmp(m,n)>0
                                tmp(m,n) = tmp(m,n) -1;
                            else
                                tmp(m,n) = tmp(m,n) +1;
                            end
                        end   
                        index = index + 1;                     
                    elseif (mod(abs(tmp(m,n)),2) == 0 && tmp(m,n) ~= 0 && index <=LEN)
                        if Secret(index) == '1'
                            if tmp(m,n)>0
                                tmp(m,n) = tmp(m,n) +1;
                            else
                                tmp(m,n) = tmp(m,n) -1;
                            end
                        end   
                        index = index + 1; 
                    end
                end
            end
            gray(8*(i-1)+1:8*i,8*(j-1)+1:j*8)=tmp;
        end
     end
 elseif choice == '2'
    for i =1:floor(height/8)
        for j =1:floor(width/8)
            tmp = gray(8*(i-1)+1:8*i,8*(j-1)+1:j*8);
            for m =1:8
                for n =1:8
                    if abs(tmp(m,n)) == 1 && index <=LEN
                        if Secret(index) == '0'
                            tmp(m,n) = 0;
                        else 
                            index = index + 1;
                        end
                    elseif mod(abs(tmp(m,n)),2) == 0 && tmp(m,n) ~= 0 && index <=LEN
                        if Secret(index) == '1'
                            index = index+1;
                            if tmp(m,n)>0
                                tmp(m,n) = tmp(m,n) - 1;
                            else
                                tmp(m,n) = tmp(m,n) + 1;
                            end
                        else
                            index = index+1;
                        end
                    elseif mod(abs(tmp(m,n)),2) == 1 && abs(tmp(m,n)) ~= 1 && index <=LEN
                        if Secret(index) == '0'
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
            gray(8*(i-1)+1:8*i,8*(j-1)+1:j*8)=tmp;
        end
    end
 else    
 end
 fprintf('*****��Ϣ��д�ɹ���*****\n\n*****���濪ʼ��ԭ��*****\n');
%  %������
%  backtmp = gray;
%  for i=1:floor(height/8)*8
%      if(mod(i,8) == 0)
%          tmpi = 8;
%      else
%          tmpi = mod(i,8);
%      end
%      for j=1:floor(width/8)*8
%          if(mod(j,8) == 0)
%              tmpj = 8;
%          else
%              tmpj = mod(j,8);
%          end
%          tmpk = backtmp(i,j)*Format(tmpi,tmpj);
%          backtmp(i,j) = tmpk;
%      end
%  end
% %8X8����IDCT�任��д��
% for i =1:floor(height/8)
%     for j =1:floor(width/8)
%         tmp = backtmp(8*(i-1)+1:8*i,8*(j-1)+1:j*8);
%         tmp = idct2(tmp);
%         for m =1:8
%             for n =1:8
%                 backtmp(8*(i-1)+m,8*(j-1)+n) = tmp(m,n);
%             end
%         end
%     end
% end
% imshow(gray);

%��ȡ��Ϣ
str = '';
index = 1;
if choice == '1'
    for i =1:floor(height/8)
        for j =1:floor(width/8)
            tmp = gray(8*(i-1)+1:8*i,8*(j-1)+1:j*8);
            for m =1:8
                for n =1:8
                    if mod(abs(tmp(m,n)),2) == 0 && tmp(m,n) ~= 0 && index<=LEN
                        str = strcat(str,'0');
                        index = index + 1;
                    elseif mod(abs(tmp(m,n)),2) == 1 && abs(tmp(m,n)) ~= 1 && index<=LEN
                        str = strcat(str,'1');
                        index = index + 1;
                    end 
                end
            end   
        end
    end     
elseif choice == '2'
    for i =1:floor(height/8)
        for j =1:floor(width/8)
            tmp = gray(8*(i-1)+1:8*i,8*(j-1)+1:j*8);
            for m =1:8
                for n =1:8
                    if mod(abs(tmp(m,n)),2) == 0 && tmp(m,n) ~= 0 && index<=LEN
                        str = strcat(str,'0');
                        index = index + 1;
                    elseif mod(abs(tmp(m,n)),2) == 1 && index<=LEN
                        str = strcat(str,'1');
                        index = index + 1;
                    end 
                end
            end   
        end
    end
else
    str='';
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
        fprintf('�ļ�д��ɹ���%s\n',s);
    else
        fprintf('��ȡ������Ϣ��%s\n',str);
    end
end

 