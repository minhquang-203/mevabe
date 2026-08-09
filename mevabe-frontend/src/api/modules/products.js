import http from '@/api/http'

export function listProducts(params) {
  return http.get('/products', { params })
}

export function getProduct(id) {
  return http.get(`/products/${id}`)
}

export function createProduct(payload) {
  return http.post('/products', payload)
}

export function updateProduct(id, payload) {
  return http.put(`/products/${id}`, payload)
}

export function removeProduct(id) {
  return http.delete(`/products/${id}`)
}
