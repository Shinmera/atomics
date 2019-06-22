#|
 This file is a part of Atomics
 (c) 2019 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(asdf:defsystem atomics-test
  :version "1.0.0"
  :license "zlib"
  :author "Nicolas Hafner <shinmera@tymoon.eu>"
  :maintainer "Nicolas Hafner <shinmera@tymoon.eu>"
  :description "Test system for the Atomics library"
  :homepage "https://shinmera.github.io/atomics/"
  :bug-tracker "https://github.com/Shinmera/atomics/issues"
  :source-control (:git "https://github.com/Shinmera/atomics.git")
  :serial T
  :components ((:file "tests"))
  :depends-on (:parachute :atomics)
  :perform (asdf:test-op (op c) (uiop:symbol-call :parachute :test :atomics-test)))
