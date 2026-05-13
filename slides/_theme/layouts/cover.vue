<template>
  <div class="slidev-layout colmex-cover">
    <img src="/colmex-logo.png" alt="El Colegio de México" class="colmex-logo-cover" />
    <h1>{{ $frontmatter.title || $slidev.configs.title }}</h1>
    <div v-if="$frontmatter.subtitle || $slidev.configs.subtitle" class="subtitle">
      {{ $frontmatter.subtitle || $slidev.configs.subtitle }}
    </div>
    <div class="author">{{ $frontmatter.author || $slidev.configs.author || 'Daniel Kelly' }}</div>
    <div class="institute">
      El Colegio de México &mdash; Licenciatura en Economía
    </div>
    <div class="date">{{ $frontmatter.date || $slidev.configs.date || 'Otoño 2026' }}</div>
  </div>
</template>
