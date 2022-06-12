function [X,Y] = Sur_Coevolution(Data,Ens,Train,Xind,Mind,Sim,bu,bd,N,gmax,W,B,C,P)

dim = length(bu); %ά��
g = 0;
[~,ind] = sort(Data(:,end));
S = Data(ind(1:ceil(N/2)),:);
pc=1.0;  %Crossover Probability �������
pm=1/dim;  %Mutation Probability �������

rng('shuffle');
k = randperm(length(Ens),1);
model = Ens{k};  xind = Xind{Mind(k)};
ldim = length(xind);  %������������ά��
train = Train{Mind(k)};
X = S(:,1:dim);  Y = S(:,dim+1);
% aX = S(:,xind);  aY = S(:,dim+1);
X0 = initialize_pop(N/2,dim,bu,bd); %��ʼ����������ʼ��ȺX
Y0 = Ens_predictor(X0,Ens,Train,Xind,Mind,Sim,W,B,C,P);
X = [X;X0];  Y = [Y;Y0];
aX = initialize_pop(N,ldim,bu(:,xind),bd(:,xind)); %��ʼ�����������ĳ�ʼ��ȺaX
% aY = rbfpredict(model,train(:,1:end-1),aX);
i = Mind(k);
aY = RBF_predictor(W(i,:),B(i),C{i},P(:,i),aX);
while g <= gmax
    
    X1 = SBX(X,bu,bd,pc,N/2);
    X2 = mutation(X1(1:N/2,:),bu,bd,pm,N/2);
    aX1 = SBX(aX,bu(:,xind),bd(:,xind),pc,N/2);
    aX2 = mutation(aX1(1:N/2,:),bu(:,xind),bd(:,xind),pm,N/2);
%     X2 = DE(X,Y,bu,bd,0.8,0.8,6);  % 6 --> DE/best/1/bin
%     aX2 = DE(aX,aY,bu(:,xind),bd(:,xind),0.8,0.8,6);
    X3 = X2;  X3(:,xind) = aX2;
    X = [X;X2;X3];
    aX3 = X2(:,xind);
    aX = [aX;aX2;aX3];
    y = Ens_predictor([X2;X3],Ens,Train,Xind,Mind,Sim,W,B,C,P);
%     ay = rbfpredict(model,train(:,1:end-1),[aX2;aX3]);
    ay = RBF_predictor(W(i,:),B(i),C{i},P(:,i),[aX2;aX3]);
    Y = [Y;y];
    aY = [aY;ay];
%     y = Ens_predictor([X2;X3],Ens,Train,Xind,Mind);
%     Y = [Y;y];
%     Y = Ens_predictor(X,Ens,Train,Xind,Mind);
%     aY = rbfpredict(model,train(:,1:end-1),aX);
    [sY,is1] = sort(Y);  %��Ӧֵ����
    [saY,is2] = sort(aY);
    X = X(is1(1:N),:);  %ѡ��ǰN��
    Y = Y(is1(1:N),1);
    aX = aX(is2(1:N),:);
    aY = aY(is2(1:N),1);
    g = g + 1;
end

end

function y = Ens_predictor(X,Ens,Train,Xind,Mind,Sim,W,B,C,P)

N = size(X,1);
K = length(Ens);
pre = zeros(N,K);
for i = 1 : K
    
    S = Train{Mind(i)};
%     pre(:,i) = rbfpredict(Ens{i},S(:,1:end-1),X(:,Xind{Mind(i)}));
    I = Mind(i);
    pre(:,i) = RBF_predictor(W(I,:),B(I),C{I},P(:,I),X(:,Xind{Mind(i)}));
end
% y = mean(pre,2);
sim = 1./Sim;
w = sim(Mind(1:K))/sum(sim(Mind(1:K)));
wpre = repmat(w,N,1) .* pre;
y = sum(wpre,2);
end
