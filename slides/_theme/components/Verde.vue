<template>
  <div class="colmex-block verde">
    <div class="colmex-block-header">{{ t }}</div>
    <div class="colmex-block-body">
      <slot />
    </div>
  </div>
</template>

<script setup lang="ts">
defineProps<{
  t: string
}>()
</script>
