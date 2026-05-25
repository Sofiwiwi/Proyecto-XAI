# Estado del Arte: Resolución de Ambigüedad Conforme mediante Explicaciones Contrafácticas

Este documento contiene el análisis del estado del arte para el proyecto descrito en [main.tex](file:///home/mrepetto/Documentos/XAI-ENTREGA-2/main.tex). Se enfoca en la intersección entre la **Predicción Conforme (PC)** (cuantificación de incertidumbre) y las **Explicaciones Contrafácticas (XAI)** en espacios tabulares.

---

## 1. Contexto Científico y Problema Central

El problema a resolver es la **ambigüedad** en la predicción conforme, definida cuando el conjunto de predicción $C(X)$ contiene más de una clase ($|C(X)| > 1$) a un nivel de significancia $\alpha$. Aunque esto es estadísticamente correcto, reduce la utilidad del modelo en dominios críticos.

Las explicaciones contrafácticas tradicionales (como la formulación original de Wachter et al., 2018) buscan una perturbación mínima $X'$ para cambiar una predicción puntual de $Y$ a $Y_t$. En este proyecto, el objetivo cambia: **se busca que $X'$ no solo altere la predicción del clasificador base, sino que colapse el conjunto conforme resultante a un singleton $\{Y_t\}$ ($|C(X')| = 1$)**, garantizando plausibilidad mediante restricciones multivariadas como la distancia de Mahalanobis.

---

## 2. Trabajos Clave de la Literatura

### A. Explicaciones Contrafácticas para Conjuntos de Predicción Conforme (COPA 2025)
* **Autores:** Aicha Maalej, Cecilia Sönströd, y Ulf Johansson.
* **Publicación:** *Proceedings of Machine Learning Research (PMLR)*, Vol. 266, pp. 405–424.
* **DOI / Enlace:** [https://doi.org/10.48550/arXiv.2502.16480](https://doi.org/10.48550/arXiv.2502.16480) (Alternativa: [Enlace PMLR](https://proceedings.mlr.press/v266/maalej25a.html))
* **Resumen:**
  Es el antecedente directo de este trabajo. Propone generar explicaciones contrafácticas específicamente para clasificadores conformes en problemas de clasificación. Optimiza para alterar la composición del conjunto de predicción ($C(X)$) a un nivel de significancia fijo. Introduce una métrica llamada **credibilidad** (conformal credibility) derivada de los propios p-valores conformes para asegurar la plausibilidad de los contrafácticos.

> [!WARNING]
> **Corrección Crítica de Cita en [main.tex](file:///home/mrepetto/Documentos/XAI-ENTREGA-2/main.tex):**
> En la sección de referencias del documento actual (línea 434, `\bibitem{b6}`), has colocado:
> `R. Maalej, R. Confalonieri, y M. Lippi, "Counterfactual explanations for conformal prediction sets," in Proc. PMLR, vol. 266, 2025.`
> **Los autores reales son Aicha Maalej, Cecilia Sönströd y Ulf Johansson**. Confalonieri y Lippi no son coautores de esta investigación. Se recomienda modificar el archivo `.tex` con la autoría correcta.

---

### B. Faithful Model Explanations through Energy-Constrained Conformal Counterfactuals (ECCCo)
* **Autores:** Patrick Altmeyer, Mojtaba Farmanbar, Arie van Deursen, y Cynthia C. S. Liem.
* **Publicación:** *AAAI Conference on Artificial Intelligence*, 2024 (Vol. 38, No. 10).
* **DOI / Enlace:** [https://doi.org/10.1609/aaai.v38i10.28956](https://doi.org/10.1609/aaai.v38i10.28956) (arXiv: [https://arxiv.org/abs/2312.10648](https://arxiv.org/abs/2312.10648))
* **Resumen:**
  Introduce el marco **ECCCo**, el cual aborda la tensión entre *plausibilidad* y *fidelidad* (faithfulness). Los autores demuestran que los métodos contrafácticos previos utilizan modelos sustitutos (*surrogates*) para aprender la distribución y forzar plausibilidad, lo que genera contrafácticos realistas pero que no reflejan fielmente el comportamiento de la caja negra. ECCCo aprovecha las propiedades internas de la caja negra usando modelos basados en energía (Energy-Based Models - EBMs) y predicción conforme, eliminando la necesidad de sustitutos.

> [!NOTE]
> **Relación con tu propuesta:** ECCCo está muy alineado con tu idea de plausibilidad morfológica. Mientras ECCCo usa modelos basados en energía (útiles con acceso a gradientes y datos de imágenes), tu propuesta implementa la **distancia de Mahalanobis** sobre la matriz de covarianza de entrenamiento, que resulta óptima, interpretable y ligera para datos tabulares continuos (como el *Dry Bean Dataset*).

---

### C. Counterfactual Explanations for Conformal Regression Intervals (2026/2023)
* **Autores:** Aicha Maalej y Ulf Johansson.
* **Publicación:** *Symposium on Conformal and Probabilistic Prediction with Applications*, Springer.
* **DOI / Enlace:** [https://doi.org/10.1007/978-3-032-23833-7_11](https://doi.org/10.1007/978-3-032-23833-7_11)
* **Resumen:**
  Extiende la aplicación de contrafácticos conformes al ámbito de la regresión. Propone la generación de contrafácticos para intervalos de predicción conformes (en lugar de conjuntos de clases) e introduce métricas de dificultad (difficulty) basadas en la variabilidad de predicción del modelo para evaluar la factibilidad del contrafáctico.

---

## 3. Distinción Metodológica en el Estado del Arte

Al compilar tu marco teórico y de estado del arte, es fundamental clasificar y separar claramente dos vertientes de investigación que emplean los términos **conformal** y **counterfactual** pero con propósitos opuestos:

* **Inferencia Causal / Inferencia Conforme de Contrafácticos:**
  * *Ejemplos:* *«Conformal Inference of Counterfactuals and Individual Treatment Effects»* (Lei & Candès, 2020) u *«An Exact and Robust Conformal Inference Method for Counterfactual and Synthetic Controls»* (Chernozhukov et al., 2021).
  * *Objetivo:* Cuantificación de incertidumbre alrededor de resultados potenciales o estimación de efectos de tratamientos causales.
* **Explainable AI (XAI) / Explicaciones Contrafácticas en Predicción Conforme:**
  * *Ejemplos:* Maalej et al. (2025), ECCCo (2024) y **este proyecto**.
  * *Objetivo:* Generar explicaciones sobre decisiones del modelo y resolver la ambigüedad en conjuntos de predicción conformal mediante perturbaciones de características de entrada.

---

## 4. Matriz Comparativa y Posicionamiento de tu Trabajo

La siguiente tabla posiciona tu propuesta frente a los enfoques más significativos de la literatura:

| Característica / Trabajo | Maalej et al. (2025) | ECCCo (Altmeyer et al., 2024) | **Tu Propuesta** |
| :--- | :--- | :--- | :--- |
| **Meta Principal** | Modificar pertenencia en conjunto $C(X)$ | Equilibrar plausibilidad y fidelidad explicativa | Colapsar conjuntos ambiguos $|C(X)|>1$ a singletons $\{Y_t\}$ |
| **Mecanismo de Plausibilidad** | Métrica de *conformal credibility* (p-valores) | Modelos Basados en Energía (EBMs) a nivel de modelo | **Distancia de Mahalanobis** multivariada sobre covarianza |
| **Tipo de Datos Dominante** | Texto y Tabulares genéricos | Imágenes y Tabulares | Tabulares continuos correlacionados (*Dry Bean Dataset*) |
| **Función de Pérdida** | Basada en p-valores conformes directos | Pérdida compuesta de energía + normas $L_1$/$L_2$ | Compuesta: Regularización de norma + pérdida tipo *hinge* con $q_\alpha$ + penalización multivariada |
| **Complejidad / Acceso** | Post-hoc agnóstico | Requiere acceso a gradientes (caja blanca/gris) | **Post-hoc agnóstico** (evalúa Regresión Logística, XGBoost y MLP) |
