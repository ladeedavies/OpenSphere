;; Content Moderation Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-unauthorized (err u102))

;; Data Variables
(define-data-var moderation-threshold uint u100)

;; Data Maps
(define-map moderation-votes
  { content-id: uint, user: principal }
  { vote: bool }
)

(define-map moderation-tallies
  { content-id: uint }
  { upvotes: uint, downvotes: uint }
)

;; Public Functions
(define-public (vote-on-content (content-id uint) (upvote bool))
  (let
    (
      (user tx-sender)
      (existing-vote (map-get? moderation-votes { content-id: content-id, user: user }))
      (existing-tally (default-to { upvotes: u0, downvotes: u0 } (map-get? moderation-tallies { content-id: content-id })))
    )
    (asserts! (is-none existing-vote) err-unauthorized)
    (map-set moderation-votes
      { content-id: content-id, user: user }
      { vote: upvote }
    )
    (map-set moderation-tallies
      { content-id: content-id }
      (if upvote
        (merge existing-tally { upvotes: (+ (get upvotes existing-tally) u1) })
        (merge existing-tally { downvotes: (+ (get downvotes existing-tally) u1) })
      )
    )
    (ok true)
  )
)

(define-public (set-moderation-threshold (new-threshold uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ok (var-set moderation-threshold new-threshold))
  )
)

;; Read-only Functions
(define-read-only (get-moderation-votes (content-id uint))
  (map-get? moderation-tallies { content-id: content-id })
)

(define-read-only (is-content-flagged (content-id uint))
  (let
    (
      (tally (unwrap! (map-get? moderation-tallies { content-id: content-id }) false))
    )
    (> (get downvotes tally) (var-get moderation-threshold))
  )
)

