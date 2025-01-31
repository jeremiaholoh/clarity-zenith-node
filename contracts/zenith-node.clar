;; ZenithNode Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-unauthorized (err u100))
(define-constant err-already-registered (err u101))
(define-constant err-not-registered (err u102))
(define-constant err-invalid-status (err u103))

;; Node status enum
(define-data-var node-status-map (list 4 (string-ascii 12)) 
  (list "active" "inactive" "pending" "suspended"))

;; Data structures
(define-map nodes
  { node-id: principal }
  {
    status: (string-ascii 12),
    reputation: uint,
    resources: uint,
    last-active: uint,
    peers: (list 100 principal)
  }
)

;; Node registration
(define-public (register-node (resources uint))
  (let ((caller tx-sender))
    (if (is-registered caller)
      err-already-registered
      (ok (map-set nodes
        { node-id: caller }
        {
          status: "pending",
          reputation: u100,
          resources: resources,
          last-active: block-height,
          peers: (list)
        }
      ))
    )
  )
)

;; Update node status
(define-public (update-status (new-status (string-ascii 12)))
  (let ((caller tx-sender))
    (if (and
      (is-registered caller)
      (is-valid-status new-status))
      (ok (map-set nodes
        { node-id: caller }
        (merge (unwrap-panic (get-node-info caller))
          { status: new-status })))
      err-invalid-status)
  )
)

;; Helper functions
(define-private (is-registered (node principal))
  (is-some (map-get? nodes { node-id: node }))
)

(define-private (is-valid-status (status (string-ascii 12)))
  (is-some (index-of (var-get node-status-map) status))
)

;; Read only functions
(define-read-only (get-node-info (node principal))
  (map-get? nodes { node-id: node })
)

(define-read-only (get-node-status (node principal))
  (get status (unwrap-panic (get-node-info node)))
)

(define-read-only (get-node-reputation (node principal))
  (get reputation (unwrap-panic (get-node-info node)))
)
