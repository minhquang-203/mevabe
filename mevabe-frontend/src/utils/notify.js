function ensureToastHost() {
  let host = document.getElementById('app-toast-host')
  if (!host) {
    host = document.createElement('div')
    host.id = 'app-toast-host'
    host.className = 'toast-container position-fixed top-0 end-0 p-3'
    host.style.zIndex = '1080'
    document.body.appendChild(host)
  }
  return host
}

function showToast(message, variant = 'primary') {
  const host = ensureToastHost()
  const el = document.createElement('div')
  el.className = `toast align-items-center text-bg-${variant} border-0 show`
  el.setAttribute('role', 'alert')
  el.innerHTML = `
    <div class="d-flex">
      <div class="toast-body">${message}</div>
      <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>
    </div>
  `
  host.appendChild(el)

  const close = () => el.remove()
  el.querySelector('.btn-close')?.addEventListener('click', close)
  setTimeout(close, 2800)
}

export const toast = {
  success(message) {
    showToast(message, 'success')
  },
  error(message) {
    showToast(message, 'danger')
  },
  info(message) {
    showToast(message, 'primary')
  },
}

export function confirmDialog(message, title = 'Xác nhận') {
  return new Promise((resolve) => {
    const backdrop = document.createElement('div')
    backdrop.className = 'modal-backdrop fade show'
    const modal = document.createElement('div')
    modal.className = 'modal fade show d-block'
    modal.tabIndex = -1
    modal.innerHTML = `
      <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">${title}</h5>
            <button type="button" class="btn-close" data-action="cancel"></button>
          </div>
          <div class="modal-body"><p class="mb-0">${message}</p></div>
          <div class="modal-footer">
            <button type="button" class="btn btn-outline-secondary" data-action="cancel">Huỷ</button>
            <button type="button" class="btn btn-danger" data-action="ok">Xác nhận</button>
          </div>
        </div>
      </div>
    `

    const cleanup = (ok) => {
      modal.remove()
      backdrop.remove()
      document.body.classList.remove('modal-open')
      resolve(ok)
    }

    modal.addEventListener('click', (e) => {
      const action = e.target?.getAttribute?.('data-action')
      if (action === 'ok') cleanup(true)
      if (action === 'cancel') cleanup(false)
    })

    document.body.classList.add('modal-open')
    document.body.appendChild(backdrop)
    document.body.appendChild(modal)
  })
}
