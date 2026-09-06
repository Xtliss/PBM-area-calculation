# Cómo ejecutar (Prolog)

Requiere SWI-Prolog (probado con versión 9.0.4).

Desde la carpeta `Prolog/`, con `curva_binaria_P4.pbm` copiado dentro
de esta carpeta (o ajustando `archivo_pbm/1` en `main.pl` si está en
otra ruta):

```bash
swipl main.pl
```

El programa se ejecuta automáticamente al cargar (`initialization(main, main)`)
y termina solo. Si prefieres cargarlo interactivo y correrlo a mano:

```bash
swipl
?- [main].
?- main.
```

Salida esperada: igual en contenido a la versión de Haskell — dimensiones
de la imagen, silueta reducida, gráfico de M[x], 10 muestras x_i -> f(x_i),
y el área final (108660 píxeles cuadrados para el archivo suministrado).
