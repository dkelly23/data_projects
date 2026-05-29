# Slides — Programación para Proyectos de Datos

Presentaciones del curso construidas con [Slidev](https://sli.dev). Una carpeta
por semana. Distribución vía GitHub Pages.

## Stack

- **Slidev** — Markdown + Vue + Vite, syntax highlight con Shiki.
- **Tema custom Colmex** en `_theme/` — paleta `#5e002b`, layouts `cover` /
  `section` / `default`, componentes `<Azul>` / `<Rojo>` / `<Verde>`.
- **Node.js** como runtime — solo para autoría y build. Los estudiantes
  consumen sitio estático, no necesitan Node.

## Estructura del directorio

```
slides/
├── _theme/                     ← compartido entre todas las semanas
│   ├── layouts/                  cover.vue, section.vue, default.vue
│   ├── components/               Azul, Rojo, Verde, Blue/Orange/Green, Block
│   ├── public/                   colmex-logo, title-bg, section-bg, final-bg
│   ├── style.css                 paleta, footer, bloques
│   └── scripts/build-student.mjs filtra contenido instructor-only
├── template/                   ← plantilla maestra
│   ├── slides.md                 deck de ejemplo con todos los patrones
│   ├── package.json              scripts npm (dev, build, preview, export)
│   ├── vite.config.mjs           amplía fs.allow para los symlinks
│   ├── layouts → ../_theme/layouts
│   ├── components → ../_theme/components
│   ├── public → ../_theme/public
│   └── style.css → ../_theme/style.css
└── semana_NN/                  ← una por semana, misma forma que template/
```

`layouts/`, `components/`, `public/` y `style.css` son **symlinks**: un
cambio al tema se propaga a todas las semanas sin tocar archivo por archivo.

---

## Requisitos (una vez por máquina)

```bash
# Node y Slidev
brew install node                       # si no lo tienes
npm install -g @slidev/cli              # CLI global, evita node_modules en iCloud

# Para exportar a PDF (Slidev usa Chromium headless vía Playwright):
npm install -g playwright-chromium      # el paquete (Slidev lo busca aquí)
npx playwright install chromium         # el binario del browser
```

> Python 3 viene preinstalado en macOS y se usa para servir builds estáticos
> localmente (`python3 -m http.server`).

---

## Desarrollo local

### Arrancar una semana nueva

```bash
cp -RP slides/template slides/semana_05
cd slides/semana_05
# editar slides.md con el contenido de la semana
slidev --open
```

> **Importante:** `cp -RP` preserva los symlinks. Sin `-P`, macOS los expande y
> se rompe el flujo de tema compartido.

### Comandos por semana

Desde dentro de `slides/semana_NN/`:

```bash
# Dev server con hot reload → http://localhost:3030
slidev --open
# o equivalente:
npm run dev

# Build estático → ./dist/
npm run build

# Preview del build localmente vía HTTP → http://localhost:4173
npm run preview

# Export a PDF
npm run export
```

> **Importante:** el `dist/` NO se puede abrir con `file://` (Safari y Chrome
> bloquean los ES modules vía esa scheme). Para preview local usa siempre
> `npm run preview`, que levanta un servidor HTTP sobre `dist/` con Python.

### Convenciones de autoría del slides.md

**Layouts** disponibles (frontmatter del slide):

| Layout    | Uso                                                                            |
|-----------|--------------------------------------------------------------------------------|
| `cover`   | Portada; abre y cierra el deck. Toma `title`, `subtitle`, `author`, `date`.   |
| `section` | Separador de sección. Toma `eyebrow` opcional.                                 |
| `default` | Slides normales. Toma `section`, `subsection`, `author` que van al footer.    |

**Componentes de bloque:**

```md
<Azul t="Título" cita="Wickham (2023), cap. 3">

Contenido en **markdown**.

</Azul>

<Rojo t="Título" cita="ENSU 4T 2023">

La moción aquí.

</Rojo>

<Verde t="Título">

Enunciado del ejercicio.

</Verde>
```

Siempre con **línea en blanco** entre la apertura del tag y el contenido (y
otra antes del cierre) para que el contenido se parsee como Markdown.

**Énfasis de color inline** — sintaxis de clase MDC, **no** etiquetas Vue:

```md
Texto con [palabra azul]{.colmex-blue}, [naranja]{.colmex-orange} y [verde]{.colmex-green}.
```

---

## Distribución a estudiantes vía GitHub Pages

Workflow recomendado: cada semana queda como una URL pública estable
del tipo `https://dkelly23.github.io/data_projects/semana_NN/`.

### Setup inicial (una vez para todo el repo)

1. **Habilitar GitHub Pages** en el repo:
   - GitHub → Settings → Pages.
   - Source: "GitHub Actions".

2. **Añadir el workflow** en `.github/workflows/deploy-slides.yml`:

   ```yaml
   name: Deploy slides to Pages
   on:
     push:
       branches: [main]
       paths: ['slides/**']
     workflow_dispatch:

   permissions:
     contents: read
     pages: write
     id-token: write

   jobs:
     build:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v4
         - uses: actions/setup-node@v4
           with:
             node-version: 20
         - run: npm install -g @slidev/cli playwright-chromium
         - name: Build cada semana
           run: |
             mkdir -p public
             for dir in slides/semana_*/; do
               week=$(basename "$dir")
               echo "Building $week..."
               (cd "$dir" && slidev build --base "/data_projects/$week/" --out "../../public/$week")
             done
         - name: Index page
           run: |
             cat > public/index.html <<'HTML'
             <!DOCTYPE html>
             <html lang="es"><head><meta charset="utf-8">
             <title>Programación para Proyectos de Datos</title></head>
             <body><h1>Programación para Proyectos de Datos</h1>
             <ul>
             HTML
             for dir in public/semana_*/; do
               week=$(basename "$dir")
               echo "<li><a href=\"$week/\">$week</a></li>" >> public/index.html
             done
             echo "</ul></body></html>" >> public/index.html
         - uses: actions/upload-pages-artifact@v3
           with:
             path: public

     deploy:
       needs: build
       runs-on: ubuntu-latest
       environment:
         name: github-pages
         url: ${{ steps.deployment.outputs.page_url }}
       steps:
         - id: deployment
           uses: actions/deploy-pages@v4
   ```

3. **Commit + push.** Cada push a `main` que toque `slides/**` corre el
   workflow y publica.

### Resultado

- Index del curso: `https://dkelly23.github.io/data_projects/`
- Por semana: `https://dkelly23.github.io/data_projects/semana_01/`
- El build usa `--base "/data_projects/semana_NN/"` para que las rutas
  internas a assets respeten el subpath del repo en GitHub Pages.

### Alternativas

- **Netlify Drop** — para probar rápido sin tocar GitHub Actions. Arrastra
  `slides/semana_NN/dist/` (construido con `npm run build`) a
  [app.netlify.com/drop](https://app.netlify.com/drop). Te da una URL.
- **PDF como backup offline** — `npm run export` produce un PDF lineal por
  si los estudiantes lo prefieren para descarga.
