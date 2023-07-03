(asdf:defsystem atomics-test
  :version "1.0.0"
  :license "zlib"
  :author "Yukari Hafner <shinmera@tymoon.eu>"
  :maintainer "Yukari Hafner <shinmera@tymoon.eu>"
  :description "Test system for the Atomics library"
  :homepage "https://shinmera.github.io/atomics/"
  :bug-tracker "https://github.com/Shinmera/atomics/issues"
  :source-control (:git "https://github.com/Shinmera/atomics.git")
  :serial T
  :components ((:file "tests"))
  :depends-on (:parachute :atomics)
  :perform (asdf:test-op (op c) (uiop:symbol-call :parachute :test :atomics-test)))
