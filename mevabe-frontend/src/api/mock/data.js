let productSeq = 4

export const mockUsers = {
  admin: {
    id: 1,
    userCode: 'USR-ADMIN',
    fullName: 'Quản trị viên',
    email: 'admin@mevabe.local',
    roleCode: 'admin',
    avatarUrl: '',
  },
}

/** @type {Array<Record<string, any>>} */
export let mockProducts = [
  {
    id: 1,
    productCode: 'PRD-001',
    categoryCode: 'CAT-MILK',
    brandCode: 'BRD-ABBOTT',
    sku: 'SKU-MILK-001',
    name: 'Sữa bột Abbott Grow 1',
    slug: 'sua-bot-abbott-grow-1',
    shortDescription: 'Sữa bột dinh dưỡng cho bé 0-6 tháng',
    description: 'Sản phẩm sữa bột hỗ trợ phát triển chiều cao và trí não.',
    originCountry: 'Ireland',
    genderTarget: 'unisex',
    basePrice: 485000,
    salePrice: 459000,
    costPrice: 320000,
    weightGram: 850,
    isFeatured: true,
    isActive: true,
    viewCount: 120,
    soldCount: 45,
    avgRating: 4.5,
    createdAt: '2026-01-10T08:00:00Z',
    updatedAt: '2026-01-15T10:00:00Z',
  },
  {
    id: 2,
    productCode: 'PRD-002',
    categoryCode: 'CAT-DIAPER',
    brandCode: 'BRD-PAMPERS',
    sku: 'SKU-DIAPER-002',
    name: 'Tã quần Pampers size M',
    slug: 'ta-quan-pampers-size-m',
    shortDescription: 'Tã quần mềm mại, thấm hút tốt',
    description: 'Tã quần dành cho bé 6-11kg, chống tràn hiệu quả.',
    originCountry: 'Japan',
    genderTarget: 'unisex',
    basePrice: 295000,
    salePrice: null,
    costPrice: 180000,
    weightGram: 1200,
    isFeatured: false,
    isActive: true,
    viewCount: 88,
    soldCount: 30,
    avgRating: 4.2,
    createdAt: '2026-01-12T09:00:00Z',
    updatedAt: '2026-01-16T11:00:00Z',
  },
  {
    id: 3,
    productCode: 'PRD-003',
    categoryCode: 'CAT-CLOTHES',
    brandCode: 'BRD-CANIFA',
    sku: 'SKU-CLOTHES-003',
    name: 'Bộ quần áo sơ sinh Canifa',
    slug: 'bo-quan-ao-so-sinh-canifa',
    shortDescription: 'Cotton mềm, thân thiện với da bé',
    description: 'Bộ quần áo sơ sinh 100% cotton organic.',
    originCountry: 'Vietnam',
    genderTarget: 'girl',
    basePrice: 189000,
    salePrice: 159000,
    costPrice: 90000,
    weightGram: 250,
    isFeatured: true,
    isActive: false,
    viewCount: 54,
    soldCount: 12,
    avgRating: 4.0,
    createdAt: '2026-01-18T07:30:00Z',
    updatedAt: '2026-01-20T14:20:00Z',
  },
]

export function nextProductId() {
  return productSeq++
}

export function setMockProducts(products) {
  mockProducts = products
}
