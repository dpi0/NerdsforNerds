;; Copyright (C) 2024 Skylar Widulski <cobra@vern.cc>
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

(define-module (nerd scraping)
  #:use-module (libxml2)
  #:use-module (system foreign)
  #:use-module (ice-9 regex)
  #:use-module (ice-9 string-fun)
  #:use-module (ice-9 binary-ports)
  #:export (get-article))

(define (get-article d)
  (define article-text
    (get-xpath-node
      "//div[@class=\"a-wrapper\"]/article/div[@class=\"text\"]"
      d))
  (define chld (child1 article-text 0))
  (define chld1 %null-pointer)
  (define lst (list ""))
  (while (not (null-pointer? chld))
         (cond
           ((or (equal? (name chld) "p")
                (equal? (name chld) "blockquote")
                (equal? (name chld) "ul")
                (equal? (name chld) "ol")
                (equal? (name chld) "img")
                (equal? (name chld) "table")
                (equal? (name chld) "h2")
                (equal? (name chld) "h3")
                (and (equal? (name chld) "div")
                     (equal? (name (attrs chld)) "id")
                     (equal? (text (attrs chld)) "table_of_content")))
            (append!
              lst
              (list (cons
                      (regexp-substitute/global
                        #f "<img [^>]*src=\"(https://[^\"]*)\"[^>]*>"
                        (regexp-substitute/global
                          #f "</?(span|em)[^>]*>"
                          (dump-xml chld)
                          'pre "" 'post)
                        'pre "<img src=\"/proxy?url=" 1
                        "\" loading=\"lazy\" />" 'post)
                      ""))))
           ((and (equal? (name chld) "div")
                 (equal? (name (attrs chld)) "class")
                 (equal? (text (attrs chld)) "code-output"))
            (append!
              lst
              (list (cons
                      (regexp-substitute/global
                        #f "</?(span|strong|em)[^>]*>"
                        (dump-xml chld)
                        'pre "" 'post)
                      ""))))
           ((and (equal? (name chld) "div")
                 (not (null-pointer? (next (attrs chld) 0)))
                 (equal? (name (next (attrs chld) 0)) "class")
                 (equal? (text (next (attrs chld) 0)) "wp-caption alignnone"))
            (append!
              lst
              (list (cons
                      (regexp-substitute/global
                        #f (string-append
                             "<div[^>]*><img [^>]*src=\"(https://"
                             "[^\"]*)\"[^>]*><p[^>]*>([^<]*)</p></div>")
                        (dump-xml chld)
                        'pre "<img src=\"/proxy?url=" 1
                        "\" loading=\"lazy\" alt=\"" 2
                        "\" title=\"" 2 "\" />" 'post)
                      ""))))
           ((equal? (name chld) "pre")
            (append!
              lst
              (list (cons
                      (regexp-substitute/global
                        #f "</?span[^>]*>"
                        (string-replace-substring
                          (dump-xml chld)
                          "<br/>\n" "")
                        'pre "" 'post)
                      ""))))
           ((equal? (name chld) "")
            (do ((i 1 (+ i 2)))
                ((null-pointer?
                   (get-xpath-node
                     (string-append "//*[name(.) =''][" (number->string i) "]")
                     chld)))
              (append!
                lst
                (list (cons
                        (regexp-substitute/global
                          #f "</?span[^>]*>"
                          (text (get-xpath-node
                                  (string-append "//*[name(.) ='']["
                                                 (number->string i) "]")
                                  chld))
                          'pre "" 'post)
                        (regexp-substitute/global
                          #f "</?(span|pre)[^>]*>"
                          (dump-xml (get-xpath-node
                                      (string-append "//*[name(.) ='']["
                                                     (number->string (1+ i))
                                                     "]/code/div/pre")
                                      chld))
                          'pre "" 'post))))))
           ((and (equal? (name chld) "div")
                 (equal? (name (attrs chld)) "class")
                 (equal? (text (attrs chld)) "responsive-tabs"))
            (append!
              lst
              (list (cons
                      (text (child1 chld 0))
                      (regexp-substitute/global
                        #f "(<div class=\"container\">\n|</?(code|div)[^>]*>)"
                        (dump-xml (get-xpath-node "//tbody/tr/td/div" chld))
                        'pre "" 'post))))))
         (set! chld (next chld 0)))
  (define lst1
    (let ((pref "//div[@class=\"a-wrapper\"]/article"))
      (list
        (get-xpath-string
          (string-append 
            pref "/div[1]/div[1]/div[1]/h1/text()") d #f)
        (get-xpath-string
          (string-append 
            pref "/div[1]/div[1]/div[2]/span[2]/text()")
          d #f))))
  (define sidebar
    (list
      (if (not (xpath-null? "//ul[@class=\"leftBarList\"]" d))
        (string-replace-substring
          (string-replace-substring
            (dump-xpath-xml "//ul[@class=\"leftBarList\"]/div" d)
            "<div class=\"second\">" "")
          "</div>" ""))))
  (append lst1 sidebar (cdr lst)))
