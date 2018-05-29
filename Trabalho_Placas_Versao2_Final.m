%%---------------------------------
% Copyright (C) 2017-2018, by Marcelo R. Petry
% This file is distributed under the MIT license
% 
% Copyright (C) 2017-2018, by Marcelo R. Petry
% Este arquivo é distribuido sob a licença MIT
%%---------------------------------

%%---------------------------------
% BLU3040 - Visao Computacional em Robotica
% Avaliacao 2 - Deteccao de placas
% Requisitos:
%   MATLAB
%   Machine Vision Toolbox 
%       P.I. Corke, “Robotics, Vision & Control�?, Springer 2011, ISBN 978-3-642-20143-1.
%       http://petercorke.com/wordpress/toolboxes/machine-vision-toolbox
%%---------------------------------

%%---------------------------------
% Objetivo 
% O reconhecimento de caracteres em arquivos de imagens é uma tarefa
% extremamente útil dada a diversificada gama de aplicações. O
% reconhecimento de placas veiculares, por exemplo, tem se demonstrado
% fundamental para o controle automático de entrada e saída de veículos em
% portos, aeroportos, terminais ferroviários, industrias e centros
% comerciais. Na robótica o reconhecimento de placas é empregado em robôs
% de vigilância e, mais recentemente, como ferramenta auxiliarem veículos
% autômonos. 
%
% O objetivo deste trabalho consiste em desenvolver uma função que receba
% imagens com placas de veículos e seja capaz de reconhecer e retornar os
% caracteres alfanuméricos utilizando template matching e features de região. 
%
%%---------------------------------

%%---------------------------------
% Dataset 
% O dataset padrão para testes contém duas imagens coloridas, uma
% placa de automovel e uma placa de motocicleta, e esta disponivel na pasta /dataset/
%%---------------------------------


%%---------------------------------
% Entregas
% Cada grupo deverá descrever a sua funcao sob a forma de relatório técnico. 
% No relatório deverá ser apresentado:
% * Contextualização
% * Breve explicação sobre as metodologias utilizas
% * Descrição da lógica 
% * Testes e resultados
% * Conclusão
% 
% Além do relatório, cada um dos grupos deverá criar um projeto público no
% GitHub e fazer upload do código desenvolvido. O link para o projeto do
% GitHub deverá constar no relatório entregue. O projeto no GitHub deverá
% conter um arquivo README explicando brevemente o algoritmo e como
% executá-lo. Cada grupo também deverá realizar uma demonstração do seu
% algoritmo durante a aula.

%%---------------------------------
% Avaliação 
% A pontuacao do trabalho será atribuida de acordo com os
% criterios estabaleceidos a seguir: 
% *Até 7.0: A funcao recebe como argumento uma imagem, e retorna um vetor com
% dois elementos contendo os três caracteres alfabeticos e os quatro
% caracteres numericos referentes ao número da placa do veículo. O
% algoritmo devera reconhecer os caracteres em pelo menos 3 imagens
% diferentes.
% *Até 8.0: Alem dos requesitos estabelecidos anteriormente, a funcao
% devera retornar os caracteres numericos referentes ao estado e a cidade.
% *Até 10.0: Alem dos requesitos estabelecidos anteriormente, as imagens
% passadas para a funcao deverao ter outros elementos alem da placa do
% veiculo, tais como parachoque, pavimento, pessoas, etc. Esta deverá
% primeiramente identificar, extrair e orientar a placa. Devem ser
% utilizadas tecnicas de conversao do espaco de cor, operacoes monadicas e
% homografia.
% *Até 12.0: Alem dos requesitos estabelecidos anteriormente, a funcao
% devera receber video, de arquivo ou da webcam, e retornar os
% caracteres da placa.
%%---------------------------------


%%
clc
clear all

%% Leitura da imagem
% im1 = iread('placa_carro1.jpg','grey','double');
% im1 = iread('placa_carro2.jpg','grey','double');
% im1 = iread('placa_carro3.jpg','grey','double');


