#|
 This file is a part of Atomics
 (c) 2019 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(defpackage #:atomics
  (:nicknames #:org.shirakumo.atomics)
  (:use #:cl)
  (:shadow #:defstruct)
  (:export
   #:implementation-not-supported
   #:operation
   #:cas
   #:atomic-incf
   #:atomic-decf
   #:atomic-pop
   #:atomic-push
   #:atomic-update
   #:defstruct))
(in-package #:org.shirakumo.atomics)

(define-condition implementation-not-supported (error)
  ((operation :initarg :operation :initform NIL :reader operation))
  (:report (lambda (c s) (format s "~
~:[~a is not supported by the Atomics library.~;
~:*The ~a operation is not supported by ~a in Atomics.~]
This is most likely due to lack of support by the implementation.

If you think this is in error, and the implementation does expose
the necessary operators, please file an issue at

  https://github.com/shinmera/atomics/issues"
                                 (operation c)
                                 (lisp-implementation-type)))))

(defun no-support (&optional operation)
  (error 'implementation-not-supported :operation operation))

#-(or allegro ccl clasp ecl lispworks mezzano sbcl)
(no-support)

(defmacro cas (place old new)
  #+allegro
  `(if (excl:atomic-conditional-setf ,place ,new ,old) T NIL)
  #+ccl
  `(ccl::conditional-store ,place ,old ,new)
  #+clasp
  (let ((tmp (gensym "OLD")))
    `(let ((,tmp ,old)) (eq ,tmp (mp:cas ,place ,tmp ,new))))
  #+ecl
  (let ((tmp (gensym "OLD")))
    `(let ((,tmp ,old)) (eq ,tmp (mp:compare-and-swap ,place ,tmp ,new))))
  #+lispworks
  `(system:compare-and-swap ,place ,old ,new)
  #+mezzano
  (let ((tmp (gensym "OLD")))
    `(let ((,tmp ,old))
       (eq ,tmp (mezzano.extensions:compare-and-swap ,place ,tmp ,new))))
  #+sbcl
  (let ((tmp (gensym "OLD")))
    `(let ((,tmp ,old)) (eq ,tmp (sb-ext:cas ,place ,tmp ,new))))
  #-(or allegro ccl clasp ecl lispworks mezzano sbcl)
  (no-support 'CAS))

(defmacro atomic-incf (place &optional (delta 1))
  #+allegro
  `(excl:incf-atomic ,place ,delta)
  #+ccl
  `(ccl::atomic-incf-decf ,place ,delta)
  #+clasp
  `(mp:atomic-incf ,place ,delta)
  #+ecl
  `(+ (mp:atomic-incf ,place ,delta) ,delta)
  #+lispworks
  `(system:atomic-incf ,place ,delta)
  #+mezzano
  `(+ (mezzano.extensions:atomic-incf ,place ,delta) ,delta)
  #+sbcl
  `(+ (sb-ext:atomic-incf ,place ,delta) ,delta)
  #-(or allegro ccl clasp ecl lispworks mezzano sbcl)
  (no-support 'atomic-incf))

(defmacro atomic-decf (place &optional (delta 1))
  #+allegro
  `(excl:decf-atomic ,place ,delta)
  #+ccl
  `(ccl::atomic-incf-decf ,place (- ,delta))
  #+clasp
  `(mp:atomic-decf ,place ,delta)
  #+ecl
  `(- (mp:atomic-decf ,place ,delta) ,delta)
  #+lispworks
  `(system:atomic-decf ,place ,delta)
  #+mezzano
  `(- (mezzano.extensions:atomic-decf ,place ,delta) ,delta)
  #+sbcl
  `(- (sb-ext:atomic-decf ,place ,delta) ,delta)
  #-(or allegro ccl clasp ecl lispworks mezzano sbcl)
  (no-support 'atomic-decf))

(defmacro atomic-pop (place)
  #+allegro
  `(excl:pop-atomic ,place)
  #+ecl
  `(mp:atomic-pop ,place)
  #+lispworks
  `(system:atomic-pop ,place)
  #+sbcl
  `(sb-ext:atomic-pop ,place)
  #-(or allegro ecl lispworks sbcl)
  (let ((new (gensym))
        (old (gensym)))
    `(let* ((,old ,place))
       (loop for ,new = (cdr ,old)
             until (cas ,place ,old ,new)
             finally (return (car ,old))))))

(defmacro atomic-push (value place)
  #+allegro
  `(excl:push-atomic ,value ,place)
  #+ecl
  `(mp:atomic-push ,value ,place)
  #+lispworks
  `(system:atomic-push ,value ,place)
  #+sbcl
  `(sb-ext:atomic-push ,value ,place)
  #-(or allegro ecl lispworks sbcl)
  (let ((new (gensym))
        (old (gensym)))
    `(let* ((,old ,place)
            (,new (cons ,value ,old)))
       (loop until (cas ,place ,old ,new)
             do (setf (cdr ,new) ,old)
             finally (return ,new)))))

(defmacro atomic-update (place update-fn)
  #+allegro
  (let ((value (gensym "VALUE")))
    `(excl:update-atomic (,value ,place) (funcall ,update-fn ,value)))
  #+clasp
  `(mp:atomic-update ,place ,update-fn)
  #+ecl
  `(mp:atomic-update ,place ,update-fn)
  #+sbcl
  `(sb-ext:atomic-update ,place ,update-fn)
  #-(or allegro clasp ecl sbcl)
  (let ((old (gensym "OLD"))
        (new (gensym "NEW")))
    `(loop for ,old = ,place
           for ,new = (funcall ,update-fn ,old)
           until (cas ,place ,old ,new))))

(defmacro defstruct (name &rest slots)
  #+ecl
  `(cl:defstruct (,@(if (listp name) name (list name))
                  :atomic-accessors)
     ,@slots)
  #-ecl
  `(cl:defstruct ,name ,@slots))
