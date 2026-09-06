% render.pl
% Todo lo relacionado con mostrar algo en una terminal mucho mas
% pequena que la imagen original. La misma lista reducida por bloques
% (promedio de M) sirve tanto para la silueta de la curva como para el
% grafico de M[x]; el area y f(x) mostrados en otras partes del
% programa siempre usan M completo, sin reducir - esta reduccion es
% puramente visual.

:- encoding(utf8).
:- module(render, [reducir_bloques/3, dibujar_silueta/2, dibujar_barras_altura/2]).

% reducir_bloques(+K, +Lista, -Reducida)
% Parte Lista en bloques de tamano K (el ultimo puede ser mas chico) y
% reemplaza cada bloque por su promedio entero.
reducir_bloques(K, Lista, Reducida) :-
    K > 0,
    partir_en_bloques(K, Lista, Bloques),
    maplist(promedio, Bloques, Reducida).

partir_en_bloques(_, [], []) :- !.
partir_en_bloques(K, Lista, [Bloque | Resto]) :-
    length(Bloque0, K),
    ( append(Bloque0, Cola, Lista)
    -> Bloque = Bloque0, partir_en_bloques(K, Cola, Resto)
    ;  Bloque = Lista, Resto = []
    ).

promedio(Bloque, Promedio) :-
    sum_list(Bloque, Suma),
    length(Bloque, N),
    Promedio is Suma // N.

% Caracteres de bloque Unicode, de "vacio" a "lleno".
caracteres_bloque([' ', '▁', '▂', '▃', '▄', '▅', '▆', '▇', '█']).

% caracter_para(+Valor, +Maximo, -Caracter)
caracter_para(_, Maximo, Caracter) :-
    Maximo =< 0, !,
    caracteres_bloque(Caracteres),
    last(Caracteres, Caracter).
caracter_para(Valor, Maximo, Caracter) :-
    caracteres_bloque(Caracteres),
    length(Caracteres, Longitud),
    N is Longitud - 1,
    IdxCrudo is (Valor * N) // Maximo,
    Idx is max(0, min(N, IdxCrudo)),
    nth0(Idx, Caracteres, Caracter).

% dibujar_silueta(+AlturasReducidas, -Lineas)
% Lineas es una lista de strings (una por fila de consola), pintando
% con bloques llenos desde abajo hasta la altura normalizada de cada
% columna, para "filasConsola" filas fijas.
dibujar_silueta(AlturasReducidas, Lineas) :-
    FilasConsola = 20,
    max_list([1 | AlturasReducidas], MaxAltura),
    maplist(normalizar(FilasConsola, MaxAltura), AlturasReducidas, Normalizadas),
    findall(Linea,
            ( between(1, FilasConsola, Fila),
              Y is Fila - 1,
              fila_silueta(Normalizadas, FilasConsola, Y, Linea)
            ),
            Lineas).

normalizar(FilasConsola, MaxAltura, Altura, Normalizada) :-
    Normalizada is (Altura * FilasConsola) // MaxAltura.

fila_silueta(Normalizadas, FilasConsola, Y, Linea) :-
    findall(Char,
            ( member(H, Normalizadas),
              ( H >= FilasConsola - Y -> Char = '█' ; Char = ' ' )
            ),
            Chars),
    atomic_list_concat(Chars, Linea).

% dibujar_barras_altura(+AlturasReducidas, -Linea)
% M[x] reducida como una sola linea de bloques Unicode graduados: un
% "sparkline" de la funcion de altura.
dibujar_barras_altura(AlturasReducidas, Linea) :-
    max_list([1 | AlturasReducidas], MaxAltura),
    findall(Char,
            ( member(V, AlturasReducidas),
              caracter_para(V, MaxAltura, Char)
            ),
            Chars),
    atomic_list_concat(Chars, Linea).
