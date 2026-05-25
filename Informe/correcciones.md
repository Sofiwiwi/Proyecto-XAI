# Reporte de Correcciones y Observaciones Críticas de la Propuesta (main.tex)

Este documento detalla las inconsistencias teóricas, vacíos de diseño metodológico y errores detectados en la propuesta de investigación contenida en `main.tex`. Se estructuran con su ubicación exacta, el fundamento del problema y la acción correctiva recomendada para asegurar la rigurosidad científica de la entrega.

---

## 1. Pérdida de Garantías Conformes (Falta de Intercambiabilidad)

* **Ubicación en `main.tex`:**
  * **Líneas 124-126:** *"...proporcionando una decisión única y estadísticamente respaldada."*
  * **Líneas 280-283:** *"...se garantiza la cobertura marginal: $P(Y \in C(X)) \geq 1 - \alpha$."*

* **Descripción del problema:**
  La propuesta asume implícitamente que el conjunto de predicción resultante para el contrafáctico optimizado $X'$ ($C(X')$) hereda de forma directa las garantías formales de cobertura estadística ($1-\alpha$) del clasificador conforme. Esto es un error conceptual severo.

* **Base teórica / Fundamento:**
  La garantía matemática de la Predicción Conforme (PC) se sostiene sobre el supuesto de **intercambiabilidad** (*exchangeability*) de los datos. Esto significa que la nueva instancia de prueba debe comportarse como si hubiera sido extraída de la misma distribución que el conjunto de calibración. 
  Al optimizar $X'$ para cumplir un objetivo específico (minimizar la pérdida $\mathcal{L}(X, X')$ y colapsar el conjunto de predicción a un singleton), se introduce un **sesgo de selección**. El punto $X'$ es un dato sintético optimizado ad-hoc, lo cual rompe la intercambiabilidad con las muestras de calibración. Por lo tanto, el nivel de confianza empírico en $X'$ no tiene garantía matemática de ser $\geq 1-\alpha$.

* **Acción Correctiva:**
  * Modificar el texto para admitir esta limitación teórica: aclarar que el colapso del conjunto de predicción a un singleton en $X'$ es una métrica de certidumbre local del modelo y una guía heurística de optimización, pero que el contrafáctico generado no posee la garantía formal de cobertura marginal del split conformal tradicional.
  * Opcionalmente, proponer como trabajo futuro o extensión el uso de marcos de **Predicción Conforme Localizada (LCP)** (ej. CONFEX, 2024), que recalculan la calibración en un entorno local alrededor de $X'$ para recuperar garantías estadísticas aproximadas.

---

## 2. Distancia de Mahalanobis Global vs. Condicional por Clase

