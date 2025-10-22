# ==============================================================================
# GITHUB CLI - Aliases para gh (GitHub CLI)
# ==============================================================================

# Comando base
alias gh='gh'

# ==============================================================================
# AUTENTICACIÓN Y CONFIGURACIÓN
# ==============================================================================

alias ghauth='gh auth login'
alias ghauthstatus='gh auth status'
alias ghauthlogout='gh auth logout'
alias ghauthrefresh='gh auth refresh'
alias ghauthtoken='gh auth token'

# Configuración
alias ghconfig='gh config list'
alias ghconfigset='gh config set'
alias ghconfigget='gh config get'

# ==============================================================================
# REPOSITORIOS (REPO)
# ==============================================================================

# Listar y buscar
alias ghrepo='gh repo'
alias ghrepolist='gh repo list'
alias ghreposearch='gh search repos'
alias ghrepoview='gh repo view'
alias ghrepoweb='gh repo view --web'

# Crear y clonar
alias ghrepocreate='gh repo create'
alias ghrepoclone='gh repo clone'
alias ghrepofork='gh repo fork'

# Gestión
alias ghreporename='gh repo rename'
alias ghrepodelete='gh repo delete'
alias ghreposync='gh repo sync'
alias ghrepoarchive='gh repo archive'

# Releases
alias ghreleases='gh release list'
alias ghrelease='gh release view'
alias ghreleasecreate='gh release create'
alias ghreleasedownload='gh release download'

# ==============================================================================
# PULL REQUESTS (PR)
# ==============================================================================

# Listar y ver
alias ghpr='gh pr'
alias ghprlist='gh pr list'
alias ghprview='gh pr view'
alias ghprweb='gh pr view --web'
alias ghprstatus='gh pr status'

# Crear y gestionar
alias ghprcreate='gh pr create'
alias ghprdraft='gh pr create --draft'
alias ghpredit='gh pr edit'
alias ghprclose='gh pr close'
alias ghprreopen='gh pr reopen'
alias ghprready='gh pr ready'

# Revisión
alias ghprdiff='gh pr diff'
alias ghprreview='gh pr review'
alias ghprchecks='gh pr checks'
alias ghprmerge='gh pr merge'

# Checkout
alias ghprcheckout='gh pr checkout'
alias ghprco='gh pr checkout'

# Comentarios
alias ghprcomment='gh pr comment'

# ==============================================================================
# ISSUES
# ==============================================================================

# Listar y ver
alias ghissue='gh issue'
alias ghissuelist='gh issue list'
alias ghissueview='gh issue view'
alias ghissueweb='gh issue view --web'
alias ghissuestatus='gh issue status'

# Crear y gestionar
alias ghissuecreate='gh issue create'
alias ghissueedit='gh issue edit'
alias ghissueclose='gh issue close'
alias ghissuereopen='gh issue reopen'

# Comentarios
alias ghissuecomment='gh issue comment'

# Búsqueda
alias ghissuesearch='gh search issues'

# ==============================================================================
# GISTS
# ==============================================================================

alias ghgist='gh gist'
alias ghgistlist='gh gist list'
alias ghgistcreate='gh gist create'
alias ghgistview='gh gist view'
alias ghgistedit='gh gist edit'
alias ghgistdelete='gh gist delete'
alias ghgistclone='gh gist clone'

# ==============================================================================
# ACTIONS / WORKFLOWS
# ==============================================================================

# Workflows
alias ghworkflow='gh workflow'
alias ghworkflowlist='gh workflow list'
alias ghworkflowview='gh workflow view'
alias ghworkflowrun='gh workflow run'
alias ghworkflowenable='gh workflow enable'
alias ghworkflowdisable='gh workflow disable'

# Runs
alias ghrun='gh run'
alias ghrunlist='gh run list'
alias ghrunview='gh run view'
alias ghrunwatch='gh run watch'
alias ghrunrerun='gh run rerun'
alias ghruncancel='gh run cancel'
alias ghrundownload='gh run download'
alias ghrunlogs='gh run view --log'

# ==============================================================================
# PROYECTOS
# ==============================================================================

alias ghproject='gh project'
alias ghprojectlist='gh project list'
alias ghprojectview='gh project view'
alias ghprojectcreate='gh project create'

