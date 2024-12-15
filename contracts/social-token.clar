;; Social Token Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-unauthorized (err u102))

;; Token definition
(define-fungible-token social-token)

;; Public Functions
(define-public (mint (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ft-mint? social-token amount recipient)
  )
)

(define-public (transfer (amount uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) err-unauthorized)
    (ft-transfer? social-token amount sender recipient)
  )
)

;; Read-only Functions
(define-read-only (get-balance (account principal))
  (ok (ft-get-balance social-token account))
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply social-token))
)

