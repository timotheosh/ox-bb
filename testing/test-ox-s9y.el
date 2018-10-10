;;; test-ox-s9y.el --- unit tests for Serendipity HTML Back-End for Org Export Engine -*- lexical-binding: t; -*-

;; Copyright (C) 2017  Christian Garbs <mitch@cgarbs.de>
;; Licensed under GNU GPL v3 or later.

;; This file is part of ox-s9y.

;; ox-s9y is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; ox-s9y is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with ox-s9y.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; unit tests for ox-s9y

;;; Code:

(require 'ox-s9y)

;;;;;
;;;;; test helpers
;;;;;

(defmacro org-s9y-export-temp-text (text)
    "Run ox-s9y export for given input.
Create a temporary buffer with Org mode as the active mode
holding TEXT and export it with 'ox-s9y, returning the export
result as a string."
    (with-temp-buffer
      (org-mode)
      (insert text)
      (org-export-as 's9y nil nil nil nil)))

;;;;;
;;;;; tests for backend methods
;;;;;

;;; org-s9y-bold

(ert-deftest org-s9y/bold ()
  (should (equal (org-s9y-export-temp-text "foo *BAR* baz")
		 "<p>foo <strong>BAR</strong> baz</p>\n")))

;;; org-s9y-code

(ert-deftest org-s9y/code ()
  (should (equal (org-s9y-export-temp-text "foo ~BAR~ baz")
		 "<p>foo <code>BAR</code> baz</p>\n")))

;;; org-s9y-geshi-block

(ert-deftest org-s9y/geshi-block ()
  (should (equal (org-s9y-export-temp-text "#+BEGIN_SRC java\npackage foo;\n/* dummy dummy */\n#+END_SRC")
		 "[geshi lang=java]\npackage foo;\n/* dummy dummy */\n[/geshi]\n")))

;;; org-s9y-headline

(ert-deftest org-s9y/headline/lv1-as-comment ()
  (should (equal (org-s9y-export-temp-text "* TOPIC")
		 "<!--  TOPIC  -->\n")))
(ert-deftest org-s9y/headline/lv2-as-comment ()
  (should (equal (org-s9y-export-temp-text "* dummy\n** TOPIC")
		 "<!--  dummy  -->\n<!--  TOPIC  -->\n")))

(ert-deftest org-s9y/headline/lv3-as-h3 ()
  (should (equal (org-s9y-export-temp-text "* dummy\n** dummy\n*** TOPIC")
		 "<!--  dummy  -->\n<!--  dummy  -->\n<h3>TOPIC</h3>\n")))

(ert-deftest org-s9y/headline/lv4-as-h4 ()
  (should (equal (org-s9y-export-temp-text "* dummy\n** dummy\n*** dummy\n**** TOPIC")
		 "<!--  dummy  -->\n<!--  dummy  -->\n<h3>dummy</h3>\n<h4>TOPIC</h4>\n")))

(ert-deftest org-s9y/headline/lv5-as-h5 ()
  (should (equal (org-s9y-export-temp-text "* dummy\n** dummy\n*** dummy\n**** dummy\n***** TOPIC")
		 "<!--  dummy  -->\n<!--  dummy  -->\n<h3>dummy</h3>\n<h4>dummy</h4>\n<h5>TOPIC</h5>\n")))

;;; org-s9y-italic

(ert-deftest org-s9y/italic ()
  (should (equal (org-s9y-export-temp-text "foo /BAR/ baz")
		 "<p>foo <em>BAR</em> baz</p>\n")))

;;; org-s9y-line-break

(ert-deftest org-s9y/line-break ()
  (should (equal (org-s9y-export-temp-text "foo\\\\\nbar")
		 "<p>foo<br>\nbar</p>\n")))

;;; org-s9y-link

(ert-deftest org-s9y/link/http ()
  (should (equal (org-s9y-export-temp-text "[[http://foo/][bar]]")
		 "<p><a href=\"http://foo/\">bar</a></p>\n")))

(ert-deftest org-s9y/link/https ()
  (should (equal (org-s9y-export-temp-text "[[https://foo/][bar]]")
		 "<p><a href=\"https://foo/\">bar</a></p>\n")))

(ert-deftest org-s9y/link/todo ()
  (should (equal (org-s9y-export-temp-text "[[todo://this-part-is-ignored/][bar]]")
		 "<p><abbr title=\"Artikel folgt\">bar</abbr></p>\n")))

(ert-deftest org-s9y/link/about ()
  (should (equal (org-s9y-export-temp-text "[[about:config][bar]]")
		 "<p><a href=\"about:config\">bar</a></p>\n")))

(ert-deftest org-s9y/link/encode-url ()
  (should (equal (org-s9y-export-temp-text "[[http://foo/ bar][baz]]")
		 "<p><a href=\"http://foo/%20bar\">baz</a></p>\n")))

(ert-deftest org-s9y/link/encode-url-only-once ()
  (should (equal (org-s9y-export-temp-text "[[http://foo/%20bar][baz]]")
		 "<p><a href=\"http://foo/%20bar\">baz</a></p>\n")))

;;; org-s9y-paragraph

(ert-deftest org-s9y/paragraph/single-paragraph ()
  (should (equal (org-s9y-export-temp-text "foo")
		 "<p>foo</p>\n")))

(ert-deftest org-s9y/paragraph/multiline-paragraph ()
  (should (equal (org-s9y-export-temp-text "foo\nbar")
		 "<p>foo\nbar</p>\n")))

(ert-deftest org-s9y/paragraph/multiple-paragraphs ()
  (should (equal (org-s9y-export-temp-text "foo\n\nbar")
		 "<p>foo</p>\n\n<p>bar</p>\n")))

;;; org-s9y-underline

(ert-deftest org-s9y/underline ()
  (should (equal (org-s9y-export-temp-text "foo _BAR_ baz")
		 "<p>foo <u>BAR</u> baz</p>\n")))

;;; org-s9y-verbatim

(ert-deftest org-s9y/verbatim ()
  (should (equal (org-s9y-export-temp-text "foo =BAR= baz")
		 "<p>foo <code>BAR</code> baz</p>\n")))

;;; PLAIN-LIST UNORDERED
;;; org-s9y-item
;;; org-s9y-list

(ert-deftest org-s9y/plain-list/unordered ()
  (should (equal (org-s9y-export-temp-text "- foo\n- bar")
		 "<ul><li>foo</li>\n<li>bar</li></ul>\n")))

;;; PLAIN-LIST ORDERED
;;; org-s9y-item
;;; org-s9y-list

(ert-deftest org-s9y/plain-list/ordered ()
  (should (equal (org-s9y-export-temp-text "1. foo\n2. bar")
		 "<ol><li>foo</li>\n<li>bar</li></ol>\n")))

;;; PLAIN-LIST DESCRIPTIVE
;;; org-s9y-item
;;; org-s9y-list

(ert-deftest org-s9y/plain-list/descriptive ()
  (should (equal (org-s9y-export-temp-text "- foo :: pokey\n- bar :: hokey")
		 "<dl><dt>foo</dt>\n<dd>pokey</dd>\n<dt>bar</dt>\n<dd>hokey</dd></dl>\n")))

;;;;;
;;;;; tests for internal methods
;;;;;

;;; org-s9y--put-in-tag

(ert-deftest org-s9y/put-in-tag/no-attribute ()
  (should (equal (org-s9y--put-in-tag "p" "foo")
		 "<p>foo</p>")))

(ert-deftest org-s9y/put-in-tag/single-attribute ()
  (should (equal (org-s9y--put-in-tag "a" "foo" '(("href" "file.htm")))
		 "<a href=\"file.htm\">foo</a>")))

(ert-deftest org-s9y/put-in-tag/multiple-attributes ()
  (should (equal (org-s9y--put-in-tag "div" "foo" '(("class" "bar") ("style" "margin: 0;")))
		 "<div class=\"bar\" style=\"margin: 0;\">foo</div>")))

;;; org-s9y--put-a-href

(ert-deftest org-s9y/put-a-href/plain ()
  (should (equal (org-s9y--put-a-href "some text" "https://example.com/")
		 "<a href=\"https://example.com/\">some text</a>")))

(ert-deftest org-s9y/put-a-href/encode-url-only-once ()
  (should (equal (org-s9y--put-a-href "baz" "http://foo/%20bar")
		 "<a href=\"http://foo/%20bar\">baz</a>")))

;;; org-s9y--remove-trailing-newline

(ert-deftest org-s9y/remove-trailing-newline/remove ()
  (should (equal( org-s9y--remove-trailing-newline "some text\n")
		"some text")))

(ert-deftest org-s9y/remove-trailing-newline/only-remove-last-newline ()
  (should (equal( org-s9y--remove-trailing-newline "some text\n\n")
		"some text\n")))

(ert-deftest org-s9y/remove-trailing-newline/keep-newlines-within ()
  (should (equal( org-s9y--remove-trailing-newline "line 1\nline 2\n")
		"line 1\nline 2")))

(ert-deftest org-s9y/remove-trailing-newline/dont-fail-with-no-newline ()
  (should (equal( org-s9y--remove-trailing-newline "some text")
		"some text")))



;;; Register file

(provide 'test-ox-s9y)

;;; test-ox-s9y.el ends here
