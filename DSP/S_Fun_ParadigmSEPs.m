 function [sys,x0,str,ts] = S_Fun_ParadigmMEPs(t,x,u,flag)

%
% The following outlines the general structure of an S-function.
%


global TRG
global ContAux
global Estado
global PrevMode
global SjWin
global fs
global MEPaux
global Indaux

    %% NUEVAS VARIABLES
global n_epochs         % Esta creo que no es necesaria que sea global
global n_samples        % n_samples = valor del pico - sd: valor del pico + sd
global delay_in         % delay_in = valor del pico - sd
global eeg              % Será donde almacene los datos
global template         % El template debe estar normalizado ya y con smooth.
global epochs            % Cantidad de epochs que necesitamos 
global hist_corr
% La adquisicion del template se ha hecho de manera previa, ahora solo lo
% cargamos.



switch flag,
    
    
    




   %%%%%%%%%%%%%%%%%%
   % Initialization %
   %%%%%%%%%%%%%%%%%%
   case 0,
      [sys,x0,str,ts]=mdlInitializeSizes;

      %% Variables S-func.
      TRG   = 0;
      ContAux = 0;
      Estado = 0;
      PrevMode = 0;
      fs = 1200;
      MEPaux = NaN(.1*fs,1);
      Indaux = 6;
      
      
      %% Inicialización nuevas variables:
      load('template.mat')
      eeg = [];
      epochs = 4;
      n_epochs = 0;       % Sera mi contador. Cuando llegue al valor 'epochs', se procesaran los datos recogidos
      % n_samples y delay_in depende de las frecuencias (estim. y resampleo) y
      % del pico que elijamos.
      hist_corr = [];     % Historial de correlaciones
      
      %% Define figure
      WindowPosition        = [0.05 .05 .8 .8];              
      SjWin.handle          = figure('Units', 'normalized', ...
                            'position', WindowPosition, ...
                            'menubar', 'none', ...
                            'Name', 'Paradigm Window', ...
                            'color', 'w',...
                            'NumberTitle','off',...
                            'Toolbar','none');
     
      SjWin.hAxes(1) = axes('Parent',SjWin.handle,...
        'xlim',[0 100],'ylim',...
        [-1000 1000],'Color',[.7 .9 .7],'LineWidth',4,...
        'drawmode','fast','Position',[0.1 0.55 0.2 0.3]);    
      hold all;
      SjWin.LevelP1   = plot([0 100],[25 25],'--',...
                                  'Color',[1 0 0],'MarkerSize',8,...
                                  'LineWidth',2,'visible','off');
      SjWin.LevelN1   = plot([0 100],[-25 -25],'--',...
                                  'Color',[1 0 0],'MarkerSize',8,...
                                  'LineWidth',2,'visible','off');    
      SjWin.MEP(1)      = plot(linspace(0,100,.1*fs),MEPaux,...
                                  'Color',[0 0 1],'MarkerSize',8,...
                                  'LineWidth',1,'visible','on');    
      xlabel('time (ms)')
      ylabel('Amp. (uV)')  
%       axis on;
      
      SjWin.hAxes(2) = axes('Parent',SjWin.handle,...
        'xlim',[0 100],'ylim',...
        [-1000 1000],'Color','w',...
        'drawmode','fast','Position',[0.4 0.55 0.2 0.3]);
      hold all;
      SjWin.LevelP2   = plot([0 100],[25 25],'--',...
                                  'Color',[1 0 0],'MarkerSize',8,...
                                  'LineWidth',2,'visible','off');
      SjWin.LevelN2   = plot([0 100],[-25 -25],'--',...
                                  'Color',[1 0 0],'MarkerSize',8,...
                                  'LineWidth',2,'visible','off');    
      SjWin.MEP(2)      = plot(linspace(0,100,.1*fs),MEPaux,...
                                  'Color',[0 0 1],'MarkerSize',8,...
                                  'LineWidth',1,'visible','on');    
      xlabel('time (ms)')
      ylabel('Amp. (uV)')  
