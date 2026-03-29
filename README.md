# SegmentedLinearFit

Aplicacion desktop en Qt 6 + C++ para construir un ajuste lineal por tramos a partir de:

- un CSV con columnas `X` y `Y`
- o un rango manual `min / max / intervalos` para generar puntos equiespaciados

La app permite:

- cargar puntos desde CSV
- generar puntos manuales
- editar los valores `Y`
- calcular rectas por tramos
- ver ecuaciones finales
- generar codigo PLC tipo `IF / ELSIF`

## Build en Windows con Qt

```powershell
C:\Qt\6.10.2\llvm-mingw_64\bin\qt-cmake.bat -S . -B build-cpp-qt -G Ninja -DCMAKE_MAKE_PROGRAM=C:/Qt/Tools/Ninja/ninja.exe -DCMAKE_CXX_COMPILER=C:/Qt/Tools/llvm-mingw1706_64/bin/clang++.exe
C:\Qt\Tools\Ninja\ninja.exe -C build-cpp-qt
```

Ejecutable esperado:

- `build-cpp-qt/SegmentedLinearFit.exe`

## Estructura nueva

- `src/`: backend C++
- `qml/`: interfaz Qt Quick
- `files/`: notebooks y datos de referencia
- `docs/`: documentacion del notebook original

## Nota

La version C++ ya es la ruta principal del proyecto. Los archivos Python originales siguen en el repo como referencia de migracion.
