(package! ii-utils :recipe
  (:host github
   :branch "master"
   :repo "ii/ii-utils"
   :files ("*.el")))
(package! ii-pair :recipe
  (:host github
   :branch "main"
   :repo "humacs/ii-pair"
   :files ("*.el")))

(package! direnv)
(package! envrc)
(package! skewer-mode)
(package! sql)
(package! ob-sql-mode)
(package! ob-tmux)
(package! ox-gfm) ; org dispatch github flavoured markdown
(package! kubernetes)
(package! kubernetes-evil)
(package! exec-path-from-shell)
(package! tomatinho)
(package! graphviz-dot-mode)
(package! feature-mode)
(package! almost-mono-themes)
(package! graphviz-dot-mode)
(package! ob-async
  :recipe (:host github :repo "astahlman/ob-async"))

(package! git-link)
