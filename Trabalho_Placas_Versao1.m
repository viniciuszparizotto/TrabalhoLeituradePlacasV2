clear all
clc
%Im1=iread('IMG_4426.JPG','grey');
template=iread('mandator_specimen.jpg','grey','double');
abecedario = ['a','b','d','e','f','h','i','j','k','l','m','g','c','n','o','p','q','r','s','t','u','v','w','x','y','z'];
numeros = ['0','1','2','3','4','5','6','7','8','9'];

t2 = otsu(template);
% 
% %imagem 
% Im1=iread('01.jpg','grey','double');
% t = otsu(Im1);
% Im1=Im1<=t; %imagem 1
% aceitavel=-0.600;
% aceitaveletras=-0.600;
% on=0;

%imagem 2
% Im1=iread('02.jpg','grey','double');
% t = otsu(Im1);
% Im1=Im1<=t; 
% aceitavel=-0.60;
% aceitaveletras=-0.70;
% on=0;


%Imagem 3
Im1=iread('03.jpg','grey','double');
t = otsu(Im1);
Im1=Im1<=0.54; 
aceitavel=-0.68;
aceitaveletras=-0.5;
on=1;
%%
template=template<=t2;
f=iblobs(Im1,'boundary','class',1);

f2=iblobs(template,'boundary','class',1);
figure
idisp(Im1);
f.plot_boundary('r.')
f.plot_box('g')
% figure
% idisp(template);
% f2.plot_boundary('r.')
% f2.plot_box('g')

anterior = 0;
pos = 1;
%verificar a ordem
% for i=1:length(f2)
%     menor = 10000;
%     for c=1:length(f2)
%         if f2(c).uc <menor && f2(c).uc > anterior
%             menor = f2(c).uc;
%             b = c;
%         end      
%     end
%     temp{pos} = template((f2(b).vmin:f2(b).vmax),(f2(b).umin:f2(b).umax));
% 
%     pos = pos + 1;
%     anterior = f2(b).uc; 
% end 
for i=1:67
    temp{i} = template((f2(i).vmin:f2(i).vmax),(f2(i).umin:f2(i).umax));
end
%% template Letras
for i=1:26
    templateLetras{i} = temp{i};
end
%% template Letras
pos=1;
for i=53:63
    templateNumeros{pos} = temp{i};
    pos=pos+1;
end

anterior = 0;
pos = 1;
%verificar a ordem
for i=1:length(f)
    menor = 10000;
    for c=1:length(f)
        if f(c).uc <menor && f(c).uc > anterior
            menor = f(c).uc;
            b = c;
        end      
    end
    img2{pos} = Im1((f(b).vmin:f(b).vmax),(f(b).umin:f(b).umax));

    pos = pos + 1;
    anterior = f(b).uc; 
end 
wx=1;
for i=1:length(f)
[m,n]=size(img2{i}); 
area=m*n;
        if area>100
           img{wx}=img2{i}
           wx=wx+1;
        end
end
o=1;
lenght1=length(img);
for tea=1:length(templateLetras)
for i=1:lenght1
  
        im2=isamesize(img{i},templateLetras{tea});
        im2=im2<=t;
        if size(im2)==size(templateLetras{tea})        
        S{i}=zncc(im2,temp{tea});
        if S{i}<aceitaveletras
        VetorSaida(o,1)=i;
        VetorSaida(o,3)=S{i};
        VetorSaida(o,2)=tea;
        o=o+1;
        end
        else
            i=i+1;
        end
      end
end

 
o=1;
for tea=1:length(templateNumeros)
for i=1:lenght1

      
        im2=isamesize(img{i},templateNumeros{tea});
        im2=im2<=t;
        if size(im2)==size(temp{tea})        
        S{i}=zncc(im2,templateNumeros{tea});
        if S{i}<aceitavel
        VetorSaidaNumeros(o,1)=i;
        VetorSaidaNumeros(o,3)=S{i};
        VetorSaidaNumeros(o,2)=tea;
        o=o+1;
        end
end
    
        end
end

resL = NaN;

[~,idx] = sort(VetorSaida(:,1)); % sort just the first column
VetorSaida2 = VetorSaida(idx,:);   % sort the whole matrix using the sort indices
[~,idx] = sort(VetorSaidaNumeros(:,1)); % sort just the first column
VetorSaidaNumeros2 = VetorSaidaNumeros(idx,:);   % sort the whole matrix using the sort indices
   if on==1
    posicao=VetorSaida2(1,2);
    resL = strcat(resL,abecedario(posicao));
    posicao=VetorSaida2(7,2);
    resL = strcat(resL,abecedario(posicao));
    posicao=VetorSaida2(9,2);
    resL = strcat(resL,abecedario(posicao));
    else
for a=1:3
  
      
    posicao=VetorSaida2(a,2);
    resL = strcat(resL,abecedario(posicao));
     end
end
for a=1:4
    posicao=VetorSaidaNumeros2(a,2);
   
    
    resL = strcat(resL,numeros(posicao));
    
end

resL