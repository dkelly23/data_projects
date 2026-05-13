<template>
  <div class="colmex-block fragmento">
    <div class="colmex-block-header">{{ t }} {{ n }}</div>
    <div class="colmex-block-body">
      <slot />
      <span v-if="cita" class="colmex-block-cite">{{ cita }}</span>
    </div>
  </div>
</template>

<script setup lang="ts">
defineProps<{
  t: string
  n: string | number
  cita?: string
}>()
</script>
