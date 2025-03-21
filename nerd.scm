;; Copyright (C) 2024 Skylar Astaroth <cobra@vern.cc>
;;
;; This file is part of NerdsforNerds
;;
;; NerdsforNerds is free software: you can redistribute it and/or modify it
;; under the terms of the GNU Affero General Public License as published by the
;; Free Software Foundation, either version 3 of the License, or (at your
;; option) any later version.
;;
;; This program is distributed in the hope that it will be useful, but WITHOUT
;; ANY WARRANTY; without even the implied warranty of  MERCHANTABILITY or
;; FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License
;; for more details.
;;
;; You should have received a copy of the GNU Affero General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

(define-module (nerd)
  #:use-module (nerd pages)
  #:use-module (web server)
  #:use-module (web uri)
  #:use-module (web request)
  #:use-module (web http)
  #:use-module (ice-9 textual-ports)
  #:use-module (ice-9 binary-ports))

(define (handler request request-body)
  (let ((uri (request-uri request))
        (path (uri-path (request-uri request)))
        (path-components
          (split-and-decode-uri-path
            (uri-path
              (request-uri request)))))

    (display (string-append
               (strftime "%c" (localtime (current-time)))
               ": " (uri->string uri)))
    (cond
      ((equal? path "/style.css")
       (display ";\tHandler: internal") (newline)
       (values `((content-type . (text/css)))
               (call-with-input-file "static/style.css" get-string-all)))
      ((equal? path "/favicon.png")
       (display ";\tHandler: internal") (newline)
       (values `((content-type . (image/png))
                 (cache-control .
                  ,(parse-header 'cache-control
                                 "max-age=604800")))
               (call-with-input-file "static/logo.png" get-bytevector-all)))
      ((equal? path "/")
       (let ((host (request-host request)))
         (if (cdr host)
           (index-page (string-append
                         (car host) ":"
                         (number->string (cdr host))))
           (index-page (car host)))))
      ((equal? path "/proxy")
       (proxy-page (uri-query uri)))
      (else (article-page path)))))

(let ((port (if (getenv "PORT")
              (string->number (getenv "PORT"))
              8006))
      (sock (socket PF_INET SOCK_STREAM 0)))
  (bind sock AF_INET INADDR_ANY port)
  (fcntl sock F_SETFL (logior O_NONBLOCK
                              (fcntl sock F_GETFL)))
  (run-server handler 'http `(#:socket ,sock)))
