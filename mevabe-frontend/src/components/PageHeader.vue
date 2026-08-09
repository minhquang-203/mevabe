<script setup>
defineProps({
  title: {
    type: String,
    required: true,
  },
  subtitle: {
    type: String,
    default: '',
  },
})
</script>

<template>
  <div class="page-header">
    <div>
      <h2 class="page-header__title">{{ title }}</h2>
      <p v-if="subtitle" class="page-header__subtitle">{{ subtitle }}</p>
    </div>
    <div class="page-header__actions">
      <slot name="actions" />
    </div>
  </div>
</template>

<style scoped>
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 16px;
  margin-bottom: 16px;
}

.page-header__title {
  margin: 0;
  font-size: 22px;
  font-weight: 700;
}

.page-header__subtitle {
  margin: 6px 0 0;
  color: #909399;
  font-size: 14px;
}

.page-header__actions {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}
</style>