%       axis on;
      
      SjWin.hAxes(3) = axes('Parent',SjWin.handle,...
        'xlim',[0 100],'ylim',...
        [-1000 1000],'Color','w',...
        'drawmode','fast','Position',[0.7 0.55 0.2 0.3]);
      hold all;
      SjWin.LevelP3   = plot([0 100],[25 25],'--',...
                                  'Color',[1 0 0],'MarkerSize',8,...
                                  'LineWidth',2,'visible','off');
      SjWin.LevelN3   = plot([0 100],[-25 -25],'--',...
                                  'Color',[1 0 0],'MarkerSize',8,...
                                  'LineWidth',2,'visible','off');    
      SjWin.MEP(3)      = plot(linspace(0,100,.1*fs),MEPaux,...
                                  'Color',[0 0 1],'MarkerSize',8,...
                                  'LineWidth',1,'visible','on');    
      xlabel('time (ms)')
      ylabel('Amp. (uV)')  
%       axis on;
      
      SjWin.hAxes(4) = axes('Parent',SjWin.handle,...
        'xlim',[0 100],'ylim',...
        [-1000 1000],'Color','w',...
        'drawmode','fast','Position',[0.1 0.1 0.2 0.3]);
      hold all;
      SjWin.LevelP4   = plot([0 100],[25 25],'--',...
                                  'Color',[1 0 0],'MarkerSize',8,...
                                  'LineWidth',2,'visible','off');
      SjWin.LevelN4   = plot([0 100],[-25 -25],'--',...
                                  'Color',[1 0 0],'MarkerSize',8,...
                                  'LineWidth',2,'visible','off');    
      SjWin.MEP(4)      = plot(linspace(0,100,.1*fs),MEPaux,...
                                  'Color',[0 0 1],'MarkerSize',8,...
                                  'LineWidth',1,'visible','on');    
      xlabel('time (ms)')
      ylabel('Amp. (uV)')  
%       axis on;
      
      SjWin.hAxes(5) = axes('Parent',SjWin.handle,...
        'xlim',[0 100],'ylim',...
        [-1000 1000],'Color','w',...
        'drawmode','fast','Position',[0.4 0.1 0.2 0.3]);
      hold all;
      SjWin.LevelP5   = plot([0 100],[25 25],'--',...
                                  'Color',[1 0 0],'MarkerSize',8,...
                                  'LineWidth',2,'visible','off');
      SjWin.LevelN5   = plot([0 100],[-25 -25],'--',...
                                  'Color',[1 0 0],'MarkerSize',8,...
                                  'LineWidth',2,'visible','off');    
      SjWin.MEP(5)      = plot(linspace(0,100,.1*fs),MEPaux,...
                                  'Color',[0 0 1],'MarkerSize',8,...
                                  'LineWidth',1,'visible','on');    
      xlabel('time (ms)')
      ylabel('Amp. (uV)')  
%       axis on;
      
      SjWin.hAxes(6) = axes('Parent',SjWin.handle,...
        'xlim',[0 100],'ylim',...
        [-1000 1000],'Color','w',...
        'drawmode','fast','Position',[0.7 0.1 0.2 0.3]);
      hold all;
      SjWin.LevelP6   = plot([0 100],[25 25],'--',...
                                  'Color',[1 0 0],'MarkerSize',8,...
                                  'LineWidth',2,'visible','off');
      SjWin.LevelN6   = plot([0 100],[-25 -25],'--',...
                                  'Color',[1 0 0],'MarkerSize',8,...
                                  'LineWidth',2,'visible','off');    
      SjWin.MEP(6)      = plot(linspace(0,100,.1*fs),MEPaux,...
                                  'Color',[0 0 1],'MarkerSize',8,...
                                  'LineWidth',1,'visible','on');    
      xlabel('time (ms)')
      ylabel('Amp. (uV)')  
