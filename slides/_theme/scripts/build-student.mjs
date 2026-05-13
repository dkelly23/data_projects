#!/usr/bin/env node
/**
 * Filtra slides.md → slides.student.md eliminando contenido marcado como
 * solo para el instructor.
 *
 * Lee desde process.cwd() (no desde __dirname), de modo que funciona
 * correctamente cuando este archivo se invoca desde una semana específica
 * vía npm-script — independientemente de que el archivo en sí viva bajo
 * slides/_theme/scripts/.
 *
 * Reglas:
 *   1. Slides con `instructor: true` en su frontmatter se eliminan completos.
 *   2. Bloques `<!-- instructor-only --> … <!-- /instructor-only -->`
 *      dentro de cualquier slide también se eliminan.
 */

import { readFileSync, writeFileSync } from 'node:fs'
import { resolve } from 'node:path'

const cwd = process.cwd()
const SRC = resolve(cwd, 'slides.md')
const DST = resolve(cwd, 'slides.student.md')

const raw = readFileSync(SRC, 'utf8')

// 1. Bloques instructor-only dentro de slides.
const sinBloques = raw.replace(
  /<!--\s*instructor-only\s*-->[\s\S]*?<!--\s*\/instructor-only\s*-->\s*/g,
  ''
)

// 2. Slides completos marcados con `instructor: true`.
//    Slidev separa slides con `---` en su propia línea; el primer bloque es
//    el frontmatter global.
const partes = sinBloques.split(/^---\s*$/m)
const out = [partes[0]]
let i = 1
while (i < partes.length) {
  const front = partes[i] ?? ''
  const cuerpo = partes[i + 1]
  const esInstructor = /^\s*instructor:\s*true\s*$/m.test(front)
  if (!esInstructor) {
    out.push('---')
    out.push(front)
    if (cuerpo !== undefined) {
      out.push('---')
      out.push(cuerpo)
    }
  }
  i += 2
}

const final = out.join('').replace(/\n{3,}/g, '\n\n')
writeFileSync(DST, final, 'utf8')
console.log(`✓ Escrito ${DST}`)
