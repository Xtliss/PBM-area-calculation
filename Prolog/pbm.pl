% pbm.pl
% Lectura de archivos PBM P4 y acceso a pixeles individuales.
% Responsabilidad de este modulo: leer el archivo como bytes crudos,
% separar el header (ancho, alto) de los datos binarios, y ofrecer una
% relacion que dice si un pixel (X, Y) es negro o blanco.
%
% Los datos se guardan como un string de SWI-Prolog leido con
% encoding(octet): cada "caracter" del string es exactamente un byte
% (codigo 0-255), lo que da acceso O(1) via string_code/3 sin pagar el
% costo de una lista enlazada para una imagen de miles de bytes.

:- module(pbm, [leer_pbm/3, bytes_por_fila/2, pixel_negro/4, byte_de/3]).

% leer_pbm(+Ruta, -Info, -Datos)
% Info es el compound imagen(Ancho, Alto). Datos es el string de bytes
% binarios (ya sin el header), listo para acceso aleatorio.
leer_pbm(Ruta, imagen(Ancho, Alto), Datos) :-
    read_file_to_string(Ruta, Contenido, [encoding(octet)]),
    string_length(Contenido, Total),
    LargoMuestra is min(200, Total),
    sub_string(Contenido, 0, LargoMuestra, _, Muestra),
    string_codes(Muestra, CodigosHeader),
    parse_header(CodigosHeader, Ancho, Alto, Consumido),
    LargoDatos is Total - Consumido,
    sub_string(Contenido, Consumido, LargoDatos, 0, Datos).

% parse_header(+Codigos, -Ancho, -Alto, -Consumido)
% Interpreta "P4" [comentarios/espacios] Ancho [comentarios/espacios] Alto
% seguido de exactamente un caracter de espacio antes de los datos.
% Consumido es el numero de bytes que ocupa el header completo.
parse_header(Codigos, Ancho, Alto, Consumido) :-
    Codigos = [0'P, 0'4 | Resto0],
    saltar_espacios_comentarios(Resto0, Resto1),
    leer_entero(Resto1, Ancho, Resto2),
    saltar_espacios_comentarios(Resto2, Resto3),
    leer_entero(Resto3, Alto, Resto4),
    Resto4 = [_UnEspacio | RestoDatos],
    length(Codigos, LargoTotal),
    length(RestoDatos, LargoRestante),
    Consumido is LargoTotal - LargoRestante.

% Salta espacios en blanco y comentarios ("#" hasta fin de linea),
% repitiendo hasta encontrar el inicio de un token real.
saltar_espacios_comentarios([C | Cs], Resto) :-
    code_type(C, space), !,
    saltar_espacios_comentarios(Cs, Resto).
saltar_espacios_comentarios([0'# | Cs], Resto) :-
    !,
    saltar_linea(Cs, Cs2),
    saltar_espacios_comentarios(Cs2, Resto).
saltar_espacios_comentarios(Codigos, Codigos).

saltar_linea([0'\n | Cs], Cs) :- !.
saltar_linea([_ | Cs], Resto) :- !, saltar_linea(Cs, Resto).
saltar_linea([], []).

% Lee una secuencia de digitos ASCII y la convierte a entero.
leer_entero(Codigos, Valor, Resto) :-
    leer_digitos(Codigos, Digitos, Resto),
    number_codes(Valor, Digitos).

leer_digitos([C | Cs], [C | Ds], Resto) :-
    code_type(C, digit), !,
    leer_digitos(Cs, Ds, Resto).
leer_digitos(Codigos, [], Codigos).

% bytes_por_fila(+Ancho, -BytesPorFila)
% Cada byte empaqueta 8 pixeles (bits); se redondea hacia arriba.
bytes_por_fila(Ancho, BytesPorFila) :-
    BytesPorFila is (Ancho + 7) // 8.

% byte_de(+Datos, +Indice0, -Byte)
% Byte en la posicion Indice0 (base 0) del string de datos.
byte_de(Datos, Indice0, Byte) :-
    Indice1 is Indice0 + 1,
    string_code(Indice1, Datos, Byte).

% pixel_negro(+X, +Y, +Info, +Datos)
% Verdadero si el pixel (X, Y) es negro (bit = 1). El bit mas
% significativo de un byte corresponde al pixel mas a la izquierda
% del grupo de 8.
pixel_negro(X, Y, imagen(Ancho, _Alto), Datos) :-
    bytes_por_fila(Ancho, BytesPorFila),
    IndiceByte is Y * BytesPorFila + X // 8,
    byte_de(Datos, IndiceByte, Byte),
    PosicionBit is 7 - (X mod 8),
    Bit is (Byte >> PosicionBit) /\ 1,
    Bit =:= 1.
