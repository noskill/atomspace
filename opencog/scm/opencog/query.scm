;
; OpenCog Pattern matcher module
;

(define-module (opencog query))

; We need this to set the LTDL_LIBRARY_PATH
(use-modules (opencog))

; This is also loaded by (opencog exec) We need it here,
; else we get undefined symbols in libquery.
(load-extension "libexecution" "opencog_exec_init")

(load-extension "libquery" "opencog_query_init")

(define-public (cog-bind handle)
	(display "Obsolete! Do not use cog-bind, use cog-execute! insead.\n")
	(cog-bind-first-n handle -1)
)
(define-public (cog-bind-single handle)
	(cog-bind-first-n handle 1)
)
(define-public (cog-satisfying-set handle)
	(display "Obsolete! Do not use cog-satisfying-set, use cog-execute! insead.\n")
	(cog-satisfying-set-first-n handle -1)
)
(define-public (cog-satisfying-element handle)
	(cog-satisfying-set-first-n handle 1)
)

(set-procedure-property! cog-bind 'documentation
"
 cog-bind HANDLE
    OBSELETE! DO NOT USE IN NEW CODE!

    Run pattern matcher on HANDLE.  HANDLE must be a BindLink.
    Uses crisp (non-probabilistic) logic during the evaluation
    of evaluatable terms.
")

(set-procedure-property! cog-bind-first-n 'documentation
"
 cog-bind-first-n HANDLE
    Run pattern matcher on HANDLE.  HANDLE must be a BindLink.
    The search is terminated after the first N matches are found.
")

(set-procedure-property! cog-bind-single 'documentation
"
 cog-bind-single HANDLE
    Run pattern matcher on HANDLE.  HANDLE must be a BindLink.
    The search is terminated after the first match is found.
")

(set-procedure-property! cog-bind-af 'documentation
"
 cog-bind-af HANDLE
    Run pattern matcher on HANDLE.  HANDLE must be a BindLink.
    A special-purpose pattern matcher used by the URE.
")

(set-procedure-property! cog-satisfy 'documentation
"
 cog-satisfy HANDLE
    Run pattern matcher on HANDLE.  HANDLE must be a SatisfactionLink.
    Return a TV. Only satisfaction is performed, no implication.
")
