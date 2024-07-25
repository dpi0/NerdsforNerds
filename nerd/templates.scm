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

(define-module (nerd templates)
  #:use-module (nerd scraping)
  #:use-module (libxml2)
  #:use-module (htmlprag)
  #:use-module (ice-9 string-fun)
  #:use-module (system foreign)
  #:export (error-template
            index-template
            article-template
            article->sxml))

(define (html-head title)
  `(head (title ,title)
         (meta (@ (charset "UTF-8")))
         (meta (@ (name "viewport") (content "width=device-width")))
         (link (@ (rel "stylesheet") (href "/style.css")))
         (link (@ (rel "icon") (type "image/png") (href "/favicon.png")))))

(define heading
  `(header))

(define footer
  `(footer
     (p (a (@ (href "https://git.vern.cc/cobra/NerdsforNerds"))
           "Source Code"))
     ,(if (getenv "PATCHES_URL")
        `(p (a (@ (href ,(getenv "PATCHES_URL")))
               "Patches"))
        `())))

(define (index-template host)
  (shtml->html
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
               (pre (code
                      ,(string-append
                         "https://www.geeksforgeeks.org/script-command-in-linux"
                         "-with-examples/")))
               (p "becomes")
               (pre (code
                      ,(string-append
                         "https://" host "/script-command-in-"
                         "linux-with-examples/"))))
             ,footer))))

(define (article-template d)
  (let ((article (get-article d)))
    (shtml->html
      `(html ,(html-head (string-append (car article) " - NerdsforNerds"))
             (body
               ,heading
               ,(article->sxml article)
               ,footer)))))

(define (article->sxml article)
  `(div
     (aside
       (input (@ (id "yuri")
                 (type "checkbox")
                 (name "yuri")))
       (label (@ (for "yuri")) "yuri")
       (ul ,(html->shtml (string-replace-substring
                           (caddr article)
                           "https://www.geeksforgeeks.org" ""))))
     (article
       (h1 ,(car article))
       (h4 "Last updated: " ,(cadr article))
       (hr)
       (main
         ,(map (lambda (p)
                 (if (equal? (cdr p) "")
                   (html->shtml (string-replace-substring
                                  (car p)
                                  "https://www.geeksforgeeks.org" ""))
                   `(div ,(html->shtml
                            (string-replace-substring
                              (car p)
                              "https://www.geeksforgeeks.org" ""))
                         (pre
                           (code
                             ,(html->shtml
                                (string-replace-substring
                                  (cdr p)
                                  "https://www.geeksforgeeks.org" "")))))))
               (cdddr article))))))


(define (error-template code)
  (shtml->html
    `(html ,(html-head
              (string-append
                (number->string code)
                " - NerdsforNerds"))
           (body
             ,heading
             (h1 ,(number->string code))
             ,footer))))
