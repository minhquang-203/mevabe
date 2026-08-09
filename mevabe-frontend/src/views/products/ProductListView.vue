<script setup>
import { onMounted, reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import PageHeader from '@/components/PageHeader.vue'
import TableToolbar from '@/components/TableToolbar.vue'
import Pagination from '@/components/Pagination.vue'
import StatusTag from '@/components/StatusTag.vue'
import { listProducts, removeProduct } from '@/api/modules/products'
import { ACTIVE_STATUS_OPTIONS, DEFAULT_PAGE_SIZE } from '@/constants'
import { formatCurrency, formatDateTime } from '@/utils/format'
import { confirmDialog, toast } from '@/utils/notify'

const router = useRouter()
const loading = ref(false)
const rows = ref([])
const total = ref(0)

const query = reactive({
  keyword: '',
  isActive: '',
  page: 1,
  size: DEFAULT_PAGE_SIZE,
})

async function fetchData() {
  loading.value = true
  try {
    const data = await listProducts({
      keyword: query.keyword || undefined,
      isActive: query.isActive === '' ? undefined : query.isActive,
      page: query.page,
      size: query.size,
    })
    rows.value = data.content || []
    total.value = data.totalElements || 0
  } finally {
    loading.value = false
  }
}

function handleSearch() {
  query.page = 1
  fetchData()
}

function goCreate() {
  router.push({ name: 'product-create' })
}

function goEdit(row) {
  router.push({ name: 'product-edit', params: { id: row.id } })
}

async function handleDelete(row) {
  const ok = await confirmDialog(`Xóa sản phẩm "${row.name}"?`, 'Xác nhận xoá')
  if (!ok) return

  try {
    await removeProduct(row.id)
    toast.success('Đã xóa sản phẩm')
    if (rows.value.length === 1 && query.page > 1) {
      query.page -= 1
    }
    await fetchData()
  } catch {
    // error already toasted by http
  }
}

onMounted(fetchData)
</script>

<template>
  <div>
    <PageHeader title="Sản phẩm" subtitle="Module CRUD mẫu — copy cấu trúc này khi thêm feature mới." />

    <div class="page-card">
      <TableToolbar
        v-model:keyword="query.keyword"
        placeholder="Tìm theo tên, SKU, mã SP..."
        add-text="Thêm sản phẩm"
        @search="handleSearch"
        @add="goCreate"
      >
        <template #filters>
          <select
            v-model="query.isActive"
            class="form-select"
            style="width: 160px"
            @change="handleSearch"
          >
            <option value="">Trạng thái</option>
            <option
              v-for="item in ACTIVE_STATUS_OPTIONS"
              :key="String(item.value)"
              :value="String(item.value)"
            >
              {{ item.label }}
            </option>
          </select>
        </template>
      </TableToolbar>

      <div class="table-responsive position-relative">
        <div v-if="loading" class="table-loading">
          <div class="spinner-border text-primary" role="status"></div>
        </div>
        <table class="table table-striped table-bordered align-middle mb-0">
          <thead>
            <tr>
              <th>Mã SP</th>
              <th>Tên sản phẩm</th>
              <th>SKU</th>
              <th>Danh mục</th>
              <th>Giá bán</th>
              <th class="text-center">Nổi bật</th>
              <th class="text-center">Trạng thái</th>
              <th>Cập nhật</th>
              <th>Thao tác</th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="!rows.length">
              <td colspan="9" class="text-center text-secondary py-4">Chưa có sản phẩm</td>
            </tr>
            <tr v-for="row in rows" :key="row.id">
              <td>{{ row.productCode }}</td>
              <td>{{ row.name }}</td>
              <td>{{ row.sku }}</td>
              <td>{{ row.categoryCode }}</td>
              <td>{{ formatCurrency(row.salePrice ?? row.basePrice) }}</td>
              <td class="text-center">
                <span v-if="row.isFeatured" class="badge text-bg-warning">Hot</span>
                <span v-else>-</span>
              </td>
              <td class="text-center">
                <StatusTag :active="row.isActive" />
              </td>
              <td>{{ formatDateTime(row.updatedAt) }}</td>
              <td class="text-nowrap">
                <button type="button" class="btn btn-link btn-sm p-0 me-2" @click="goEdit(row)">
                  Sửa
                </button>
                <button type="button" class="btn btn-link btn-sm text-danger p-0" @click="handleDelete(row)">
                  Xóa
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <Pagination
        v-model:page="query.page"
        v-model:size="query.size"
        :total="total"
        @change="fetchData"
      />
    </div>
  </div>
</template>

<style scoped>
.table-loading {
  position: absolute;
  inset: 0;
  background: rgba(255, 255, 255, 0.65);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1;
}
</style>