% im1 = iread('placa_moto1.jpg','grey','double');
% im1 = iread('placa_moto2.jpg','grey','double');
% im1 = iread('placa_moto3.jpg','grey','double');
% im1 = iread('placa_moto4.jpg','grey','double');
% im1 = iread('placa_moto5.jpg','grey','double');



%% Defini��o dos templates 
template = iread('MandatoryA2.jpg','grey','double');
templateN = iread('MandatoryN.jpg','grey','double');
abecedario = ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'];
numeros = ['0','1','2','3','4','5','6','7','8','9'];

%Tratamento dos templates
template = template <= 0.9;
templateblobs = iblobs (template,'area', [900,3000]);
templateN = templateN <= 0.9;
templateNblobs = iblobs (templateN);

% Ordena blobs do template de letras

menor=10000;
anterior = 0;
pos = 1;
for i=1:length(templateblobs)
    menor = 10000;
    for c=1:length(templateblobs)
        if templateblobs(c).uc <menor && templateblobs(c).uc > anterior
            menor = templateblobs(c).uc;
            b = c;
        end      
    end
    abc_ordem{pos} = template((templateblobs(b).vmin:templateblobs(b).vmax),(templateblobs(b).umin:templateblobs(b).umax));
    pos = pos + 1;
    anterior = templateblobs(b).uc; 
end 

aux = zeros(size(abc_ordem{9},1),size(abc_ordem{9},2)+10);
abc_ordem{9}=ipaste(aux,abc_ordem{9},[5 1]);

%ordena blobs do template de numeros

posN =1;

for i=1:length(templateNblobs)
   if (templateNblobs(i).vmax - templateNblobs(i).vmin) < 40 && (templateNblobs(i).vmax - templateNblobs(i).vmin) > 27
       blobnumero(posN)=templateNblobs(i);
       posN = posN +1; 
   end
end

menor=10000;
anterior = 0;
pos = 1;
for i=1:length(blobnumero)
    menor = 10000;
    for c=1:length(blobnumero)
        if blobnumero(c).uc <menor && blobnumero(c).uc > anterior
            menor = blobnumero(c).uc;
            b = c;
        end      
    end
    numero_ordem{pos} = templateN((blobnumero(b).vmin:blobnumero(b).vmax),(blobnumero(b).umin:blobnumero(b).umax));
    pos = pos + 1;
    anterior = blobnumero(b).uc; 
end

%% Tratamento da imagem

T1 = otsu(im1)/1.3;
im1 = im1 <= T1;
placa_carro = false;
placa_moto = false;

proporcao= size(im1,2)/size(im1,1);
if proporcao > 1.5
    placa_carro = true;
else
    placa_moto=true;
end

%% Leitura e separa��o de blobs placa moto

