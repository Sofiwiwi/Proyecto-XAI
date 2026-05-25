#!/bin/bash
# Script de compilación ordenada para main.tex

# Detener la ejecución si ocurre un error
set -e

echo "=== Limpiando archivos auxiliares antiguos ==="
rm -f main.aux main.log main.out main.toc main.pdf

echo "=== Primera pasada de pdflatex ==="
pdflatex -interaction=nonstopmode main.tex

echo "=== Segunda pasada de pdflatex (resolviendo referencias y citas) ==="
pdflatex -interaction=nonstopmode main.tex

echo "=== ¡Compilación completada con éxito! ==="
