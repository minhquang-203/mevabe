<script setup>
import { computed } from 'vue'
import { PAGE_SIZES } from '@/constants'

const props = defineProps({
  page: {
    type: Number,
    required: true,
  },
  size: {
    type: Number,
    required: true,
  },
  total: {
    type: Number,
    required: true,
  },
})

const emit = defineEmits(['update:page', 'update:size', 'change'])

const totalPages = computed(() => Math.max(1, Math.ceil(props.total / props.size) || 1))

const pages = computed(() => {
  const current = props.page
  const last = totalPages.value
  const start = Math.max(1, current - 2)
  const end = Math.min(last, start + 4)
  const list = []
  for (let i = start; i <= end; i += 1) list.push(i)
  return list
})

function onPageChange(value) {
  if (value < 1 || value > totalPages.value || value === props.page) return
  emit('update:page', value)
  emit('change')
}

function onSizeChange(event) {
  emit('update:size', Number(event.target.value))
  emit('update:page', 1)
  emit('change')
}
</script>

<template>
  <div class="pagination-wrap">
    <div class="text-muted small">Tổng {{ total }} bản ghi</div>
    <div class="d-flex align-items-center gap-2 flex-wrap">
      <select class="form-select form-select-sm" style="width: auto" :value="size" @change="onSizeChange">
        <option v-for="item in PAGE_SIZES" :key="item" :value="item">{{ item }} / trang</option>
      </select>

      <nav>
        <ul class="pagination pagination-sm mb-0">
          <li class="page-item" :class="{ disabled: page <= 1 }">
            <button type="button" class="page-link" @click="onPageChange(page - 1)">Trước</button>
          </li>
          <li v-for="item in pages" :key="item" class="page-item" :class="{ active: item === page }">
            <button type="button" class="page-link" @click="onPageChange(item)">{{ item }}</button>
          </li>
          <li class="page-item" :class="{ disabled: page >= totalPages }">
            <button type="button" class="page-link" @click="onPageChange(page + 1)">Sau</button>
          </li>
        </ul>
      </nav>
    </div>
  </div>
</template>

<style scoped>
.pagination-wrap {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 12px;
  flex-wrap: wrap;
  margin-top: 16px;
}
</style>