%       axis on;
   
   %%%%%%%%%%%
   % Output  %
   %%%%%%%%%%%
   case 3,
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    sys=mdlUpdate(t,x,u);
      
    %--- ContAux is always either increasing or reseted -- %
    ContAux         = ContAux+1;

    if u(3)~=PrevMode
        switch u(3),
            case 1,
                Indaux = 6;
                set(SjWin.hAxes(1),'ylim',[-1000 1000]);
                set(SjWin.hAxes(2),'ylim',[-1000 1000]);
                set(SjWin.hAxes(3),'ylim',[-1000 1000]);
                set(SjWin.hAxes(4),'ylim',[-1000 1000]);
                set(SjWin.hAxes(5),'ylim',[-1000 1000]);
                set(SjWin.hAxes(6),'ylim',[-1000 1000]);
                set(SjWin.LevelP1,'visible','off');
                set(SjWin.LevelP2,'visible','off');
                set(SjWin.LevelP3,'visible','off');
                set(SjWin.LevelP4,'visible','off');
                set(SjWin.LevelP5,'visible','off');
                set(SjWin.LevelP6,'visible','off');
                set(SjWin.LevelN1,'visible','off');
                set(SjWin.LevelN2,'visible','off');
                set(SjWin.LevelN3,'visible','off');
                set(SjWin.LevelN4,'visible','off');
                set(SjWin.LevelN5,'visible','off');
                set(SjWin.LevelN6,'visible','off');
                for ii=1:6
                    set(SjWin.MEP(ii),'ydata',MEPaux*NaN);
                    set(SjWin.hAxes(ii),'color','w','LineWidth',1);
                end;
                set(SjWin.hAxes(Indaux),'Color',[.7 .9 .7],'LineWidth',4);
            case 2,
                Indaux = 6;
                set(SjWin.hAxes(1),'ylim',[-50 50]) 
                set(SjWin.hAxes(2),'ylim',[-50 50]) 
                set(SjWin.hAxes(3),'ylim',[-50 50]) 
                set(SjWin.hAxes(4),'ylim',[-50 50]) 
                set(SjWin.hAxes(5),'ylim',[-50 50]) 
                set(SjWin.hAxes(6),'ylim',[-50 50]) 
                set(SjWin.LevelP1,'visible','on','ydata',[25 25]);
                set(SjWin.LevelP2,'visible','on','ydata',[25 25]);
                set(SjWin.LevelP3,'visible','on','ydata',[25 25]);
                set(SjWin.LevelP4,'visible','on','ydata',[25 25]);
                set(SjWin.LevelP5,'visible','on','ydata',[25 25]);
                set(SjWin.LevelP6,'visible','on','ydata',[25 25]);
                set(SjWin.LevelN1,'visible','on','ydata',[-25 -25]);
                set(SjWin.LevelN2,'visible','on','ydata',[-25 -25]);
                set(SjWin.LevelN3,'visible','on','ydata',[-25 -25]);
                set(SjWin.LevelN4,'visible','on','ydata',[-25 -25]);
                set(SjWin.LevelN5,'visible','on','ydata',[-25 -25]);
                set(SjWin.LevelN6,'visible','on','ydata',[-25 -25]);
                for ii=1:6
                    set(SjWin.MEP(ii),'ydata',MEPaux*NaN);
                    set(SjWin.hAxes(ii),'color','w','LineWidth',1);
                end;
                set(SjWin.hAxes(Indaux),'Color',[.7 .9 .7],'LineWidth',4);
            case 3,
                Indaux = 6;
                set(SjWin.hAxes(1),'ylim',[-200 200])
                set(SjWin.hAxes(2),'ylim',[-200 200])
                set(SjWin.hAxes(3),'ylim',[-200 200])
                set(SjWin.hAxes(4),'ylim',[-200 200])
                set(SjWin.hAxes(5),'ylim',[-200 200])
                set(SjWin.hAxes(6),'ylim',[-200 200])
                set(SjWin.LevelP1,'visible','on','ydata',[100 100]);
                set(SjWin.LevelP2,'visible','on','ydata',[100 100]);
                set(SjWin.LevelP3,'visible','on','ydata',[100 100]);
                set(SjWin.LevelP4,'visible','on','ydata',[100 100]);
                set(SjWin.LevelP5,'visible','on','ydata',[100 100]);
                set(SjWin.LevelP6,'visible','on','ydata',[100 100]);
                set(SjWin.LevelN1,'visible','on','ydata',[-100 -100]);
                set(SjWin.LevelN2,'visible','on','ydata',[-100 -100]);
                set(SjWin.LevelN3,'visible','on','ydata',[-100 -100]);
                set(SjWin.LevelN4,'visible','on','ydata',[-100 -100]);
                set(SjWin.LevelN5,'visible','on','ydata',[-100 -100]);
                set(SjWin.LevelN6,'visible','on','ydata',[-100 -100]);
                for ii=1:6
                    set(SjWin.MEP(ii),'ydata',MEPaux*NaN);
                    set(SjWin.hAxes(ii),'color','w','LineWidth',1);
                end;
                set(SjWin.hAxes(Indaux),'Color',[.7 .9 .7],'LineWidth',4);
            case 4,
                Indaux = 6;
                set(SjWin.hAxes(1),'ylim',[-1000 1000])
                set(SjWin.hAxes(2),'ylim',[-1000 1000])
                set(SjWin.hAxes(3),'ylim',[-1000 1000])
                set(SjWin.hAxes(4),'ylim',[-1000 1000])
                set(SjWin.hAxes(5),'ylim',[-1000 1000])
                set(SjWin.hAxes(6),'ylim',[-1000 1000])
                set(SjWin.LevelP1,'visible','on','ydata',[500 500]);
                set(SjWin.LevelP2,'visible','on','ydata',[500 500]);
                set(SjWin.LevelP3,'visible','on','ydata',[500 500]);
                set(SjWin.LevelP4,'visible','on','ydata',[500 500]);
                set(SjWin.LevelP5,'visible','on','ydata',[500 500]);
                set(SjWin.LevelP6,'visible','on','ydata',[500 500]);
                set(SjWin.LevelN1,'visible','on','ydata',[-500 -500]);
                set(SjWin.LevelN2,'visible','on','ydata',[-500 -500]);
                set(SjWin.LevelN3,'visible','on','ydata',[-500 -500]);
                set(SjWin.LevelN4,'visible','on','ydata',[-500 -500]);
                set(SjWin.LevelN5,'visible','on','ydata',[-500 -500]);
                set(SjWin.LevelN6,'visible','on','ydata',[-500 -500]);
                for ii=1:6
                    set(SjWin.MEP(ii),'ydata',MEPaux*NaN);
                    set(SjWin.hAxes(ii),'color','w','LineWidth',1);
                end;
                set(SjWin.hAxes(Indaux),'Color',[.7 .9 .7],'LineWidth',4);
        end;
    end;
    PrevMode = u(3);
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%% NUEVO CODIGO  %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   switch Estado
        case 0 %ESTADO 0-- IDLE --%
            if u(3) > 0   % u(3) = trigger
                Estado      = 1;
                ContAux     = 0;
                if n_epochs == 0;
                    eeg     = NaN(.1*fs,n_epochs);      % inicializo vector
                else
                    n_epochs     = n_epochs + 1;
                end
            end;
        case 1 
            % ESTADO 2: COLLECT
            if (ContAux > delay_in)  && (ContAux < delay_in + n_samples)  %fs*.1 = 100 ms   aññañdir caso de
                eeg(n_epochs, ContAux-delay_in) = u(2);
                Estado = 0;
                
            % ESTADO 3: PROCESSING
            % Si tengo todos los epochs, busco correlación    
            if (ContAux > delay_in+n_samples) && (n_epochs == epochs) % && ContAux < delay_in + n_samples
                eeg = eeg./norm(eeg);   % Ya tengo mi señal
                eeg = mean(eeg,1);
                eeg = smooth(smooth(eeg),20);
                              
                        % Correlacion cruzada para localizar máxima correlación:
                        [c, lags] = xcorr(template, eeg);
                        eeg_corr = eeg(max(lags)-length(template)+1:max(lags)); % Nos quedamos con el valor de mayor corr
                
                        % Correlacion para el valor del feedback
                        r = corr(template', eeg_corr')
                        hist_corr(end+1) = r;   % para tener un historial de las correlaciones y ver la evolucion
                
                Estado = 0;     %Cuando acabo vuelvo al estado de espera
            end                    
          