# ==============================================================================
# BÚSQUEDA (SEARCH)
# ==============================================================================

alias ghsearch='gh search'
alias ghsearchrepos='gh search repos'
alias ghsearchissues='gh search issues'
alias ghsearchprs='gh search prs'
alias ghsearchcode='gh search code'

# ==============================================================================
# USUARIOS Y ORGANIZACIONES
# ==============================================================================

alias ghuser='gh api user'
alias ghorgs='gh api user/orgs'

# ==============================================================================
# ALIAS CORTOS Y CONVENIENTES
# ==============================================================================

# Repositorio actual
alias ghv='gh repo view'
alias ghvw='gh repo view --web'
alias ghb='gh browse'

# Pull Requests
alias ghprs='gh pr list'
alias ghprc='gh pr create'
alias ghprv='gh pr view'
alias ghprm='gh pr merge'

# Issues
alias ghis='gh issue list'
alias ghic='gh issue create'
alias ghiv='gh issue view'

# Workflows
alias ghw='gh workflow list'
alias ghr='gh run list'
alias ghrv='gh run view'
alias ghrw='gh run watch'

# ==============================================================================
# FUNCIONES ÚTILES
# ==============================================================================

# Crear PR con título y cuerpo
ghpr-quick() {
    if [ -z "$1" ]; then
        echo "Uso: ghpr-quick '<título>' [descripción]"
        echo "Ejemplo: ghpr-quick 'feat: nueva característica' 'Descripción detallada'"
    else
        local title="$1"
        local body="${2:-}"
        if [ -n "$body" ]; then
            gh pr create --title "$title" --body "$body"
        else
            gh pr create --title "$title"
        fi
    fi
}

# Ver el último PR creado
ghpr-last() {
    gh pr list --limit 1 --state open
}

# Crear issue rápido
ghissue-quick() {
    if [ -z "$1" ]; then
        echo "Uso: ghissue-quick '<título>' [descripción]"
        echo "Ejemplo: ghissue-quick 'bug: error en login' 'Descripción del error'"
    else
        local title="$1"
        local body="${2:-}"
        if [ -n "$body" ]; then
            gh issue create --title "$title" --body "$body"
        else
            gh issue create --title "$title"
        fi
    fi
}

# Ver PRs del usuario actual
ghpr-mine() {
    local user=$(gh api user -q .login 2>/dev/null)
    if [ -n "$user" ]; then
        gh pr list --author "$user" --state all
    else
        echo "Error: No se pudo obtener el usuario actual"
    fi
}

# Ver issues asignados a ti
ghissue-mine() {
    local user=$(gh api user -q .login 2>/dev/null)
    if [ -n "$user" ]; then
        gh issue list --assignee "$user" --state open
    else
        echo "Error: No se pudo obtener el usuario actual"
    fi
}

# Ver el estado completo del repositorio
ghstatus() {
    echo "=== Estado del Repositorio ==="
    echo ""
    echo "--- Repositorio ---"
    gh repo view --json name,description,url,isPrivate,defaultBranchRef \
        --jq '"Nombre: \(.name)\nDescripción: \(.description)\nURL: \(.url)\nPrivado: \(.isPrivate)\nBranch: \(.defaultBranchRef.name)"'
    echo ""
    echo "--- Pull Requests Abiertos ---"
    gh pr list --limit 5 --state open --json number,title,author --jq '.[] | "#\(.number) \(.title) (@\(.author.login))"' 2>/dev/null || echo "No hay PRs abiertos"
    echo ""
    echo "--- Issues Abiertos ---"
    gh issue list --limit 5 --state open --json number,title,author --jq '.[] | "#\(.number) \(.title) (@\(.author.login))"' 2>/dev/null || echo "No hay issues abiertos"
    echo ""
    echo "--- Últimas GitHub Actions ---"
    gh run list --limit 5 --json conclusion,status,name,createdAt --jq '.[] | "\(.conclusion // .status) - \(.name) (\(.createdAt[:10]))"' 2>/dev/null || echo "No hay runs"
}

