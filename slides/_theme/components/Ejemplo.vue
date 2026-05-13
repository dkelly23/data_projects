<template>
  <div class="colmex-block ejemplo">
    <div class="colmex-block-header">Ejemplo {{ n }}</div>
    <div class="colmex-block-body">
      <strong>Ejemplo:</strong> <em><slot /></em>
      <span v-if="cita" class="colmex-block-cite">{{ cita }}</span>
    </div>
  </div>
</template>

<script setup lang="ts">
defineProps<{
  n: string | number
  cita?: string
}>()
</script>
