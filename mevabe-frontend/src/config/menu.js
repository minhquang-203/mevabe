export const adminMenus = [
  {
    index: '/dashboard',
    title: 'Dashboard',
    icon: 'bi-speedometer2',
  },
  {
    index: 'catalog',
    title: 'Danh mục & Sản phẩm',
    icon: 'bi-box-seam',
    children: [
      { index: '/products', title: 'Sản phẩm' },
      { index: '/categories', title: 'Danh mục', disabled: true },
      { index: '/brands', title: 'Thương hiệu', disabled: true },
    ],
  },
  {
    index: '/orders',
    title: 'Đơn hàng',
    icon: 'bi-receipt',
    disabled: true,
  },
  {
    index: '/inventory',
    title: 'Kho hàng',
    icon: 'bi-archive',
    disabled: true,
  },
  {
    index: '/promotions',
    title: 'Khuyến mãi',
    icon: 'bi-ticket-perforated',
    disabled: true,
  },
  {
    index: '/users',
    title: 'Người dùng',
    icon: 'bi-people',
    disabled: true,
  },
  {
    index: 'content',
    title: 'Blog / CMS',
    icon: 'bi-journal-richtext',
    children: [
      { index: '/blog', title: 'Bài viết', disabled: true },
      { index: '/banners', title: 'Banner', disabled: true },
    ],
  },
  {
    index: '/settings',
    title: 'Cài đặt',
    icon: 'bi-gear',
    disabled: true,
  },
]
