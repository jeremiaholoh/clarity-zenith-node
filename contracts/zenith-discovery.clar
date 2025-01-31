;; Node Discovery Contract

(define-map peer-connections
  { from: principal, to: principal }
  { connected-at: uint }
)

(define-public (connect-peer (peer principal))
  (let ((caller tx-sender))
    (ok (map-set peer-connections
      { from: caller, to: peer }
      { connected-at: block-height }))
  )
)

(define-read-only (get-peers (node principal))
  (map-get? peer-connections { from: node })
)
