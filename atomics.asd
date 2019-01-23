#|
 This file is a part of Atomics
 (c) 2019 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(asdf:defsystem atomics
  :version "1.0.0"
  :license "Artistic"
  :author "Nicolas Hafner <shinmera@tymoon.eu>"
  :maintainer "Nicolas Hafner <shinmera@tymoon.eu>"
  :description "Portability layer for atomic operations like compare-and-swap (CAS)."
  :homepage "https://shinmera.github.io/atomics/"
  :bug-tracker "https://github.com/Shinmera/atomics/issues"
  :source-control (:git "https://github.com/Shinmera/atomics.git")
  :serial T
  :components ((:file "atomics")
               (:file "documentation"))
  :depends-on (:documentation-utils)
  :in-order-to ((asdf:test-op (asdf:test-op :atomics-test))))