%                 set(SjWin.hAxes(Indaux),'color','w','LineWidth',1);
                
%                 if Indaux<6
%                     Indaux = Indaux+1;
%                 else
%                     Indaux = 1;
%                 end;
%                 set(SjWin.MEP(Indaux),'ydata',MEPaux);
%                 SjWin.MEP(Indaux)=plot;
%                 set(SjWin.hAxes(Indaux),'color',[.7 .9 .7],'LineWidth',4);
            end;
    end; 
%     % Dentro del while(1) (va a dar problemas??) busco todo el rato el
%     % nuevo pico. 
%     %   - Si no hay --> estado 0, break y vuelvo al while(1)
%     %   - Si hay trigger --> estado 1: almaceno datos hasta que tenga los
%     %   nº de epochs necesarios y luego doy el feedback
%     
%             % Busco el pico
%             trg = find(peaks > 0);
%             if trg == 0
%                 estado = 0;     % No hay trigger
%             else
%                 estado = 1;     % Encuentro trigger
%             end
% 
% 
%             switch(estado)
%                 case 0          % IDLE  No hace nada, vuelve a la busqueda
%                     b  % vuelve al while(1) a buscar
% 
%                 case 1          % HAY TRIGGER
%                     % EMPIEZO A RECOGER DATOS
%                     tic
%                     x = [];                      %Variable auxiliar
%                     % Almaceno datos:
%                     %   Guardo en un vector los primeros 300 ms de cada epoch:
%                     for kk=1:n_samples + delay_in
%                         x(1,kk) = signal;     %       
%                     end
%                     eeg = eeg + x(delay_in:end); %eeg = n_epochs x n_samples 
%                     n_epochs = n_epochs+1;       %Incremente contador de epochs
%                     t_adq = toc
% 
% 
%                     % Si ya tengo todos los epochs, doy el feedback:               
%                     if n_epochs == 3        % 3 son los epochs que necesito (por ejemplo)
%                         tic
%                         % Deberia quedar tiempo suficiente para hacer el procesamiento de
%                         % los datos ( Comprobado con tic-toc )
%                         eeg = eeg./n_epochs;        % Promedio la señal
%                         eeg = smooth(smooth(smooth(smooth(smooth(eeg)))));
%                         eeg = eeg./norm;            % Y normalizo
% 
% 
%                 % Correlacion cruzada para quedarme con los que me interese:
%                         [c, lags] = xcorr(template, eeg);
%                         eeg_corr = eeg(max(lags)-length(template)+1:max(lags)); % Nos quedamos con el valor de mayor corr
%                 % Correlacion para el valor del feedback
%                         r = corr(template', eeg_corr')
% 
%                         n_epochs = 0;       % limpio variables
%                         eeg = [];
% 
%                         t_proc = toc
%                     end
% 
% 
%                 end
%             
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    
    
    
%     switch Estado
%         case 0 %-- WAIT --%
%             if u(2) > 0
%                 Estado      = 1;
%                 ContAux     = 0;
%                 MEPaux      = NaN(.1*fs,1);
%             end;
%         case 1 %-- PLOT MEPS --%
%             if ContAux < fs*.1
%                 MEPaux(ContAux) = u(1);
%             else
%                 Estado      = 0;
%                 ContAux     = 0;
%                 set(SjWin.hAxes(Indaux),'color','w','LineWidth',1);
%                 
%                 if Indaux<6
%                     Indaux = Indaux+1;
%                 else
%                     Indaux = 1;
%                 end;
%                 set(SjWin.MEP(Indaux),'ydata',MEPaux);
%                 set(SjWin.hAxes(Indaux),'color',[.7 .9 .7],'LineWidth',4);
%             end;
%     end;
      
   sys = [];
  
   %-----------%
   % Terminate %
   %-----------%
   case 9,
    sys=mdlTerminate(t,x,u);

   case { 1, 2, 4}
    sys=[];

   %%%%%%%%%%%%%%%%%%%%
   % Unexpected flags %
   %%%%%%%%%%%%%%%%%%%%
   otherwise
    DAStudio.error('Simulink:blocks:unhandledFlag', num2str(flag));