if placa_moto
    % Separa��o de blobs em superiores medios e inferiores
    
    blobim = iblobs (im1);
    possup = 1;
    posmed = 1;
    posinf = 1;
    for i=1:length(blobim)
        altura = blobim(i).vmax - blobim(i).vmin;
        areaim = size(im1,1)*size(im1,2);
        if blobim(i).vc < (size(im1,1)/4.3)&& blobim(i).vc > (size(im1,1)*0.036) && (altura) < (0.12*size(im1,1)) && (altura) > (0.03*size(im1,1)) && blobim(i).area > (0.0008*areaim) && blobim(i).area < (0.005*areaim)
            blobimsup(possup)= blobim(i);
            possup = possup +1;
        elseif blobim(i).vc > (size(im1,1)*0.6)&& (altura) > (0.25*size(im1,1)) && (altura) < (0.36*size(im1,1))&& blobim(i).area > (0.01*areaim)&& blobim(i).area < (0.045*areaim)
            blobiminf(posinf)= blobim(i);
            posinf = posinf +1;
        elseif blobim(i).vc < (size(im1,1)*0.6)&& blobim(i).vc > (size(im1,1)*0.24) && (altura) > (0.25*size(im1,1)) && (altura) < (0.4*size(im1,1)) && blobim(i).area > (0.01*areaim)&& blobim(i).area < (0.045*areaim)
            blobimmed(posmed)= blobim(i);
            posmed = posmed +1;
        end
    end
    
    % Ordena blobs inferiores
    
    menor=10000;
    anterior = 0;
    pos = 1;
    for i=1:length(blobiminf)
        menor = 10000;
        for c=1:length(blobiminf)
            if blobiminf(c).uc <menor && blobiminf(c).uc > anterior
                menor = blobiminf(c).uc;
                b = c;
            end      
        end
    plateinf{pos} = im1((blobiminf(b).vmin:blobiminf(b).vmax),(blobiminf(b).umin:blobiminf(b).umax));
    pos = pos + 1;
    anterior = blobiminf(b).uc; 
    end
    
    % Ordena blobs superiores
    
    menor=10000;
    anterior = 0;
    pos = 1;
    for i=1:length(blobimsup)
        menor = 10000;
        for c=1:length(blobimsup)
            if blobimsup(c).uc <menor && blobimsup(c).uc > anterior
                menor = blobimsup(c).uc;
                b = c;
            end      
        end
        platesup{pos} = im1((blobimsup(b).vmin:blobimsup(b).vmax),(blobimsup(b).umin:blobimsup(b).umax));
        pos = pos + 1;
        anterior = blobimsup(b).uc; 
    end
    
    % Ordena blobs medios
    
    menor=10000;
    anterior = 0;
    pos = 1;
    for i=1:length(blobimmed)
        menor = 10000;
        for c=1:length(blobimmed)
            if blobimmed(c).uc <menor && blobimmed(c).uc > anterior
                menor = blobimmed(c).uc;
                b = c;
            end      
        end
        platemed{pos} = im1((blobimmed(b).vmin:blobimmed(b).vmax),(blobimmed(b).umin:blobimmed(b).umax));
        pos = pos + 1;
        anterior = blobimmed(b).uc; 
    end
end

%% Leitura e separa��o de blobs placa carro

if placa_carro
    % Separa��o de blobs em superiores e inferiores
    
    blobim = iblobs (im1);
    possup = 1;
    posinf = 1;
    for i=1:length(blobim)
        altura = blobim(i).vmax - blobim(i).vmin;
        areaim = size(im1,1)*size(im1,2);
         if blobim(i).vc < (size(im1,1)/2.5) && blobim(i).vc > (size(im1,1)/5.4) &&(altura) < (0.12*size(im1,1)) && (altura) > (0.07*size(im1,1)) && blobim(i).area > (0.0002*areaim) && blobim(i).area < (0.0025*areaim)
            blobimsup(possup)= blobim(i);
            possup = possup +1;
        elseif blobim(i).vc > (size(im1,1)/2.3) && blobim(i).vc < (size(im1,1)/1.15) && (altura) > (0.39*size(im1,1)) && (altura) < (0.54*size(im1,1))
            blobiminf(posinf)= blobim(i);
            posinf = posinf +1;
        end
    end

    % Ordena blobs inferiores

    menor=10000;
    anterior = 0;
    pos = 1;
    for i=1:length(blobiminf)
        menor = 10000;
        for c=1:length(blobiminf)
            if blobiminf(c).uc <menor && blobiminf(c).uc > anterior
                menor = blobiminf(c).uc;
                b = c;
            end      
        end
        plateinf{pos} = im1((blobiminf(b).vmin:blobiminf(b).vmax),(blobiminf(b).umin:blobiminf(b).umax));
        pos = pos + 1;
        anterior = blobiminf(b).uc; 
    end 

    % Ordena blobs superiores
    
    menor=10000;
    anterior = 0;
    pos = 1;
    for i=1:length(blobimsup)
        menor = 10000;
        for c=1:length(blobimsup)
            if blobimsup(c).uc <menor && blobimsup(c).uc > anterior
                menor = blobimsup(c).uc;
                b = c;
            end      
        end
        platesup{pos} = im1((blobimsup(b).vmin:blobimsup(b).vmax),(blobimsup(b).umin:blobimsup(b).umax));
        pos = pos + 1;
        anterior = blobimsup(b).uc; 
    end
