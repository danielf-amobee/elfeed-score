;;; elfeed-score-test-scoring.el --- ERT tests for elfeed-score scoring  -*- lexical-binding: t; -*-

;; Copyright (C) 2020 Michael Herstine <sp1ff@pobox.com>

;; Author: Michael Herstine <sp1ff@pobox.com>

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; Scoring tests.

;;; Code:

(require 'elfeed-score-tests)

(ert-deftest elfeed-score-test-test-scoring-on-title-0 ()
  "Test scoring against entry title-- substring matching."

  (let* ((lorem-ipsum "Lorem ipsum dolor sit amet")
         (entry-title "foo bar splat"))
    (with-elfeed-test
     (let* ((feed (elfeed-test-generate-feed))
            (entry (elfeed-score-test-generate-entry
                    feed entry-title lorem-ipsum
                    :tags '(foo splat))))
       (elfeed-db-add entry)
       ;; case-insensitive
     (with-elfeed-score-test
      (let* ((elfeed-score--title-rules
              (list (elfeed-score-title-rule--create :text "Bar" :value 1 :type 's)))
             (score (elfeed-score--score-entry entry)))
        (should (eq score 1))
        (should (eq 1 (elfeed-score-title-rule-hits (car elfeed-score--title-rules))))))
     ;; case-sensitive
     (with-elfeed-score-test
      (let* ((elfeed-score--title-rules
              (list (elfeed-score-title-rule--create :text "Bar" :value 1 :type 'S)))
             (score (elfeed-score--score-entry entry)))
        (should (eq score 0))))
     ;; case-insensitive, scoped by tags
     (with-elfeed-score-test
      (let* ((elfeed-score--title-rules
              (list (elfeed-score-title-rule--create :text "bar" :value 1 :type 's
                                                     :tags '(t . (foo bar)))))
             (score (elfeed-score--score-entry entry)))
        (should (eq score 1))))
     (with-elfeed-score-test
      (let* ((elfeed-score--title-rules
              (list (elfeed-score-title-rule--create :text "bar" :value 1 :type 's
                                                     :tags '(nil . (foo bar)))))
             (score (elfeed-score--score-entry entry)))
        (should (eq score 0))))))))

(ert-deftest elfeed-score-test-test-scoring-on-title-1 ()
  "Test scoring against entry title-- regexp matching."

  (let* ((lorem-ipsum "Lorem ipsum dolor sit amet")
         (entry-title "foo bar splat"))
    (with-elfeed-test
     (let* ((feed (elfeed-test-generate-feed))
            (entry (elfeed-score-test-generate-entry
                    feed entry-title lorem-ipsum)))
       (elfeed-db-add entry)
       ;; case-insensitive
       (with-elfeed-score-test
        (let* ((elfeed-score--title-rules
                (list (elfeed-score-title-rule--create :text "Ba\\(r\\|z\\)" :value 1 :type 'r)))
               (score (elfeed-score--score-entry entry)))
          (should (eq score 1))))
       ;; case-sensitive
       (with-elfeed-score-test
        (let* ((elfeed-score--title-rules
                (list (elfeed-score-title-rule--create :text "Ba\\(r\\|z\\)" :value 1 :type 'R)))
               (score (elfeed-score--score-entry entry)))
          (should (eq score 0))))))))

(ert-deftest elfeed-score-test-test-scoring-on-title-2 ()
  "Test scoring against entry title-- whole-word matching."

  (let* ((lorem-ipsum "Lorem ipsum dolor sit amet")
         (entry-title "foo bar splat"))
    (with-elfeed-test
     (let* ((feed (elfeed-test-generate-feed))
            (entry (elfeed-score-test-generate-entry
                    feed entry-title lorem-ipsum)))
       (elfeed-db-add entry)
       ;; case-insensitive
       (with-elfeed-score-test
        (let* ((elfeed-score--title-rules
                (list (elfeed-score-title-rule--create :text "Ba\\(r\\|z\\)" :value 1 :type 'w)))
               (score (elfeed-score--score-entry entry)))
          (should (eq score 0))))
       ;; case-sensitive
       (with-elfeed-score-test
        (let* ((elfeed-score--title-rules
                (list (elfeed-score-title-rule--create :text "Ba\\(r\\|z\\)" :value 1 :type 'W)))
               (score (elfeed-score--score-entry entry)))
          (should (eq score 0)))))))
  (let* ((lorem-ipsum "Lorem ipsum dolor sit amet")
         (entry-title "foo barsplat"))
    (with-elfeed-test
     (let* ((feed (elfeed-test-generate-feed))
            (entry (elfeed-score-test-generate-entry
                    feed entry-title lorem-ipsum)))
       (elfeed-db-add entry)
       ;; case-insensitive
       (with-elfeed-score-test
        (let* ((elfeed-score--title-rules
                (list (elfeed-score-title-rule--create :text "Ba\\(r\\|z\\)" :value 1 :type 'w)))
               (score (elfeed-score--score-entry entry)))
          (should (eq score 0))))
       ;; case-sensitive
       (with-elfeed-score-test
        (let* ((elfeed-score--title-rules
                (list (elfeed-score-title-rule--create :text "Ba\\(\\|z\\)r" :value 1 :type 'W)))
               (score (elfeed-score--score-entry entry)))
          (should (eq score 0))))
       ))))

(ert-deftest elfeed-score-test-test-scoring-on-feed-title-0 ()
  "Test scoring against entry feed title-- substring matching."

  (let* ((lorem-ipsum "Lorem ipsum dolor sit amet")
         (entry-title "foo bar splat"))
    (with-elfeed-test
     (let* ((feed (elfeed-score-test-generate-feed
                   "Feed" "http://www.feed.com/rss"))
            (entry (elfeed-score-test-generate-entry
                    feed entry-title lorem-ipsum)))
       (elfeed-db-add entry)
       ;; case-insensitive
       (should (equal "Feed" (elfeed-feed-title (elfeed-entry-feed entry))))
       (with-elfeed-score-test
        (let* ((elfeed-score--feed-rules
                (list (elfeed-score-feed-rule--create :text "feed" :value 1 :type 's :attr 't)))
               (score (elfeed-score--score-entry entry)))
          (should (eq score 1))
          (should (eq 1 (elfeed-score-feed-rule-hits (car elfeed-score--feed-rules))))))
       ;; case-sensitive
       (with-elfeed-score-test
        (let* ((elfeed-score--feed-rules
                (list (elfeed-score-feed-rule--create :text "feed" :value 1 :type 'S :attr 't)))
               (score (elfeed-score--score-entry entry)))
          (should (eq score 0))))))))

(ert-deftest elfeed-score-test-test-scoring-on-feed-title-1 ()
  "Test scoring against entry feed title-- regexp matching."

  (let* ((lorem-ipsum "Lorem ipsum dolor sit amet")
         (entry-title "foo bar splat"))
    (with-elfeed-test
     (let* ((feed (elfeed-score-test-generate-feed
                   "Feed" "http://www.feed.com/rss"))
            (entry (elfeed-score-test-generate-entry
                    feed entry-title lorem-ipsum)))
       (elfeed-db-add entry)
       ;; case-insensitive
       (with-elfeed-score-test
        (let* ((elfeed-score--feed-rules
                (list (elfeed-score-feed-rule--create :text "f\\(eed\\|oo\\)" :value 1 :type 'r :attr 't)))
               (score (elfeed-score--score-entry entry)))
          (should (eq score 1))))
       ;; case-sensitive
       (with-elfeed-score-test
        (let* ((elfeed-score--feed-rules
                (list (elfeed-score-feed-rule--create :text "f\\(eed\\|oo\\)" :value 1 :type 'R :attr 't)))
               (score (elfeed-score--score-entry entry)))
          (should (eq score 0))))
       ))))

(ert-deftest elfeed-score-test-test-scoring-on-feed-url-0 ()
  "Test scoring against entry feed URL-- substring matching."

  (let* ((lorem-ipsum "Lorem ipsum dolor sit amet")
         (entry-title "foo bar splat"))
    (with-elfeed-test
     (let* ((feed (elfeed-score-test-generate-feed
                   "Feed" "http://www.feed.com/rss"))
            (entry (elfeed-score-test-generate-entry
                    feed entry-title lorem-ipsum)))
       (elfeed-db-add entry)
       ;; case-insensitive
       (with-elfeed-score-test
        (let* ((elfeed-score--feed-rules
                (list (elfeed-score-feed-rule--create :text "feed.com" :value 1 :type 's :attr 'u)))
               (score (elfeed-score--score-entry entry)))
          (should (eq score 1))))
       ;; case-sensitive
       (with-elfeed-score-test
        (let* ((elfeed-score--feed-rules
                (list (elfeed-score-feed-rule--create :text "Feed.com" :value 1 :type 'S :attr 'u)))
               (score (elfeed-score--score-entry entry)))
          (should (eq score 0))))))))

(ert-deftest elfeed-score-test-test-scoring-on-feed-url-1 ()
  "Test scoring against entry feed URL-- regexp matching."

  (let* ((lorem-ipsum "Lorem ipsum dolor sit amet")
         (entry-title "foo bar splat"))
    (with-elfeed-test
     (let* ((feed (elfeed-score-test-generate-feed
                   "Feed" "http://www.feed.com/rss"))
            (entry (elfeed-score-test-generate-entry
                    feed entry-title lorem-ipsum)))
       (elfeed-db-add entry)
       ;; case-insensitive
       (with-elfeed-score-test
        (let* ((elfeed-score--feed-rules
                (list (elfeed-score-feed-rule--create :text "f\\(eed\\|oo\\)\\.com" :value 1 :type 'r :attr 'u)))
               (score (elfeed-score--score-entry entry)))
          (should (eq score 1))))
       ;; case-sensitive
       (with-elfeed-score-test
        (let* ((elfeed-score--feed-rules
                (list (elfeed-score-feed-rule--create :text "F\\(eed\\|oo\\)\\.com" :value 1 :type 'R :attr 'u)))
               (score (elfeed-score--score-entry entry)))
          (should (eq score 0))))))))

(ert-deftest elfeed-score-test-test-scoring-on-content-0 ()
  "Test scoring based on content-- substring matching."

  (let* ((lorem-ipsum "Lorem ipsum dolor sit amet")
         (entry-title "foo bar splat"))
    (with-elfeed-test
     (let* ((feed (elfeed-test-generate-feed))
            (entry (elfeed-score-test-generate-entry
                    feed entry-title lorem-ipsum)))
       (elfeed-db-add entry)
       ;; case-insensitive
       (with-elfeed-score-test
        (let* ((elfeed-score--content-rules
                (list (elfeed-score-content-rule--create :text "lorem" :value 1 :type 's)))
               (score (elfeed-score--score-entry entry)))
          (should (eq score 1))
          (should (eq 1 (elfeed-score-content-rule-hits (car elfeed-score--content-rules))))))
       ;; case-sensitive
       (with-elfeed-score-test
        (let* ((elfeed-score--content-rules
                (list (elfeed-score-content-rule--create :text "lorem" :value 1 :type 'S)))
               (score (elfeed-score--score-entry entry)))
          (should (eq score 0))))))))

(ert-deftest elfeed-score-test-test-scoring-on-content-1 ()
  "Test scoring based on content-- regexp matching."

  (let* ((lorem-ipsum "Lorem ipsum dolor sit amet")
         (entry-title "foo bar splat"))
    (with-elfeed-test
     (let* ((feed (elfeed-test-generate-feed))
            (entry (elfeed-score-test-generate-entry
                    feed entry-title lorem-ipsum)))
       (elfeed-db-add entry)
       ;; case-insensitive
       (with-elfeed-score-test
        (let* ((elfeed-score--content-rules
                (list (elfeed-score-content-rule--create :text "lo\\(rem\\|om\\)" :value 1 :type 'r)))
               (score (elfeed-score--score-entry entry)))
          (should (eq score 1))))
       ;; case-sensitive
       (with-elfeed-score-test
        (let* ((elfeed-score--content-rules
                (list (elfeed-score-content-rule--create :text "lo\\(rem\\|om\\)" :value 1 :type 'R)))
               (score (elfeed-score--score-entry entry)))
          (should (eq score 0))))))))

(ert-deftest elfeed-score-test-test-scoring-on-title-or-content-0 ()
  "Test scoring based on title-or-content-- substring matching."

  (let* ((lorem-ipsum "Lorem ipsum dolor sit amet")
         (entry-title "Lorem ipsum"))
    (with-elfeed-test
     (let* ((feed (elfeed-test-generate-feed))
            (entry (elfeed-score-test-generate-entry
                    feed entry-title lorem-ipsum)))
       (elfeed-db-add entry)
       ;; case-insensitive
       (with-elfeed-score-test
        (let* ((elfeed-score--title-or-content-rules
                (list (elfeed-score-title-or-content-rule--create
                       :text "lorem ipsum" :title-value 2 :content-value 1
                       :type 's)))
               (score (elfeed-score--score-entry entry)))
          (should (eq score 3))
          (should (eq 2 (elfeed-score-title-or-content-rule-hits (car elfeed-score--title-or-content-rules))))))
       ;; case-sensitive
       (with-elfeed-score-test
        (let* ((elfeed-score--title-or-content-rules
                (list (elfeed-score-title-or-content-rule--create
                       :text "lorem ipsum" :title-value 2 :content-value 1
                       :type 'S)))
               (score (elfeed-score--score-entry entry)))
          (should (eq score 0))))))))

(ert-deftest elfeed-score-test-test-scoring-on-title-or-content-1 ()
  "Test scoring based on title-or-content-- substring matching,
tags scoping."

  (let* ((lorem-ipsum "Lorem ipsum dolor sit amet")
         (entry-title "Lorem ipsum"))
    (with-elfeed-test
     (let* ((feed (elfeed-test-generate-feed))
            (entry (elfeed-score-test-generate-entry
                    feed entry-title lorem-ipsum
                    :tags '(foo bar))))
       (elfeed-db-add entry)
       ;; case-insensitive
       (with-elfeed-score-test
        (let* ((elfeed-score--title-or-content-rules
                (list (elfeed-score-title-or-content-rule--create
                       :text "lorem ipsum" :title-value 1 :content-value 0
                       :type 's)
                      (elfeed-score-title-or-content-rule--create
                       :text "lorem ipsum" :title-value 1 :content-value 0
                       :type 's :tags '(t . (foo splat)))
                      (elfeed-score-title-or-content-rule--create
                       :text "lorem ipsum" :title-value 1 :content-value 0
                       :type 's :tags '(t . (splat)))))
               (score (elfeed-score--score-entry entry)))
          (should (eq score 2))))))))

(ert-deftest elfeed-score-test-test-scoring-on-authors-1 ()
  "Test scoring based on authors-- substring matching,
tags scoping."

  (let* ((lorem-ipsum "Lorem ipsum dolor sit amet")
         (entry-title "Lorem ipsum"))
    (with-elfeed-test
     (let* ((feed (elfeed-test-generate-feed))
            (entry (elfeed-score-test-generate-entry
                    feed entry-title lorem-ipsum
                    :authors '((:name "John Hancock"))
                    :tags '(foo bar))))
       (elfeed-db-add entry)
       ;; case-insensitive
       (with-elfeed-score-test
        (let* ((elfeed-score--authors-rules
                (list (elfeed-score-authors-rule--create
                       :text "Hancock" :value 1 :type 's)
                      (elfeed-score-authors-rule--create
                       :text "John" :value 1
                       :type 'S :tags '(t . (foo splat)))
                      (elfeed-score-authors-rule--create
                       :text "john hancock" :value 1
                       :type 's :tags '(t . (splat)))))
               (score (elfeed-score--score-entry entry))
               (should (eq 1 (elfeed-score-authors-rule-hits (car elfeed-score--authors-rules)))))
          (should (eq score 2))))))))

(ert-deftest elfeed-score-test-missed-match-20200217 ()
  "Test whole-word scoring.

Thought I had a bug; turns out I didn't understand `word-search-regexp'"

  (let ((test-title "AR/VR engineers 1400% rise! Hired: AR/VR engineers replace blockchain programmers as hottest commodity! Thanks God I`m AR engineer"))
    (with-elfeed-test
     (let* ((feed (elfeed-test-generate-feed))
            (entry (elfeed-score-test-generate-entry
                    feed test-title "blah")))
       (elfeed-db-add entry)
       (with-elfeed-score-test
        (let* ((elfeed-score--title-or-content-rules
                (list
                 (elfeed-score-title-or-content-rule--create
                  :text "b\\(lockchain\\|itcoin\\|tc\\)"
                  :title-value 1 :content-value 1 :type 'r)
                 (elfeed-score-title-or-content-rule--create
                  :text "blockchain"
                  :title-value 1 :content-value 1 :type 'w)))
               (score (elfeed-score--score-entry entry)))
          (should (eq score 2))))))))

(ert-deftest elfeed-score-test-test-marking-as-read-0 ()
  "Test marking entries as read if they score low enough."

  (let* ((lorem-ipsum "Lorem ipsum dolor sit amet")
         (entry-title "foo bar splat"))
    (with-elfeed-test
     (let* ((feed (elfeed-test-generate-feed))
            (entry (elfeed-score-test-generate-entry
                    feed entry-title lorem-ipsum)))
       (elfeed-db-add entry)
       (with-elfeed-score-test
        (let* ((elfeed-score--title-rules
                (list (elfeed-score-title-rule--create :text "foo" :value -1 :type 's)))
               (elfeed-score--score-mark 0))
          (elfeed-score--score-entry entry)
          (should (not (elfeed-tagged-p 'unread entry)))))))))

(ert-deftest elfeed-score-test-tags-20200314 ()
  "Test scoring by a rule with multiple tag matches."
  (let ((test-title "Traits, dynamic dispatch and upcasting"))
    (with-elfeed-test
     (let* ((feed (elfeed-test-generate-feed))
            (entry (elfeed-score-test-generate-entry
                    feed test-title "some content")))
       (elfeed-db-add entry)
       (elfeed-tag entry '@dev 'rust)
       (with-elfeed-score-test
        (let* ((elfeed-score--title-or-content-rules
                (list
                 (elfeed-score-title-or-content-rule--create
                  :text "\\(traits\\|upcasting\\)"
                  :title-value 2
                  :content-value 1
                  :type 'r
                  :tags '(t . (@dev rust splat)))))
               (score (elfeed-score--score-entry entry)))
          (should (eq score 2))))))))

(provide 'elfeed-score-tests)

;;; elfeed-score-tests.el ends here