# Checkout de PR por número
ghpr-co() {
    if [ -z "$1" ]; then
        echo "Uso: ghpr-co <pr-number>"
        echo "Ejemplo: ghpr-co 42"
        echo ""
        echo "Pull Requests disponibles:"
        gh pr list --limit 10
    else
        gh pr checkout "$1"
    fi
}

# Ver diff de un PR
ghpr-diff() {
    if [ -z "$1" ]; then
        echo "Uso: ghpr-diff <pr-number>"
        echo "Ejemplo: ghpr-diff 42"
    else
        gh pr diff "$1"
    fi
}

# Mergear PR con squash
ghpr-squash() {
    if [ -z "$1" ]; then
        echo "Uso: ghpr-squash <pr-number>"
        echo "Ejemplo: ghpr-squash 42"
    else
        gh pr merge "$1" --squash --delete-branch
    fi
}

# Aprobar PR
ghpr-approve() {
    if [ -z "$1" ]; then
        echo "Uso: ghpr-approve <pr-number> [comentario]"
        echo "Ejemplo: ghpr-approve 42 'LGTM!'"
    else
        local comment="${2:-LGTM}"
        gh pr review "$1" --approve --body "$comment"
    fi
}

# Ver logs de la última GitHub Action
ghrun-logs() {
    local run_id=$(gh run list --limit 1 --json databaseId --jq '.[0].databaseId')
    if [ -n "$run_id" ]; then
        gh run view "$run_id" --log
    else
        echo "No se encontraron runs"
    fi
}

# Crear release
ghrelease-create() {
    if [ -z "$1" ]; then
        echo "Uso: ghrelease-create <tag> [title] [notes]"
        echo "Ejemplo: ghrelease-create v1.0.0 'Release 1.0.0' 'Primera versión estable'"
    else
        local tag="$1"
        local title="${2:-$tag}"
        local notes="${3:-Release $tag}"
        gh release create "$tag" --title "$title" --notes "$notes"
    fi
}

# Clonar repositorio rápido (con o sin usuario)
ghclone() {
    if [ -z "$1" ]; then
        echo "Uso: ghclone <repo> [usuario]"
        echo "Ejemplo: ghclone dotfiles"
        echo "Ejemplo: ghclone dotfiles otro-usuario"
    else
        local repo="$1"
        local user="${2:-$(gh api user -q .login 2>/dev/null)}"
        if [ -n "$user" ]; then
            gh repo clone "$user/$repo"
        else
            gh repo clone "$repo"
        fi
    fi
}

# Ver trending repos del día
ghtrending() {
    local language="${1:-}"
    if [ -n "$language" ]; then
        gh search repos --sort stars --order desc --limit 10 \
            --created "$(date -d '1 day ago' +%Y-%m-%d)" \
            --language "$language"
    else
        gh search repos --sort stars --order desc --limit 10 \
            --created "$(date -d '1 day ago' +%Y-%m-%d)"
    fi
}

# Buscar en código del repo actual
ghcode() {
    if [ -z "$1" ]; then
        echo "Uso: ghcode <query>"
        echo "Ejemplo: ghcode 'function login'"
    else
        local repo=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null)
        if [ -n "$repo" ]; then
            gh search code --repo "$repo" "$1"
        else
            echo "Error: No se pudo determinar el repositorio"
        fi
    fi
}

# Ver info del usuario actual
ghme() {
    echo "=== Mi perfil de GitHub ==="
    gh api user --jq '"Usuario: \(.login)\nNombre: \(.name)\nEmail: \(.email)\nBio: \(.bio)\nURL: \(.html_url)\nRepos públicos: \(.public_repos)\nSeguidores: \(.followers)\nSiguiendo: \(.following)\nCreado: \(.created_at[:10])"'
}

# Crear repo nuevo con template común
ghrepo-new() {
    if [ -z "$1" ]; then
        echo "Uso: ghrepo-new <nombre> [descripción] [privado:y/n]"
        echo "Ejemplo: ghrepo-new my-project 'Mi nuevo proyecto' y"
    else
        local name="$1"
        local description="${2:-$name}"
        local private="${3:-n}"

        local flags="--description '$description'"
        [ "$private" = "y" ] && flags="$flags --private" || flags="$flags --public"

        eval "gh repo create $name $flags --clone"
    fi
}