end

% end sfuntmpl

%
%=============================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=============================================================================
%
function [sys,x0,str,ts,simStateCompliance]=mdlInitializeSizes

%
% call simsizes for a sizes structure, fill it in and convert it to a
% sizes array.
%
% Note that in this example, the values are hard coded.  This is not a
% recommended practice as the characteristics of the block are typically
% defined by the S-function parameters.
%
sizes = simsizes;

sizes.NumContStates  = 0;
sizes.NumDiscStates  = 0;
sizes.NumOutputs     = 0;
sizes.NumInputs      = 3;
sizes.DirFeedthrough = 1;
sizes.NumSampleTimes = 1;   % at least one sample time is needed

sys = simsizes(sizes);

%
% initialize the initial conditions
%
x0  = [];

%
% str is always an empty matrix
%
str = [];

%
% initialize the array of sample times
%
ts  = [-1 0];

% Specify the block simStateCompliance. The allowed values are:
%    'UnknownSimState', < The default setting; warn and assume DefaultSimState
%    'DefaultSimState', < Same sim state as a built-in block
%    'HasNoSimState',   < No sim state
%    'DisallowSimState' < Error out when saving or restoring the model sim state
simStateCompliance = 'UnknownSimState';

% end mdlInitializeSizes

%
%=============================================================================
% mdlDerivatives
% Return the derivatives for the continuous states.
%=============================================================================
%
function sys=mdlDerivatives(t,x,u) %#ok<INUSD,DEFNU>

