%% Reto 3 - Algoritmo de control de cargas de una microred
% Simulacion de 24 horas en MATLAB
% Las potencias/energias se consideran valores por cada intervalo de 1 hora.

clc;                 % Limpia la ventana de comandos.
clear;               % Borra las variables del espacio de trabajo.
close all;           % Cierra las figuras que esten abiertas.

%% 1. Configuracion inicial
hora = 1:24;         % Vector con las 24 horas del dia.

% Datos horarios desarrollados en el Reto 2:
solar = [0 0 0 0 0 5 8 12 16 20 23 25 23 20 16 12 8 5 0 0 0 0 0 0];
eolica = [8 10 7 12 9 6 11 14 10 13 8 12 15 11 9 13 7 10 12 8 14 9 11 6];
demanda = [3 3 2 3 4 6 7 7 8 8 9 9 10 9 8 7 8 15 15 15 15 4 3 3];

generacion = solar + eolica; % Suma la generacion solar y eolica.
capacidad_bat = 100;          % Capacidad total de la bateria en kWh.
SOC = zeros(1,24);            % Reserva espacio para guardar el SOC de cada hora.
SOC_actual = 50;              % La bateria comienza con 50 % de carga.

% Vectores para guardar el reporte horario.
balance = zeros(1,24);        % Generacion menos demanda.
excedente = zeros(1,24);       % Energia sobrante cuando hay superavit.
faltante = zeros(1,24);        % Energia faltante cuando hay deficit.
escuela = strings(1,24);       % Estado de la escuela.
bombeo = strings(1,24);        % Estado del bombeo de agua.
alumbrado = strings(1,24);     % Estado del alumbrado publico.

%% 2. Bucle de simulacion de las 24 horas
for h = 1:24

    balance(h) = generacion(h) - demanda(h); % Calcula el balance de esta hora.

    %% 3. Decision: superavit o deficit de energia
    if balance(h) >= 0
        % Superavit: la generacion cubre la demanda y sobra energia.
        excedente(h) = balance(h);
        faltante(h) = 0;

        % El excedente carga la bateria. Capacidad expresada en kWh.
        SOC_nuevo = SOC_actual + (excedente(h) / capacidad_bat) * 100;

    else
        % Deficit: la bateria cubre la diferencia entre demanda y generacion.
        faltante(h) = abs(balance(h));
        excedente(h) = 0;

        % La bateria entrega energia y disminuye su estado de carga.
        SOC_nuevo = SOC_actual - (faltante(h) / capacidad_bat) * 100;
    end

    % Proteccion: el SOC nunca puede superar 100 % ni bajar de 0 %.
    SOC_nuevo = min(100, max(0, SOC_nuevo));

    %% 4. Control de cargas segun el SOC calculado
    if SOC_nuevo > 40
        % Ruta segura: todos los servicios permanecen activos.
        escuela(h) = "Activa";
        bombeo(h) = "Activo";
        alumbrado(h) = "Activo";

    elseif SOC_nuevo > 20
        % Ruta de alerta: se desconecta solo el alumbrado publico.
        escuela(h) = "Activa";
        bombeo(h) = "Activo";
        alumbrado(h) = "Suspendido";

    else
        % Ruta de emergencia: escuela prioritaria; se apagan las otras cargas.
        escuela(h) = "Activa";
        bombeo(h) = "Suspendido";
        alumbrado(h) = "Suspendido";
    end

    % Guarda el SOC de esta hora para mostrarlo en la tabla final.
    SOC(h) = SOC_nuevo;

    %% 5. Reporte por consola para la hora actual
    fprintf('\\nHora %02d: Generacion = %.1f kWh, Demanda = %.1f kWh\\n', ...
        h, generacion(h), demanda(h));
    fprintf('Balance = %.1f kWh | SOC = %.1f %%\\n', balance(h), SOC_nuevo);
    fprintf('Escuela: %s | Bombeo: %s | Alumbrado: %s\\n', ...
        escuela(h), bombeo(h), alumbrado(h));

    % El SOC calculado se convierte en el estado inicial de la siguiente hora.
    SOC_actual = SOC_nuevo;
end

%% 6. Tabla resumen de las 24 horas
Reporte = table(hora', solar', eolica', generacion', demanda', balance', SOC', ...
    escuela', bombeo', alumbrado', ...
    'VariableNames', {'Hora','Solar_kWh','Eolica_kWh','Generacion_kWh', ...
    'Demanda_kWh','Balance_kWh','SOC_porcentaje','Escuela','Bombeo','Alumbrado'});

disp(' ');
disp('===== REPORTE FINAL DE LAS 24 HORAS =====');
disp(Reporte);
