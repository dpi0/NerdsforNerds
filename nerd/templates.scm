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

(define-module (nerd templates)
  #:use-module (nerd scraping)
  #:use-module (htmlprag)
  #:use-module (ice-9 string-fun)
  #:export (error-template
            index-template
            article-template))

(define (html-head title)
  `(head (title ,title " - NerdsforNerds")
         (meta (@ (charset "UTF-8")))
         (meta (@ (name "viewport") (content "width=device-width")))
         (link (@ (rel "stylesheet") (href "/style.css")))
         (link (@ (rel "icon") (type "image/png") (href "/favicon.png")))))

(define heading
  `(header))

(define source
  `(aside (@ (class "right"))
          (p (a (@ (href "https://git.vern.cc/cobra/NerdsforNerds"))
                "Source Code"))
          ,(if (getenv "PATCHES_URL")
             `(p (a (@ (href ,(getenv "PATCHES_URL")))
                    "Patches"))
             `())))

(define (index-template host)
  `(html ,(html-head "NerdsforNerds")
         (body
           ,heading
           (article
             (h1 "NerdsforNerds")
             (p "NerdsforNerds is a privacy-respecting"
                " front-end to GeeksforGeeks.")
             (h2 "Usage")
             (p "You can use NerdsforNerds by replacing "
                (code "www.geeksforgeeks.org")
                " with this website's domain")
             (h3 "Example")
             (pre (code "https://www.geeksforgeeks.org/script-command-in"
                        "-linux-with-examples/"))
             (p "becomes")
             (pre (code "https://" ,host "/script-command-in-"
                        "linux-with-examples/")))
           ,source)))

(define (article-template d)
  (let ((article (get-article d)))
    `(html ,(html-head (car article))
           (body
             ,heading
             (input (@ (id "yuri")
                       (type "checkbox")
                       (name "girls,,,")))
             (aside (@ (class "left"))
                    (label (@ (for "yuri"))
                           (svg
                             (@ (xmlns "http://www.w3.org/2000/svg")
                                (fill "#ffffff")
                                (width "5em")
                                (height "5em")
                                (viewbox "-2.5 0 19 19"))
                             (path
                               (@ (d ;,(string-append
                                        "M.789 4.836a1.03 1.03 0 0 1 1"
                                        ".03-1.029h10.363a1.03 1.03 0 "
                                        "1 1 0 2.059H1.818A1.03 1.03 0"
                                        " 0 1 .79 4.836zm12.422 4.347a"
                                        "1.03 1.03 0 0 1-1.03 1.029H1."
                                        "819a1.03 1.03 0 0 1 0-2.059h1"
                                        "0.364a1.03 1.03 0 0 1 1.029 1"
                                        ".03zm0 4.345a1.03 1.03 0 0 1-"
                                        "1.03 1.03H1.819a1.03 1.03 0 1"
                                        " 1 0-2.059h10.364a1.03 1.03 0"
                                        " 0 1 1.029 1.03z"))))) ;)
                    ,(list-ref article 5)
                    (a (@ (href ,(string-replace-substring
                                   (caddr article)
                                   "https://www.geeksforgeeks.org" "")))
                       (p ,(cadddr article))
                       (p ,(list-ref article 4))))
             (article
               (h1 ,(car article))
               (h4 "Last updated: " ,(cadr article))
               (hr)
               (main
                 ,(cddr (cddddr article))))
             ,source))))

(define (error-template code)
  `(html ,(html-head (number->string code))
         (body
           ,heading
           (h1 ,(number->string code))
           ,source)))
