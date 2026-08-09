<script setup>
import { useRouter } from 'vue-router'

const router = useRouter()
</script>

<template>
  <div class="not-found">
    <div class="text-center">
      <div class="display-3 fw-bold text-warning">404</div>
      <p class="text-secondary mt-2 mb-4">Trang bạn tìm không tồn tại.</p>
      <button type="button" class="btn btn-primary" @click="router.push('/dashboard')">
        Về Dashboard
      </button>
    </div>
  </div>
</template>

<style scoped>
.not-found {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f5f7fa;
}
</style>
