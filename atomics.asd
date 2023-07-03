(asdf:defsystem atomics
  :version "1.0.0"
  :license "zlib"
  :author "Yukari Hafner <shinmera@tymoon.eu>"
  :maintainer "Yukari Hafner <shinmera@tymoon.eu>"
  :description "Portability layer for atomic operations like compare-and-swap (CAS)."
  :homepage "https://shinmera.github.io/atomics/"
  :bug-tracker "https://github.com/Shinmera/atomics/issues"
  :source-control (:git "https://github.com/Shinmera/atomics.git")
  :serial T
  :components ((:file "atomics")
               (:file "documentation"))
  :depends-on (:documentation-utils)
  :in-order-to ((asdf:test-op (asdf:test-op :atomics-test))))
