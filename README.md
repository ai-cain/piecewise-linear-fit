# piecewise-linear-fit

Qt 6 + C++ desktop application for building a piecewise linear approximation from:

- a CSV file with `X` and `Y` columns
- or a manual `min / max / intervals` range that generates evenly spaced points

The app currently supports:

- multi-page navigation with `Home`, `Data`, and `Results`
- CSV point loading
- manual point generation
- editable `Y` values
- piecewise linear analysis
- final segment equations
- PLC-style `IF / ELSIF` code generation

## Open In Qt Creator

Open `CMakeLists.txt`, not `.pro` or `.pyproject`.

## Build On Windows With Qt

```powershell
C:\Qt\6.10.2\llvm-mingw_64\bin\qt-cmake.bat -S . -B build-cpp-qt -G Ninja -DCMAKE_MAKE_PROGRAM=C:/Qt/Tools/Ninja/ninja.exe -DCMAKE_CXX_COMPILER=C:/Qt/Tools/llvm-mingw1706_64/bin/clang++.exe
C:\Qt\Tools\Ninja\ninja.exe -C build-cpp-qt
C:\Qt\6.10.2\llvm-mingw_64\bin\windeployqt.exe --qmldir qml build-cpp-qt\piecewise-linear-fit.exe
```

Expected executable:

- `build-cpp-qt/piecewise-linear-fit.exe`

## Project Structure

- `src/`: C++ backend
- `qml/`: Qt Quick interface
- `files/`: reference notebook and sample data
- `docs/`: documentation for the original notebook workflow

## Note

The C++ version is now the main application path. The original notebook is still kept in `files/segmented_linear_fit.ipynb` together with sample CSV files.
