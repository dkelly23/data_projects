// Config local de Vite para Slidev.
// Sin `import` para no requerir `node_modules` local (slidev es global).
//
// layouts/, components/, public/ y style.css son symlinks a ../_theme/.
// Vite resuelve symlinks a su path real y bloquea reads fuera del root
// (server.fs.allow). Hay que ampliar la lista permitida.
export default {
  server: {
    fs: {
      strict: false,
      allow: ['..']
    }
  }
}
