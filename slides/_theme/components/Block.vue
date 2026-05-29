<template>
  <div :class="['colmex-block', tipo]">
    <div class="colmex-block-header">{{ t }} {{ n }}</div>
    <div class="colmex-block-body">
      <span v-if="label" class="colmex-block-label">{{ label }}</span>
      <span class="colmex-block-content">
        <slot />
        <sup v-if="cita" class="colmex-block-footnote-marker">a</sup>
      </span>
      <span v-if="cita" class="colmex-block-footnote">
        <span class="colmex-block-footnote-marker">a</span>{{ cita }}
      </span>
    </div>
  </div>
</template>

<script setup lang="ts">
withDefaults(
  defineProps<{
    t: string
    n: string | number
    label?: string
    cita?: string
    tipo?: 'azul' | 'rojo' | 'verde'
  }>(),
  {
    tipo: 'rojo'
  }
)
</script>