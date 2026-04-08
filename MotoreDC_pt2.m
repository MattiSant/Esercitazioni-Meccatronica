%% ESERCITAZIONI 2 - Motore DC

clc;
close all ;
clear all;

%% Dati
% Associare i valori della tensione [0,12]V a valori di tempo di simulink
% per plot, input a rampa

%Convertire omega da rad/sec a giri/min -> x60/2pi

V = 0:1:12;     %[V]
R = 4.4;        %[Ohm]
L = 6.2e-3;     %[H]
J = 16e-7;      %[Kg m^2]

Ke = 0.025;     %[V s/rad]
Kt = 2.5e-2;    %[N m/A]           

C_Rated = 2.0e-2;     %[N m]

ts = [0.01 0.025 0.05 0.075 0.1 0.125]; % [s]

%% Punto 1
% Vedi appunti valerio per calcoli 

beta = 4*J./ts; % Beta per raggiungere regime in ts
tau = J./beta;  % tau = 1/4 * ts -> +- 2%

%% Punto 2
omega_ss = C_Rated./beta;                   % controllo rad/s
omega_ss_girimin = omega_ss *(60/(2*pi));   % controllo giri/min

%% Punto 3

% SS matrici
A = -beta./J;
B = 1/J;
C = 1;
D = 0;

% Transfer Function Coppia-VelAngolare
[C_Num_omega1,C_Den_omega1] = ss2tf(A(1),B,C,D);
[C_Num_omega2,C_Den_omega2] = ss2tf(A(2),B,C,D);
[C_Num_omega3,C_Den_omega3] = ss2tf(A(3),B,C,D);
[C_Num_omega4,C_Den_omega4] = ss2tf(A(4),B,C,D);
[C_Num_omega5,C_Den_omega5] = ss2tf(A(5),B,C,D);
[C_Num_omega6,C_Den_omega6] = ss2tf(A(6),B,C,D);

%%
out = sim('DC_Motor_pt2');

%% Punto 5

nomi_campi = fieldnames(out.omega_simulink);

fprintf('\n--- VERIFICA PUNTO OMEGA a REGIME  --- \n');
fprintf('--------------------------------------------------------------------------\n');
fprintf('%-15s | %-15s | %-15s | %-15s\n', 'Target ts [s]', 'w_ss Analitico', 'w_ss Simulink', 'Errore %');
fprintf('--------------------------------------------------------------------------\n');

for i = 1:length(nomi_campi)

    nome_corrente = nomi_campi{i};
    dati_sim = out.omega_simulink.(nome_corrente); 
    
    omega_ss_sim_rpm = dati_sim.Data(end);    % ultimo valore campionato) 
    
    % errore rispetto al valore teorico 
    errore_ss = abs(omega_ss_girimin(i) - omega_ss_sim_rpm) / omega_ss_girimin(i) * 100;
    
    % Verifica del tempo di assestamento
    % Al tempo t = ts(i), la velocità deve essere circa il 98% del valore finale
    [~, idx_ts] = min(abs(dati_sim.Time - ts(i))); % indice più vicino al tempo ts
    valore_a_ts = dati_sim.Data(idx_ts);
    percentuale_raggiunta = (valore_a_ts / omega_ss_sim_rpm) * 100;

    fprintf('%-15.3f | %-15.2f | %-15.2f | %-10.2e %%\n', ts(i), omega_ss_girimin(i), omega_ss_sim_rpm, errore_ss);
             
    if percentuale_raggiunta >= 98
        fprintf('   > Verifica ts: OK (Raggiunto il %.2f%% del regime a t=%.3fs)\n', percentuale_raggiunta, ts(i));
    else
        fprintf('   > Verifica ts: ATTENZIONE (Raggiunto solo il %.2f%% a t=%.3fs)\n', percentuale_raggiunta, ts(i));
    end
end