* **Ubicación en `main.tex`:**
  * **Línea 295 (Ecuación 1):** El término de regularización es $\gamma \cdot d_M(X', \mathcal{D})$.
  * **Líneas 332-340:** Definición del estimador global de la distancia de Mahalanobis:
    $$d_M(X', \mathcal{D}) = \sqrt{(X' - \mu)^\top \Sigma^{-1} (X' - \mu)}$$
    donde $\mu$ y $\Sigma$ son la media y matriz de covarianza de todo el conjunto de entrenamiento $\mathcal{D}$.

* **Descripción del problema:**
  El uso de una media y covarianza globales para un dataset con clases tan morfológicamente heterogéneas como *Dry Bean Dataset* (frijoles gigantes como *Bombay* versus pequeños y elípticos como *Dermason*) invalida el propósito del regularizador, que es mantener la plausibilidad física del frijol sintético.

* **Base teórica / Fundamento:**
  Al usar $\mu$ y $\Sigma$ calculados sobre la totalidad del dataset $\mathcal{D}$, la distancia de Mahalanobis asume que la distribución morfológica global es unimodal. Al optimizar un contrafáctico $X'$ hacia una clase objetivo $Y_t$ (por ejemplo, *Bombay*), el optimizador penalizará a $X'$ si este se aleja del "frijol promedio global" (el cual está dominado por las clases mayoritarias de menor tamaño). Esto impedirá que el contrafáctico adquiera las dimensiones físicas y proporciones características de la clase objetivo, generando un frijol que no es plausible ni coherente con la clase $Y_t$.

* **Acción Correctiva:**
  Reemplazar la formulación por la **distancia de Mahalanobis condicional a la clase objetivo** ($Y_t$):
  $$d_M(X', \mathcal{D}_{Y_t}) = \sqrt{(X' - \mu_{Y_t})^\top \Sigma_{Y_t}^{-1} (X' - \mu_{Y_t})}$$
  donde $\mu_{Y_t}$ y $\Sigma_{Y_t}$ se computan exclusivamente con las muestras de entrenamiento que pertenecen a la clase objetivo $Y_t$.

---

## 3. No-Diferenciabilidad de XGBoost en la Optimización Continua

* **Ubicación en `main.tex`:**
  * **Líneas 243-245:** XGBoost como uno de los modelos base de clasificación.
  * **Líneas 288-297:** Formulación de la optimización del contrafáctico minimizando la pérdida continua $\mathcal{L}(X, X')$.

* **Descripción del problema:**
  La función de pérdida propuesta depende del score de no conformidad $s(X', y) = 1 - \hat{p}(y \mid X')$. Si se utiliza descenso de gradiente estándar para encontrar $X'$, el pipeline fallará para XGBoost.

* **Base teórica / Fundamento:**
  Los modelos basados en árboles (como XGBoost) son funciones escalonadas constantes por trozos. Esto implica que la derivada de las probabilidades predichas con respecto a las características de entrada es exactamente cero ($\nabla_{X'} \hat{p}(y \mid X') = \mathbf{0}$) en casi todo el dominio y no está definida en las fronteras de decisión de los árboles. Por lo tanto, el descenso de gradiente no puede propagar señales para ajustar el punto $X'$.

* **Acción Correctiva:**
  * Aclarar en la metodología que, a diferencia de MLP y Regresión Logística (que admiten optimización continua basada en gradiente), el modelo XGBoost requerirá el uso de optimizadores libres de gradiente (ej. algoritmos genéticos o de búsqueda aleatoria local), los cuales están soportados por el modo agnóstico de `DiCE-ML`.

---

## 4. Incompatibilidad de las Métricas de Fidelidad de `Quantus`

* **Ubicación en `main.tex`:**
  * **Líneas 378-385:** Evaluación de la fidelidad mediante las métricas *Faithfulness Correlation* y *Faithfulness Estimate* de la librería `Quantus`.

* **Descripción del problema:**
  `Quantus` es una librería diseñada para evaluar explicaciones basadas en **atribución de características** (como SHAP, LIME, Gradientes Integrados). Las explicaciones contrafácticas no son vectores de atribución de importancia, sino puntos en el espacio de características.

* **Base teórica / Fundamento:**
  Las métricas de fidelidad de atribución evalúan cómo cambia la predicción del modelo al remover o perturbar las características identificadas como "más importantes". Si se trata la perturbación $\delta = X' - X$ como una atribución, aplicar métricas de perturbación iterativa sobre un punto sintético $X'$ que ya fue optimizado para estar en el borde de decisión es teóricamente inconsistente y puede arrojar métricas de correlación sesgadas o carentes de significado científico.

* **Acción Correctiva:**
  * Sustituir las métricas de atribución por métricas nativas de evaluación de explicaciones contrafácticas:
    1. **Sparsity (Escasez):** Cuántas características requirieron modificarse.
    2. **Proximity (Proximidad):** La distancia $L_1$ o $L_2$ entre $X$ y $X'$.
    3. **Plausibility (Plausibilidad):** El valor de la distancia de Mahalanobis condicional del contrafáctico resultante.
    4. **Actionability (Accionabilidad):** Análisis cualitativo sobre si los cambios ocurren en variables morfológicas que en la práctica no son modificables (e.g. área del frijol).

---

## 5. Error Factográfico en Referencia Bibliográfica

* **Ubicación en `main.tex`:**
  * **Línea 434 (Referencia `[b6]`):**
    `\bibitem{b6} R. Maalej, R. Confalonieri, y M. Lippi, "Counterfactual explanations for conformal prediction sets," in Proc. PMLR, vol. 266, 2025.`

* **Descripción del problema y fundamento:**
  Los autores reales de la publicación citada (presentada en COPA 2025 / PMLR vol. 266) son **Aicha Maalej, Cecilia Sönströd y Ulf Johansson**. Roberto Confalonieri y Marco Lippi no forman parte del equipo de autores de dicho artículo.

* **Acción Correctiva:**
  Corregir la línea 434 del archivo `main.tex` con la autoría correcta:
  ```latex
  \bibitem{b6} A. Maalej, C. Sönströd, y U. Johansson, ``Counterfactual explanations for conformal prediction sets,'' in \textit{Proc. PMLR}, vol.\ 266, 2025.
  ```
