;; User Profile and Data Vault Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-unauthorized (err u102))

;; Data Maps
(define-map user-profiles
  { user: principal }
  {
    username: (string-ascii 30),
    bio: (string-utf8 280),
    data-vault-hash: (optional (buff 32))
  }
)

;; Public Functions
(define-public (create-profile (username (string-ascii 30)) (bio (string-utf8 280)))
  (let
    (
      (user tx-sender)
    )
    (asserts! (is-none (map-get? user-profiles { user: user })) err-unauthorized)
    (ok (map-set user-profiles
      { user: user }
      {
        username: username,
        bio: bio,
        data-vault-hash: none
      }
    ))
  )
)

(define-public (update-profile (new-username (string-ascii 30)) (new-bio (string-utf8 280)))
  (let
    (
      (user tx-sender)
    )
    (asserts! (is-some (map-get? user-profiles { user: user })) err-not-found)
    (ok (map-set user-profiles
      { user: user }
      {
        username: new-username,
        bio: new-bio,
        data-vault-hash: (get data-vault-hash (unwrap! (map-get? user-profiles { user: user }) err-not-found))
      }
    ))
  )
)

(define-public (update-data-vault (data-vault-hash (buff 32)))
  (let
    (
      (user tx-sender)
    )
    (asserts! (is-some (map-get? user-profiles { user: user })) err-not-found)
    (ok (map-set user-profiles
      { user: user }
      (merge (unwrap! (map-get? user-profiles { user: user }) err-not-found)
        { data-vault-hash: (some data-vault-hash) }
      )
    ))
  )
)

;; Read-only Functions
(define-read-only (get-profile (user principal))
  (map-get? user-profiles { user: user })
)

