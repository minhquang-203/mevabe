import { mockProducts, mockUsers, nextProductId, setMockProducts } from './data'
import { slugify } from '@/utils/format'

const USE_MOCK = String(import.meta.env.VITE_USE_MOCK).toLowerCase() === 'true'

function delay(ms = 0) {
  return new Promise((resolve) => setTimeout(resolve, ms))
}

function ok(data, message = 'OK') {
  return {
    status: 'SUCCESS',
    message,
    data,
    timestamp: new Date().toISOString(),
  }
}

function fail(code, message, status = 400) {
  const error = new Error(message)
  error.response = {
    status,
    data: {
      status: 'FAILED',
      code,
      message,
      timestamp: new Date().toISOString(),
    },
  }
  throw error
}

function paginate(items, params = {}) {
  const page = Number(params.page || 1)
  const size = Number(params.size || 10)
  const keyword = String(params.keyword || '')
    .trim()
    .toLowerCase()

  let filtered = [...items]
  if (keyword) {
    filtered = filtered.filter((item) =>
      [item.name, item.sku, item.productCode, item.categoryCode]
        .filter(Boolean)
        .some((field) => String(field).toLowerCase().includes(keyword)),
    )
  }

  if (params.isActive !== undefined && params.isActive !== null && params.isActive !== '') {
    const active = String(params.isActive) === 'true'
    filtered = filtered.filter((item) => item.isActive === active)
  }

  const total = filtered.length
  const start = (page - 1) * size
  const content = filtered.slice(start, start + size)

  return {
    content,
    page,
    size,
    totalElements: total,
    totalPages: Math.max(1, Math.ceil(total / size)),
  }
}

async function handleMock(config) {
  await delay()
  const method = (config.method || 'get').toLowerCase()
  const url = config.url || ''
  const params = config.params || {}
  const body = typeof config.data === 'string' ? JSON.parse(config.data || '{}') : config.data || {}

  if (url === '/auth/login' && method === 'post') {
    if (!body.email || !body.password) {
      fail('AUTH_INVALID', 'Email và mật khẩu là bắt buộc', 400)
    }
    return ok({
      token: 'mock-jwt-token',
      user: mockUsers.admin,
    })
  }

  if (url === '/auth/me' && method === 'get') {
    return ok(mockUsers.admin)
  }

  if (url === '/auth/logout' && method === 'post') {
    return ok(null, 'Đã đăng xuất')
  }

  if (url === '/products' && method === 'get') {
    return ok(paginate(mockProducts, params))
  }

  if (url === '/products' && method === 'post') {
    const id = nextProductId()
    const now = new Date().toISOString()
    const created = {
      id,
      productCode: body.productCode || `PRD-${String(id).padStart(3, '0')}`,
      categoryCode: body.categoryCode || 'CAT-OTHER',
      brandCode: body.brandCode || null,
      sku: body.sku,
      name: body.name,
      slug: body.slug || slugify(body.name),
      shortDescription: body.shortDescription || '',
      description: body.description || '',
      originCountry: body.originCountry || '',
      genderTarget: body.genderTarget || 'unisex',
      basePrice: Number(body.basePrice || 0),
      salePrice: body.salePrice === null || body.salePrice === '' ? null : Number(body.salePrice),
      costPrice: body.costPrice === null || body.costPrice === '' ? null : Number(body.costPrice),
      weightGram: body.weightGram === null || body.weightGram === '' ? null : Number(body.weightGram),
      isFeatured: Boolean(body.isFeatured),
      isActive: body.isActive !== false,
      viewCount: 0,
      soldCount: 0,
      avgRating: 0,
      createdAt: now,
      updatedAt: now,
    }
    setMockProducts([created, ...mockProducts])
    return ok(created, 'Tạo sản phẩm thành công')
  }

  const productMatch = url.match(/^\/products\/(\d+)$/)
  if (productMatch) {
    const id = Number(productMatch[1])
    const index = mockProducts.findIndex((item) => item.id === id)
    if (index < 0) {
      fail('PRODUCT_NOT_FOUND', 'Không tìm thấy sản phẩm', 404)
    }

    if (method === 'get') {
      return ok(mockProducts[index])
    }

    if (method === 'put') {
      const current = mockProducts[index]
      const updated = {
        ...current,
        ...body,
        id: current.id,
        productCode: current.productCode,
        basePrice: Number(body.basePrice ?? current.basePrice),
        salePrice:
          body.salePrice === null || body.salePrice === ''
            ? null
            : Number(body.salePrice ?? current.salePrice),
        costPrice:
          body.costPrice === null || body.costPrice === ''
            ? null
            : Number(body.costPrice ?? current.costPrice),
        weightGram:
          body.weightGram === null || body.weightGram === ''
            ? null
            : Number(body.weightGram ?? current.weightGram),
        slug: body.slug || current.slug || slugify(body.name || current.name),
        updatedAt: new Date().toISOString(),
      }
      const next = [...mockProducts]
      next[index] = updated
      setMockProducts(next)
      return ok(updated, 'Cập nhật sản phẩm thành công')
    }

    if (method === 'delete') {
      setMockProducts(mockProducts.filter((item) => item.id !== id))
      return ok(null, 'Xóa sản phẩm thành công')
    }
  }

  fail('MOCK_NOT_FOUND', `Mock chưa hỗ trợ ${method.toUpperCase()} ${url}`, 404)
}

export function isMockEnabled() {
  return USE_MOCK
}

export async function mockAdapter(config) {
  const payload = await handleMock(config)
  return {
    data: payload,
    status: 200,
    statusText: 'OK',
    headers: {},
    config,
    request: {},
  }
}