sys = [];

% end mdlDerivatives

%
%=============================================================================
% mdlUpdate
% Handle discrete state updates, sample time hits, and major time step
% requirements.
%=============================================================================
%
function sys=mdlUpdate(t,x,u) %#ok<INUSD>

sys = [];
    
% end mdlUpdate

%
%=============================================================================
% mdlOutputs
% Return the block outputs.
%=============================================================================
%
function sys=mdlOutputs(t,x,u) %#ok<INUSD,DEFNU>

sys = [];

% end mdlOutputs

%
%=============================================================================
% mdlGetTimeOfNextVarHit
% Return the time of the next hit for this block.  Note that the result is
% absolute time.  Note that this function is only used when you specify a
% variable discrete-time sample time [-2 0] in the sample time array in
% mdlInitializeSizes.
%=============================================================================
%
function sys=mdlGetTimeOfNextVarHit(t,x,u) %#ok<INUSD,DEFNU>
sampleTime = 1;    %  Example, set the next hit to be one second later.
sys = t + sampleTime;

% end mdlGetTimeOfNextVarHit

%
%=============================================================================
% mdlTerminate
% Perform any end of simulation tasks.
%=============================================================================
%
function sys=mdlTerminate(t,x,u) %#ok<INUSD>
sys = [];

% end mdlTerminate

function [msg_60, msg_70] = fcn_Decode_UDP_Msg(ID, udp_msg)
   global therapy
   global arm
   global initAngles
   global targetAngles
   global HLCstate
   
   msg_60 = 0;
   msg_70 = 0;
   
      if(ID == 1)
%          fprintf('@ UDP MSG (1) --> HLC State: %d - NewState: ', HLCstate);
%          if((udp_msg(2) == 6) && (HLCstate == 5))
         if((udp_msg(2) == 6))
            msg_60 = 1;
            HLCstate = udp_msg(2);
%          elseif(((udp_msg(2) == 3) || (udp_msg(2) == 0)) && (HLCstate > 3))
         elseif((HLCstate > udp_msg(2)))
            msg_70 = 1;
            HLCstate = udp_msg(2);
         else
            HLCstate = udp_msg(2);
         end
%          fprintf('%d; MSG60: %d; MSG70: %d \n', udp_msg(2), msg_60, msg_70);
         
      elseif(ID == 11)
         therapy = udp_msg(2);
         arm = udp_msg(1);
%          fprintf('@ UDP MSG (11) --> Therapy Config --> Therapy: %d, Arm: %d \n', therapy, arm);

      elseif(ID == 60)
         % End MOV State
         msg_60 = 1;
         
      elseif(ID == 70)
         % End FinTR state
         msg_70 = 1;

      elseif(ID == 90)
         % Arm position
            arm_angles(1) = udp_msg(3);
            arm_angles(2) = udp_msg(4);
            arm_ref(1) = udp_msg(1);
            arm_ref(2) = udp_msg(2);
            fcn_UpdatePaintV1(arm_angles, arm_ref);

      elseif(ID == 91)
         endX = udp_msg(1);
         endY = udp_msg(2);
         endZ = udp_msg(3);
         
      elseif(ID == 100)
         % Performance
         perform(1) = udp_msg(1);
         perform(2) = udp_msg(2);
%          fprintf('@ UDP MSG (Performance) --> P1: %d; P2: %d\n', perform(1), perform(2));
         fcn_ShowPerformance(perform);
         
      elseif(ID == 110)
         % Init Angles
         initAngles(1) = udp_msg(1);
         initAngles(2) = udp_msg(2);
         targetAngles(1) = udp_msg(3);
         targetAngles(2) = udp_msg(4);
