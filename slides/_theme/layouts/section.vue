<template>
  <div class="slidev-layout colmex-section">
    <div v-if="$frontmatter.eyebrow" class="eyebrow">{{ $frontmatter.eyebrow }}</div>
    <slot />
  </div>
</template>
