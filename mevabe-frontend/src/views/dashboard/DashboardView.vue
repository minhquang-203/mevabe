<script setup>
import PageHeader from '@/components/PageHeader.vue'

const stats = [
  { title: 'Sản phẩm', value: '128', icon: 'bi-box-seam', color: '#409eff' },
  { title: 'Đơn hàng hôm nay', value: '24', icon: 'bi-receipt', color: '#67c23a' },
  { title: 'Doanh thu (tháng)', value: '86.5tr', icon: 'bi-wallet2', color: '#e6a23c' },
  { title: 'Khách hàng mới', value: '37', icon: 'bi-people', color: '#f56c6c' },
]
</script>

<template>
  <div>
    <PageHeader title="Dashboard" subtitle="Tổng quan hoạt động cửa hàng (số liệu mẫu)." />

    <div class="row g-3">
      <div v-for="item in stats" :key="item.title" class="col-12 col-sm-6 col-lg-3">
        <div class="card h-100 border-0 shadow-sm">
          <div class="card-body d-flex justify-content-between align-items-center">
            <div>
              <div class="text-secondary mb-1">{{ item.title }}</div>
              <div class="fs-3 fw-bold">{{ item.value }}</div>
            </div>
            <i class="bi fs-1" :class="item.icon" :style="{ color: item.color }"></i>
          </div>
        </div>
      </div>
    </div>

    <div class="card border-0 shadow-sm mt-3">
      <div class="card-body">
        <h3 class="h5">Bắt đầu nhanh</h3>
        <ol class="mb-0">
          <li>Vào menu <strong>Danh mục &amp; Sản phẩm → Sản phẩm</strong> để xem CRUD mẫu.</li>
          <li>Copy cấu trúc module sản phẩm khi thêm chức năng mới.</li>
          <li>Đặt <code>VITE_USE_MOCK=false</code> khi backend API đã sẵn sàng.</li>
        </ol>
      </div>
    </div>
  </div>
</template>
