;; Content Creation and Sharing Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-unauthorized (err u102))

;; Data Variables
(define-data-var last-content-id uint u0)

;; Data Maps
(define-map contents
  { content-id: uint }
  {
    author: principal,
    title: (string-ascii 100),
    content-hash: (buff 32),
    timestamp: uint,
    likes: uint,
    shares: uint
  }
)

;; Public Functions
(define-public (create-content (title (string-ascii 100)) (content-hash (buff 32)))
  (let
    (
      (content-id (+ (var-get last-content-id) u1))
      (user tx-sender)
    )
    (map-set contents
      { content-id: content-id }
      {
        author: user,
        title: title,
        content-hash: content-hash,
        timestamp: block-height,
        likes: u0,
        shares: u0
      }
    )
    (var-set last-content-id content-id)
    (ok content-id)
  )
)

(define-public (like-content (content-id uint))
  (let
    (
      (content (unwrap! (map-get? contents { content-id: content-id }) err-not-found))
    )
    (map-set contents
      { content-id: content-id }
      (merge content { likes: (+ (get likes content) u1) })
    )
    (ok true)
  )
)

(define-public (share-content (content-id uint))
  (let
    (
      (content (unwrap! (map-get? contents { content-id: content-id }) err-not-found))
    )
    (map-set contents
      { content-id: content-id }
      (merge content { shares: (+ (get shares content) u1) })
    )
    (ok true)
  )
)

;; Read-only Functions
(define-read-only (get-content (content-id uint))
  (map-get? contents { content-id: content-id })
)

