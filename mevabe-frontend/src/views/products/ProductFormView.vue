<script setup>
import { computed, onMounted, reactive, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import PageHeader from '@/components/PageHeader.vue'
import { createProduct, getProduct, updateProduct } from '@/api/modules/products'
import { GENDER_TARGET_OPTIONS } from '@/constants'
import { slugify } from '@/utils/format'
import { toast } from '@/utils/notify'

const route = useRoute()
const router = useRouter()

const loading = ref(false)
const saving = ref(false)
const slugTouched = ref(false)

const isEdit = computed(() => Boolean(route.params.id))
const pageTitle = computed(() => (isEdit.value ? 'Sửa sản phẩm' : 'Thêm sản phẩm'))

const form = reactive({
  productCode: '',
  categoryCode: '',
  brandCode: '',
  sku: '',
  name: '',
  slug: '',
  shortDescription: '',
  description: '',
  originCountry: '',
  genderTarget: 'unisex',
  basePrice: null,
  salePrice: null,
  costPrice: null,
  weightGram: null,
  isFeatured: false,
  isActive: true,
})

const errors = reactive({
  name: '',
  sku: '',
  categoryCode: '',
  basePrice: '',
  genderTarget: '',
})

watch(
  () => form.name,
  (value) => {
    if (!isEdit.value && !slugTouched.value) {
      form.slug = slugify(value)
    }
  },
)

function validate() {
  errors.name = form.name.trim() ? '' : 'Nhập tên sản phẩm'
  errors.sku = form.sku.trim() ? '' : 'Nhập SKU'
  errors.categoryCode = form.categoryCode.trim() ? '' : 'Nhập mã danh mục'
  errors.basePrice =
    form.basePrice === null || form.basePrice === '' || Number.isNaN(Number(form.basePrice))
      ? 'Nhập giá gốc'
      : ''
  errors.genderTarget = form.genderTarget ? '' : 'Chọn đối tượng'
  return !Object.values(errors).some(Boolean)
}

async function loadDetail() {
  if (!isEdit.value) return
  loading.value = true
  try {
    const data = await getProduct(route.params.id)
    Object.assign(form, {
      productCode: data.productCode || '',
      categoryCode: data.categoryCode || '',
      brandCode: data.brandCode || '',
      sku: data.sku || '',
      name: data.name || '',
      slug: data.slug || '',
      shortDescription: data.shortDescription || '',
      description: data.description || '',
      originCountry: data.originCountry || '',
      genderTarget: data.genderTarget || 'unisex',
      basePrice: data.basePrice ?? null,
      salePrice: data.salePrice ?? null,
      costPrice: data.costPrice ?? null,
      weightGram: data.weightGram ?? null,
      isFeatured: Boolean(data.isFeatured),
      isActive: data.isActive !== false,
    })
    slugTouched.value = true
  } finally {
    loading.value = false
  }
}

async function handleSubmit() {
  if (!validate()) return

  saving.value = true
  try {
    const payload = {
      ...form,
      slug: form.slug || slugify(form.name),
    }

    if (isEdit.value) {
      await updateProduct(route.params.id, payload)
      toast.success('Cập nhật sản phẩm thành công')
    } else {
      await createProduct(payload)
      toast.success('Tạo sản phẩm thành công')
    }
    router.push({ name: 'products' })
  } finally {
    saving.value = false
  }
}

function goBack() {
  router.push({ name: 'products' })
}

onMounted(loadDetail)
</script>

<template>
  <div class="position-relative">
    <div v-if="loading" class="form-loading">
      <div class="spinner-border text-primary" role="status"></div>
    </div>

    <PageHeader :title="pageTitle" subtitle="Form mẫu dùng Bootstrap + validate thủ công.">
      <template #actions>
        <button type="button" class="btn btn-outline-secondary" @click="goBack">Quay lại</button>
      </template>
    </PageHeader>

    <div class="page-card">
      <form style="max-width: 860px" @submit.prevent="handleSubmit">
        <div class="row g-3">
          <div class="col-md-6">
            <label class="form-label">Tên sản phẩm</label>
            <input
              v-model="form.name"
              type="text"
              maxlength="255"
              class="form-control"
              :class="{ 'is-invalid': errors.name }"
            />
            <div v-if="errors.name" class="invalid-feedback">{{ errors.name }}</div>
          </div>
          <div class="col-md-6">
            <label class="form-label">SKU</label>
            <input
              v-model="form.sku"
              type="text"
              maxlength="50"
              class="form-control"
              :class="{ 'is-invalid': errors.sku }"
            />
            <div v-if="errors.sku" class="invalid-feedback">{{ errors.sku }}</div>
          </div>
          <div class="col-md-6">
            <label class="form-label">Mã danh mục</label>
            <input
              v-model="form.categoryCode"
              type="text"
              class="form-control"
              placeholder="CAT-MILK"
              :class="{ 'is-invalid': errors.categoryCode }"
            />
            <div v-if="errors.categoryCode" class="invalid-feedback">{{ errors.categoryCode }}</div>
          </div>
          <div class="col-md-6">
            <label class="form-label">Mã thương hiệu</label>
            <input v-model="form.brandCode" type="text" class="form-control" placeholder="BRD-ABBOTT" />
          </div>
          <div class="col-md-6">
            <label class="form-label">Slug</label>
            <input
              v-model="form.slug"
              type="text"
              class="form-control"
              placeholder="tu-dong-tao-tu-ten"
              @input="slugTouched = true"
            />
          </div>
          <div class="col-md-6">
            <label class="form-label">Đối tượng</label>
            <select
              v-model="form.genderTarget"
              class="form-select"
              :class="{ 'is-invalid': errors.genderTarget }"
            >
              <option v-for="item in GENDER_TARGET_OPTIONS" :key="item.value" :value="item.value">
                {{ item.label }}
              </option>
            </select>
            <div v-if="errors.genderTarget" class="invalid-feedback">{{ errors.genderTarget }}</div>
          </div>
          <div class="col-md-6">
            <label class="form-label">Giá gốc</label>
            <input
              v-model.number="form.basePrice"
              type="number"
              min="0"
              step="1000"
              class="form-control"
              :class="{ 'is-invalid': errors.basePrice }"
            />
            <div v-if="errors.basePrice" class="invalid-feedback">{{ errors.basePrice }}</div>
          </div>
          <div class="col-md-6">
            <label class="form-label">Giá sale</label>
            <input v-model.number="form.salePrice" type="number" min="0" step="1000" class="form-control" />
          </div>
          <div class="col-md-6">
            <label class="form-label">Giá vốn</label>
            <input v-model.number="form.costPrice" type="number" min="0" step="1000" class="form-control" />
          </div>
          <div class="col-md-6">
            <label class="form-label">Khối lượng (g)</label>
            <input v-model.number="form.weightGram" type="number" min="0" step="10" class="form-control" />
          </div>
          <div class="col-md-6">
            <label class="form-label">Xuất xứ</label>
            <input v-model="form.originCountry" type="text" class="form-control" />
          </div>
          <div class="col-md-6">
            <label class="form-label d-block">Cờ trạng thái</label>
            <div class="d-flex flex-wrap gap-3 pt-2">
              <div class="form-check form-switch">
                <input id="isActive" v-model="form.isActive" class="form-check-input" type="checkbox" />
                <label class="form-check-label" for="isActive">Đang bán</label>
              </div>
              <div class="form-check form-switch">
                <input id="isFeatured" v-model="form.isFeatured" class="form-check-input" type="checkbox" />
                <label class="form-check-label" for="isFeatured">Nổi bật</label>
              </div>
            </div>
          </div>
          <div class="col-12">
            <label class="form-label">Mô tả ngắn</label>
            <textarea
              v-model="form.shortDescription"
              class="form-control"
              rows="2"
              maxlength="500"
            ></textarea>
          </div>
          <div class="col-12">
            <label class="form-label">Mô tả chi tiết</label>
            <textarea v-model="form.description" class="form-control" rows="4"></textarea>
          </div>
        </div>

        <div class="d-flex gap-2 mt-4">
          <button type="submit" class="btn btn-primary" :disabled="saving">
            <span v-if="saving" class="spinner-border spinner-border-sm me-2"></span>
            Lưu
          </button>
          <button type="button" class="btn btn-outline-secondary" @click="goBack">Huỷ</button>
        </div>
      </form>
    </div>
  </div>
</template>

<style scoped>
.form-loading {
  position: absolute;
  inset: 0;
  background: rgba(255, 255, 255, 0.65);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1;
}
</style>