%          fprintf('@ UDP MSG (110) --> Init: %d %d; Target: %d %d \n', initAngles(1), initAngles(2), targetAngles(1), targetAngles(2));
      end
%    end
   
   


function fcn_Set1DFigurePosition()
   global SjWin
   global arm
   global therapy 
   
   if(therapy <= 3)
      if(arm == 0)
         xInit = 1; yInit = 0.5;
         xFinal = 0; yFinal = 0.5;
         xCurrent = xInit; yCurrent = yInit;
         axesX = 0.65; axesY = 0.01;
      else
         xInit = 0; yInit = 0.5;
         xFinal = 1; yFinal = 0.5;
         xCurrent = xInit; yCurrent = yInit;
         axesX = 0.18; axesY = 0.01;
      end
   else
      xInit = 0.5; yInit = 0;
      xFinal = 0.5; yFinal = 1;
      xCurrent = xInit; yCurrent = yInit;
      axesX = 0.44; axesY = 0.01;
   end
   
   set(SjWin.barAxes,'Position',[axesX axesY 0.3 0.13]);
   
   set(SjWin.Paradigm.initPos, 'XData', xInit,'YData', yInit);
   set(SjWin.Paradigm.armPos, 'XData', xCurrent,'YData', yCurrent);
   set(SjWin.Paradigm.finalPos, 'XData', xFinal,'YData', yFinal);
   set(SjWin.Paradigm.refPos, 'XData', xCurrent,'YData', yCurrent);
   % Reset Faces Performance
   set(SjWin.Paradigm.imag1,'CData',SjWin.Paradigm.face_excelente_wb);
   set(SjWin.Paradigm.imag2,'CData',SjWin.Paradigm.face_muybien_wb);
   set(SjWin.Paradigm.imag3,'CData',SjWin.Paradigm.face_bien_wb);
   set(SjWin.Paradigm.imag4,'CData',SjWin.Paradigm.face_mal_wb);

   

function fcn_Set2DFigurePosition()
   global SjWin
   global arm
   
   if(arm == 0)
      xInit = 1; yInit = 0;
      xFinal = 0; yFinal = 1;
      xCurrent = xInit; yCurrent = yInit;
      axesX = 0.65; axesY = 0.01;
   else
      xInit = 0; yInit = 0;
      xFinal = 1; yFinal = 1;
      xCurrent = xInit; yCurrent = yInit;
      axesX = 0.18; axesY = 0.01;
   end
   
   set(SjWin.barAxes,'Position',[axesX axesY 0.3 0.13]);
     
   set(SjWin.Paradigm.initPos, 'XData', xInit,'YData', yInit);
   set(SjWin.Paradigm.armPos, 'XData', xCurrent,'YData', yCurrent);
   set(SjWin.Paradigm.finalPos, 'XData', xFinal,'YData', yFinal);
   set(SjWin.Paradigm.refPos, 'XData', xCurrent,'YData', yCurrent);
   % Reset Faces Performance
   set(SjWin.Paradigm.imag1,'CData',SjWin.Paradigm.face_excelente_wb);
   set(SjWin.Paradigm.imag2,'CData',SjWin.Paradigm.face_muybien_wb);
   set(SjWin.Paradigm.imag3,'CData',SjWin.Paradigm.face_bien_wb);
   set(SjWin.Paradigm.imag4,'CData',SjWin.Paradigm.face_mal_wb);



