<script setup>
defineProps({
  keyword: {
    type: String,
    default: '',
  },
  placeholder: {
    type: String,
    default: 'Tìm kiếm...',
  },
  addText: {
    type: String,
    default: 'Thêm mới',
  },
  showAdd: {
    type: Boolean,
    default: true,
  },
})

const emit = defineEmits(['update:keyword', 'search', 'add'])

function onSearch() {
  emit('search')
}
</script>

<template>
  <div class="page-toolbar">
    <div class="page-toolbar__filters">
      <div class="input-group" style="max-width: 320px">
        <input
          :value="keyword"
          type="text"
          class="form-control"
          :placeholder="placeholder"
          @input="emit('update:keyword', $event.target.value)"
          @keyup.enter="onSearch"
        />
        <button class="btn btn-outline-secondary" type="button" @click="onSearch">
          <i class="bi bi-search"></i>
        </button>
      </div>
      <button type="button" class="btn btn-primary" @click="onSearch">Tìm</button>
      <slot name="filters" />
    </div>

    <div>
      <button v-if="showAdd" type="button" class="btn btn-primary" @click="emit('add')">
        <i class="bi bi-plus-lg me-1"></i>
        {{ addText }}
      </button>
    </div>
  </div>
</template>
