<template>
  <div class="slidev-layout">
    <div v-if="$frontmatter.instructor" class="colmex-instructor-banner">
      Slide solo para el instructor
    </div>
    <img src="/colmex-logo.png" alt="" class="colmex-logo-corner" />
    <slot />
    <div class="colmex-footer">
      <div>{{ $frontmatter.author || $slidev.configs.author || 'Daniel Kelly' }}</div>
      <div>
        <span v-if="$frontmatter.section">{{ $frontmatter.section }}</span>
        <span v-if="$frontmatter.subsection"> &mdash; {{ $frontmatter.subsection }}</span>
      </div>
      <div>{{ $slidev.nav.currentPage }} / {{ $slidev.nav.total }}</div>
    </div>
  </div>
</template>
