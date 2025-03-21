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

(define-module (nerd pages)
  #:use-module (nerd templates)
  #:use-module (htmlprag)
  #:use-module (web response)
  #:use-module (web client)
  #:use-module (web http)
  #:use-module (web uri)
  #:use-module (ice-9 receive)
  #:use-module (ice-9 string-fun)
  #:export (error-page
            index-page
            article-page
            proxy-page))

(define good-response
  (build-response #:code 200
                  #:headers `((content-type . (text/html)))))

(define (redirect response code)
  (values (build-response #:code code
                          #:headers `((location . ,(parse-header
                                                     'location
                                                     (uri-path
                                                       (response-location
                                                         response))))))
          "Redirect"))

(define (error-page code)
  (display ";\tHandler: error-page") (newline)
  (values (build-response
            #:code code
            #:headers `((content-type . (text/html))))
          (shtml->html (error-template code))))

(define (generic-page procedure path)
  (let ((resp "")
        (body "")
        (ret ""))
    (receive (_resp _body)
             (http-request (string-append "https://www.geeksforgeeks.org" path))
             (set! resp _resp)
             (set! body _body))
    (display (string-append ";\tStatus: "
                            (number->string (response-code resp))))
    (newline)
    (cond ((equal? (response-code resp) 200)
           (let ((doc (html->sxml-0nf body #:strict? #t)))
             (values good-response
                     (string-replace-substring
                       (string-replace-substring
                         (string-replace-substring
                           (shtml->html (procedure doc))
                           "&amp;" "&")
                         "https://media.geeksforgeeks.org/"
                         "/proxy?url=https://media.geeksforgeeks.org/")
                       "https://www.geeksforgeeks.org" ""))))
          ((and (>= (response-code resp) 300) (<= (response-code resp) 399))
           (redirect resp (response-code resp)))
          (else (error-page (response-code resp))))))

(define (index-page host)
  (display ";\tHandler: index-page") (newline)
  (values good-response (shtml->html (index-template host))))

(define (article-page path)
  (display ";\tHandler: article-page")
  (generic-page article-template path))

(define (proxy-page query)
  (display ";\tHandler: proxy-page") (newline)
  (let ((resp "")
        (body "")
        (url ""))
    (map (lambda (p)
           (if (equal? (car p) "url")
             (set! url (cadr p))))
         (map (lambda (s)
                (string-split s #\=))
              (string-split query #\&)))
    (if (and
          (>= (string-length url) 32)
          (equal? (substring url 0 32) "https://media.geeksforgeeks.org/"))
      (begin
        (receive (_resp _body) (http-request url)
                 (set! resp _resp)
                 (set! body _body))
        (cond
          ((equal? (response-code resp) 200)
           (values (build-response
                     #:code 200
                     #:headers `((content-type .
                                   ,(response-content-type resp))
                                 (cache-control .
                                   ,(parse-header 'cache-control
                                                  "max-age=604800"))))
                   body))
          ((and (>= (response-code resp) 300) (<= (response-code resp) 399))
           (values (build-response
                     #:code (response-code resp)
                     #:headers `((location . ,(parse-header
                                                'location
                                                (uri-path
                                                  (response-location
                                                    resp))))
                                 (content-type .
                                   ,(response-content-type resp))))
                   "Redirect"))
          (else (error-page 404))))
    (error-page 400))))
