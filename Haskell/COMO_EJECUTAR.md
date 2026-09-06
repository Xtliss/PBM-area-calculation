# Cómo compilar y ejecutar (Haskell)

Requiere GHC (probado con GHC 9.4.7). No se usan paquetes externos además
de `bytestring`, que viene incluido con GHC.

Desde la carpeta `Haskell/`, con `curva_binaria_P4.pbm` en la raíz del
repositorio (un nivel arriba de `Haskell/`) o copiado dentro de esta
carpeta antes de ejecutar:

```bash
ghc -isrc -o area_haskell src/Main.hs
./area_haskell
```

Si `curva_binaria_P4.pbm` está en otra ubicación relativa, ajustar la
constante `archivoPBM` en `src/Main.hs`.

Salida esperada: dimensiones de la imagen, silueta de la curva reducida,
gráfico de M[x], 10 muestras x_i -> f(x_i), y el área final en píxeles
cuadrados (108660 para el archivo suministrado por el profesor).