end

%% Confere placa moto

if placa_moto
    
   % Confere letras
   
    for i=1:(size(platemed,2))
        for a=1:size(abc_ordem,2)
            sizemedio=floor((size(platemed{i})+ size(abc_ordem{a}))/2);
            media = zeros(sizemedio(1),sizemedio(2));
            tamanholetra1 = imresize(platemed{i},[size(media)]);
            tamanholetra2 = imresize(abc_ordem{a},[size(media)]);
            resultado(a) = zncc(tamanholetra1,tamanholetra2); 
        end
        [val,I] = max(resultado);
        resL(i) = abecedario(I);
    end

	% Confere N�meros

    for i=1:(size(plateinf,2))
        for a=1:size(numero_ordem,2)
            sizemedio=floor((size(plateinf{i})+ size(numero_ordem{a}))/2);
            media = zeros(sizemedio(1),sizemedio(2));
            tamanholetra1 = imresize(plateinf{i},[size(media)]);
            tamanholetra2 = imresize(numero_ordem{a},[size(media)]);
            resultado2(a) = zncc(tamanholetra1,tamanholetra2); 
        end
        [val,I] = max(resultado2);
        resN(i) = numeros(I);
    end

	% Confere estado e cidade

    for i=1:size(platesup,2)
        for a=1:size(abc_ordem,2)
            sizemedio=floor((size(platesup{i})+ size(abc_ordem{a}))/2);
            media = zeros(sizemedio(1),sizemedio(2));
            tamanholetra1 = imresize(platesup{i},[size(media)]);
            tamanholetra2 = imresize(abc_ordem{a},[size(media)]);
            resultado3(a) = zncc(tamanholetra1,tamanholetra2); 
        end
        [val,I] = max(resultado3);
        resE(i) = abecedario(I);
    end 
    
    tam =length(resE);
    for i=0:(tam-3)
        resE(tam-i+1)=resE(tam-i);
    end
    resE(3)='-';
    
end

%% Confere placa carro

if placa_carro
    
    % Confere letras

    for i=1:(size(plateinf,2)-4)
        for a=1:size(abc_ordem,2)
            sizemedio=floor((size(plateinf{i})+ size(abc_ordem{a}))/2);
            media = zeros(sizemedio(1),sizemedio(2));
            tamanholetra1 = imresize(plateinf{i},[size(media)]);
            tamanholetra2 = imresize(abc_ordem{a},[size(media)]);
            resultado(a) = zncc(tamanholetra1,tamanholetra2); 
        end
        [val,I] = max(resultado);
        resL(i) = abecedario(I);
 
    end
    
    % Confere N�meros 
    

    for i=4:(size(plateinf,2))
        for a=1:size(numero_ordem,2)
            sizemedio=floor((size(plateinf{i})+ size(numero_ordem{a}))/2);
            media = zeros(sizemedio(1),sizemedio(2));
            tamanholetra1 = imresize(plateinf{i},[size(media)]);
            tamanholetra2 = imresize(numero_ordem{a},[size(media)]);
            resultado2(a) = zncc(tamanholetra1,tamanholetra2); 
        end
        [val,I] = max(resultado2);
        resN(i-3) = numeros(I);
    end
    
    % Confere estado e cidade
    
    for i=1:size(platesup,2)
        for a=1:size(abc_ordem,2)
            sizemedio=floor((size(platesup{i})+ size(abc_ordem{a}))/2);
            media = zeros(sizemedio(1),sizemedio(2));
            tamanholetra1 = imresize(platesup{i},[size(media)]);
            tamanholetra2 = imresize(abc_ordem{a},[size(media)]);
            resultado3(a) = zncc(tamanholetra1,tamanholetra2); 
        end
        [val,I] = max(resultado3);
        resE(i) = abecedario(I);
    end
    tam =length(resE);
    for i=0:(tam-3)
        resE(tam-i+1)=resE(tam-i);
    end
    resE(3)='-';
    
end

%%
plate{1} = resL;
plate{2} = resN;
plate{3} = resE;

resultado = plate