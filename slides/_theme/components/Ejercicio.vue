<template>
  <div class="colmex-block ejercicio">
    <div class="colmex-block-header">Ejercicio {{ n }}</div>
    <div class="colmex-block-body">
      <slot />
    </div>
  </div>
</template>

<script setup lang="ts">
defineProps<{
  n: string | number
}>()
</script>
