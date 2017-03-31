[fn, pn] = uigetfile({'*.bmp'}, '选择图片');
name = strcat(pn, fn);
[fn, pn] = uigetfile({'*.bmp'}, '选择图片');
name2 = strcat(pn, fn);
RSP(name,1);
RSP(name2,2);
function RSP(name,x)
BMP=imread(name);
[~,~,channels] = size(BMP);
if channels == 3 
    t = rgb2gray(imread(name));% 转换成灰度图像
else
    t = BMP;
end
[p,q]=size(t);
I = t(1:p, 1:q);
sz = size(I);
m = floor(sz(1) / 8);
n = floor(sz(2) / 8);
rs = zeros(10, 4);% 生成零矩阵
cor = zeros(1, 3);
M = randsrc(8, 8, [0 1]);% 生成0,1随机矩阵
tmp = zeros(8, 8);
for i = 1 : 10
     r = floor(sz(1) * i / 10);% floor为向下取整
     c = floor(sz(2) * i / 10);
     msg = randsrc(r, c, [0 1]);
     s = I;
     s(1:r, 1:c) = bitset(s(1:r, 1:c), 1, msg);
    %计算 RS
    for j = 1 : m
        rv = [(j - 1) * 8 + 1 : j * 8];
        for k = 1 : n
            cv = [(k - 1) * 8 + 1 : k * 8];
            tmp = s(rv, cv);
            cor(1) = Space(tmp);% 不进行任何翻转，直接求图像块空间相关性
            cor(2) = Space(f1(tmp, M));% 经过非负翻转图像块空间相关性
            cor(3) = Space(f_1(tmp, M));% 经过非正翻转图像块空间相关性
            if cor(2) > cor(1)
            %计算 Rm
                rs(i, 1) = rs(i, 1) + 1;% f1作用下正则组个数
            else
                if cor(2) < cor(1)
            %计算 Sm
                    rs(i, 2) = rs(i, 2) + 1;% f1作用下奇异组个数
                end;
            end;
            if cor(3) > cor(1)
            %计算 R-m
                rs(i, 3) = rs(i, 3) + 1;% f_1作用下正则组个数
            else
                if cor(3) < cor(1)
            %计算 S-m
                    rs(i, 4) = rs(i, 4) + 1;% f_1作用下奇异组个数
                end
            end
        end
    end
end
rs = rs / (m * n);
if(x == 1)
    subplot(121);
    plot([0.1:0.1:1.0], rs(:, 1),[0.1:0.1:1.0],rs(:, 2),[0.1:0.1:1.0],rs(:, 3),[0.1:0.1:1.0],rs(:, 4)),title('原图像RS分析曲线');
    legend('R+','S+','R-','S-');
else
    subplot(122);
    plot([0.1:0.1:1.0], rs(:, 1),[0.1:0.1:1.0],rs(:, 2),[0.1:0.1:1.0],rs(:, 3),[0.1:0.1:1.0],rs(:, 4)),title('隐写图RS分析曲线');
    legend('R+','S+','R-','S-');
end
end
function y = Space(x)
% 计算指定图像块的空间相关性
% 8*8图像块之字形扫描的位置顺序
    index = [1, 1; 1, 2; 2, 1; 3, 1; 2, 2; 1, 3; 1, 4; 2, 3; 3, 2; 4, 1; 5, 1; 4, 2; 3, 3; 2, 4; 1, 5;...
        1, 6; 2, 5; 3, 4; 4, 3; 5, 2; 6, 1; 7, 1; 6, 2; 5, 3; 4, 4; 3, 5; 2, 6; 1, 7;...
        1, 8; 2, 7; 3, 6; 4, 5; 5, 4; 6, 3; 7, 2; 8, 1; 8, 2; 7, 3; 6, 4; 5, 5; 4, 6; 3,7; 2, 8;...
        3, 8; 4, 7; 5, 6; 6, 5; 7, 4; 8, 3; 8, 4; 7, 5; 6, 6; 5, 7; 4, 8; 5, 8; 6, 7; 7, 6; 8, 5;...
        8, 6; 7, 7; 6, 8; 7, 8; 8, 7; 8, 8;];
    n = 64;
    y = 0;
    for i = 1 : n - 1
        r1 = index(i, 1);
        c1 = index(i, 2);
        r2 = index(i + 1, 1);
        c2 = index(i + 1, 2);
        y = y + abs(x(r1, c1) - x(r2, c2));
    end
end
function y = f_1(x, M)
% 对应于翻转图谱M，对图像块x应用非正翻转并返回结果
    szx = size(x);
    szm = size(M);
    if szx ~= szm
        fprintf(1, 'X和M必须大小相等！\n');
    end;
    y = x;
    for i = 1 : szx(1)
        for j = 1 : szx(2)
            if M(i, j) ~= 0
                odd = mod(x(i, j), 2);
                %应用负翻转，像素灰度值在2i和2i-1之间变化
                if odd == 0
                    y(i, j) = x(i, j) - 1;
                else
                    y(i, j) = x(i, j) + 1;
                end
            end
        end
    end
end
function y = f1(x, M)
% 对应于翻转图谱M，对图像块x应用非负翻转并返回结果
    szx = size(x);
    szm = size(M);
    if szx ~= szm
        fprintf(1, 'X和M必须大小相等！\n');
    end
    y = x;
    for i = 1 : szx(1)
        for j = 1 : szx(2)
            if M(i, j) ~= 0
                odd = mod(x(i, j), 2);
                %应用正翻转，像素灰度值在2i和2i+1之间变化
                if odd == 0
                    y(i, j) = x(i, j) + 1;
                else
                    y(i, j) = x(i, j) - 1;
                end
            end
        end
    end
end