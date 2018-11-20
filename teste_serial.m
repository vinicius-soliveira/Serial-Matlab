
delete(instrfindall);  % deletando portas seriais abertas no Matlab
s = instrfind('Port','COM31'); %instanciando a porta serial COM31

if isempty(s) %verificando a disponibilidade da porta escolhida, caso livre configura
s = serial('COM31');
set(s,'BaudRate', 9600);
set(s,'DataBits', 8);
set(s,'StopBits', 1);
set(s,'Parity', 'none');
set(s, 'Timeout', 1.1);
set(s, 'FlowControl', 'hardware');
set(s, 'InputBufferSize', 30);
else
    fclose(s);
    s = s(1);
end

fopen(s); %abre a porta serial

%configurando a imagem dos gráfico1
figureHandle1 = figure('NumberTitle','off','Name','Curva de Temperatura','Color',[1 1 1],'Visible','off');

% configurando os eixos
axesHandle1 = axes('Parent',figureHandle1,'YGrid','on','YColor',[0 0 0],'XGrid','on','XColor',[0 0 0],'Color',[1 1 1]);

hold on
plotHandle1 = plot(axesHandle1,NaN,NaN,'LineWidth',1,'Color',[1 0 0]);
plotHandle2 = plot(axesHandle1,NaN,NaN,'LineWidth',1,'Color',[0 1 0]);
plotHandle3 = plot(axesHandle1,NaN,NaN,'LineWidth',1,'Color',[0 0 1]);

grid on

xlabel('Tempo','FontWeight','bold','FontSize',14,'Color',[0 0 0]);

ylabel('Temperatura(°C)','FontWeight','bold','FontSize',14,'Color',[0 0 0]);

title('Curvas de Temperatura','FontSize',15,'Color',[0 0 0]);

legend({'Top', 'Bottom', 'Side'} ,'FontSize',8,'FontWeight','bold');

%configurando a imagem dos gráfico4
figureHandle2 = figure('NumberTitle','off','Name','Curva de Tensão','Color',[1 1 1],'Visible','off');

% configurando os eixos
axesHandle2 = axes('Parent',figureHandle2,'YGrid','on','YColor',[0 0 0],'XGrid','on','XColor',[0 0 0],'Color',[1 1 1]);

plotHandle4 = plot(axesHandle2,NaN,NaN,'LineWidth',1,'Color',[0 0 0]);
grid on

xlabel('Tempo','FontWeight','bold','FontSize',14,'Color',[0 0 0]);

ylabel('Tensão(V)','FontWeight','bold','FontSize',14,'Color',[0 0 0]);

title('Curva de Tensão','FontSize',15,'Color',[0 0 0]);

%configurando a imagem dos gráfico5
figureHandle3 = figure('NumberTitle','off','Name','Diferença de temperaturas entre placas','Color',[1 1 1],'Visible','off');

% configurando os eixos
axesHandle3 = axes('Parent',figureHandle3,'YGrid','on','YColor',[0 0 0],'XGrid','on','XColor',[0 0 0],'Color',[1 1 1]);

hold on
plotHandle5 = plot(axesHandle3,NaN,NaN,'LineWidth',1,'Color',[1 1 0]);
plotHandle6 = plot(axesHandle3,NaN,NaN,'LineWidth',1,'Color',[1 0 1]);

grid on
xlabel('Tempo','FontWeight','bold','FontSize',14,'Color',[0 0 0]);

ylabel('Temperatura (°C)','FontWeight','bold','FontSize',14,'Color',[0 0 0]);

title('Diferença de Temperatura','FontSize',15,'Color',[0 0 0]);

legend({'Top - Bottom', 'Top-Side'} ,'FontSize',8,'FontWeight','bold');

while 1
  pause(2);
  t = clock; 
  
  if mod(s.BytesAvailable, 30) == 0 && s.BytesAvailable ~=0
       
  dado=fread(s);% leitura da porta serial
  
  % conversão AD
  temp=(256*dado(22)+dado(23))*(120/1023);
  temp2=(256*dado(24)+dado(25))*(120/1023);
  temp3=(256*dado(26)+dado(27))*(120/1023);
  tensao =(256*dado(28)+dado(29))*(1.2/1023);
  diff = temp -temp2;
  diff2 = temp-temp3;
  
  time =now;
 
  enviar = [t,temp, temp2, temp3, tensao, temp-temp2, temp-temp3, temp2-temp3]; %dados a serem enviados
  dlmwrite('dados_Lixo.csv', enviar, '-append');%criando arquivo .csv
  
  
  %plotando os gráficos
  set(plotHandle1,'XData', [get(plotHandle1, 'XData'), time],'YData', [get(plotHandle1, 'YData'),temp]);
  set(plotHandle2,'XData', [get(plotHandle2, 'XData'), time],'YData', [get(plotHandle2, 'YData'),temp2]);
  set(plotHandle3,'XData', [get(plotHandle3, 'XData'), time],'YData', [get(plotHandle3, 'YData'),temp3]);
  datetick(axesHandle1,'x',13);
  set(figureHandle1,'Visible','on');
   
  set(plotHandle4,'XData', [get(plotHandle4, 'XData'), time],'YData', [get(plotHandle4, 'YData'),tensao]);
  datetick(axesHandle2,'x',13);
  set(figureHandle2,'Visible','on');
  
  set(plotHandle5,'XData', [get(plotHandle5, 'XData'), time],'YData', [get(plotHandle5, 'YData'),diff]);
  set(plotHandle6,'XData', [get(plotHandle6, 'XData'), time],'YData', [get(plotHandle6, 'YData'),diff2]);
  datetick(axesHandle3,'x',13);
  set(figureHandle3,'Visible','on');
   
  dado=0; % limpa a buffer

  end
       
end
fclose(s);
delete(s);
clear s;

