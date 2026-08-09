<script setup>
import { computed } from 'vue'

const props = defineProps({
  active: {
    type: Boolean,
    default: false,
  },
  activeText: {
    type: String,
    default: 'Đang bán',
  },
  inactiveText: {
    type: String,
    default: 'Ngừng bán',
  },
})

const text = computed(() => (props.active ? props.activeText : props.inactiveText))
const badgeClass = computed(() => (props.active ? 'text-bg-success' : 'text-bg-secondary'))
</script>

<template>
  <span class="badge" :class="badgeClass">{{ text }}</span>
</template>
