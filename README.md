## Resultados y Validación

Se procesó la imagen PBM binaria `curva_binaria_P4.pbm` de dimensión **567 × 319 píxeles** en ambas implementaciones.

| Métrica / Parámetro | Haskell (Funcional) | Prolog (Lógico / Declarativo) | Coincidencia |
| :--- | :--- | :--- | :---: |
| **Ancho (px)** | 567 | 567 | Exacta |
| **Alto (px)** | 319 | 319 | Exacta |
| **Área total ($f(x)$)** | 108,660 | 108,660 | **100%** |

---

## Comparativa Técnica: Haskell vs. Prolog

### 1. Haskell (Paradigma Funcional)
* **Procesamiento:** Manipulación de imágenes mediante evaluación perezosa y transformación de flujos de datos (`ByteString` / Listas).
* **Cálculo de Área:** La integral discreta se resuelve mediante una composición limpia de funciones de orden superior (`foldl'` / `map`), sumando el número de píxeles activos por columna.
* **Fortalezas:** Tipado estático fuerte que previene errores en tiempo de compilación y alto rendimiento en la manipulación recursiva de listas.

### 2. Prolog (Paradigma Lógico)
* **Procesamiento:** Basado en unificación, coincidencia de patrones (pattern matching) y recursión sobre listas de códigos de caracteres/bytes.
* **Cálculo de Área:** La función de altura $f(x)$ y la suma acumulada del área se construyen declarativamente mediante predicados y acumuladores.
* **Fortalezas:** Representación muy natural del problema en forma de relaciones lógicas y reglas de consulta.

---

## Conclusiones

1. **Equivalencia Algorítmica:** Ambos paradigmas convergen en el mismo resultado matemático (**108,660 píxeles cuadrados**), demostrando que la abstracción funcional y la deducción lógica son igualmente efectivas para el cálculo de integrales discretas sobre imágenes binarias.
2. **Representación de Datos:** Mientras Haskell destaca por su velocidad y manejo de tipos para flujos binarios, Prolog ofrece una expresividad clara mediante cláusulas para modelar las propiedades de la curva.	