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

(define-module (nerd scraping)
  #:use-module (sxml simple)
  #:use-module (sxml xpath)
  #:export (get-article))

(define (get-article d)
  (append
    (list ((sxpath '(// article div div div h1 *any*)) d))
    (cdr ((sxpath '(// article div div div div span *text*)) d))
    ((sxpath '(html body div div div div a @ href *text*)) d)
    ((sxpath '(html body div div div div a div span *text*)) d)
    ((sxpath '(html body div div div div a div div *text*)) d)
    ((sxpath '(html body div div ul)) d)
    ((filter
       (lambda (nodeset)
         (equal?
           '(#f #f)
           (map (lambda (s)
                  (equal?
                    (string-prefix-length
                      (sxml->string
                        (append '(placeholder)
                                ((sxpath '(@ id)) nodeset)))
                      s)
                    4))
                '("GFG_" "_GFG")))))
     ((take-until (filter (sxpath '(@ class (equal? "article_bottom_text")))))
      ((sxpath '(// article (div 3) *)) d)))))