function fcn_UpdatePaintV1(angles, reference)
   global SjWin
   global therapy
   global arm
   global initAngles
   global targetAngles
   global upperLimit
   global lowerLimit
   global Estado
   
   Mov_State = 3;
   
   delta(1) = targetAngles(1)-initAngles(1);
   delta(2) = targetAngles(2)-initAngles(2);
   error = 0;
   
   switch (therapy) 
      case{1,2} %% Elbow Extension or Elbow+Wrist Extension
         if(delta(2) ~= 0)
            if(arm == 0)
              % Calculate current position --> from 0 to 1
              currentX = 1-((angles(2) - initAngles(2))/delta(2));
              % Calculate Reference Position --> from 0 to 1
               if(Estado == Mov_State)
                  refX = 1-((reference(2) - initAngles(2))/delta(2));
               else
                  refX = 1;
               end
            else
               % Calculate current position --> from 0 to 1
               currentX = (angles(2) - initAngles(2))/delta(2);
               % Calculate Reference Position --> from 0 to 1
               if(Estado == Mov_State)
                  refX = (reference(2) - initAngles(2))/delta(2);
               else
                  refX = 0; 
               end
            end
            currentY = 0.5;
            refY = 0.5; 
         else
            error = 1;
         end
      
      case{3,4} %% Combined Elbow+Shoulder Extension or Elbow+Shoulder+Wrist Extension
         % x: elbow extension
         % y: shoulder Flexion
         % Calculate current position --> from 0 to 1
         if((delta(2) ~= 0) && (delta(1) ~= 0))
            if(arm == 0)
               currentX = 1-((angles(2) - initAngles(2))/delta(2));
               if(Estado == Mov_State)
                  refX = 1-((reference(2) - initAngles(2))/delta(2));
               else
                  refX = 1;
               end
            else
               currentX = (angles(2) - initAngles(2))/delta(2);
               if(Estado == Mov_State)
                  refX = (reference(2) - initAngles(2))/delta(2);
               else
                  refX = 0;
               end
            end
            currentY = (angles(1) - initAngles(1))/delta(1);
            % Calculate Reference Position --> from 0 to 1
            if(Estado == Mov_State)
               refY = (reference(1) - initAngles(1))/delta(1);
            else
               refY = 0;
            end
         else
            error = 1;
         end
      
      case{5,6} %% Shoulder Extension or Shoulder+Wrist Extension
         if(delta(1) ~= 0)
            currentY = (angles(1) - initAngles(1))/delta(1);
            if(Estado == Mov_State)
               refY = (reference(1) - initAngles(1))/delta(1);
            else
               refY = 0;
            end
            currentX = 0.5;
            refX = 0.5;
         else
            error = 1;
         end
%          fprintf('\t - Delta: %d; Init: %d; Target: %d;\n', delta(1), initAngles(1), targetAngles(1));
%          fprintf('\t - Ref: %d; Pos: %d; --> NormRef: %.3f; NormPos%.3f\n', reference(1), angles(1), ref, current);
      otherwise
         currentX = 0;
         currentY = 0;
         refX = 0;
         refY = 0;
         error = 1;
   end
   
   
   %% Detect combined or single movement
   if(~error)
      if(currentX > upperLimit) currentX = upperLimit;
      elseif(currentX < lowerLimit)currentX = lowerLimit; end

      if(currentY > upperLimit) currentY = upperLimit;       
      elseif(currentY < lowerLimit) currentY = lowerLimit; end
      
      if(refX > upperLimit) refX = upperLimit;
      elseif(refX < lowerLimit) refX = lowerLimit; end

      if(refY > upperLimit) refY = upperLimit;
      elseif(refY < lowerLimit) refY = lowerLimit; end
      
      set(SjWin.Paradigm.refPos, 'XData', refX, 'YData', refY);
      set(SjWin.Paradigm.armPos, 'XData', currentX, 'YData', currentY);
   else
      fprintf('-- Error equal to zero\n');
   end



function fcn_ShowPerformance(perform)
   global SjWin 
   global therapy
  
   red = [255 0 0]/255;
   yellow = [255 255 0]/255;
   orange = [255 153 18]/255;
   
   switch(therapy)
      case{1,2}  % Elbow Extension or Elbow Extension+Wrist
         perform_index = perform(2);
         
      case {3,4} % Combined Shoulder+Elbow or Combined Shoulder+Elbow+Wrist
         perform_index = (perform(1)+perform(2))/2;

      case{5,6}  % Shoulder Extension or Shoulder Extension+Wrist
         perform_index = perform(1);
         
      otherwise
         fprintf('-- Error... No therapy defined\n fcn_ShowPerformance');
         return;
   end
   
   if(perform_index >= 80)
      set(SjWin.Paradigm.imag1,'CData',SjWin.Paradigm.face_excelente);
   elseif(perform_index >= 60)
      set(SjWin.Paradigm.imag2,'CData',SjWin.Paradigm.face_muybien);
   elseif(perform_index >= 50)
      set(SjWin.Paradigm.imag3,'CData',SjWin.Paradigm.face_bien);
   else
      set(SjWin.Paradigm.imag4,'CData',SjWin.Paradigm.face_mal);
   end
   